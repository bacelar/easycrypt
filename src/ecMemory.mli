(* -------------------------------------------------------------------- *)
open EcSymbols
open EcPath

(* -------------------------------------------------------------------- *)
type memory = EcIdent.t

val mem_equal : memory -> memory -> bool

(* -------------------------------------------------------------------- *)
type memenv

exception DuplicatedMemoryBinding of symbol

(* -------------------------------------------------------------------- *)
val memory   : memenv -> memory
val bindings : memenv -> EcTypes.ty Msym.t

(* -------------------------------------------------------------------- *)
val empty  : memory -> memenv
val bind   : symbol -> EcTypes.ty -> memenv -> memenv
val lookup : symbol -> memenv -> EcTypes.ty option