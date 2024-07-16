`Rulia`: `julia` for `R`
================

<!-- Rscript -e "rmarkdown::render('README.Rmd')";rm README.html -->

`Rulia` is an attempt to provide an `R` package in order to facilitate
the creation of `R` package for “wrapping” `julia` package. It can also
be viewed as a tool similar to `Rcpp` but using the `julia` language
instead of `C++`.

Also, you can visit to [Rencontres R 2024
(Vannes)](https://cqls.dyndoc.fr/talk/Rulia) to have a presentation of
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
    ## <bytecode: 0x124a367b0>
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
<code>UnsafeArray</code> thanks to <code>RCall.jl</code>
</h1>
</summary>

Conversion of `R` object to `julia` system can be magically avoided
thanks to `RCall.jl`. After installing `RCall.jl` and loading
`jlinclude(Rulia::RCall)`, one can have access to this feature. `R()`
which is usually used for conversion of `julia` object to `R` object is
here exceptionnaly used as a “wrapper” of `R` vector into a `jlvalue`
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

    ## [1] 0.1811532 0.9403991 0.1423605

``` r
Rzz <- R(zz) # this is a jlvalue object wrapping zz
Rzz
```

    ## 3-element Vector{Float64}:
    ##  0.18115319311618805
    ##  0.9403990821447223
    ##  0.14236049889586866

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
    ##  0.9403990821447223
    ##  0.14236049889586866

``` r
## and magically (no conversion)
zz
```

    ## [1] 2.0000000 0.9403991 0.1423605

`Rzz` is the viewed in the `julia` side as a true `Vector{Float64}`
pointing exactly to address of the `zz` vector.  
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
    ##  2.9403990821447223
    ##  2.1423604988958687

``` r
## and the magic part
zz
```

    ## [1] 4.000000 2.940399 2.142360

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

    ## v"1.10.4"

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

    ## sum (generic function with 17 methods)

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

    ## v"1.10.4"

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

    ## sum (generic function with 17 methods)

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

``` r
summary_mbs <- round(sapply(1:6, function(i) sapply(1:28, function(k) mean((mbs[[i]][mbs[[i]]$expr == levels(mbs[[i]]$expr)[3],]$time)) / mean((mbs[[i]][mbs[[i]]$expr == levels(mbs[[i]]$expr)[k],]$time)))),2)
rownames(summary_mbs) <- levels(mbs[[1]]$expr)
colnames(summary_mbs)<- names(mbs)
summary_mbs
```

    ##                                   n=1000 n=10000 n=1e+05 n=1e+06 n=1e+07 n=1e+08
    ## sum(x)                             19.01   14.92   15.16   15.14   15.22   15.05
    ## sumC(x)                             3.80   15.72   19.66   20.29   20.39   19.91
    ## sumR(x)                             1.00    1.00    1.00    1.00    1.00    1.00
    ## R(sumJL(x))                         0.05    0.29    1.03    1.05    1.25    1.24
    ## R(sumJL(x_jl))                      0.05    0.34    3.39   21.50   74.84   86.13
    ## R(sumJL(jl_x))                      0.03    0.34    2.80   20.51   76.25  101.99
    ## R(sumJL(R(x)))                      0.02    0.16    1.73   12.22   59.46  101.37
    ## R(sumJLCall(x_jl))                  0.03    0.28    2.51   17.80   71.94   93.53
    ## R(sumJLCall(jl_x))                  0.04    0.21    2.78   19.90   72.51  103.72
    ## R(sumJLCall(R(x)))                  0.02    0.13    1.49   11.54   54.39   90.42
    ## R(sumJLFuncClosure(x_jl))           0.05    0.34    3.34   22.84   67.48   85.33
    ## R(sumJLFuncClosure(jl_x))           0.05    0.36    2.32   23.13   76.74  102.64
    ## R(sumJLFuncClosure(R(x)))           0.02    0.15    1.55   11.91   58.20   98.52
    ## R(sumJLValueCall(x_jl))             3.35   17.61   73.28   93.90  109.95   79.50
    ## R(sumJLValueCall(jl_x))             3.20   17.90   69.91   93.01  111.84  102.58
    ## R(sumJLValueCall(R(x)))             0.03    0.28    2.91   19.11   72.87   98.06
    ## R(sumJLValueFunc(x_jl))             0.55    5.66   39.51   80.97  106.49   94.37
    ## R(sumJLValueFunc(jl_x))             0.87    5.62   39.52   82.74  109.29  111.09
    ## R(sumJLValueFunc(R(x)))             0.04    0.28    2.82   17.75   71.03  100.23
    ## R(sumJLValueFuncClosure(x_jl))      2.78   17.37   70.46   92.00  111.66  101.00
    ## R(sumJLValueFuncClosure(jl_x))      3.17   17.12   71.58   28.56  110.51  106.44
    ## R(sumJLValueFuncClosure(R(x)))      0.04    0.24    3.06   18.19   73.34  105.20
    ## R(sommeJLValueFuncClosure(x_jl))    2.88   10.07   18.52   19.95   20.27   19.92
    ## R(sommeJLValueFuncClosure(jl_x))    2.86   10.18   18.48   19.82   20.26   20.08
    ## R(sommeJLValueFuncClosure(R(x)))    0.04    0.27    2.74    8.57   18.43   19.99
    ## R(somme2JLValueFuncClosure(x_jl))   2.83    9.85   18.48   19.98   20.27   19.83
    ## R(somme2JLValueFuncClosure(jl_x))   2.85   10.15   18.47   19.95   20.23   19.82
    ## R(somme2JLValueFuncClosure(R(x)))   0.04    0.25    2.49   10.80   18.41   19.74

``` r
mbs[["n=1000"]]
```

    ## Unit: microseconds
    ##                               expr      min        lq       mean    median        uq       max neval
    ##                             sum(x)    1.312    1.4760    1.52110    1.5170    1.5580     2.132   100
    ##                            sumC(x)    1.435    2.1730    7.60427    3.7515    4.4895   416.396   100
    ##                            sumR(x)   19.106   19.4340   28.90869   19.7415   20.0285   926.190   100
    ##                        R(sumJL(x))  488.310  511.2085  613.22019  527.7315  580.2525  2817.807   100
    ##                     R(sumJL(x_jl))  475.108  493.4145  603.15018  510.7575  625.5370  2245.816   100
    ##                     R(sumJL(jl_x))  470.967  495.8335 1089.82182  511.6595  534.4965 53067.038   100
    ##                     R(sumJL(R(x))) 1015.201 1058.9685 1333.98502 1107.4920 1354.9475  4852.596   100
    ##                 R(sumJLCall(x_jl))  559.691  575.1890 1101.22146  596.6115  619.4690 47776.152   100
    ##                 R(sumJLCall(jl_x))  558.092  579.0840  667.22580  600.0760  733.4080  2121.299   100
    ##                 R(sumJLCall(R(x))) 1127.459 1162.1040 1573.11670 1200.2955 1303.4310 17883.216   100
    ##          R(sumJLFuncClosure(x_jl))  475.272  495.6900  591.02443  513.6890  621.3345  3686.638   100
    ##          R(sumJLFuncClosure(jl_x))  473.058  493.0660  559.03582  508.6460  535.7060  2136.059   100
    ##          R(sumJLFuncClosure(R(x))) 1035.783 1082.2360 1279.42673 1123.8920 1307.7565  9721.715   100
    ##            R(sumJLValueCall(x_jl))    7.011    7.7695    8.62394    8.2615    9.2660    14.432   100
    ##            R(sumJLValueCall(jl_x))    7.175    8.0770    9.04091    8.5690    9.6760    13.694   100
    ##            R(sumJLValueCall(R(x)))  567.563  591.2610  829.42344  613.7085  748.7420  8611.271   100
    ##            R(sumJLValueFunc(x_jl))   28.044   29.6840   52.59193   31.4060   37.0025  1976.815   100
    ##            R(sumJLValueFunc(jl_x))   28.003   30.0530   33.23132   31.7750   37.0230    44.321   100
    ##            R(sumJLValueFunc(R(x)))  585.480  610.1005  687.00625  628.0995  663.4415  2766.967   100
    ##     R(sumJLValueFuncClosure(x_jl))    7.175    8.1795   10.40457    8.9380   10.2910    75.727   100
    ##     R(sumJLValueFuncClosure(jl_x))    7.626    8.2615    9.12496    8.7740    9.8400    13.120   100
    ##     R(sumJLValueFuncClosure(R(x)))  567.153  592.5525  694.66628  613.0320  694.2940  3405.173   100
    ##   R(sommeJLValueFuncClosure(x_jl))    8.323    8.9175   10.04869    9.6350   10.5780    17.958   100
    ##   R(sommeJLValueFuncClosure(jl_x))    8.077    8.8560   10.11675    9.6145   11.1110    15.908   100
    ##   R(sommeJLValueFuncClosure(R(x)))  568.916  589.4365  661.90482  610.4490  712.3750  2165.456   100
    ##  R(somme2JLValueFuncClosure(x_jl))    8.323    8.9380   10.20572    9.5940   11.0700    17.753   100
    ##  R(somme2JLValueFuncClosure(jl_x))    7.995    8.9790   10.13479    9.6145   10.9060    18.245   100
    ##  R(somme2JLValueFuncClosure(R(x)))  567.850  583.6965  687.14975  602.5155  623.3845  3486.599   100

``` r
mbs[["n=10000"]]
```

    ## Unit: microseconds
    ##                               expr      min        lq       mean    median        uq       max neval
    ##                             sum(x)   12.382   12.5050   12.66039   12.5870   12.6895    13.817   100
    ##                            sumC(x)    9.635   10.7010   12.02079   12.1565   13.0380    17.753   100
    ##                            sumR(x)  186.181  186.8370  188.93333  187.2470  190.2605   205.656   100
    ##                        R(sumJL(x))  580.806  600.2810  659.02334  621.1910  674.4705  1574.482   100
    ##                     R(sumJL(x_jl))  464.407  487.3055  558.68281  503.1725  535.0295  3196.401   100
    ##                     R(sumJL(jl_x))  464.530  481.9960  558.35235  501.6555  622.6260  2791.444   100
    ##                     R(sumJL(R(x)))  999.211 1038.0380 1195.57312 1086.7255 1362.5530  2604.771   100
    ##                 R(sumJLCall(x_jl))  546.858  565.2670  675.22695  586.7715  741.2595  4082.616   100
    ##                 R(sumJLCall(jl_x))  548.252  568.5060  896.99021  599.4405  723.8140 21453.455   100
    ##                 R(sumJLCall(R(x))) 1099.784 1135.5360 1504.94887 1184.7975 1434.3030 12215.622   100
    ##          R(sumJLFuncClosure(x_jl))  463.587  479.9050  556.47168  503.0905  533.8200  3462.532   100
    ##          R(sumJLFuncClosure(jl_x))  470.680  484.1075  531.65684  501.3480  531.4215   903.394   100
    ##          R(sumJLFuncClosure(R(x))) 1019.547 1044.8440 1228.98976 1097.4060 1369.7280  4074.334   100
    ##            R(sumJLValueCall(x_jl))    9.020    9.7170   10.72601   10.2295   11.6850    14.145   100
    ##            R(sumJLValueCall(jl_x))    9.061    9.7990   10.55422   10.1475   11.2340    13.940   100
    ##            R(sumJLValueCall(R(x)))  558.871  582.7125  677.15272  605.6520  733.9000  3863.717   100
    ##            R(sumJLValueFunc(x_jl))   29.315   30.9345   33.36662   32.0620   33.5380    45.715   100
    ##            R(sumJLValueFunc(jl_x))   29.561   30.3605   33.62902   32.0620   34.6450    44.854   100
    ##            R(sumJLValueFunc(R(x)))  579.945  600.4245  684.26786  623.5895  655.0980  2820.800   100
    ##     R(sumJLValueFuncClosure(x_jl))    9.143   10.0860   10.87730   10.5370   11.5415    15.662   100
    ##     R(sumJLValueFuncClosure(jl_x))    9.102   10.0040   11.03433   10.4960   11.2135    17.343   100
    ##     R(sumJLValueFuncClosure(R(x)))  560.593  579.6375  776.84258  613.5445  768.7910  3562.449   100
    ##   R(sommeJLValueFuncClosure(x_jl))   16.851   17.6505   18.76898   18.3065   19.5775    23.411   100
    ##   R(sommeJLValueFuncClosure(jl_x))   16.728   17.5685   18.55455   17.9990   19.3315    26.732   100
    ##   R(sommeJLValueFuncClosure(R(x)))  566.866  590.8920  707.17661  615.5945  779.2870  3771.672   100
    ##  R(somme2JLValueFuncClosure(x_jl))   16.933   17.5890   19.17775   18.3680   19.9260    45.633   100
    ##  R(somme2JLValueFuncClosure(jl_x))   16.892   17.5890   18.61441   18.1425   19.1265    33.415   100
    ##  R(somme2JLValueFuncClosure(R(x)))  566.907  583.8605  749.81989  607.2100  704.7080  3840.880   100

``` r
mbs[["n=1e+05"]]
```

    ## Unit: microseconds
    ##                               expr      min        lq       mean    median        uq       max neval
    ##                             sum(x)  122.959  123.1230  125.95200  123.7995  127.5920   157.522   100
    ##                            sumC(x)   92.660   94.7305   97.16795   96.5140   98.7485   112.381   100
    ##                            sumR(x) 1859.760 1865.8280 1909.93416 1878.5995 1933.7650  2545.444   100
    ##                        R(sumJL(x)) 1570.833 1624.3790 1858.91868 1659.1675 1780.8965  4919.836   100
    ##                     R(sumJL(x_jl))  476.789  493.0660  563.85783  504.5460  523.5700  1874.725   100
    ##                     R(sumJL(jl_x))  481.012  490.0320  683.28181  504.2180  523.4880  6777.669   100
    ##                     R(sumJL(R(x))) 1014.012 1036.9310 1102.74133 1064.2780 1092.4040  2149.261   100
    ##                 R(sumJLCall(x_jl))  560.224  572.8930  762.06700  590.7075  607.7635 13339.801   100
    ##                 R(sumJLCall(jl_x))  558.625  576.8905  685.89556  588.6165  621.7650  3536.004   100
    ##                 R(sumJLCall(R(x))) 1109.501 1139.0620 1283.06876 1171.3495 1221.9025  4236.366   100
    ##          R(sumJLFuncClosure(x_jl))  478.511  494.8085  572.13245  510.1015  527.6495  3634.199   100
    ##          R(sumJLFuncClosure(jl_x))  479.372  488.9660  822.01720  503.8080  524.6360 28613.203   100
    ##          R(sumJLFuncClosure(R(x))) 1032.462 1056.6110 1228.29850 1089.3290 1127.5205  3855.107   100
    ##            R(sumJLValueCall(x_jl))   24.108   25.0100   26.06493   25.5840   26.5065    37.433   100
    ##            R(sumJLValueCall(jl_x))   24.067   24.9075   27.32035   25.5840   26.5680    80.073   100
    ##            R(sumJLValueCall(R(x)))  571.622  586.5050  657.42885  600.3425  627.1770  3873.557   100
    ##            R(sumJLValueFunc(x_jl))   44.280   46.2070   48.34556   47.4985   49.0565    66.338   100
    ##            R(sumJLValueFunc(jl_x))   44.198   45.8790   48.32465   47.0885   49.0770    75.522   100
    ##            R(sumJLValueFunc(R(x)))  592.491  601.1420  678.41716  620.6785  658.9315  2952.369   100
    ##     R(sumJLValueFuncClosure(x_jl))   24.313   25.3175   27.10551   25.9120   27.3470    63.755   100
    ##     R(sumJLValueFuncClosure(jl_x))   24.313   25.1330   26.68362   25.8710   27.1010    44.239   100
    ##     R(sumJLValueFuncClosure(R(x)))  569.900  583.0405  624.58826  593.7620  620.7605  2054.428   100
    ##   R(sommeJLValueFuncClosure(x_jl))   99.835  100.7985  103.14411  102.3770  104.6935   118.203   100
    ##   R(sommeJLValueFuncClosure(jl_x))   99.876  100.7370  103.35526  102.2745  104.9395   122.180   100
    ##   R(sommeJLValueFuncClosure(R(x)))  648.005  661.9040  697.05576  679.7595  703.0475   977.481   100
    ##  R(somme2JLValueFuncClosure(x_jl))   99.671  100.9215  103.32861  102.4590  105.5750   110.782   100
    ##  R(somme2JLValueFuncClosure(jl_x))   99.999  100.9010  103.39380  102.4385  105.5955   116.686   100
    ##  R(somme2JLValueFuncClosure(R(x)))  645.914  662.3550  767.10303  675.3110  702.1045  3917.837   100

``` r
mbs[["n=1e+06"]]
```

    ## Unit: microseconds
    ##                               expr       min         lq       mean     median         uq       max neval
    ##                             sum(x)  1230.861  1239.1225  1257.6143  1248.1425  1263.4765  1659.434   100
    ##                            sumC(x)   922.254   926.9075   938.3252   932.4835   946.7515   972.274   100
    ##                            sumR(x) 18623.102 18718.5910 19041.7468 18965.2060 19022.5445 21504.459   100
    ##                        R(sumJL(x)) 11821.284 12550.9610 18141.3184 12999.1115 13630.5935 74728.691   100
    ##                     R(sumJL(x_jl))   691.014   745.3595   885.8681   796.0560   885.8255  3587.131   100
    ##                     R(sumJL(jl_x))   675.106   731.3170   928.2818   798.6185   892.5905  3594.552   100
    ##                     R(sumJL(R(x)))  1235.412  1330.9215  1557.6146  1403.2250  1667.9825  4837.631   100
    ##                 R(sumJLCall(x_jl))   778.795   829.4710  1069.8839   877.3795   993.0405 16578.678   100
    ##                 R(sumJLCall(jl_x))   777.688   832.7510   956.8108   885.4360  1009.2150  2877.749   100
    ##                 R(sumJLCall(R(x)))  1348.777  1443.4255  1649.9892  1545.2285  1832.2080  3416.858   100
    ##          R(sumJLFuncClosure(x_jl))   693.310   727.9960   833.5833   761.8005   828.0565  2593.127   100
    ##          R(sumJLFuncClosure(jl_x))   681.379   728.4470   823.1148   782.6490   875.6780  2186.858   100
    ##          R(sumJLFuncClosure(R(x)))  1278.011  1370.3635  1598.6663  1422.1670  1545.0645  6948.311   100
    ##            R(sumJLValueCall(x_jl))   191.921   197.5380   202.7917   200.4695   206.4965   221.933   100
    ##            R(sumJLValueCall(jl_x))   192.536   196.5335   204.7278   199.0960   203.2370   426.851   100
    ##            R(sumJLValueCall(R(x)))   775.802   862.1480   996.4566   916.2885  1035.7420  4006.110   100
    ##            R(sumJLValueFunc(x_jl))   215.045   225.2950   235.1674   232.1010   239.7885   323.777   100
    ##            R(sumJLValueFunc(jl_x))   215.250   221.6255   230.1437   227.4475   234.9095   287.984   100
    ##            R(sumJLValueFunc(R(x)))   812.702   853.5585  1072.9282   907.0225  1068.8905  9731.719   100
    ##     R(sumJLValueFuncClosure(x_jl))   193.233   198.6655   206.9754   201.3305   209.3255   299.997   100
    ##     R(sumJLValueFuncClosure(jl_x))   192.823   198.2145   666.6903   200.7155   205.9840 46508.883   100
    ##     R(sumJLValueFuncClosure(R(x)))   797.614   844.5180  1046.6521   903.3530  1045.2130  6216.871   100
    ##   R(sommeJLValueFuncClosure(x_jl))   931.971   938.4285   954.2894   944.6400   965.0990  1112.084   100
    ##   R(sommeJLValueFuncClosure(jl_x))   931.766   937.5675   960.8813   951.3025   961.3270  1591.210   100
    ##   R(sommeJLValueFuncClosure(R(x)))  1530.858  1601.8905  2221.7273  1673.5380  1761.6880 55386.736   100
    ##  R(somme2JLValueFuncClosure(x_jl))   931.233   939.5970   953.0376   952.3890   957.7395  1031.724   100
    ##  R(somme2JLValueFuncClosure(jl_x))   932.094   937.8750   954.6682   950.9745   959.3385  1057.964   100
    ##  R(somme2JLValueFuncClosure(R(x)))  1518.886  1594.4490  1763.3108  1639.5080  1748.1170  4336.406   100

``` r
mbs[["n=1e+07"]]
```

    ## Unit: milliseconds
    ##                               expr        min         lq       mean     median         uq        max neval
    ##                             sum(x)  12.315129  12.358404  12.580265  12.551699  12.596717  16.079790   100
    ##                            sumC(x)   9.238858   9.272806   9.390938   9.354786   9.425757  11.361141   100
    ##                            sumR(x) 187.338061 189.871717 191.487275 190.131596 191.969441 217.344649   100
    ##                        R(sumJL(x)) 123.426031 131.008407 153.574691 138.326763 178.441102 255.623766   100
    ##                     R(sumJL(x_jl))   2.284438   2.338476   2.558461   2.393703   2.547802   6.381281   100
    ##                     R(sumJL(jl_x))   2.281732   2.366766   2.511199   2.417688   2.537183   5.641559   100
    ##                     R(sumJL(R(x)))   2.898085   2.995214   3.220407   3.095397   3.332767   5.566242   100
    ##                 R(sumJLCall(x_jl))   2.392842   2.465535   2.661656   2.520639   2.697615   6.108959   100
    ##                 R(sumJLCall(jl_x))   2.404240   2.471049   2.640888   2.524103   2.668239   4.353421   100
    ##                 R(sumJLCall(R(x)))   3.018543   3.103556   3.520860   3.188098   3.466099  18.188338   100
    ##          R(sumJLFuncClosure(x_jl))   2.287349   2.337164   2.837623   2.394626   2.526973  33.368219   100
    ##          R(sumJLFuncClosure(jl_x))   2.295590   2.349382   2.495403   2.393560   2.510102   5.365916   100
    ##          R(sumJLFuncClosure(R(x)))   2.923751   3.025554   3.290042   3.086931   3.372004   6.057750   100
    ##            R(sumJLValueCall(x_jl))   1.656728   1.682435   1.741653   1.705928   1.733972   2.656759   100
    ##            R(sumJLValueCall(jl_x))   1.657261   1.675793   1.712126   1.698958   1.725157   1.945778   100
    ##            R(sumJLValueCall(R(x)))   2.406946   2.473058   2.627972   2.513730   2.652146   5.052061   100
    ##            R(sumJLValueFunc(x_jl))   1.682886   1.720544   1.798202   1.740839   1.767059   4.573919   100
    ##            R(sumJLValueFunc(jl_x))   1.684526   1.715584   1.752066   1.741373   1.762631   2.276156   100
    ##            R(sumJLValueFunc(R(x)))   2.419369   2.487060   2.695713   2.520803   2.627321  11.712757   100
    ##     R(sumJLValueFuncClosure(x_jl))   1.653530   1.676100   1.714893   1.702628   1.728130   1.980300   100
    ##     R(sumJLValueFuncClosure(jl_x))   1.656892   1.675711   1.732815   1.698405   1.725178   2.856716   100
    ##     R(sumJLValueFuncClosure(R(x)))   2.378041   2.463628   2.611018   2.532857   2.664385   4.994456   100
    ##   R(sommeJLValueFuncClosure(x_jl))   9.280883   9.317844   9.445949   9.399086   9.485022  11.021989   100
    ##   R(sommeJLValueFuncClosure(jl_x))   9.278546   9.317578   9.449597   9.396995   9.481680  10.587758   100
    ##   R(sommeJLValueFuncClosure(R(x)))  10.010191  10.130567  10.388021  10.286121  10.475971  13.566285   100
    ##  R(somme2JLValueFuncClosure(x_jl))   9.278505   9.304786   9.444730   9.364051   9.484940  12.046251   100
    ##  R(somme2JLValueFuncClosure(jl_x))   9.277316   9.319587   9.463268   9.454231   9.493345  11.259092   100
    ##  R(somme2JLValueFuncClosure(R(x)))  10.012036  10.079522  10.398766  10.206171  10.424865  21.428896   100

``` r
mbs[["n=1e+08"]]
```

    ## Unit: milliseconds
    ##                               expr        min         lq       mean     median         uq        max neval
    ##                             sum(x)  125.44266  125.64208  127.71174  125.86026  126.38949  224.01281   100
    ##                            sumC(x)   93.86643   94.21380   96.49658   94.33132   94.72900  177.54861   100
    ##                            sumR(x) 1903.67305 1906.57948 1921.48862 1909.71721 1921.99410 2123.34699   100
    ##                        R(sumJL(x)) 1274.69886 1367.22751 1552.98340 1445.73772 1648.63345 2514.77407   100
    ##                     R(sumJL(x_jl))   17.57563   17.74818   22.30805   17.91331   18.31517  153.31544   100
    ##                     R(sumJL(jl_x))   17.49581   17.70565   18.83913   17.89258   18.28258   38.30421   100
    ##                     R(sumJL(R(x)))   18.20535   18.37501   18.95485   18.59584   19.07976   26.57046   100
    ##                 R(sumJLCall(x_jl))   17.63008   17.78149   20.54369   17.98797   18.27370  191.47295   100
    ##                 R(sumJLCall(jl_x))   17.64722   17.76770   18.52490   17.94004   18.34483   28.35212   100
    ##                 R(sumJLCall(R(x)))   18.26948   18.49079   21.24989   18.84317   19.31274  146.30071   100
    ##          R(sumJLFuncClosure(x_jl))   17.55698   17.71784   22.51703   17.90931   18.22397  149.78846   100
    ##          R(sumJLFuncClosure(jl_x))   17.50716   17.69306   18.72116   17.85509   18.42302   73.69246   100
    ##          R(sumJLFuncClosure(R(x)))   18.20019   18.40869   19.50389   18.67249   19.21012   67.33766   100
    ##            R(sumJLValueCall(x_jl))   16.85412   16.92962   24.17098   17.08130   17.48336  221.43998   100
    ##            R(sumJLValueCall(jl_x))   16.83739   16.90233   18.73169   16.98913   17.24124   73.68627   100
    ##            R(sumJLValueCall(R(x)))   17.64091   17.79787   19.59583   17.95064   18.23985   60.40091   100
    ##            R(sumJLValueFunc(x_jl))   16.87777   16.96022   20.36186   17.03882   17.29737  123.64600   100
    ##            R(sumJLValueFunc(jl_x))   16.88097   16.93029   17.29721   16.99200   17.21754   25.07105   100
    ##            R(sumJLValueFunc(R(x)))   17.65837   17.82233   19.17142   17.99252   18.30679   51.60908   100
    ##     R(sumJLValueFuncClosure(x_jl))   16.83911   16.90711   19.02497   16.97913   17.22381  142.74408   100
    ##     R(sumJLValueFuncClosure(jl_x))   16.82214   16.89446   18.05209   16.97964   17.21106   81.70583   100
    ##     R(sumJLValueFuncClosure(R(x)))   17.63525   17.76487   18.26481   17.96805   18.26948   24.19025   100
    ##   R(sommeJLValueFuncClosure(x_jl))   92.64503   94.28659   96.44964   94.40320   94.79858  227.92388   100
    ##   R(sommeJLValueFuncClosure(jl_x))   92.89161   94.26757   95.70633   94.39676   94.82529  130.49078   100
    ##   R(sommeJLValueFuncClosure(R(x)))   94.01808   95.16254   96.14257   95.41832   95.83574  123.00783   100
    ##  R(somme2JLValueFuncClosure(x_jl))   93.43183   94.27772   96.88669   94.38850   94.92638  239.24410   100
    ##  R(somme2JLValueFuncClosure(jl_x))   92.69116   94.26472   96.93767   94.37999   94.75063  182.93454   100
    ##  R(somme2JLValueFuncClosure(R(x)))   94.11931   95.20163   97.36201   95.37342   95.86632  160.08249   100

</details>
