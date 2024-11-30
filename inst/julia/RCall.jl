module RCallPtr
using RCall
using CategoricalArrays
using DataFrames

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
    d = length(RCall.getattrib(s,RCall.Const.DimSymbol))
    if d==0
        d = 1
    end
    CategoricalArray{String, d}(refs, pool)
end

reval_unprotected_factor(str::T, env=RCall.Const.GlobalEnv) where T <: Union{AbstractString, Symbol} = unsafe_categorical(RCall.reval_p(RCall.rparse_p(str), sexp(env)))

function unsafe_dataframe(s::Ptr{VecSxp};
    normalizenames::Bool=true, 
    sanitize::Union{Bool,Nothing}=nothing)
    if sanitize !== nothing
        Base.depwarn("The `sanitize` keyword argument is deprecated. Use `normalizenames` instead.", :rcopy)
        normalizenames = sanitize
    end
    RCall.isFrame(s) || error("s is not an R data frame")
    vnames = rcopy(Array{Symbol},RCall.getnames(s))
    if normalizenames
        vnames = [Symbol(replace(string(v), '.' => '_')) for v in vnames]
    end
    DataFrame([RCall.isFactor(s) ? unsafe_categorical(c) : RCall.unsafe_array(c)   for c in s], vnames, copycols=false)
end

reval_unprotected_dataframe(str::T, env=RCall.Const.GlobalEnv) where T <: Union{AbstractString, Symbol} = unsafe_dataframe(RCall.reval_p(RCall.rparse_p(str), sexp(env)))

end