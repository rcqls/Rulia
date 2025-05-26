
## More internal stuff

.jlinit <- function() {
  .External("Rulia_init", PACKAGE = "Rulia")
  .jl_load_rulia_module()
  return(invisible())
}

.jlexit <- function() {
  .External("Rulia_exit", PACKAGE = "Rulia")
  return(invisible())
}

.jl_load_rulia_module <- function() {
  f <- system.file(file.path("julia", "Rulia.jl"), package = "Rulia")
  if(f != "") {
    cmd <-  paste0('include("', f, '")')
    jlrun(cmd)
  }
}

.jl_load_display_buffer <- function() {
  f <- system.file("display_buffer.jl", package = "Rulia")
  if (f != "") {
    cmd <-  paste0('include("', f, '")')
    jlrun(cmd)
  }
}

.jlrunning <- function() {
  .Call("Rulia_running", PACKAGE = "Rulia")
}

## the main julia parsing expression !!!


.jlans <- function() {
  .Call("Rulia_get_ans", PACKAGE = "Rulia")
}