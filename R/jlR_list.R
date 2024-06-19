## Convert to Tuple or NamedTuple
jlvalue.list <-  function(obj, ...) {
    ## if(!.jlrunning()) .jlinit()
    if(is.null(names(obj))) {
        .RList2jlTuple(obj)
    } else {
        names(obj)[names(obj) == ""] <- paste0("var",1:sum(names(obj) == ""))
        .RNamedList2jlNamedTuple(obj)
        # .RNamedlist2jlDict(obj)
    }
}
