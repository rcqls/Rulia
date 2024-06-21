Rulia: julia for R
================

<details>
  <summary>Click me</summary>
  
  ### Heading
  1. Foo
  2. Bar
     * Baz
     * Qux

  ### Some Javascript
  ```js
  function logSomething(something) {
    console.log('Something', something);
  }
  ```
</details>

<!-- Rscript -e "rmarkdown::render('README.Rmd')";rm README.html -->

# Getting started

This is an attempt to embed the `julia` language in `R`. Actually, very
basic `julia` types are converted to `R` objects.

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

### Comments

Let us notice that theres exists alternatives `R` package like
[`JuliaCall`](https://github.com/Non-Contradiction/JuliaCall). Notably,
the big difference with `Rulia` is that `JuliaCall` depends on the `R`
package `Rcpp` and the `julia` package `RCall.jl`. In other words,
`Rulia` only depends on the C API of both `R` and `julia` languages.

## Quick live session

``` r
require(Rulia)
```

    ## Le chargement a nécessité le package : Rulia

    ## Welcome! Rulia has initialized julia inside R

``` r
jl(`1`)
```

    ## 1

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

The only thing to do in order to initialize `julia` is to load the
library `Rulia`.

# How it works for the user: the `jl()` function

1.  `Rulia` package when loaded, initializes a `julia` session useable
    inside the current `R` session.
2.  `jl()` is the **only user friendly function** to use in order to:

- execute regular `julia` code inside `R`
- convert `R` object in `julia` object
- call `julia` function returned by `jl()` function itself
- define `julia` variable(s) directly inside the `julia` session

## `jl()` as evaluation of `julia` expressions

Thanks to the `jl()` function, `Rulia` allows us to call `julia`
(possibly multilines) expression given with expression between backticks
“\`” (i.e. of class `name` or type `symbol`).

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

``` r
jl(`[
    1.0,
    3.0,
    2.0
    ]`)
```

    ## 3-element Vector{Float64}:
    ##  1.0
    ##  3.0
    ##  2.0

All these commands return `jlvalue` objects which are `R` external
pointers wrapping `jl_value_t*` values.

## `jl()` as `julia` converter of `R` objects

A lot of `R` objects can be converted in `julia` objects by simply put
them as argument of the `jl()` function.

``` r
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

``` r
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

``` r
jl(matrix("one"))
```

    ## "one"

``` r
jl(list(a=c(TRUE,FALSE,TRUE), b=1L))
```

    ## @NamedTuple{a::Array, b::Int64}((Bool[1, 0, 1], 1))

## `jl()` function to call `julia` function inside `R` system

The main use of the `Rulia` package is to call `julia` function (in
fact, `julia` method because of the implicit **multiple dispatching**
provided by `julia`) inside the `R` system. The more challenging goal of
`Rulia` is to try to provide a `R` syntax to call `julia` function which
as most as possible close to the original `julia` syntax.

Lets start with a simple example:

``` r
jl(rand)(`2`)   # julia integer
```

    ## 2-element Vector{Float64}:
    ##  0.8304573691757956
    ##  0.36074634985549137

``` r
jl(rand)(2L)    # implicitly converted R integer
```

    ## 2-element Vector{Float64}:
    ##  0.9055620507309137
    ##  0.2369878642855625

In fact both these lines are user-friendy simplified versions of what
would be necessary to call:

``` r
jl(rand)(jl(`2`))   # julia integer
```

    ## 2-element Vector{Float64}:
    ##  0.8935457646403547
    ##  0.5178798009636498

``` r
jl(rand)(jl(2L))    # implicitly converted R integer
```

    ## 2-element Vector{Float64}:
    ##  0.16213599880948582
    ##  0.9190867746146514

But what one want in `Rulia` as a first goal is:

    An expression in `Rulia` only need only one call of the `jl()` function whenever many `jl()` calls would be normally necessary.

How is a such trick possible?

Let us first observe the result returned of `jl()` when the argument is
the expression of a `julia function`.

``` r
jl(`sum`)       # the usual way
```

    ## sum (generic function with 10 methods)

``` r
jl(sum)         # which is equivalent to the simplified way thanks to R
```

    ## sum (generic function with 10 methods)

``` r
class(jl(sum))  # this is not directly a jlvalue R object
```

    ## [1] "typeof(sum)" "jlfunction"

Let us comment what is special here. `jl(sum)` should normally returns
an `R` object of class `jlvalue`. But since our goal is to apply the
function, `jl(sum)` is tranformed in a `jlfunction` that can be called
with arguments that need to be `R` objects of class `jlvalue`. Thanks to
the metaprogramming provided by `R`, one only needs to provided the
arguments of the `jlfunction` with

- `R` objects implicitly converted to `jlvalue` objects  
- `julia` expressions given between backticks also implicitly executed
  (for you) in the `julia` side to finally provide `jlvalue` results

## Conversion `julia` to `R`

Once

## Rulia in the statistic context

- `DataFrame` (`julia` side) and `data.frame` (`R` side)

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

To compute `julia` code needs to be put between two backticks and not
between quote or double quote (which is a regular `R` character object
to be converted in `julia`). It is better to insist, don’t confuse the
third line before and the first following one (which returns a simple
`julia` object of type `String`):

``` r
jl("(a=1,b=DataFrame(a=1:3,b=2:4))") -> str_jl
str_jl
```

    ## "(a=1,b=DataFrame(a=1:3,b=2:4))"

``` r
list(jltypeof(str_jl), typeof(str_jl), class(str_jl))
```

    ## [[1]]
    ## String
    ## 
    ## [[2]]
    ## [1] "externalptr"
    ## 
    ## [[3]]
    ## [1] "String"  "jlvalue"

As expected, `Rulia` offers conversion in both directions, `julia` to
`R` and conversely `R` to `julia`

``` r
nt_R <- R(nt_jl)
nt_R
```

    ## $a
    ## [1] 1
    ## 
    ## $b
    ##   a b
    ## 1 1 2
    ## 2 2 3
    ## 3 3 4

and conversely `R` to `julia`

``` r
jl(nt_R)
```

    ## (a = 1, b = 3×2 DataFrame
    ##  Row │ a      b
    ##      │ Int64  Int64
    ## ─────┼──────────────
    ##    1 │     1      2
    ##    2 │     2      3
    ##    3 │     3      4)

- `CategoricalArray` (`julia` side) and `factor` (`R` side)

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
list(jltypeof(ca_jl), typeof(ca_jl), class(ca_jl))
```

    ## [[1]]
    ## CategoricalVector{String, UInt32, String, CategoricalValue{String, UInt32}, Union{}} (alias for CategoricalArray{String, 1, UInt32, String, CategoricalValue{String, UInt32}, Union{}})
    ## 
    ## [[2]]
    ## [1] "externalptr"
    ## 
    ## [[3]]
    ## [1] "CategoricalArray" "AbstractArray"    "Struct"           "jlvalue"

Below, the conversion `julia` to `R`

``` r
ca_R <- R(ca_jl)
ca_R
```

    ## [1] titi toto titi
    ## Levels: titi toto

and conversely, the conversion `R` to `julia`

``` r
jl(ca_R)
```

    ## 3-element CategoricalArray{String,1,UInt32}:
    ##  "titi"
    ##  "toto"
    ##  "titi"

# Rulia in low level mode

# R Finalizers

Following the documentation on embedding `julia`, a system of preserved
references to `julia` values has been created. An `R` finalizer is
assiocated to each `jlvalue` object (in fact, an `R` external pointer
wrapping some `jl_value_t*` value). Whenever the `jlvalue` is gabarged
collected, the reference on the associated `julia` value is also
dereferenced which is then cleaned up by the `julia` garbage collector.
