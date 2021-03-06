(* --------------------------------------------------------------------
 * Copyright (c) - 2012--2015 - IMDEA Software Institute
 * Copyright (c) - 2012--2015 - Inria
 * 
 * Distributed under the terms of the CeCILL-C-V1 license
 * -------------------------------------------------------------------- *)

(* -------------------------------------------------------------------- *)
open EcSymbols
open EcCoreGoal

(* -------------------------------------------------------------------- *)
val t_pr_rewrite_i : symbol *  EcFol.form option -> FApi.backward
val t_pr_rewrite : symbol * EcParsetree.pformula option -> FApi.backward

