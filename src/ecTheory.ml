(* -------------------------------------------------------------------- *)
open EcUtils
open EcSymbols
open EcDecl

open EcModules

(* -------------------------------------------------------------------- *)
module Sp = EcPath.Sp

(* -------------------------------------------------------------------- *)
type theory = theory_item list

and theory_item =
  | Th_type      of (symbol * tydecl)
  | Th_operator  of (symbol * operator)
  | Th_axiom     of (symbol * axiom)
  | Th_modtype   of (symbol * module_sig)
  | Th_module    of module_expr
  | Th_theory    of (symbol * theory)
  | Th_export    of EcPath.path

(* -------------------------------------------------------------------- *)
type ctheory = {
  cth_desc   : ctheory_desc;
  cth_struct : ctheory_struct;
}

and ctheory_desc =
  | CTh_struct of ctheory_struct
  | CTh_clone  of ctheory_clone

and ctheory_struct = ctheory_item list

and ctheory_item =
  | CTh_type      of (symbol * tydecl)
  | CTh_operator  of (symbol * operator)
  | CTh_axiom     of (symbol * axiom)
  | CTh_modtype   of (symbol * module_sig)
  | CTh_module    of module_expr
  | CTh_theory    of (symbol * ctheory)
  | CTh_export    of EcPath.path

and ctheory_clone = {
  cthc_base : EcPath.path;
  cthc_ext  : (EcIdent.t * ctheory_override) list;
}

and ctheory_override =
| CTHO_Type   of EcTypes.ty
| CTHO_Module of EcPath.path * (EcPath.path list)

(* -------------------------------------------------------------------- *)
let module_comps_of_module_sig_comps (comps : module_sig_body) =
  let onitem = function
    | Tys_variable (x, ty) ->
        MI_Variable {
          v_name = x;
          v_type = ty;
        }

    | Tys_function funsig ->
        MI_Function { 
          f_name = funsig.fs_name;
          f_sig  = funsig;
          f_def  = None;
        }
  in
    List.map onitem comps

(* -------------------------------------------------------------------- *)
let module_expr_of_module_sig (name : EcIdent.t) mp (tymod : module_sig) =

  let tycomps = module_comps_of_module_sig_comps tymod.mt_body in

    { me_name  = EcIdent.name name;
      me_body  = ME_Decl mp;
      me_comps = tycomps;
      me_sig   = tymod;
      me_uses  = Sp.empty;                (* FIXME *)
      me_types = [mp]; }