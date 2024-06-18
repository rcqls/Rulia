
## Facility function to use julia inside R

.jlEnv <- function() {
    obj <- new.env()
    class(obj) <- "jlEnv"
    obj
}

## get access to globalenv()$jl inside the package 
jlEnv <- function() get("jl", envir = globalenv())

# `[.jlEnv` <- function(obj, key) {
#     # OLD version (to remove)
#     # key <- deparse(substitute(key))
#     # if((substr(key,1,1) == substr(key,nchar(key),nchar(key))) && (substr(key,1,1) %in% c("'", '"'))) {
#     #     key <- substr(key,2,nchar(key) - 1)
#     #     function(...) {jlnew(key, ...)}
#     # } else {
#     #     function(...) {jlvalue_call(key, ...)}
#     # }
#     if(class(substitute(key)) == "character") {
#         function(...) {jlnew(key, ...)}
#     } else {
#         key <- deparse(substitute(key))
#         function(...) {jlvalue_call(key, ...)}
#     }
# }

`[[.jlEnv` <- function(obj, key) {
    if (class(substitute(key)) != "character") {
        key <- deparse(substitute(key))
    }
    ## check if key is a generic function
    gen = jleval(key)
    if(is.jlexception(gen)) {
        function(...) gen
    } else {
        parent_envir <- parent.frame()
        function(...) {
            # args <- jl_args_rexprs(substitute(list(...)), parent.frame())
            # if(any(sapply(args, is.jlexception))) {
            #     jlexceptions(args)
            # } else {
            #     do.call("jlvalue_call", c(key, lapply(args, jl)))
            # }
            jlval <- jltrycall(key, ..., parent_envir = parent_envir)
            jlval ## jlvalue_with_exception(match.call(), jlval)
        }
    }
}

## TODO: same spirit than jltrycall or at least jl_args_rexprs
`[.jlEnv` <- function(obj, key) {
    if(class(substitute(key)) != "character") {
        key <- deparse(substitute(key))
    }
    #function(...) {jlStruct(key, ...)}
    function(...) {
        args <- c(key, jl_rexprs(substitute(list(...)), list(...)))
        do.call("jlStruct", args)
    }
}

`$.jlEnv` <- function(obj, field) {
    field <- as.character(substitute(field))
    jlvalue_get(field)
}

`$<-.jlEnv` <- function(obj, field, value) {
    field <- as.character(substitute(field))
    jlvalue_set(field, value)
    obj
}

`names.jlEnv` <- function(obj) {
    ## setdiff(R(jleval("names(Main)")), c("Base","Core","Main","display_buffer","Rulia_ANSWER","preserved_refs"))
    # No Module returned
    setdiff(R(jlvalue_eval("tmp=names(Main);tmp[.!(convert.(Bool, isa.(eval.(tmp),Module)))]")), c("display_buffer","Rulia_ANSWER","preserved_refs"))
}

`print.jlEnv` <- function(obj, ...) {
    if(length(names(obj)) == 0) {
        cat("julia environment empty!\n")
    } else {
        cat("julia environment: ", paste( names(obj), collapse=", "),"\n")
    }
}
