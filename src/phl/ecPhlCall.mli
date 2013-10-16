(* -------------------------------------------------------------------- *)
open EcParsetree
open EcFol
open EcBaseLogic
open EcLogic

(* -------------------------------------------------------------------- *)
class rn_hl_call : bool option -> form -> form ->
object
  inherit xrule

  method post : form
  method pre  : form
  method side : bool option
end

(* -------------------------------------------------------------------- *)
val t_hoare_call   : form -> form -> tactic
val t_bdHoare_call : form -> form -> form option -> tactic
val wp2_call       :  EcEnv.env ->
           form -> form ->
           EcModules.lvalue option * EcPath.xpath * EcTypes.expr list ->
           EcPV.PV.t ->
           EcModules.lvalue option * EcPath.xpath * EcTypes.expr list ->
           EcPV.PV.t ->
           EcMemory.memory -> EcMemory.memory -> form -> 
           EcEnv.LDecl.hyps -> form

val t_equiv_call   : form -> form -> tactic
val t_equiv_call1  : bool -> form -> form -> tactic

(* -------------------------------------------------------------------- *)
val process_call : bool option -> call_info fpattern -> tactic