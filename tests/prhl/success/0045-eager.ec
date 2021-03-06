require import FSet.
require import FMap.
require import Distr.

type from.
type to.

op dsample:to distr.

module type ARO = {
  proc o(x:from): to
}.

module RO = {
  var m:(from,to) map

  proc init(): unit = {
    m = FMap.empty;
  }

  proc o(x:from): to = {
    var y:to;

    y = $dsample;
    if (!mem x (dom m)) m.[x] = y;
    return oget m.[x];
  }
}.

module ROe = {

  var xs : from
  var hs : to
  var m : (from, to) map

  proc init (x:from) : unit = {
    xs = x;
    m = FMap.empty;
    hs = $dsample;

  }

  proc o(x:from) : to = {
    var y : to;
    y = $dsample;
    if (!mem x (dom m))
      m.[x] = if x = xs then hs else y;
    return oget (m.[x]);
  }
     
}.

module type Adv (O:ARO) = {
  proc a0 () : from {}
  proc a1 () : bool 
}.

section.
  declare module A : Adv {RO, ROe}.

  local module A1 = A(RO).
  local module A2 = A(ROe). 
 
  local module G1 = {
    proc main() : bool = {
      var x:from;
      var b:bool;
      x = A1.a0();
      RO.init();
      b = A1.a1();
      return b;
    }
  }.

  local module G2 = {
    proc main() : bool = {
      var x:from;
      var b:bool;
      x = A2.a0();
      ROe.init(x);
      b = A2.a1();
      return b;
    }
  }.

  local lemma foo1:
    weight dsample = 1%r => 
    equiv [G2.main ~ G1.main: ={glob A} ==>
                              ={glob A,res} /\ ROe.m{1} = RO.m{2} ].
  proof.
  intros Hw;proc.
  inline RO.init ROe.init.
  seq 4 2 : (={glob A,x} /\ ROe.m{1} = RO.m{2} );first by sim. 
  eager (h : ROe.hs = $dsample;  ~  : true ==> true) : (={glob A} /\ ROe.m{1} = RO.m{2})=> //.
  rnd{1} => //.
  eager proc h (ROe.m{1} = RO.m{2}) => //.
  eager proc.
  case (!mem x{1} (dom ROe.m{1})).
   rcondt{1} 3.
     intros &m;conseq (_ : _ ==> true) => //.
   rcondt{2} 2.
     intros &m;conseq (_ : _ ==> true) => //.
   wp;case (x{1} = ROe.xs{1}).
    rnd{1};rnd => //.
    rnd;rnd{1};skip;progress => //;smt.
  rcondf{1} 3.
    intros &m;conseq (_ : _ ==> true) => //.
  rcondf{2} 2.
    intros &m;conseq (_ : _ ==> true) => //.
  sim;rnd{1} => //.
  proc;sim.
qed.
