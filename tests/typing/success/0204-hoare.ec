require import Int.

module G = {
  proc f(x : int, y : int) : int = {
    return x + y;
  }
}.

lemma L : forall u v, hoare[G.f : (x = u /\ y = v) ==> (res = u + v)].
proof -strict. admit. qed.
