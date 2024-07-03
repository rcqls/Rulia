## Facility function

jlpkg <- function(cmd) {
  if (class(substitute(cmd)) != "character") {
    cmd <- deparse(substitute(cmd))
  }
  cat(paste0("import Pkg; Pkg.",cmd), "\n")
  jlrun(paste0("import Pkg;Pkg.",cmd))
}

jlusing <- function(..., force = FALSE) {
  pkgs <- sapply(substitute(c(...))[-1], function(e) ifelse(is.character(e), e, as.character(e)))
  for(pkg in pkgs) {
    if(!jlpkgisinstalled_(pkg)) {
      stop(paste0("Package ", pkg, " not installed in the julia side! Install it: jlpkgadd(",pkg,")"))
    }
  }
  if(force) {
    ## fix a weird issue with loading dll
    ## that need to be called several time (maybe an issue with the order) 
    for(pkg in pkgs) jlusing_force(pkg)
  } else {
    jlrun(paste0("using ", paste(pkgs,collapse=", ")))
  }
}

# if package is specified the file path is relative to inst folder package
jlinclude <- function(jlfile, package="") {
  if(package == "") {
    jlfile <- substitute(jlfile)
    if(!is.character(jlfile) && is.call(jlfile) && jlfile[[1]] == as.name("::") && length(jlfile) == 3) {
      package <- deparse(jlfile[[2]])
      jlfile <- paste0(deparse(jlfile[[3]]),".jl")
    } else {
      warning("Argument badly formed!")
      jlfile <- "" 
    }
  } 
  if(package != "") {
    jlfile <- system.file(file.path("julia", jlfile), package=package)
  }
  if(jlfile != "") {
    cmd <-  paste0('include("',jlfile,'")')
    jlrun(cmd)
  }
}

## Trick for jlusing badly called because of dlopen error
jlusing_force <- function(pkg, n = 10) {
  repeat {
    res <- jlvalue_eval(paste0("using ", pkg))
    n <- n - 1
    if(!inherits(res, "jlexception") || n < 0) break
  }
  if( n >= 0) invisible(NULL) else res
}

jlpkgadd_ <- function(pkg) {
  jlrun(paste0("import Pkg;Pkg.add(\"", pkg, "\")"))
}

jlpkgadd <- function(..., url = NULL) {
    if (!is.null(url)) {
        jlrun(paste0("import Pkg;Pkg.add(url=\"", url, "\")"))
    } else {
        pkgs <- sapply(substitute(c(...))[-1], function(e) ifelse(is.character(e), e, as.character(e)))
        for (pkg in pkgs) jlpkgadd_(pkg)
    }
}

jlpkgisinstalled_ <- function(pkg) {
  jlcode = paste0("using TOML;d = TOML.parsefile(Base.active_project());haskey(d[\"deps\"], \"", pkg,"\")")
  R(jlvalue_eval(jlcode))
}

jlpkgisinstalled <- function(pkg) {
  if (class(substitute(pkg)) != "character") {
    pkg <- deparse(substitute(pkg))
  }
  jlpkgisinstalled_(pkg)
}

jlpkgcheckinstalled <- function() {
  if(!jlpkgisinstalled(DataFrames)) {
    cat("DataFrames.jl required! Install it from the julia side\n")
  }
  if(!jlpkgisinstalled(CategoricalArrays)) {
    cat("CategoricalArrays.jl required! Install it from the julia side\n")
  }
  if(!jlpkgisinstalled(RCall)) {
    cat("RCall.jl not required but used for UnsafeArray! Install it from the julia side\n")
  }
}