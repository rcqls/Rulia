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