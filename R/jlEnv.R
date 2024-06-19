
## Facility function to use julia inside R

.jlEnv <- function() {
    obj <- list()
    class(obj) <- "jlEnv"
    obj
}

`$.jlEnv` <- function(obj, field) {
    field <- as.character(substitute(field))
    jlvalue_get(field)
}


`names.jlEnv` <- function(obj) {
    ## setdiff(R(jleval("names(Main)")), c("Base","Core","Main","display_buffer","Rulia_ANSWER","preserved_refs"))
    # No Module returned
    setdiff(R(jlvalue_eval("names(Main)[.!(convert.(Bool, isa.(eval.(names(Main)),Module)))]")), c("display_buffer","Rulia_ANSWER","preserved_refs"))
}

`print.jlEnv` <- function(obj, ...) {
    if(length(names(obj)) == 0) {
        cat("julia environment empty!\n")
    } else {
        cat("julia environment: ", paste( names(obj), collapse=", "),"\n")
    }
}
