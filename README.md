`Rulia`: `julia` for `R`
================

<!-- Rscript -e "rmarkdown::render('README.Rmd')";rm README.html -->
<details>
<summary>
<h1>
Getting started
</h1>
</summary>

This is an attempt to embed the `julia` language in `R`.

Let us notice that there already exist alternatives `R` packages (see
[`JuliaCall`](https://github.com/Non-Contradiction/JuliaCall) README
page for a complete list).
[`JuliaCall`](https://github.com/Non-Contradiction/JuliaCall) is the
main one. However, the big difference between `Rulia` and `JuliaCall` is
that `JuliaCall` depends on the `R` package `Rcpp` and the `julia`
package `RCall.jl`. In other words, `Rulia` only depends on the C APIs
of `R` and `julia`. There is then **no dependencies** (except `julia`).

Also `Rulia` is the next step of the preliminary project called
[`jl4R`](https://github.com/rcqls/jl4R) started more than 10 years ago.
The author thinks that `Rulia` is a more funny name than `jl4R`.

## Install

1.  `julia` installation (all Operating Systems)

    Go to [Julia](https://julialang.org/downloads/)

    1.  For any Operation system (Windows, MacOS and linux), as proposed
        first in the `julia` download page, prefer the `juliaup`
        installation one. It offers multi-installation of different
        versions of `julia`.
    2.  Alternative installation (**to avoid** if possible)is to install
        `julia` from a binary installer to download. For Windows users
        don’t forget to select `PATH` in the installer

2.  Install `Rulia`

    - From binary (**Windows user only**)

      1.  Donwload
          [Rulia-0.0.1.zip](https://github.com/rcqls/Rulia/releases/download/v0.0.1/Rulia_0.0.1.zip)
          and install it inisde R
      2.  Inside a terminal: Whether `julia` is installed with `juliaup`
          or you specified the `PATH` when launching the binary
          installer, loading (`library(Rulia)/require(Rulia)`) `Rulia`
          inside `R` would normally just work.

    - From source (**all Operating System**)

      1.  Windows user need the following setup:

          - Install
            [RTools](https://cran.r-project.org/bin/windows/Rtools/) and
            a terminal with bash (for instance, [Git
            Bash](https://gitforwindows.org/))
          - Add `Rscript` in the `PATH` environment variable (see for
            example [this
            page](https://www.hanss.info/sebastian/post/rtools-path/))

      2.  You need the `remotes` R package.

      3.  Bash installation (all Operating Systems): click the `copy`
          button to copy the following line and paste in in a `bash`
          terminal:

``` bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rcqls/Rulia/HEAD/inst/install.sh)"
```

3.  Install the followiwng `julia` packages required for `Rulia` in
    statistic mode: `DataFrames`, `CategoricalArrays`.

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
v_jl        # notice the julia output format 
```

    ## 3-element Vector{Float64}:
    ##  1.0
    ##  3.0
    ##  2.0

``` r
class(v_jl)
```

    ## [1] "Array"   "jlvalue"

``` r
typeof(v_jl)
```

    ## [1] "externalptr"

``` r
jltypeof(v_jl)
```

    ## Vector{Float64} (alias for Array{Float64, 1})

``` r
R(v_jl)     # here the R output format 
```

    ## [1] 1 3 2

``` r
## a potentially useful task is to call a julia fonction applied on an R ao object
jl(sum)(c(1,3,2))           # the result is a julia object (here a jlvalue R object)
```

    ## 6.0

``` r
# and then get the result as an R object
jl(sum)(c(1,3,2)) |> R()    # corresponding in the julia side to `sum([1.0, 3.0, 2.0])`
```

    ## [1] 6

The only thing to do in order to initialize `julia` is to load the
library `Rulia`.

Then, it is pretty direct to:

1.  convert an `R` object to `julia` object (in fact, a `jlvalue`
    external pointer in the `R` side)
2.  apply a `julia` function to the `R` object
3.  and finally convert the `julia` result to an `R` object

</details>
<details>
<summary>
<h1>
<code>Rulia</code> in user-friendly mode
</h1>
</summary>

1.  `Rulia` package when loaded, initializes a `julia` session useable
    inside the current `R` session.
2.  `jl()` is the **only user friendly function** to use in order to:

- execute regular `julia` code inside `R`
- convert `R` object in `julia` object
- call `julia` function returned by `jl()` function itself
- define `julia` variable(s) directly inside the `julia` session

<details>
<summary>
<h2>
<code>jl()</code>: <code>julia</code> code evaluation
</h2>
</summary>

Thanks to the `jl()` function, `Rulia` allows us to execute `julia`
(possibly multilines) expression given with expression between backticks
“\`” (i.e. of class `name` or type `symbol` in the `R` side).

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
</details>
<details>
<summary>
<h2>
<code>jl()</code>: <code>julia</code> converter of <code>R</code>
objects
</h2>
</summary>

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

``` r
jl(2 * sin(1:3))    # this is a R call
```

    ## 3-element Vector{Float64}:
    ##  1.682941969615793
    ##  1.8185948536513634
    ##  0.2822400161197344

``` r
2 * sin(1:3)
```

    ## [1] 1.682942 1.818595 0.282240

</details>
<details>
<summary>
<h2>
<code>jl()</code>: <code>julia</code> function call inside
<code>R</code>
</h2>
</summary>

The main use of the `Rulia` package is to call `julia` function (in
fact, `julia` method because of the implicit **multiple dispatching**
provided by `julia`) inside the `R` system. The more challenging goal of
`Rulia` is to try to provide a `R` syntax to call `julia` function which
as most as possible close to the original `julia` syntax.

Let us start with a simple example.

``` r
## An utility function to fix the seed of Random number in julia
```

``` r
jl_set.seed(12) # to fix the seed 
jl(rand)(`2`)   # julia integer
```

    ## 2-element Vector{Float64}:
    ##  0.32018269515620323
    ##  0.938582363311554

``` r
jl(rand)(2L)    # implicitly converted R integer
```

    ## 2-element Vector{Float64}:
    ##  0.5501748910470424
    ##  0.9475566588373514

Also `jl_set.seed()` is a facility function equivalent to:

``` r
jl_set.seed
```

    ## function (n) 
    ## {
    ##     jlusing(Random)
    ##     invisible(jl(`Random.seed!`)(as.integer(n)))
    ## }
    ## <bytecode: 0x14455b590>
    ## <environment: namespace:Rulia>

``` r
jlusing(Random)
jl(`Random.seed!`)(12L)
```

    ## TaskLocalRNG()

In fact both these lines are user-friendy simplified versions of what
would be necessary to call:

``` r
jl(rand)(jl(`2`))   # julia integer
```

    ## 2-element Vector{Float64}:
    ##  0.32018269515620323
    ##  0.938582363311554

``` r
jl(rand)(jl(2L))    # implicitly converted R integer
```

    ## 2-element Vector{Float64}:
    ##  0.5501748910470424
    ##  0.9475566588373514

The challenging primary goal in `Rulia` is:

    An expression in `Rulia` only need a unique `jl()` call (whenever many `jl()` calls would be normally necessary).

How is a such trick possible?

Let us first observe the result returned when the argument of `jl()` is
an expression of a `julia function`.

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
the metaprogramming provided by `R`, one only needs to provide the
arguments of the `jlfunction` with:

- `R` objects implicitly converted to `jlvalue` objects  
- `julia` expressions given between backticks also implicitly executed
  (for you) in the `julia` side to finally provide `jlvalue` results

The main point is that no need of `jl()` is required whe specifying
arguments of the `jlfunction`.

Notice also that the `rand` `julia` function needs an integer as
argument so:

``` r
jl(rand)(2)    # fails (use summary R generic function to have the complete julia output)
```

    ## Julia Exception: MethodError

`julia` function with keyword-arguments can be called too:

``` r
jl(sum)(1:10)           # an integer
```

    ## 55

``` r
jl(sum)(1:10, init=12)  # a double
```

    ## 67.0

</details>
<details>
<summary>
<h2>
<code>jl()</code>: <code>julia</code> variable(s) from <code>R</code>
</h2>
</summary>

``` r
jl(a=jl(rand)(2L), b=1:3)
jl(a)
```

    ## 2-element Vector{Float64}:
    ##  0.3890321538110373
    ##  0.19961796743719895

``` r
jl(b)
```

    ## 3-element Vector{Int64}:
    ##  1
    ##  2
    ##  3

A special conflict case may happen now if `b` is also a `R` variable.

``` r
jl(b)
```

    ## 3-element Vector{Int64}:
    ##  1
    ##  2
    ##  3

``` r
b <- 10
jl(b)
```

    ## 10.0

``` r
## Also notice that
jl(`b`) # Not a julia variable since jl(`b`) is equivalent to jl(b) in R
```

    ## 10.0

``` r
## To access the b julia variable
jl()$b  # as explained in the next section
```

    ## 3-element Vector{Int64}:
    ##  1
    ##  2
    ##  3

</details>
<details>
<summary>
<h2>
<code>jl()</code>: <code>julia</code> variables environment</code>
</h2>
</summary>

Without any argument, `jl()` returns the list of all `julia` variables
in the `Main` module.

``` r
jl()
```

    ## julia environment:  a, b

It is also possible to access a specific `julia` variable from the
`julia` variables environment `R` object.

``` r
jl()$b  # b variable in Main module
```

    ## 3-element Vector{Int64}:
    ##  1
    ##  2
    ##  3

``` r
jl()$c  # c does not exist and then fails
```

    ## Julia Exception: UndefVarError

</details>
<details>
<summary>
<h2>
Conversion <code>julia</code> to <code>R</code>
</h2>
</summary>

The converse conversion of `jl()` is `R()`

``` r
R(jl(rand)(2L))
```

    ## [1] 0.02964161 0.73343400

``` r
jl(rand)(2L) |> R()
```

    ## [1] 0.4582877 0.6246530

</details>
<details>
<summary>
<h2>
<code>Rulia</code> in the statistic context
</h2>
</summary>

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

``` r
nt_jl$b # suer-friendly access of a julia NamedTuple in the R style
```

    ## 3×2 DataFrame
    ##  Row │ a      b
    ##      │ Int64  Int64
    ## ─────┼──────────────
    ##    1 │     1      2
    ##    2 │     2      3
    ##    3 │     3      4

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

``` r
jl(nt_R$b)
```

    ## 3×2 DataFrame
    ##  Row │ a      b
    ##      │ Int64  Int64
    ## ─────┼──────────────
    ##    1 │     1      2
    ##    2 │     2      3
    ##    3 │     3      4

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

</details>
</details>
<details>
<summary>
<h1>
More details on <code>jl()</code>
</h1>
</summary>
TODO
</details>
<details>
<summary>
<h1>
<code>Rulia</code> in low level mode
</h1>
</summary>
TODO
</details>
<details>
<summary>
<h1>
<code>Rulia</code> utility functions
</h1>
</summary>
TODO
</details>
<details>
<summary>
<h1>
<code>R</code> Finalizers
</h1>
</summary>

Following the documentation on embedding `julia`, a system of preserved
references to `julia` values has been created. An `R` finalizer is
assiocated to each `jlvalue` object (in fact, an `R` external pointer
wrapping some `jl_value_t*` value). Whenever the `jlvalue` is gabarge
collected, the reference on the associated `julia` value is also
dereferenced which is then cleaned up by the `julia` garbage collector.

Since the `julia` session is not persistent when the `R` session is,
what happens if a `jlvalue` object is still in the Workspace
(environment return by `globalenv()` or `.GlobalEnv`).

</details>
