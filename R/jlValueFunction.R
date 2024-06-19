jlfunction <- function(jlval, parent_envir = parent.frame(3)) {
    if(is.jlfunction(jlval)) {
        attrsR <- list(
            name = R(jlvalue_call("string",jlval)),
            jlvalue = jlval,
            parent_envir = parent_envir ## VERY IMPORTANT (see comment below)
        )
        ## IMPORTANT:
        ## parent_envir is required for the next closure to know parent_envir inside its body
        jlf <- function(...) {
            jltryfunc(key, ..., parent_envir = parent_envir)
        }
        ## replace key with jlval
        body(jlf)[[2]][[2]] <- jlval
        attributes(jlf) <- attrsR
        class(jlf) <- c(R(jlvalue_call("string", jlvalue_call("typeof", jlval))), "jlfunction")
        jlf
    } else {
        function(...) {
            warning("Not a julia function!")
            jlval
        }
    }
}

is.jlfunction <- function(jlval) {
    ## Base.Callable is Union{Type, Function} and then ca
    is.jlvalue(jlval) && R(jlvalue_call("isa", jlval, jlvalue_eval("Base.Callable")))
}

jlvalue.jlfunction <- function(jlf) attr(jlf, "jlvalue")

print.jlfunction <- function(jlf) {
    print(jlvalue(jlf))
}
