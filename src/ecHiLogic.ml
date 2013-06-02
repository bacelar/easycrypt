(* -------------------------------------------------------------------- *)
open EcUtils
open EcMaps
open EcLocation
open EcSymbols
open EcParsetree
open EcTypes
open EcModules
open EcFol

open EcBaseLogic
open EcLogic
open EcPhl

module Sp = EcPath.Sp

module TT = EcTyping
module UE = EcUnify.UniEnv

(* -------------------------------------------------------------------- *)
type pprovers = EcParsetree.pprover_infos -> EcProvers.prover_infos

(* -------------------------------------------------------------------- *)
type tac_error =
  | UnknownHypSymbol of symbol
  | UnknownAxiom     of qsymbol
  | UnknownOperator  of qsymbol
  | BadTyinstance
  | NothingToIntro
  | FormulaExpected
  | MemoryExpected
  | UnderscoreExpected
  | ModuleExpected
  | ElimDoNotWhatToDo
  | NoCurrentGoal

exception TacError of tac_error

let pp_tac_error fmt =
  function
    | UnknownHypSymbol s ->
      Format.fprintf fmt "Unknown hypothesis or logical variable %s" s
    | UnknownAxiom qs ->
      Format.fprintf fmt "Unknown axioms or hypothesis : %a"
        pp_qsymbol qs
    | UnknownOperator qs ->
      Format.fprintf fmt "Unknown operator or logical variable %a"
        pp_qsymbol qs
    | BadTyinstance ->
      Format.fprintf fmt "Invalid type instance"
    | NothingToIntro ->
      Format.fprintf fmt "Nothing to introduce"
    | FormulaExpected ->
      Format.fprintf fmt "formula expected"
    | MemoryExpected ->
      Format.fprintf fmt "Memory expected"
    | UnderscoreExpected ->
      Format.fprintf fmt "_ expected"
    | ModuleExpected ->
      Format.fprintf fmt "module expected"
    | ElimDoNotWhatToDo ->
      Format.fprintf fmt "Elim : do not known what to do"
    | NoCurrentGoal ->
      Format.fprintf fmt "No current goal"

let _ = EcPException.register (fun fmt exn ->
  match exn with
  | TacError e -> pp_tac_error fmt e
  | _ -> raise exn)

let error loc e = EcLocation.locate_error loc (TacError e)

(* -------------------------------------------------------------------- *)
let process_tyargs env hyps tvi =
  let ue = EcUnify.UniEnv.create (Some hyps.h_tvar) in
    omap tvi (TT.transtvi env ue)

(* -------------------------------------------------------------------- *)
let process_instanciate env hyps ({pl_desc = pq; pl_loc = loc} ,tvi) =
  let (p, ax) =
    try EcEnv.Ax.lookup pq env
    with _ -> error loc (UnknownAxiom pq) in
  let args = process_tyargs env hyps tvi in
  let args =
    match ax.EcDecl.ax_tparams, args with
    | [], None -> []
    | [], Some _ -> error loc BadTyinstance
    | ltv, Some (UE.TVIunamed l) ->
        if not (List.length ltv = List.length l) then error loc BadTyinstance;
        l
    | ltv, Some (UE.TVInamed l) ->
        let get id =
          try List.assoc (EcIdent.name id) l
          with _ -> error loc BadTyinstance in
        List.map get ltv
    | _, None -> error loc BadTyinstance in
  p,args

(* -------------------------------------------------------------------- *)
let process_global loc env tvi g =
  let hyps = get_hyps g in
  let p, tyargs = process_instanciate env hyps tvi in
  set_loc loc t_glob env p tyargs g

(* -------------------------------------------------------------------- *)
let process_assumption loc env (pq, tvi) g =
  let hyps,concl = get_goal g in
  match pq with
  | None ->
      if (tvi <> None) then error loc BadTyinstance;
      let h  =
        try find_in_hyps env concl hyps
        with _ -> assert false in
      t_hyp env h g
  | Some pq ->
      match unloc pq with
      | ([],ps) when LDecl.has_hyp ps hyps ->
          if (tvi <> None) then error pq.pl_loc BadTyinstance;
          set_loc loc (t_hyp env (fst (LDecl.lookup_hyp ps hyps))) g
      | _ -> process_global loc env (pq,tvi) g

(* -------------------------------------------------------------------- *)
let process_intros env pis =
  let mk_id s = EcIdent.create (odfl "_" s) in
    t_intros env (List.map (lmap mk_id) pis)

(* -------------------------------------------------------------------- *)
let process_elim_arg env hyps oty a =
  let ue  = EcUnify.UniEnv.create (Some hyps.h_tvar) in
  let env = tyenv_of_hyps env hyps in
  match a.pl_desc, oty with
  | EA_form pf, Some (GTty ty) ->
    let ff = TT.transform env ue pf ty in
    AAform (EcFol.Fsubst.uni (EcUnify.UniEnv.close ue) ff)
  | _, Some (GTty _) ->
    error a.pl_loc FormulaExpected
  | EA_mem mem, Some (GTmem _) ->
    AAmem (TT.transmem env mem)
  | _, Some (GTmem _)->
    error a.pl_loc MemoryExpected
  | EA_none, None ->
    AAnode
  | EA_mp mp , Some (GTmodty _) ->
    let (mp, mt) = TT.trans_msymbol env (mk_loc a.pl_loc mp) in
      AAmp (mp, mt)
  | _, Some (GTmodty _) ->
    error a.pl_loc ModuleExpected
  | _, None ->
    error a.pl_loc UnderscoreExpected

(* -------------------------------------------------------------------- *)
let process_form_opt env hyps pf oty =
  let env = tyenv_of_hyps env hyps in
  let ue  = EcUnify.UniEnv.create (Some hyps.h_tvar) in
  let ff  = TT.transform_opt env ue pf oty in
  EcFol.Fsubst.uni (EcUnify.UniEnv.close ue) ff

(* -------------------------------------------------------------------- *)
let process_form env hyps pf ty =
  process_form_opt env hyps pf (Some ty)

(* -------------------------------------------------------------------- *)
let process_formula env g pf =
  let hyps = get_hyps g in
    process_form env hyps pf tbool

(* -------------------------------------------------------------------- *)
let process_mkn_apply process_cut env pe (juc, _ as g) = 
  let hyps = get_hyps g in
  let args = pe.fp_args in
  let (juc,fn), fgs =
    match pe.fp_kind with
    | FPNamed (pq,tvi) ->
      begin match unloc pq with
      | ([],ps) when LDecl.has_hyp ps hyps ->
        (* FIXME warning if tvi is not None *)
        let id,_ = LDecl.lookup_hyp ps hyps in
        mkn_hyp juc hyps id, []
      | _ ->
        let p,tys = process_instanciate env hyps (pq,tvi) in
        mkn_glob env juc hyps p tys, []
      end
    | FPCut pf ->
      let f = process_cut env g pf in
      let juc, fn = new_goal juc (hyps, f) in
      (juc,fn), [fn]
  in
  let (juc,an), ags = mkn_apply process_elim_arg env (juc,fn) args in
  (juc,an), fgs@ags

(* -------------------------------------------------------------------- *)
let process_apply loc env pe (_,n as g) =
  let (juc,an), gs = process_mkn_apply process_formula env pe g in
  set_loc loc (t_use env an gs) (juc,n)

(* -------------------------------------------------------------------- *)
let process_elim loc env pe (_,n as g) =
  let (juc,an), gs = process_mkn_apply process_formula env pe g in
  let (_,f) = get_node (juc, an) in
  t_on_first (set_loc loc (t_elim env f) (juc,n)) (t_use env an gs)

(* -------------------------------------------------------------------- *)
let process_rewrite loc env (s,pe) (_,n as g) =
  set_loc loc (t_rewrite_node env 
                 (process_mkn_apply process_formula env pe g) s) n

(* -------------------------------------------------------------------- *)
let process_trivial mkpv pi env g =
  let pi = mkpv pi in
  t_trivial pi env g

(* -------------------------------------------------------------------- *)
let process_cut name env phi g =
  let phi = process_formula env g phi in
  t_on_last (t_cut env phi g)
    (process_intros env [lmap (fun x -> Some x) name])

(* -------------------------------------------------------------------- *)
let process_generalize env l =
  let pr1 pf g =
    let hyps = get_hyps g in
    match pf.pl_desc with
    | PFident({pl_desc = ([],s)},None) when LDecl.has_symbol s hyps ->
      let id = fst (LDecl.lookup s hyps) in
      t_generalize_hyp env id g
    | _ ->
      let f = process_form_opt env hyps pf None in
      t_generalize_form None env f g in
  t_lseq (List.rev_map pr1 l)

(* -------------------------------------------------------------------- *)
let process_clear l g =
  let hyps = get_hyps g in
  let toid ps =
    let s = ps.pl_desc in
    if LDecl.has_symbol s hyps then (fst (LDecl.lookup s hyps))
    else error ps.pl_loc (UnknownHypSymbol s) in
  let ids = EcIdent.Sid.of_list (List.map toid l) in
  t_clear ids g

(* -------------------------------------------------------------------- *)
let process_exists env fs g =
  gen_t_exists process_elim_arg env fs g

(* -------------------------------------------------------------------- *)
let process_change env pf g =
  let f = process_formula env g pf in
  set_loc pf.pl_loc (t_change env f) g

(* -------------------------------------------------------------------- *)
let process_simplify env ri g =
  let hyps = get_hyps g in
  let delta_p, delta_h =
    match ri.pdelta with
    | None -> None, None
    | Some l ->
      let sop = ref Sp.empty and sid = ref EcIdent.Sid.empty in
      let do1 ps =
        match ps.pl_desc with
        | ([],s) when LDecl.has_symbol s hyps ->
          let id = fst (LDecl.lookup s hyps) in
          sid := EcIdent.Sid.add id !sid;
        | qs ->
          let p =
            try EcEnv.Op.lookup_path qs env
            with _ -> error ps.pl_loc (UnknownOperator qs) in
          sop := Sp.add p !sop in
      List.iter do1 l;
      Some !sop, Some !sid in
  let ri = {
    EcReduction.beta    = ri.pbeta;
    EcReduction.delta_p = delta_p;
    EcReduction.delta_h = delta_h;
    EcReduction.zeta    = ri.pzeta;
    EcReduction.iota    = ri.piota;
    EcReduction.logic   = ri.plogic; 
    EcReduction.modpath = ri.pmodpath;
  } in
  t_simplify env ri g

(* -------------------------------------------------------------------- *)
let process_elimT loc env (pf,qs) g =
  let p = set_loc qs.pl_loc (EcEnv.Ax.lookup_path qs.pl_desc) env in
  let f = process_form_opt env (get_hyps g) pf None in
  t_seq (set_loc loc (t_elimT env f p))
    (t_simplify env EcReduction.beta_red) g

(* -------------------------------------------------------------------- *)
let process_subst loc env ri g =
  if ri = [] then t_subst_all env g
  else
    let hyps = get_hyps g in
    let totac ps =
      let s = ps.pl_desc in
      try t_subst1 env (Some (fst (LDecl.lookup_var s hyps)))
      with _ -> error ps.pl_loc (UnknownHypSymbol s) in
    let tacs = List.map totac ri in
    set_loc loc (t_lseq tacs) g

(* -------------------------------------------------------------------- *)
let process_logic mkpv loc env t =
  match t with
  | Passumption pq -> process_assumption loc env pq
  | Ptrivial pi    -> process_trivial mkpv pi env
  | Pintro pi      -> process_intros env pi
  | Psplit         -> t_split env
  | Pexists fs     -> process_exists env fs
  | Pleft          -> t_left env
  | Pright         -> t_right env
  | Pelim pe       -> process_elim  loc env pe
  | Papply pe      -> process_apply loc env pe
  | Pcut (name,phi)-> process_cut name env phi
  | Pgeneralize l  -> process_generalize env l
  | Pclear l       -> process_clear l
  | Prewrite ri    -> process_rewrite loc env ri
  | Psubst   ri    -> process_subst loc env ri
  | Psimplify ri   -> process_simplify env ri
  | Pchange pf     -> process_change env pf
  | PelimT i       -> process_elimT loc env i