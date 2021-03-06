require import Int.

module type Orcl = {
  proc o1 (x:int) : int 
  proc o2 (x:int) : int
}.

module type Adv (O:Orcl) = { 
  proc * a1 (x:int) : int { O.o1}
  proc a2 (x:int) : int
}.

module O = { 
  var m : int
  var l : int
  proc o1 (x:int) : int = {
    m = x + m;
    return m;
  }
  proc o2 (x:int) : int = {
    l = l + x + m;
    return m;
  }
}.

module G (A:Adv) = {
  module AO = A(O)
  proc main (x:int) : int = { 
    x = AO.a1(x);
    x = O.o1(x);
    x = O.o2(x);
    x = AO.a2(x);
    return x;
  }
}.

equiv foo_0 (A<:Adv {O} ) : G(A).main ~ G(A).main : ={x,O.m,O.l} ==> ={res,O.m,O.l}.
proc.
sim : (={O.m,O.l,x}).
qed.

equiv foo_1 (A<:Adv {O} ) : G(A).main ~ G(A).main : ={x,O.m,O.l} ==> ={res,O.m,O.l}.
proc.
sim.
qed.

equiv foo1_0 (A<:Adv {O} ) : G(A).main ~ G(A).main : ={x,O.m,O.l} ==> ={res,O.m,glob A}.
proc.
sim (:true) : (={O.m,glob A,x,O.l}).
qed.

equiv foo1_1 (A<:Adv {O} ) : G(A).main ~ G(A).main : ={x,O.m,O.l} ==> ={res,O.m,glob A}.
proc.
sim.
qed.

