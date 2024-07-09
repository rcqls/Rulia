module RCallPtr
using RCall
using CategoricalArrays

## RCall with RObject forces the preservation of the R vectors 
## since the usual use case is to call R inside Julia
## In our case, we don't want the R object garbage collected when the julia wrapper Ptr{Sxp} is garbage collected by julia
reval_unprotected_vector(str::T, env=RCall.Const.GlobalEnv) where T <: Union{AbstractString, Symbol} = RCall.unsafe_array(RCall.reval_p(RCall.rparse_p(str), sexp(env)))

## s is here a factor and no Na allowed
function unsafe_categorical(s::Ptr{IntSxp})
    RCall.isFactor(s) || error("s is not an R factor")
    refs = RCall.unsafe_array(s)
    levels = RCall.rcopy(Array{String}, RCall.getattrib(s,RCall.Const.LevelsSymbol))
    pool = CategoricalPool{String, Int32}(levels, RCall.isOrdered(s))
    CategoricalArray{String, 1}(refs, pool)
end

reval_unprotected_factor(str::T, env=RCall.Const.GlobalEnv) where T <: Union{AbstractString, Symbol} = unsafe_categorical(RCall.reval_p(RCall.rparse_p(str), sexp(env)))

end