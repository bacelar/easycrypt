require import Distr.
require import FSet.
require import FMap.
require import Int.

module type O = { 
  proc hashA (x:int) : int 
}.

module type Adv(O:O) = { 
  proc a (h:int) : int 
}.

module RO = {
  var mH : (int,int) map
  
  proc hash (x:int) : int = { 
    var r : int;
    r = $[0..10];
    if (!mem x (dom mH)) mH.[x] = r;
    return (oget mH.[x]);
  }

  var logA : int set
  
  proc hashA (x:int) : int = { 
    var r : int;
    logA  = add x logA;
    r     = hash(x);
    return r;
  }
}.

module F1(A:Adv) = { 

  module A1 = A(RO)

  var xs : int

  proc main() : int = { 
    var h: int;
    var r : int;
    RO.mH    = FMap.empty;
    RO.logA  = FSet.empty;
    h        = RO.hash(xs);
    r        = A1.a(h);
    return r;
  }
}.

module F2(A:Adv) = { 
  module A1 = A(RO)

  var xs : int

  proc main() : int = { 
    var h: int;
    var r : int;
    RO.mH    = FMap.empty;
    RO.logA  = FSet.empty;
    h        = $[0..10];
    r        = A1.a(h);
    return r;
  }
}.

lemma foo : forall (A<:Adv{RO,F1,F2}), 
  (forall (O<:O{A}),  
      phoare [O.hashA : true ==> true] = 1%r => 
      phoare [A(O).a : true ==> true] = 1%r) =>  
  equiv [F1(A).main ~ F2(A).main : 
     (glob A){1} = (glob A){2} /\ F1.xs{1} = F2.xs{2} ==> 
     (!mem F2.xs RO.logA){2} => res{1} = res{2}].
proof -strict.
  intros A Hlossless;proc.
  call (_ : mem F2.xs RO.logA ,
            (RO.logA{1} = RO.logA{2} /\ F1.xs{1} = F2.xs{2} /\
            eq_except RO.mH{1} RO.mH{2} F2.xs{2}),  
            (F1.xs{1} = F2.xs{2})).
timeout 10.
    proc; inline RO.hash;wp;rnd;wp;skip;simplify; progress=> //; smt.
timeout 3.

    (* Hoare goal *)
    intros &2 h.
    proc.
    inline RO.hash.
    wp.
    rnd (fun (x:int), 0 <= x <= 10) .
    wp; skip.
    trivial.
    intros &hr h2.
    split;[apply Distr.Dinter.mu_in_supp | ];smt.
    (* *)
    intros &1.
    proc.
    inline RO.hash.
    wp.
    rnd (fun (x:int), 0 <= x <= 10) .
    wp;skip.
    trivial.
    intros &hr _.
    split;[apply Distr.Dinter.mu_in_supp | ];smt.
  inline RO.hash;wp;rnd;wp;skip;simplify;smt.
qed.
