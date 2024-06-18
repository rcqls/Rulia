#/bin/bash

export JULIA_DIR=$(julia -e "p=joinpath(splitpath(Sys.BINDIR)[1:end-1]);print(Sys.iswindows() ? replace(p, Base.Filesystem.path_separator => '/') : p)")
Rscript -e 'remotes::install_github("rcqls/jl4R",force=TRUE,build=FALSE)'