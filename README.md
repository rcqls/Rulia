Julia for R
================
RCqls

# Julia for R

This is an attempt to embed the julia language in R. Actually, very
basic julia types are converted to R objects. This package is also very
experimental

## Install

1.  Install Julia (all Operating System)

Install [Julia](https://julialang.org/downloads/). For Windows users
don’t forget to select `PATH` in the installer.

2.  Windows user setup

- Install [RTools](https://cran.r-project.org/bin/windows/Rtools/) and a
  terminal with bash (for instance, [Git
  Bash](https://gitforwindows.org/))
- Add Rscript in the `PATH` environment variable (see for example [this
  page](https://www.hanss.info/sebastian/post/rtools-path/))

3.  Bash installation (all Operating Systems)

In a terminal (tested on macOS M1 with julia-1.9.2:) with `julia` and
`Rscript` binaries supposed to be in the `PATH` environment variable,

``` bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rcqls/Rulia/HEAD/inst/install.sh)"
```

## How it works

### getting started

``` r
require(Rulia)
```

    ## Le chargement a nécessité le package : Rulia

``` r
jl(`1.0`)
```

    ## 1.0

``` r
jl(1)
```

    ## 1.0

``` r
v_jl <- jl(c(1,3,2))
v_jl
```

    ## 3-element Vector{Float64}:
    ##  1.0
    ##  3.0
    ##  2.0

``` r
R(v_jl)
```

    ## [1] 1 3 2

## `jl()` function

### `jl()` as evaluation of `julia` expressions given as an one-length `R` character vector

``` r
jl(`[1,3,2]`)
```

    ## 3-element Vector{Int64}:
    ##  1
    ##  3
    ##  2

``` r
jl(`[1.0,3.0,2.0]`)
```

    ## 3-element Vector{Float64}:
    ##  1.0
    ##  3.0
    ##  2.0

``` r
jl(`(a=1,b=[1,3])`)
```

    ## (a = 1, b = [1, 3])

All these results are `jlvalue` objects which are `R` external pointers
wrapping `jl_value_t*` values.

### `jl()` as `julia` converter of `R` vectors

Above, an example for conversion of a vector of double was given. Below
one completes with vector of character, logical and integer.

``` r
require(Rulia)
jl(c("one","three","two"))
```

    ## 3-element Vector{String}:
    ##  "one"
    ##  "three"
    ##  "two"

``` r
jl(c(TRUE,FALSE,TRUE))
```

    ## 3-element Vector{Bool}:
    ##  1
    ##  0
    ##  1

``` r
jl(c(1L,3L,2L))
```

    ## 3-element Vector{Int64}:
    ##  1
    ##  3
    ##  2

Notice that vector of length 1 are converted to atomic `julia` values.

``` r
require(Rulia)
jl(TRUE)
```

    ## true

``` r
jl(1L)
```

    ## 1

``` r
jl(1)
```

    ## 1.0

``` r
jl("1")
```

    ## "1"

To get a vector of length 1 in `julia` one has

``` r
require(Rulia)
jl("one", vector=TRUE) # or simply jl("one", TRUE)
```

    ## 1-element Vector{String}:
    ##  "one"

``` r
jl(TRUE, vector=TRUE) # or simply jl(TRUE, TRUE)
```

    ## 1-element Vector{Bool}:
    ##  1

``` r
jl(1L, TRUE)
```

    ## 1-element Vector{Int64}:
    ##  1

``` r
jl(1, TRUE)
```

    ## 1-element Vector{Float64}:
    ##  1.0

Notice that there is no need to set `vector=TRUE` when `dim` is not
`NULL`:

``` r
jl(matrix("one"))
```

    ## 1×1 Matrix{String}:
    ##  "one"

### Goal: conversion of `julia` structures used in statitictic to `R`

- `DataFrame`

``` r
require(Rulia)
jlusing(DataFrames)
jl(`(a=1,b=DataFrame(a=1:3,b=2:4))`) -> nt_jl
nt_jl
```

    ## (a = 1, b = 3×2 DataFrame
    ##  Row │ a      b
    ##      │ Int64  Int64
    ## ─────┼──────────────
    ##    1 │     1      2
    ##    2 │     2      3
    ##    3 │     3      4)

``` r
R(nt_jl) # or toR(nt_jl)
```

    ## $a
    ## [1] 1
    ## 
    ## $b
    ##   a b
    ## 1 1 2
    ## 2 2 3
    ## 3 3 4

``` r
list(jltypeof(nt_jl), typeof(nt_jl), class(nt_jl))
```

    ## [[1]]
    ## @NamedTuple{a::Int64, b::DataFrame}
    ## 
    ## [[2]]
    ## [1] "externalptr"
    ## 
    ## [[3]]
    ## [1] "NamedTuple" "Struct"     "jlvalue"

- `CategoricalArray`

``` r
require(Rulia)
jlusing(CategoricalArrays)
ca_jl <- jl(`categorical(["titi","toto","titi"])`)
ca_jl
```

    ## 3-element CategoricalArray{String,1,UInt32}:
    ##  "titi"
    ##  "toto"
    ##  "titi"

``` r
R(ca_jl)
```

    ## [1] titi toto titi
    ## Levels: titi toto

``` r
list(jltypeof(ca_jl), typeof(ca_jl), class(ca_jl))
```

    ## [[1]]
    ## CategoricalVector{String, UInt32, String, CategoricalValue{String, UInt32}, Union{}} (alias for CategoricalArray{String, 1, UInt32, String, CategoricalValue{String, UInt32}, Union{}})
    ## 
    ## [[2]]
    ## [1] "externalptr"
    ## 
    ## [[3]]
    ## [1] "CategoricalArray" "Struct"           "jlvalue"

## R Finalizers

Following the documentation on embedding `julia`, a system of preserved
references to `julia` values has been created. An `R` finalizer is
assiocated to each `jlvalue` object (in fact, an `R` external pointer
wrapping some `jl_value_t*` value). Whenever the `jlvalue` is gabarged
collected, the reference on the associated `julia` value is also
dereferenced which is then cleaned up by the `julia` garbage collector.
