require import Int.
module M = { 
  var m : int
  proc f (x:int) : int = { 
    m = m + x;
    return m;
  }

  proc g (x:int) : int = { return m + x; }

  proc main (w:int) : int = {
    m = 0;
    w = f(w);
    w = g(w);
    return w;
  }
}.

equiv test_0 : M.main ~ M.main : ={M.m,w} ==> ={M.m,res}.
proc.
sim : (={M.m, w}).
qed.

equiv test_1 : M.main ~ M.main : ={M.m,w} ==> ={M.m,res}.
proc.
sim.
qed.


module type Orcl = {
  proc o (x:int) : int 
}.

module type Adv (O:Orcl) = { 
  proc a1 (x:int) : int
  proc a2 (x:int) : int
}.

module O = { 
  var m : int
  proc o (x:int) : int = {
    m = x + m;
    return m;
  }
}.

module G (A:Adv) = {
  module AO = A(O)
  proc main (x:int) : int = { 
    x = AO.a1(x);
    x = O.o(x);
    x = AO.a2(x);
    return x;
  }
}.

equiv foo_0 (A<:Adv {O} ) : G(A).main ~ G(A).main : ={x,O.m,glob A} ==> ={res,O.m}.
proc.
sim : (={O.m, x}).
qed.

equiv foo_1 (A<:Adv {O} ) : G(A).main ~ G(A).main : ={x,O.m,glob A} ==> ={res,O.m}.
proc.
sim.
qed.

equiv foo1_0 (A<:Adv {O} ) : G(A).main ~ G(A).main : ={x,O.m,glob A} ==> ={res,O.m,glob A}.
proc.
sim : (={O.m,glob A, x}).
qed.

equiv foo1_1 (A<:Adv {O} ) : G(A).main ~ G(A).main : ={x,O.m,glob A} ==> ={res,O.m,glob A}.
proc.
sim.
qed.




