`Rulia`: `julia` for `R`
================

<!-- Rscript -e "rmarkdown::render('README.Rmd')";rm README.html -->

`Rulia` is an attempt to provide an `R` package in order to facilitate
the creation of `R` package for “wrapping” `julia` package. It can also
be viewed as a tool similar to `Rcpp` but using the `julia` language
instead of `C++`.

Also, you can visit [Rencontres R 2024
(Vannes)](https://cqls.dyndoc.fr/Rulia/talk) to have a presentation of
the `Rulia` package.

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
The author thinks that `Rulia` is a funnier name than `jl4R`.

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

2.  In the `julia` console, install `DataFrames.jl`,
    `CategoricalArrays.jl`:

``` bash
# julia mode package (type `]`) and then: add DataFrames, CategoricalArrays
# Optionnally, try to install later RCall.jl which is not mandatory for using Rulia
```

2.  Install `Rulia`

    - From binary (**Windows user only**)

      0.  **NB**: this method can be obsolete if the release is too old
      1.  Donwload
          [Rulia_0.1.0.zip](https://github.com/rcqls/Rulia/releases/download/v0.1.0/Rulia_0.1.0.zip)
          and install it inside R
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

      2.  Bash installation (all Operating Systems): choose one of these
          options

          1.  **remote install** with `remotes` R package and `curl`
              required

          Click the `copy` button to copy the following line and paste
          it in a `bash` terminal:

          ``` bash
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rcqls/Rulia/HEAD/inst/install.sh)"
          ```

          2.  **remote install** with `remotes` R package and `Rscript`
              required

          Click the `copy` button to copy the following lines and paste
          it in a `bash` terminal:

          ``` bash
          export JULIA_DIR=$(julia -e "p=joinpath(splitpath(Sys.BINDIR)[1:end-1]);print(Sys.iswindows() ? replace(p, Base.Filesystem.path_separator => '/') : p)")
          Rscript -e 'remotes::install_github("rcqls/Rulia",force=TRUE,build=FALSE)'
          ```

          3.  **copy of Rulia source from git** (`git` required)

          Click the `copy` button to copy the following lines and paste
          it in a `bash` terminal:

          ``` bash
          # cd <RuliaRootDir> (where <RuliaRootDir> is the root directory of your choice where Rulia source will be copied)
          git clone https://github.com/rcqls/Rulia
          export JULIA_DIR=$(julia -e "p=joinpath(splitpath(Sys.BINDIR)[1:end-1]);print(Sys.iswindows() ? replace(p, Base.Filesystem.path_separator => '/') : p)")
          R CMD INSTALL Rulia
          ```

          To update next time without cloning Rulia repo, click the
          `copy` button to copy the following lines and paste it in a
          `bash` terminal:

          ``` bash
          # cd <RuliaRootDir>/Rulia
          git pull
          export JULIA_DIR=$(julia -e "p=joinpath(splitpath(Sys.BINDIR)[1:end-1]);print(Sys.iswindows() ? replace(p, Base.Filesystem.path_separator => '/') : p)")
          R CMD INSTALL .
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

    ## 1×1 Matrix{String}:
    ##  "one"

``` r
jl(list(a=c(TRUE,FALSE,TRUE), b=1L))
```

    ## (a = Bool[1, 0, 1], b = 1)

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
    ## <bytecode: 0x12f16f588>
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

Also, one can use this syntax to call constructor of a julia struct

``` r
 jl(`struct A;a::Int;b::Vector{Float64};end`)
```

    ## nothing

``` r
 a_jl <- jl(A)(1,1:3)
 a_jl
```

    ## A(1, [1.0, 2.0, 3.0])

``` r
 class(a_jl)
```

    ## [1] "A"       "Struct"  "jlvalue"

``` r
 R(a_jl)
```

    ## $a
    ## [1] 1
    ## 
    ## $b
    ## [1] 1 2 3
    ## 
    ## ## from jl: struct A

</details>

<details>

<summary>

<h2>

<code>jl()</code>: <code>julia</code> variable(s) from <code>R</code>
</h2>

</summary>

``` r
jl(a=jl(rand)(2L), b=1:3, c=`1:3`)
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

``` r
jl(c)
```

    ## 1:3

``` r
jl(collect)(c)
```

    ## 3-element Vector{Int64}:
    ##  1
    ##  2
    ##  3

``` r
jl(`c.start, c.stop`)
```

    ## (1, 3)

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

    ## julia environment:  A, a, b, c

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
jl()$d  # d does not exist and then fails
```

    ## Julia Exception: UndefVarError

</details>

<details>

<summary>

<h2>

<code>R()</code>: <code>R</code> converter of <code>julia</code> objects
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
    ## [1] "String"  "Struct"  "jlvalue"

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

<code>UnsafeArray</code> thanks to <code>RCall.jl</code>
</h1>

</summary>

Conversion of `R` object to `julia` system can be magically avoided
thanks to `RCall.jl`. After installing `RCall.jl` and loading
`jlinclude(Rulia::RCall)`, one can have access to this feature. `R()`
which is usually used for conversion of `julia` object to `R` object is
here exceptionnally used as a “wrapper” of `R` vector into a `jlvalue`
object pointing to a `julia` of type `Array` and `R` class `UnsafeArray`
(since derived from the `unsafe_array()` `julia` function introduced by
`RCall.jl`) sharing the same memory of the original `R` vector. This
feature as illustrated below can be applied to `R` vector of type
`double`, `integer`, `complex` but not `character`. Notice that
`logical` vector is considered in `julia` as a `Vector{Int32}` since it
is the natural representation of `logical` in `R`.

``` r
jlinclude(Rulia::RCall)
zz <- runif(3)
zz
```

    ## [1] 0.7606452 0.1590223 0.2844534

``` r
Rzz <- R(zz) # jlvalue object wrapping the R object zz
Rzz
```

    ## 3-element Vector{Float64}:
    ##  0.7606452165637165
    ##  0.159022253472358
    ##  0.2844533841125667

``` r
class(Rzz)
```

    ## [1] "UnsafeArray" "Array"       "jlvalue"

``` r
jl(typeof)(Rzz)
```

    ## Vector{Float64} (alias for Array{Float64, 1})

``` r
Rzz[1] <- 2
Rzz
```

    ## 3-element Vector{Float64}:
    ##  2.0
    ##  0.159022253472358
    ##  0.2844533841125667

``` r
## and magically (no conversion)
zz
```

    ## [1] 2.0000000 0.1590223 0.2844534

`Rzz` is viewed in the `julia` side as a true `Vector{Float64}` pointing
exactly to address of `zz` which is an `R` vector.  
Modifying `Rzz` directly modifies `zz`.

These features also apply for `factor` (the `levels` part being copied
in the `julia` side) and for `data.frame` (containing exclusively
variables accepting this “wrapping” mode).

``` r
jlinclude(Rulia::RCall)
fa <- factor(c("toto", "titi", "toto"))
fa
```

    ## [1] toto titi toto
    ## Levels: titi toto

``` r
Rfa <- R(fa) # this is a jlvalue object wrapping fa
Rfa
```

    ## 3-element CategoricalArray{String,1,Int32}:
    ##  "toto"
    ##  "titi"
    ##  "toto"

``` r
class(Rfa)
```

    ## [1] "UnsafeCategoricalArray" "UnsafeArray"            "CategoricalArray"      
    ## [4] "jlvalue"

``` r
jl(typeof)(Rfa)
```

    ## CategoricalVector{String, Int32, String, CategoricalValue{String, Int32}, Union{}} (alias for CategoricalArray{String, 1, Int32, String, CategoricalValue{String, Int32}, Union{}})

``` r
Rfa[1] <- "titi"
Rfa
```

    ## 3-element CategoricalArray{String,1,Int32}:
    ##  "titi"
    ##  "titi"
    ##  "toto"

``` r
## and magically (no conversion)
fa
```

    ## [1] titi titi toto
    ## Levels: titi toto

The main use of this feature is rarely to define `Rzz` and `Rfa` but to
directly use `R(zz)` and `R(fa)` as argument(s) of a `julia` function.

``` r
jl(`
function f(x)
    x .= x .+ 2 
end
`)
```

    ## f (generic function with 1 method)

``` r
jl(f)(R(zz))
```

    ## 3-element Vector{Float64}:
    ##  4.0
    ##  2.159022253472358
    ##  2.2844533841125667

``` r
## and the magic part
zz
```

    ## [1] 4.000000 2.159022 2.284453

Important to notice that no change of dimension has to be done in the
`julia` side. The `julia` wrapper can only read or update value(s).

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

<details>

<summary>

<h2>

safe <code>jleval</code> mode
</h2>

</summary>

In `Rulia`, `jl` mode offers a way to call a **safe** low level mode
called `jleval` mode that relies mainly to three main functions:

- `jlvalue()` to convert `R` object to `jlvalue` wrapper of a `julia`
  object (as already seen previously)
- `jleval()` to evaluate a `julia` expression as its character argument
- `jlcall()` to call function by its name given as a character and safe
  since protected by a try/catch \`\`

In fact, `jl` mode uses the metaprogramming and lazziness offered by `R`
to avoid the use of quote in order to write `julia` code as expressed in
the foolowing example.

``` r
jleval("[1,3,4]")   # jl(`[1,2,3]`)
```

    ## 3-element Vector{Int64}:
    ##  1
    ##  3
    ##  4

``` r
jleval("VERSION")   # jl(VERSION)
```

    ## v"1.12.2"

``` r
jleval("            
f(x,y) = x + y
(f(2,3), f(1.0,3))
")
```

    ## (5, 4.0)

``` r
## jlvalue() is faster than jl() here
jlvalue(TRUE)       # jl(TRUE)
```

    ## true

``` r
jlvalue(1L)         # jl(1L)
```

    ## 1

``` r
jlvalue(1)          # jl(1)
```

    ## 1.0

``` r
jlvalue("1.0")      # jl("1.0") 
```

    ## "1.0"

``` r
jlvalue(c(TRUE, 1L, 1, "1.0"))      # jl(c(TRUE, 1L, 1, "1.0"))
```

    ## 4-element Vector{String}:
    ##  "TRUE"
    ##  "1"
    ##  "1"
    ##  "1.0"

``` r
jlvalue(list(TRUE, 1L, 1, "1.0"))   # jl(list(TRUE, 1L, 1, "1.0"))
```

    ## (true, 1, 1.0, "1.0")

``` r
jleval('a =[true, 1, 1.0, "1.0"]')  # jl(`a =[true, 1, 1.0, "1.0"]`)
```

    ## 4-element Vector{Any}:
    ##  true
    ##     1
    ##     1.0
    ##      "1.0"

``` r
jleval('a')                         # jl(a)
```

    ## 4-element Vector{Any}:
    ##  true
    ##     1
    ##     1.0
    ##      "1.0"

``` r
jleval('b = (true, 1, 1.0, "1.0")') # jl(`b = (true, 1, 1.0, "1.0")`)
```

    ## (true, 1, 1.0, "1.0")

``` r
jleval('b')                         # jl(b)
```

    ## (true, 1, 1.0, "1.0")

``` r
## error below don't crash
jleval('b = (true, 1, 1.0, "1.0"')  # jl(`b = (true, 1, 1.0, "1.0"`)
```

    ## Julia Exception: Base.Meta.ParseError

``` r
jleval("sum")                       # jl(sum)
```

    ## sum (generic function with 15 methods)

``` r
jleval("typeof(sum)")               # jl(typeof)(sum)
```

    ## typeof(sum) (singleton type of function sum, subtype of Function)

``` r
jlcall("sum", jleval("[1,3,2]"))    # jl(sum)(`[1,3,2]`)
```

    ## 6

``` r
jlcall("sum", c(1, 3, 2), init = 4) # jl(sum)(c(1,3,2), init=4)
```

    ## 10.0

``` r
jlcall("isa", jleval("sum"), jleval("Function"))    # jl(isa)(sum, Function)
```

    ## true

``` r
jlfunc(jleval("sum"), c(1,3,2), init = 4)           # in fact it is what jl(isa) does
```

    ## 10.0

``` r
jleval("sum isa Function")                          # jl(`sum isa Function`)
```

    ## true

The bad part of this safe low level mode is the performance issue.
Indeed, these functions are not the most efficient since they are not as
closed as the `julia C API`. An unsafe low level mode, called
`jlvalue_eval` mode, naturally exists in `Rulia` that express the
closest as possible the `julia C API`.
</details>

<details>

<summary>

<h2>

unsafe <code>jlvalue_eval</code> mode
</h2>

</summary>

As expressed before, this mode is **unsafe** and the user should be sure
that the `julia` expression is correct. One can think of using this mode
in some development package where efficiency really matters.

`jleval()` and `jlcall()` functions are then replaced by
`jlvalue_eval()` and `jlvalue_call()` functions respectively.

``` r
jlvalue_eval("[1,3,4]")
```

    ## 3-element Vector{Int64}:
    ##  1
    ##  3
    ##  4

``` r
jlvalue_eval("VERSION")
```

    ## v"1.12.2"

``` r
jlvalue_eval("
f(x,y) = x + y
(f(2,3), f(1.0,3))
")
```

    ## (5, 4.0)

``` r
jlvalue_eval('a = [true, 1, 1.0, "1.0"]')
```

    ## 4-element Vector{Any}:
    ##  true
    ##     1
    ##     1.0
    ##      "1.0"

``` r
jlvalue_eval('a')
```

    ## 4-element Vector{Any}:
    ##  true
    ##     1
    ##     1.0
    ##      "1.0"

``` r
jlvalue_eval('b = (true, 1, 1.0, "1.0")')
```

    ## (true, 1, 1.0, "1.0")

``` r
jlvalue_eval('b')
```

    ## (true, 1, 1.0, "1.0")

``` r
## error below would crash badly
# jlvalue_eval('b = (true, 1, 1.0, "1.0"')

jlvalue_eval("sum")
```

    ## sum (generic function with 15 methods)

``` r
jlvalue_eval("typeof(sum)")
```

    ## typeof(sum) (singleton type of function sum, subtype of Function)

``` r
jlvalue_call("sum",jlvalue_eval("[1,3,2]"))
```

    ## 6

``` r
jlvalue_func(jlvalue_eval("sum"),jlvalue_eval("[1,3,2]"))
```

    ## 6

``` r
## Notice that this is not possible: jlvalue_call("sum", jlvalue([1,3,2]), init=4)")
```

Also, in this mode

</details>

</details>

<details>

<summary>

<h1>

Pure <code>R</code> package made with <code>Rulia</code>
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

<details>

<summary>

<h1>

Benchmark <code>Rcpp</code> vs <code>Rulia</code>
</h1>

</summary>

see all the R functions in the file `inst/microbenchmark/RcppVsRulia.R`.

``` r
summary_mbs <- round(sapply(1:6, function(i) sapply(1:28, function(k) mean((mbs[[i]][mbs[[i]]$expr == levels(mbs[[i]]$expr)[3],]$time)) / mean((mbs[[i]][mbs[[i]]$expr == levels(mbs[[i]]$expr)[k],]$time)))),2)
rownames(summary_mbs) <- levels(mbs[[1]]$expr)
colnames(summary_mbs)<- names(mbs)
summary_mbs
```

    ##                                   n=1000 n=10000 n=1e+05 n=1e+06 n=1e+07 n=1e+08
    ## sum(x)                             24.20   19.98   19.03   18.22   19.09   19.08
    ## sumC(x)                             4.46   16.75   18.43   18.17   19.09   18.92
    ## sumR(x)                             1.00    1.00    1.00    1.00    1.00    1.00
    ## R(sumJL(x))                         0.02    0.24    1.39    3.00    5.36    5.56
    ## R(sumJL(x_jl))                      0.04    0.26    2.40   18.60   90.01  143.52
    ## R(sumJL(jl_x))                      0.04    0.24    2.33   17.15   89.30  149.30
    ## R(sumJL(R(x)))                      0.02    0.12    1.05    9.78   59.83  134.34
    ## R(sumJLCall(x_jl))                  0.03    0.21    1.97   16.56   82.34  134.87
    ## R(sumJLCall(jl_x))                  0.04    0.20    1.97   16.28   82.26  144.97
    ## R(sumJLCall(R(x)))                  0.02    0.11    0.93    8.41   58.06  137.32
    ## R(sumJLFuncClosure(x_jl))           0.04    0.23    2.30   18.90   85.17  137.78
    ## R(sumJLFuncClosure(jl_x))           0.04    0.25    2.27   19.27   86.35  145.49
    ## R(sumJLFuncClosure(R(x)))           0.02    0.11    1.07    8.81   58.17  139.36
    ## R(sumJLValueCall(x_jl))             2.83   15.44   81.25  139.73  162.55  135.90
    ## R(sumJLValueCall(jl_x))             2.78   15.34   81.62  139.40  165.85  160.08
    ## R(sumJLValueCall(R(x)))             0.03    0.19    1.77   16.18   80.35  142.11
    ## R(sumJLValueFunc(x_jl))             0.94    3.92   34.38  116.35  157.71  155.00
    ## R(sumJLValueFunc(jl_x))             0.94    5.63   40.95  117.32  158.35  152.66
    ## R(sumJLValueFunc(R(x)))             0.03    0.18    1.79   15.62   82.89  144.02
    ## R(sumJLValueFuncClosure(x_jl))      2.75   14.84   47.44  139.68  164.06  157.56
    ## R(sumJLValueFuncClosure(jl_x))      2.74   15.00   79.47  138.81  166.86  149.15
    ## R(sumJLValueFuncClosure(R(x)))      0.03    0.20    1.89   15.92   78.08  145.07
    ## R(sommeJLValueFuncClosure(x_jl))    2.55    9.17   16.45   18.62   18.99   18.83
    ## R(sommeJLValueFuncClosure(jl_x))    2.50    9.06   16.39   17.83   19.04   19.10
    ## R(sommeJLValueFuncClosure(R(x)))    0.03    0.20    1.73    9.03   17.12   18.81
    ## R(somme2JLValueFuncClosure(x_jl))   2.48    8.95   16.63   18.50   19.04   18.81
    ## R(somme2JLValueFuncClosure(jl_x))   2.55    9.08   16.55   17.95   19.03   18.89
    ## R(somme2JLValueFuncClosure(R(x)))   0.03    0.20    1.75    9.18   17.10   18.77

``` r
mbs[["n=1000"]]
```

    ## Unit: microseconds
    ##                               expr      min        lq       mean    median        uq        max neval
    ##                             sum(x)    1.681    1.8860    2.11683    2.0500    2.1730      9.020   100
    ##                            sumC(x)    2.255    3.5465   11.48123    5.4530    5.9860    647.144   100
    ##                            sumR(x)   29.438   30.3195   51.22786   30.6065   30.8730   2034.912   100
    ##                        R(sumJL(x)) 1140.661 1179.9595 2368.20182 1196.9745 1320.4665 108805.144   100
    ##                     R(sumJL(x_jl)) 1134.429 1168.0900 1320.66576 1190.0455 1308.3100   5803.345   100
    ##                     R(sumJL(jl_x)) 1131.026 1170.1195 1240.75020 1193.9610 1298.9005   1834.955   100
    ##                     R(sumJL(R(x))) 2476.769 2553.8080 2882.92115 2591.0360 2864.8545   7711.321   100
    ##                 R(sumJLCall(x_jl)) 1359.109 1400.9085 1866.81036 1425.2625 1555.1710  34400.517   100
    ##                 R(sumJLCall(jl_x)) 1363.988 1397.5875 1461.18055 1416.8780 1449.2270   2098.134   100
    ##                 R(sumJLCall(R(x))) 2750.280 2822.8705 3144.01735 2866.2280 3163.4370  20148.630   100
    ##          R(sumJLFuncClosure(x_jl)) 1137.135 1175.9825 1275.63054 1197.5075 1315.8130   4423.613   100
    ##          R(sumJLFuncClosure(jl_x)) 1138.529 1170.4885 1256.53520 1188.5490 1211.5910   4542.267   100
    ##          R(sumJLFuncClosure(R(x))) 2516.744 2584.2710 2885.77475 2625.7425 2911.9225   7765.974   100
    ##            R(sumJLValueCall(x_jl))   16.072   17.3430   18.09863   17.8350   18.7165     25.338   100
    ##            R(sumJLValueCall(jl_x))   15.744   16.9945   18.42253   17.7120   19.1880     28.864   100
    ##            R(sumJLValueCall(R(x))) 1373.459 1416.1810 1598.93563 1443.7535 1464.9710   6763.688   100
    ##            R(sumJLValueFunc(x_jl))   48.052   51.0655   54.42750   52.5005   59.2450     67.240   100
    ##            R(sumJLValueFunc(jl_x))   47.970   50.9835   54.43365   52.6850   58.2200     73.062   100
    ##            R(sumJLValueFunc(R(x))) 1424.955 1468.7430 1722.22919 1495.1470 1644.1410   6306.825   100
    ##     R(sumJLValueFuncClosure(x_jl))   16.072   17.5070   18.62384   18.1425   19.4750     31.775   100
    ##     R(sumJLValueFuncClosure(jl_x))   16.113   17.4250   18.70338   18.4705   19.8235     26.732   100
    ##     R(sumJLValueFuncClosure(R(x))) 1380.839 1423.4790 1624.19368 1444.9835 1607.3435  13495.273   100
    ##   R(sommeJLValueFuncClosure(x_jl))   17.179   18.4705   20.09369   19.8030   21.0125     30.914   100
    ##   R(sommeJLValueFuncClosure(jl_x))   16.851   18.9420   20.51353   19.9875   21.2995     41.902   100
    ##   R(sommeJLValueFuncClosure(R(x))) 1385.062 1421.8390 1515.62322 1446.7260 1577.3725   3037.444   100
    ##  R(somme2JLValueFuncClosure(x_jl))   16.892   18.7985   20.66359   19.9055   21.4020     49.036   100
    ##  R(somme2JLValueFuncClosure(jl_x))   16.892   18.8190   20.09533   19.5570   20.9715     33.579   100
    ##  R(somme2JLValueFuncClosure(R(x))) 1367.555 1423.9095 1696.44716 1460.0510 1607.0360  14673.367   100

``` r
mbs[["n=10000"]]
```

    ## Unit: microseconds
    ##                               expr      min        lq       mean    median        uq       max neval
    ##                             sum(x)   15.211   15.5390   15.70751   15.6210   15.7235    22.591   100
    ##                            sumC(x)   15.867   17.1995   18.74028   19.2700   19.8235    23.288   100
    ##                            sumR(x)  289.132  290.1570  313.89518  290.5260  292.6375  2429.496   100
    ##                        R(sumJL(x)) 1163.047 1192.2595 1291.05843 1218.7865 1325.3250  3576.635   100
    ##                     R(sumJL(x_jl)) 1126.598 1156.4665 1221.67946 1179.7750 1296.4815  1768.125   100
    ##                     R(sumJL(jl_x)) 1131.723 1161.8990 1297.52905 1179.0985 1310.8520  3876.386   100
    ##                     R(sumJL(R(x))) 2445.199 2524.4725 2729.42781 2562.7665 2812.2310  6051.600   100
    ##                 R(sumJLCall(x_jl)) 1350.007 1382.4175 1524.69406 1407.1610 1543.4245  5010.897   100
    ##                 R(sumJLCall(jl_x)) 1336.764 1388.1165 1580.35484 1413.5160 1553.4900  4252.848   100
    ##                 R(sumJLCall(R(x))) 2674.922 2755.1385 2964.44883 2795.5850 3061.1420  7255.770   100
    ##          R(sumJLFuncClosure(x_jl)) 1134.634 1161.6325 1347.04393 1183.8955 1310.6675  5130.986   100
    ##          R(sumJLFuncClosure(jl_x)) 1131.108 1164.9740 1243.01340 1184.4285 1272.8860  2958.232   100
    ##          R(sumJLFuncClosure(R(x))) 2505.059 2559.8965 2807.08837 2613.9345 2904.7475  7745.351   100
    ##            R(sumJLValueCall(x_jl))   18.245   19.1880   20.33477   19.9465   21.4430    24.723   100
    ##            R(sumJLValueCall(jl_x))   17.876   19.2905   20.46720   20.2130   21.4225    26.322   100
    ##            R(sumJLValueCall(R(x))) 1362.102 1400.8675 1676.62735 1426.3285 1583.1945 19075.824   100
    ##            R(sumJLValueFunc(x_jl))   50.553   52.7260   79.98731   54.6735   60.9875  2398.664   100
    ##            R(sumJLValueFunc(jl_x))   50.266   52.2955   55.77845   54.2225   58.4865    68.716   100
    ##            R(sumJLValueFunc(R(x))) 1392.032 1442.8515 1780.65296 1472.0025 1631.5130 17202.493   100
    ##     R(sumJLValueFuncClosure(x_jl))   18.122   19.5160   21.14698   20.2540   21.8120    35.137   100
    ##     R(sumJLValueFuncClosure(jl_x))   18.614   19.7415   20.92968   20.4180   21.8530    27.306   100
    ##     R(sumJLValueFuncClosure(R(x))) 1365.464 1401.3800 1546.20594 1430.2030 1592.8910  6269.638   100
    ##   R(sommeJLValueFuncClosure(x_jl))   31.898   33.1280   34.22721   33.7430   35.1985    39.401   100
    ##   R(sommeJLValueFuncClosure(jl_x))   31.857   33.2100   34.65402   34.3170   35.7520    46.248   100
    ##   R(sommeJLValueFuncClosure(R(x))) 1378.174 1419.5430 1548.60075 1446.4800 1585.8185  5685.265   100
    ##  R(somme2JLValueFuncClosure(x_jl))   31.734   33.3535   35.07058   34.3990   35.4855    87.043   100
    ##  R(somme2JLValueFuncClosure(jl_x))   31.693   33.1485   34.58227   34.1325   35.7725    56.170   100
    ##  R(somme2JLValueFuncClosure(R(x))) 1374.853 1420.9780 1589.16123 1456.0945 1611.0950  4861.001   100

``` r
mbs[["n=1e+05"]]
```

    ## Unit: microseconds
    ##                               expr      min        lq       mean    median        uq       max neval
    ##                             sum(x)  151.167  151.3720  152.24366  151.4950  151.6590   166.132   100
    ##                            sumC(x)  151.864  152.9300  157.20384  155.5130  162.2370   175.972   100
    ##                            sumR(x) 2886.728 2889.8235 2897.03335 2892.0375 2902.7590  2933.099   100
    ##                        R(sumJL(x)) 1413.065 1485.5120 2083.35104 1509.8455 1571.5710 40881.633   100
    ##                     R(sumJL(x_jl)) 1143.818 1170.1605 1209.16421 1179.4060 1194.1865  1746.887   100
    ##                     R(sumJL(jl_x)) 1148.123 1171.1855 1241.66081 1182.5015 1199.2705  3252.653   100
    ##                     R(sumJL(R(x))) 2470.824 2529.9050 2750.04015 2559.3020 2632.8150  6211.049   100
    ##                 R(sumJLCall(x_jl)) 1370.589 1397.4440 1473.77575 1410.6665 1422.4745  3711.730   100
    ##                 R(sumJLCall(jl_x)) 1367.883 1397.0750 1474.09965 1410.4615 1437.7675  3740.061   100
    ##                 R(sumJLCall(R(x))) 2723.548 2778.3650 3102.23466 2809.4840 2847.3475  9945.042   100
    ##          R(sumJLFuncClosure(x_jl)) 1149.435 1174.0350 1260.82380 1185.6380 1203.5550  5576.041   100
    ##          R(sumJLFuncClosure(jl_x)) 1150.132 1176.2695 1276.35911 1190.3120 1208.7620  5974.110   100
    ##          R(sumJLFuncClosure(R(x))) 2501.164 2558.5640 2701.68762 2585.7060 2621.1095  5941.474   100
    ##            R(sumJLValueCall(x_jl))   33.169   34.4810   35.65565   35.0140   35.8955    49.282   100
    ##            R(sumJLValueCall(jl_x))   33.620   34.5630   35.49247   35.0755   35.7930    47.601   100
    ##            R(sumJLValueCall(R(x))) 1387.522 1418.6205 1632.68683 1434.0160 1451.8510 15875.118   100
    ##            R(sumJLValueFunc(x_jl))   66.174   67.5885   84.27345   68.6135   71.0735  1485.553   100
    ##            R(sumJLValueFunc(jl_x))   65.436   68.1215   70.75288   69.3310   71.6475    97.416   100
    ##            R(sumJLValueFunc(R(x))) 1419.666 1454.0240 1621.94975 1471.1620 1496.5205  6110.845   100
    ##     R(sumJLValueFuncClosure(x_jl))   33.415   34.9935   61.07319   35.6085   36.8590  2518.794   100
    ##     R(sumJLValueFuncClosure(jl_x))   33.907   35.0345   36.45638   35.8340   36.8385    53.915   100
    ##     R(sumJLValueFuncClosure(R(x))) 1395.025 1420.3630 1534.49224 1433.9955 1451.5435  6257.215   100
    ##   R(sommeJLValueFuncClosure(x_jl))  168.018  169.9245  176.10402  173.3070  181.9990   197.743   100
    ##   R(sommeJLValueFuncClosure(jl_x))  167.526  170.2525  176.74485  175.6645  181.7120   206.025   100
    ##   R(sommeJLValueFuncClosure(R(x))) 1523.724 1559.9885 1677.56584 1578.8075 1629.4425  5244.105   100
    ##  R(somme2JLValueFuncClosure(x_jl))  167.690  169.4940  174.21269  171.5645  176.9355   198.317   100
    ##  R(somme2JLValueFuncClosure(jl_x))  167.772  169.7605  175.01096  172.0155  180.7690   196.472   100
    ##  R(somme2JLValueFuncClosure(R(x))) 1524.954 1555.2120 1652.67597 1571.3865 1601.4600  6254.345   100

``` r
mbs[["n=1e+06"]]
```

    ## Unit: microseconds
    ##                               expr       min         lq       mean     median         uq        max neval
    ##                             sum(x)  1512.203  1520.1775  1589.6172  1570.6280  1652.5255   1748.691   100
    ##                            sumC(x)  1515.032  1519.2140  1593.8582  1579.4635  1666.3220   1740.819   100
    ##                            sumR(x) 28877.161 28908.9770 28962.7842 28937.9025 28983.3920  29292.409   100
    ##                        R(sumJL(x))  4098.073  4618.3015  9666.6885  4829.2055  5445.9275 111578.384   100
    ##                     R(sumJL(x_jl))  1355.542  1396.7265  1557.3682  1444.5735  1562.7355   6393.417   100
    ##                     R(sumJL(jl_x))  1366.530  1411.4455  1688.9319  1467.7795  1563.2480  15280.946   100
    ##                     R(sumJL(R(x)))  2698.948  2783.2235  2962.3168  2845.1540  3098.5955   5810.643   100
    ##                 R(sumJLCall(x_jl))  1586.618  1635.8385  1749.3257  1690.1225  1817.0585   3208.332   100
    ##                 R(sumJLCall(jl_x))  1580.181  1631.5540  1779.5734  1673.9685  1805.3735   4018.902   100
    ##                 R(sumJLCall(R(x)))  2962.783  3062.1875  3445.0549  3124.7740  3465.3815   8298.236   100
    ##          R(sumJLFuncClosure(x_jl))  1362.963  1409.0675  1532.7936  1466.8980  1560.0295   4535.379   100
    ##          R(sumJLFuncClosure(jl_x))  1360.585  1409.4365  1503.0620  1462.0600  1568.1885   2127.326   100
    ##          R(sumJLFuncClosure(R(x)))  2734.618  2849.0080  3288.5108  2919.3230  3245.6010  19214.363   100
    ##            R(sumJLValueCall(x_jl))   194.873   199.9365   207.2710   205.1435   210.4120    295.610   100
    ##            R(sumJLValueCall(jl_x))   195.857   202.8065   207.7712   207.4805   210.4735    258.628   100
    ##            R(sumJLValueCall(R(x)))  1601.091  1670.7090  1790.0846  1736.9650  1838.1735   4387.779   100
    ##            R(sumJLValueFunc(x_jl))   228.083   234.2535   248.9360   241.7770   251.4325    731.071   100
    ##            R(sumJLValueFunc(jl_x))   232.757   241.2235   246.8610   244.7085   250.5715    298.439   100
    ##            R(sumJLValueFunc(R(x)))  1628.930  1701.1105  1853.7834  1743.9145  1904.6960   4540.135   100
    ##     R(sumJLValueFuncClosure(x_jl))   195.160   200.6130   207.3456   205.4920   211.0065    271.297   100
    ##     R(sumJLValueFuncClosure(jl_x))   198.440   204.7745   208.6556   207.6855   211.9085    243.499   100
    ##     R(sumJLValueFuncClosure(R(x)))  1592.522  1651.4800  1819.5201  1715.9115  1837.8045   6499.853   100
    ##   R(sommeJLValueFuncClosure(x_jl))  1532.006  1536.3930  1555.0812  1541.6615  1556.9750   1671.119   100
    ##   R(sommeJLValueFuncClosure(jl_x))  1529.792  1538.4430  1624.0666  1631.7795  1689.7535   1792.274   100
    ##   R(sommeJLValueFuncClosure(R(x)))  2942.734  3017.7230  3205.7551  3072.6630  3182.3995   7528.625   100
    ##  R(somme2JLValueFuncClosure(x_jl))  1529.751  1536.4955  1565.1361  1546.4585  1575.2405   1715.522   100
    ##  R(somme2JLValueFuncClosure(jl_x))  1531.186  1539.4885  1613.0827  1619.9305  1671.5085   1743.156   100
    ##  R(somme2JLValueFuncClosure(R(x)))  2923.013  3004.9105  3153.5121  3054.3975  3158.5580   6665.493   100

``` r
mbs[["n=1e+07"]]
```

    ## Unit: milliseconds
    ##                               expr        min         lq       mean     median         uq        max neval
    ##                             sum(x)  15.114404  15.137631  15.158342  15.145728  15.172726  15.280618   100
    ##                            sumC(x)  15.121210  15.133653  15.155279  15.143432  15.165183  15.448021   100
    ##                            sumR(x) 288.793381 289.091082 289.343586 289.269432 289.462993 295.478759   100
    ##                        R(sumJL(x))  33.875553  34.444817  53.992101  37.089010  42.775976 156.465061   100
    ##                     R(sumJL(x_jl))   2.995009   3.080453   3.214442   3.144372   3.278258   4.388189   100
    ##                     R(sumJL(jl_x))   2.968851   3.079695   3.240033   3.131683   3.237278   5.042918   100
    ##                     R(sumJL(R(x)))   4.361539   4.503789   4.836238   4.593825   4.906122   9.427540   100
    ##                 R(sumJLCall(x_jl))   3.212104   3.317125   3.513957   3.364275   3.497218   7.626943   100
    ##                 R(sumJLCall(jl_x))   3.211735   3.323788   3.517376   3.397649   3.562613   7.171105   100
    ##                 R(sumJLCall(R(x)))   4.587941   4.779411   4.983242   4.850874   5.129100   7.589674   100
    ##          R(sumJLFuncClosure(x_jl))   2.986645   3.085311   3.397052   3.128772   3.239840  22.249552   100
    ##          R(sumJLFuncClosure(jl_x))   3.013459   3.089780   3.350821   3.141666   3.237360  17.654764   100
    ##          R(sumJLFuncClosure(R(x)))   4.431772   4.575088   4.974136   4.658789   4.988532   9.668866   100
    ##            R(sumJLValueCall(x_jl))   1.702853   1.712447   1.779991   1.723578   1.751848   2.559138   100
    ##            R(sumJLValueCall(jl_x))   1.698794   1.709249   1.744610   1.718043   1.732025   2.529372   100
    ##            R(sumJLValueCall(R(x)))   3.182871   3.308680   3.600990   3.368519   3.551112   7.423583   100
    ##            R(sumJLValueFunc(x_jl))   1.742131   1.765460   1.834631   1.776366   1.807383   2.825679   100
    ##            R(sumJLValueFunc(jl_x))   1.746436   1.761586   1.827297   1.771713   1.799265   2.913583   100
    ##            R(sumJLValueFunc(R(x)))   3.251136   3.344411   3.490549   3.397486   3.531720   7.433833   100
    ##     R(sumJLValueFuncClosure(x_jl))   1.702607   1.713595   1.763622   1.720688   1.731020   2.698825   100
    ##     R(sumJLValueFuncClosure(jl_x))   1.700270   1.709639   1.734056   1.716875   1.727412   2.568322   100
    ##     R(sumJLValueFuncClosure(R(x)))   3.219115   3.296851   3.705851   3.363702   3.555315  17.633977   100
    ##   R(sommeJLValueFuncClosure(x_jl))  15.162907  15.180763  15.234693  15.199172  15.223895  16.624475   100
    ##   R(sommeJLValueFuncClosure(jl_x))  15.163973  15.178999  15.199078  15.192673  15.209135  15.333754   100
    ##   R(sommeJLValueFuncClosure(R(x)))  16.659899  16.762542  16.899443  16.829209  16.950302  19.031872   100
    ##  R(somme2JLValueFuncClosure(x_jl))  15.165572  15.178877  15.197637  15.191115  15.211164  15.277215   100
    ##  R(somme2JLValueFuncClosure(jl_x))  15.160447  15.181111  15.201870  15.191873  15.213973  15.360814   100
    ##  R(somme2JLValueFuncClosure(R(x)))  16.681014  16.776441  16.920643  16.837244  16.983778  21.337671   100

``` r
mbs[["n=1e+08"]]
```

    ## Unit: milliseconds
    ##                               expr        min         lq       mean     median         uq        max neval
    ##                             sum(x)  151.26556  151.54516  152.92796  151.76138  152.38216  178.99062   100
    ##                            sumC(x)  151.20419  151.58446  154.26420  152.02287  152.82022  187.53257   100
    ##                            sumR(x) 2891.05125 2893.68117 2917.91148 2901.65571 2913.18218 3115.43248   100
    ##                        R(sumJL(x))  365.29955  379.19578  524.62787  422.43725  580.18426 1597.48132   100
    ##                     R(sumJL(x_jl))   17.89076   18.13022   20.33173   18.65875   20.37460   57.57659   100
    ##                     R(sumJL(jl_x))   17.83516   18.23422   19.54447   18.81787   20.15349   41.30746   100
    ##                     R(sumJL(R(x)))   19.31063   19.75565   21.71982   20.15062   21.21641   88.20888   100
    ##                 R(sumJLCall(x_jl))   18.17788   18.58907   21.63518   19.37957   20.54444   93.86696   100
    ##                 R(sumJLCall(jl_x))   18.10396   18.43897   20.12777   19.02794   20.29748   58.03595   100
    ##                 R(sumJLCall(R(x)))   19.61907   20.02040   21.24900   20.77263   22.21261   25.55161   100
    ##          R(sumJLFuncClosure(x_jl))   17.91130   18.23934   21.17754   19.27861   20.71914   76.02712   100
    ##          R(sumJLFuncClosure(jl_x))   17.87813   18.19430   20.05614   19.02874   20.45867   41.93189   100
    ##          R(sumJLFuncClosure(R(x)))   19.39743   19.79378   20.93829   20.33061   21.64263   28.41255   100
    ##            R(sumJLValueCall(x_jl))   16.53177   16.66484   21.47105   17.29523   18.85555  167.80168   100
    ##            R(sumJLValueCall(jl_x))   16.53046   16.66777   18.22738   17.24774   18.49602   38.56349   100
    ##            R(sumJLValueCall(R(x)))   18.15435   18.43825   20.53322   19.31783   20.38875   65.16565   100
    ##            R(sumJLValueFunc(x_jl))   16.59290   16.74479   18.82509   17.18238   18.77640   86.21845   100
    ##            R(sumJLValueFunc(jl_x))   16.59209   16.73001   19.11342   17.15493   18.86537   74.20787   100
    ##            R(sumJLValueFunc(R(x)))   18.11815   18.44223   20.26108   19.07658   20.55529   54.80023   100
    ##     R(sumJLValueFuncClosure(x_jl))   16.55752   16.71873   18.51995   17.39363   18.90129   45.48630   100
    ##     R(sumJLValueFuncClosure(jl_x))   16.54740   16.74381   19.56353   17.30553   18.75229  106.71074   100
    ##     R(sumJLValueFuncClosure(R(x)))   18.09441   18.48196   20.11367   19.36432   20.88895   38.77567   100
    ##   R(sommeJLValueFuncClosure(x_jl))  151.14753  151.40255  154.99534  151.89465  152.51244  277.43679   100
    ##   R(sommeJLValueFuncClosure(jl_x))  151.17586  151.37944  152.75353  151.59352  152.14397  182.10790   100
    ##   R(sommeJLValueFuncClosure(R(x)))  152.72939  153.16462  155.13524  153.46843  154.20612  193.48322   100
    ##  R(somme2JLValueFuncClosure(x_jl))  151.24203  151.47352  155.15088  151.86015  152.37244  298.11067   100
    ##  R(somme2JLValueFuncClosure(jl_x))  151.17549  151.43748  154.47607  151.83419  152.35118  247.90834   100
    ##  R(somme2JLValueFuncClosure(R(x)))  152.82377  153.12908  155.42128  153.55277  154.45852  223.68460   100

</details>
