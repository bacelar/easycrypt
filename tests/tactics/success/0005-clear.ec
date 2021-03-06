(* -------------------------------------------------------------------- *)
type t.
pred p : t.

(* -------------------------------------------------------------------- *)
lemma L: forall x1, p x1 => forall x2 x3, p x2 => p x3.
proof.
  move=> x1 hx1 x2 x3 hx2.
  move: (x1) hx1 (x2) x3 hx2.
  clear x1; move=> {x2}.
  admit.
qed.
