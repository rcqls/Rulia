jl_rexpr <- function(rexpr, obj, ...) { # rexpr is generally the result of substitute(obj) 
    if (class(rexpr) == "name") {
        obj <- deparse(rexpr)
        jlval <- jlvalue_eval(obj)
        if(is.jlfunction(jlval)) {
           jlfunction(jlval) 
        } else {
            jlvalue_or_jlexception(rexpr, jlval)
        }
    } else {
        jlvalue(obj, ...)
    }
}

jl_rexprs <- function(rexprs, objs) { # rexpr is generally the result of substitute(obj) 
    rexprs <- as.list(rexprs)[-1]
    lapply(seq_along(rexprs), function(i) jl_rexpr(rexprs[[i]], objs[[i]]))

}

## Proposition of replacement of jl_rexpr and jl_rexprs mostly because
## jl_rexprs is failing
## jl() would benefit too of jl_rexpr2 instead of jl_rexpr 

jl_rexpr2 <- function(rexpr, parent_envir= parent.frame()) { # rexpr is generally the result of substitute(obj) 
    # print(list(rexpr=rexpr,class=class(rexpr)))
    if (class(rexpr) == "name") {
        obj <- deparse(rexpr)
        jlval <- jlvalue_eval(obj)
        # print(list(obj=obj, isjlf=is.jlfunction(jlval), robj = obj %in% ls(parent_envir), envir=ls(parent_envir)))
        if(is.jlfunction(jlval)) {
           jlfunction(jlval, parent_envir) 
        } else if(is.variable(obj, parent_envir)) {# (obj %in% ls(parent_envir) ) {
            obj <- eval(rexpr, envir=parent_envir)
            jlvalue(obj)
        } else {
            jlval
        }
    } else {
        if(class(rexpr) == "call") {
            # print(list(rexpr=rexpr, envir=ls(parent_envir)))
            obj <- eval(rexpr, envir = parent_envir)
            jlvalue(obj)
        } else {
            jlvalue(rexpr)
        }
    }
}

jl_rexprs2 <- function(rexprs, parent_envir) { # rexpr is generally the result of substitute(obj) 
    rexprs <- as.list(rexprs)[-1]
    nms <- names(rexprs)
    res <- lapply(seq_along(rexprs), function(i) jl_rexpr2(rexprs[[i]], parent_envir))
    names(res) <- nms
    res
}

.jlmethod <- function(meth, value) paste0(meth,"(",value,")")

.jltypeof <- function(value) .jleval(.jlmethod("typeof",value))

## No more used! To REMOVE
# .jlsafe <- function(expr) {
#   paste0("try\n", expr, "\ncatch e\n showerror(stdout,e); e\n end")
# }

# .jlsilentsafe <- function(expr) {
#   paste0("try\n", expr, "\ncatch e\n e\n end")
# }
