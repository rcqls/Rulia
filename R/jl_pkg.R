## Facility function

jlpkg <- function(cmd) {
  if (class(substitute(cmd)) != "character") {
    cmd <- deparse(substitute(cmd))
  }
  cat(paste0("import Pkg; Pkg.",cmd), "\n")
  jlrun(paste0("import Pkg;Pkg.",cmd))
}

jlusing <- function(...) {
  pkgs <- sapply(substitute(c(...))[-1], function(e) ifelse(is.character(e), e, as.character(e)))
  jlrun(paste0("using ",paste(pkgs,collapse=", ")))
}

# if package is specified the file path is relative to inst folder package
jlinclude <- function(jlfile, package="") {
  if(package != "") jlfile <- system.file(jlfile, package=package)
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

jlpkgadd <- function(..., url = NULL) {
    if (!is.null(url)) {
        jlrun(paste0("import Pkg;Pkg.add(url=\"", url, "\")"))
    } else {
        pkgs <- sapply(substitute(c(...))[-1], function(e) ifelse(is.character(e), e, as.character(e)))
        for (pkg in pkgs) jlrun(paste0("import Pkg;Pkg.add(\"", pkg, "\")"))
    }
}

jlpkgisinstalled <- function(pkg) {
  if (class(substitute(pkg)) != "character") {
    pkg <- deparse(substitute(pkg))
  }
  jlcode = paste0("using TOML;d = TOML.parsefile(Base.active_project());haskey(d[\"deps\"], \"", pkg,"\")")
  jlvalue_eval(jlcode)
}