.onLoad <- function(lib, pkg) {
  ## Use local=FALSE to allow easy loading of Tcl extensions
  library.dynam("Rulia", pkg, lib) #,local=FALSE)
}

.onAttach <- function(libname, pkgname) {
  if(!.jlrunning()) .jlinit()
  cat("Welcome to Rulia!\n")
}

.onDetach <- function(libpath) {
  if(.jlrunning()) .jlexit()
}
