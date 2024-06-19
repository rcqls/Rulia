jlDict <-  function(...) {
    obj <- list(...)
    ## if (!.jlrunning()) .jlinit()
    jlval <- jlvalue_eval("Dict{Symbol, Any}()")
    vars <- list()
    pairs <- list()
    for (nm in names(obj)) {
        vars[[nm]] <- jleval(obj[[nm]])
        pairs[[nm]] <- jlvalue_call("=>", jlsymbol(nm), vars[[nm]])
        jlvalue_call("push!", jlval, pairs[[nm]])
    }
    jlval
}

## TODO: toR.Dict

names.Dict <- function(jlval) jlvalue_callR("collect",jlvalue_call("keys",jlval))

"[.Dict" <- function(jlval, field) {
     if (field %in% names(jlval)) {
        jlvalue_call("getindex",jlval,jlsymbol(field))
    } else {
        NULL
    }
}

"$.Dict" <- function(jlval, field) jlval[field]
