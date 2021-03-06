require import Int.

module Test = {
  var x: int
  var y: int
  var z: int

  proc test () : unit = {
    x = 0;
    y = 1;
    (x,y) = (y,x);
    (z,y,x) = (x+y,y+z,x+y+z);
  }

}.


lemma test : hoare [Test.test : Test.z=10 ==> Test.z=1 /\ Test.y=10 /\ Test.x=11].
proc.
sp 1.
sp.
by skip; trivial.
qed.
