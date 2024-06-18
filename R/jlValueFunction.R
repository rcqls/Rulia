jlfunction <- function(jlval, parent_envir = parent.frame(3)) {
    if(is.jlfunction(jlval)) {
        attrsR <- list(
            name = R(jlvalue_call("string",jlval)),
            jlvalue = jlval,
            parent_envir = parent_envir ## VERY IMPORTANT (see comment below)
        )
        ## IMPORTANT:
        ## parent_envir is required for the next closure to know parent_envir inside
        jlf <- function(...) {
            jltryfunc(key, ..., parent_envir = parent_envir)
        }
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

## FIRST VERSION
# is.jlfunction <- function(jlval) {
#     if(is.jlvalue(jlval)) {
#         typR <- jlvalue_callR("typeof",jlval)
#         if(substring(typR,1,1) == "#") {
#             return(list(ok = TRUE, name = substring(typR,2)))
#         } else {
#             return(list(ok = FALSE, name = typR))
#         }
#     } else {
#         return(list(ok = FALSE))
#     }
# }


is.jlfunction <- function(jlval) {
    is.jlvalue(jlval) && R(jlvalue_call("isa", jlval, jlvalue_eval("Function")))
}


jlvalue.jlfunction <- function(jlf) attr(jlf, "jlvalue")

print.jlfunction <- function(jlf) {
    print(jlvalue(jlf))
}
