# Put here generic function used in the julia side but not in the R side
rand <- function(obj, ...) UseMethod("rand")
jl_set.seed <- function(n) {
    jlusing(Random)
    invisible(jl(`Random.seed!`)(as.integer(n)))
}
rand.integer <- rand.double <- function(obj) jlvalue_call("rand", jlvalue(as.integer(obj)))
rand.default <- function(obj, ...) jlvalue_call("rand")