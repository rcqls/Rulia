## IMPORTANT
## 1) jl(`<multiline julia expression>`) redirect to jleval("<multiline julia expression>")
## 2) jl(<R object>) is redirected to jlvalue(<RObject>)

jl <- function(obj, ...) {
  jlvars_rexprs <- as.list(sys.call())[-1L]
  if(length(jlvars_rexprs) == 0) {
    return(.jlEnv())
  } else if(!is.null(names(jlvars_rexprs))) {
    ## jl variables mode
    nmjlvars <- names(jlvars_rexprs)
    indvars <- which(nmjlvars != "")
    nmjlvars <- nmjlvars[indvars]
    for (nmvar in nmjlvars) {
      jlval <- jlvalue_eval_rexpr(jlvars_rexprs[[nmvar]], parent_envir = parent.frame())
      jlvalue_set(nmvar, jlval)
    }
  } else { ## jl mode
    rexpr <- substitute(obj)
    jlval <- jlvalue_eval_rexpr(rexpr, parent_envir = parent.frame())
    return(jlvalue_with_code(jlval, deparse(rexpr)))
  }
}

jlR <- function(obj) {
    rexpr <- substitute(obj)
    return(R(jlvalue_eval_rexpr(rexpr, parent_envir = parent.frame())))
}


jlrun_unsafe <- function(expr) {
  ## if(!.jlrunning()) .jlinit()
  invisible(.External("Rulia_run", expr, PACKAGE = "Rulia"))
}

jlrun <- jlrun_with_exception <- function(expr) {
  ## if(!.jlrunning()) .jlinit()
  res <- .External("Rulia_run_with_exception", expr, PACKAGE = "Rulia")
  if(!is.null(res)) {
    res <- jlexception(expr, res)
    summary(res)
  }
  invisible(res)
}

R <- toR <- function(jlval) UseMethod("toR")

toR.default <- function(obj) obj

jlvalue_get <- function(var) {
  ## if (!.jlrunning()) .jlinit()
  res <- jleval(var)
  return(res)
}

jlvalue_set <- function(var, value, vector = FALSE) {
  ## if (!.jlrunning()) .jlinit()
  jlval <- jlvalue(value)
  .External("Rulia_set_global_variable", var, jlval, PACKAGE = "Rulia")
  return(invisible())
}

# jltrycall safe version of jlvalue_call

jlcall <- jltrycall <- function(meth, ..., parent_envir =  parent.frame()) {
  args <- jlvalue_eval_rexprs(substitute(list(...)), parent_envir)
  ## TO DEBUG: print(list(jltcargs=args, call=match.call(), s = substitute(list(...)),env=ls(parent_envir)))
  nmargs <- names(args)
  if(is.null(nmargs)) nmargs <- rep("",length(args))
  kwargs <- args[nmargs != ""]
  args <- args[nmargs == ""]
  ## TO DEBUG: print(list(args=args, kwargs=kwargs))
  ## TO DEBUG: print(lapply(args, jl))
  ## TO DEBUG: print(.RNamedList2jlNamedTuple(kwargs))
  jlval <- .jlvalue_trycall(jlvalue(meth), jl(lapply(args, jl)), .RNamedList2jlNamedTuple(kwargs))
  jlvalue_function_with_exception(jlval, match.call(), parent_envir)
}

jlfunc <- jltryfunc <- function(jlval_meth, ..., parent_envir =  parent.frame()) {
  args <- jlvalue_eval_rexprs(substitute(list(...)), parent_envir)
  ## TO DEBUG: print(list(jltcargs=args, call=match.call(), s = substitute(list(...)),env=ls(parent_envir)))
  nmargs <- names(args)
  if(is.null(nmargs)) nmargs <- rep("",length(args))
  kwargs <- args[nmargs != ""]
  args <- args[nmargs == ""]
  ## TO DEBUG: print(list(args=args, kwargs=kwargs))
  ## TO DEBUG: print(lapply(args, jl))
  ## TO DEBUG: print(.RNamedList2jlNamedTuple(kwargs))
  jlval <- .jlvalue_tryfunc(jlval_meth, jl(lapply(args, jl)), .RNamedList2jlNamedTuple(kwargs))
  jlvalue_function_with_exception(jlval, match.call(), parent_envir)
}

jlcallR <- jltrycallR <- function(meth, ...) toR(jltrycall(meth, ...))
jlfuncR <- jltryfuncR <- function(jlval_meth, ...) toR(jltryfunc(jlval_meth, ...))
