require import Distr.
require import Bool.
require import Real.

module M = {
  var y : bool
  var x : bool
  proc f() : unit = {
    y = $Dbool.dbool;
    x = $Dbool.dbool;
  }
}.

lemma test : phoare [M.f : true ==> M.x /\ M.y ] = (1%r/4%r).
proof -strict.
 proc.
 seq 1 : (M.y) (1%r/2%r) (1%r/2%r) (1%r/2%r) 0%r => //.
 rnd ((=) true).
 skip; smt.
 rnd (fun (x:bool),x).
 skip.
 progress;try smt.
 hoare;rnd;skip;smt.
qed.

module M2 = {
  var y : bool
  var x : bool
  proc f() : unit = {
    y = true;
    x = $Dbool.dbool;
  }
}.

lemma test2 : phoare [M2.f : true ==> M2.x /\ M2.y ] <= (1%r/2%r).
proof -strict.
 proc.
 seq 1 : (M2.y) 1%r (1%r/2%r) 0%r 0%r=> //.
 rnd (fun (x:bool),x=true).
 skip;progress;smt.
 hoare;wp;trivial.
qed.


module M3 = {
  var y : bool
  var x : bool
  proc f() : unit = {
    x = $Dbool.dbool;
    y = true;
  }
}.

lemma test3 : phoare [M3.f : true ==> M3.x /\ M3.y ] <= (1%r/2%r).
proof -strict.
 proc.
 seq 1 : (M3.x) (1%r/2%r) (1%r) (1%r/2%r) (0%r)=> //.
 rnd (fun (x:bool),x=true);skip; smt.
 wp;hoare=> //.
qed.



(* FAILING *)
(*
module M2 = {
  var y : bool
  var x : bool
  proc f() : unit = {
    y = true;
    x = $Dbool.dbool;
  }
}.

lemma foo : phoare [M.f : true ==> M.x /\ M.y ] [<=] [1%r/2%r]
proof -strict.
 proc.
 seq>> 1 : (M.y) (1%r/2%r).
*)

