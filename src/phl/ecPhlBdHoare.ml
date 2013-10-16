(* -------------------------------------------------------------------- *)
open EcUtils
open EcFol
open EcBaseLogic
open EcLogic
open EcCorePhl

(* --------------------------------------------------------------------- *)
class rn_hl_hoare_equiv =
object
  inherit xrule "[hl] hoare-equiv"
end

let rn_hl_hoare_equiv = RN_xtd (new rn_hl_hoare_equiv)

(* -------------------------------------------------------------------- *)
let t_hoare_equiv p q p1 q1 p2 q2 g =
  let concl = get_concl g in
  let es = t_as_equivS concl in
  let s1 = Fsubst.f_bind_mem Fsubst.f_subst_id mhr (fst es.es_ml) in
  let s2 = Fsubst.f_bind_mem Fsubst.f_subst_id mhr (fst es.es_mr) in
  let concl1 = 
    f_forall_mems [es.es_ml;es.es_mr] 
      (f_imp es.es_pr (f_and p (f_and (Fsubst.f_subst s1 p1) (Fsubst.f_subst s2 p2)))) in
  let concl2 = 
    f_forall_mems [es.es_ml;es.es_mr]
      (f_imps [q;Fsubst.f_subst s1 q1;Fsubst.f_subst s2 q2] es.es_po) in
  let concl3 = 
    f_hoareS (mhr,snd es.es_ml) p1 es.es_sl q1 in
  let concl4 = 
    f_hoareS (mhr,snd es.es_mr) p2 es.es_sr q2 in
  let concl5 = 
    f_equivS_r { es with es_pr = p; es_po = q } in
  prove_goal_by [concl1; concl2; concl3; concl4; concl5] 
    rn_hl_hoare_equiv g

(* -------------------------------------------------------------------- *)
class rn_hl_hoare_bd_hoare =
object
  inherit xrule "[hl] hoare-bd-hoare"
end

let rn_hl_hoare_bd_hoare =
  RN_xtd (new rn_hl_hoare_bd_hoare)


(* -------------------------------------------------------------------- *)
let hoare_of_bdhoare g =
  let concl = get_concl g in
  let bhs = t_as_bdHoareS concl in
  let concl1 = f_hoareS bhs.bhs_m bhs.bhs_pr bhs.bhs_s (f_not bhs.bhs_po) in
  let concl2 = 
    let bd_cond = 
      if bhs.bhs_cmp = FHle then f_real_le f_r0 bhs.bhs_bd 
      else f_eq bhs.bhs_bd f_r0
    in
    f_forall_mems [bhs.bhs_m] (f_imp bhs.bhs_pr bd_cond ) in
  prove_goal_by [concl2;concl1] rn_hl_hoare_bd_hoare g



let bdhoare_of_hoare g =
  let concl = get_concl g in
  let hs = t_as_hoareS concl in
  let concl1 = f_bdHoareS hs.hs_m hs.hs_pr hs.hs_s (f_not hs.hs_po) FHeq f_r0 in
  prove_goal_by [concl1] rn_hl_hoare_bd_hoare g
    

let t_hoare_bd_hoare g =
  let concl = get_concl g in
  if is_bdHoareS concl then
    let subgoals = hoare_of_bdhoare g in
    t_on_first (t_try EcPhlTrivial.t_trivial) subgoals
  else if is_hoareS concl then
    bdhoare_of_hoare g
  else 
    cannot_apply "hoare/bd_hoare" "a hoare or bd_hoare judgment was expected" 



let t_bdeq g = 
  let concl = get_concl g in
  let bhs = t_as_bdHoareS concl in 
  let concl = f_bdHoareS_r {bhs with bhs_cmp=FHeq } in
    prove_goal_by [concl] (RN_xtd (new EcPhlPr.rn_hl_prbounded)) g
    