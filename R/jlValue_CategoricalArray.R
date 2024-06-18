jlCategoricalArray <- function(fa) {
    jlvalue.factor(fa)
}

toR.CategoricalArray <- function(jlval) {
    pool <- jlgetfield(jlval, "pool")
    res <- jlgetfieldR(jlval, "refs")
    attr(res,"levels") <- jlvalue_callR("levels", pool)
    class(res) <- "factor"
    res
}

levels.CategoricalArray <- function(jlval) {
    jlvalue_call("levels", jlval)
}