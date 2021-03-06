module M = {
  var y : int
  proc f(x:int) : int = {
    y = x;
    y = 1;
    return y;
  }
}.

equiv foo : M.f ~ M.f : true ==> res{1} = res{2} /\ res{1} = 1 /\ M.y{1} = 1 
                                 /\ M.y{2} = 1.  
proof -strict.
  proc.
  seq 1 1 : (M.y{1} = x{1} /\ M.y{2} = x{2}).
  admit.
  admit.
qed.
