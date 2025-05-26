##  These functions are internal functions that don't rely on jl mode

.RNamedList2jlDataFrame <- function(df) {
    jlusing("DataFrames")
    splatdf <- jlvalue_call("splat", jlvalue_eval("DataFrame"))
    args <- jlvalue_eval("[]")
    vars <- list()
    pairs <- list()
    for (nm in names(df)) {
        vars[[nm]] <- jlvalue(df[[nm]])
        pairs[[nm]] <- jlvalue_call("=>", jlsymbol(nm), vars[[nm]])
        jlvalue_call("push!", args, pairs[[nm]])
    }
    jlval <- jlvalue_func1(splatdf, args)
    ## Attempt to clean all unused jlvalue external pointers
    ## jl_finalize_jlvalues(splatdf, args, pairs, vars)
    jlval
}


## internal
.RNamedList2jlDict <- function(obj) {
    jlval <- jlvalue_eval("Dict{Symbol, Any}()")
    vars <- list()
    pairs <- list()
    for (nm in names(obj)) {
        vars[[nm]] <- jlvalue(obj[[nm]])
        pairs[[nm]] <- jlvalue_call("=>", jlsymbol(nm), vars[[nm]])
        jlvalue_call("push!", jlval, pairs[[nm]])
    }
    jlval
}

.RNamedList2jlNamedTuple <- function(obj) {
    if (length(obj) == 0) return(jlTuple())
    vars <- list()
    types <- c()
    for (nm in names(obj)) {
        vars[[nm]] <- jlvalue(obj[[nm]])
        types <- c(types, jlcallR("string", jlvalue_typeof(vars[[nm]]))) ## OLD: R(jlvalue_typeof(vars[[nm]])))
    }
    jlstruct <- paste0("@NamedTuple{", paste(names(obj), "::", types, collapse=",", sep=""), "}") 
    args <- c(jlstruct, unname(vars))
    ## print(args)
    jlval <- do.call("jlStruct", args)
    jlval
}

.RList2jlTuple <- function(obj) {
    splattuple <- jlvalue_call("splat", jlvalue_eval("tuple"))
    args <- jlvalue_eval("[]")
    vars <- list()
    obj <- unname(obj)
    for (i in seq_along(obj)) {
        vars[[i]] <- jlvalue(obj[[i]])
        jlvalue_call("push!", args, vars[[i]])
    }
    jlval <- jlvalue_func1(splattuple, args)
    jlval
}