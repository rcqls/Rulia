module RCallPtr
using RCall

## RCall with RObject forces the preservation of the R vectors 
## since the usual use case is to call R inside Julia
## In oiur case, we don't want the R object garbage collected when the julia wrapper Ptr{Sxp} is garbage collected by julia
reval_unprotected(str::T, env=RCall.Const.GlobalEnv) where T <: Union{AbstractString, Symbol} =
    RCall.unsafe_array(RCall.reval_p(RCall.rparse_p(str), sexp(env)))

end