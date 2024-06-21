.onLoad <- function(lib, pkg) {
  ## Use local=FALSE to allow easy loading of Tcl extensions
  ## Add julia PATH in R 
  Sys.setenv(PATH=paste(system('julia -e "println(Sys.BINDIR)"',intern=TRUE),Sys.getenv("PATH"),sep=";"))
  library.dynam("Rulia", pkg, lib) #,local=FALSE)
}

.onAttach <- function(libname, pkgname) {
  if(!.jlrunning()) .jlinit()
  cat("Welcome! Rulia has initialized julia inside R\n")
}

.onDetach <- function(libpath) {
  if(.jlrunning()) .jlexit()
  cat("Welcome! Rulia has exited julia\n")
}
