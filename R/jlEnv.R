
## Facility function to use julia inside R

.jlEnv <- function() {
    obj <- new.env()
    class(obj) <- "jlEnv"
    obj
}

## get access to globalenv()$jl inside the package 
jlEnv <- function() get("jl", envir = globalenv())

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
