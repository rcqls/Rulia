.onLoad <- function(lib, pkg) {
  ## Use local=FALSE to allow easy loading of Tcl extensions
  library.dynam("Rulia", pkg, lib)#,local=FALSE)
}
