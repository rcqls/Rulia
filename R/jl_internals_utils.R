# rexpr is generally the result of substitute(obj) 
jlvalue_eval_rexpr <- function(rexpr, parent_envir= parent.frame()) {
    jlval <- if (class(rexpr) == "name") {
        obj <- deparse(rexpr)
        ## Not a good idea!
        #if(is.jlvariable(obj)) {
        #    jlvalue_eval(obj)
        #} else 
        if(is.variable(obj, parent_envir)) {
            ## Priority 1: obj is an R object
            obj <- eval(rexpr, envir=parent_envir)
            jlvalue(obj)
        } else {
            ## Priority 2: obj is a string corresponding to a julia expression
            jlvalue_eval(obj)
        }
    } else {
        if(class(rexpr) == "call") {
            ## Priority 1 as a call:  
            # print(list(rexpr=rexpr, envir=ls(parent_envir)))
            obj <- eval(rexpr, envir = parent_envir)
            jlvalue(obj)
        } else {
            ## as a julia obj
            obj <- deparse(rexpr)
            jlvalue(rexpr)
        }
    }
    jlvalue_function_with_exception(jlval, obj, parent_envir)
}

jlvalue_eval_rexprs <- function(rexprs, parent_envir) { # rexpr is generally the result of substitute(obj) 
    rexprs <- as.list(rexprs)[-1]
    nms <- names(rexprs)
    res <- lapply(seq_along(rexprs), function(i) jlvalue_eval_rexpr(rexprs[[i]], parent_envir))
    names(res) <- nms
    res
}

rexpr2jlexpr <- function(term) { 
    as.call(
        lapply(
            as.list(term), 
            function(e) {
                if(is.name(e) && as.character(e) ==  "c") 
                    as.name("vcat")
                else if(length(e) == 1) 
                    e 
                else 
                    as.call(rexpr2jlexpr(e))
            }
        )
    )
}

## is a R variable
is.variable <- function(name, envir) {
    exists(name,envir=envir) && (regexpr("^[a-z,A-Z,.][a-z,A-Z,.,0-9]*", name) > 0 ) && !is.function(eval(parse(text = name), envir = envir))
}

is.jlvariable <- function(name) {
    R(jlvalue_eval(paste0(":",name, " in names(Main)")))
}
