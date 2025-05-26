
## Facility function to use julia inside R

.jlenv <- function() {
    obj <- list()
    class(obj) <- "jlenv"
    obj
}

`$.jlenv` <- function(obj, field) {
    field <- as.character(substitute(field))
    jlvalue_get(field)
}


`names.jlenv` <- function(obj) {
    ## setdiff(R(jleval("names(Main)")), c("Base","Core","Main","display_buffer","Rulia_ANSWER","preserved_refs"))
    # No Module returned
    setdiff(R(jlvalue_eval("names(Main)[.!(convert.(Bool, isa.(eval.(names(Main)),Module)))]")), c("display_buffer","Rulia_ANSWER","preserved_refs"))
}

`print.jlenv` <- function(obj, ...) {
    if(length(names(obj)) == 0) {
        cat("julia environment empty!\n")
    } else {
        cat("julia environment: ", paste( names(obj), collapse=", "),"\n")
    }
}
