require(Rcpp)
require(Rulia)
require(microbenchmark)
## Needed to use UnsafeArray as wrapper of R Vector
jlinclude(Rulia::RCall)

options(width=120)

sumR <- function(x) {
  total <- 0
  for (i in seq_along(x)) {
    total <- total + x[i]
  }
  total
}

cppFunction('double sumC(NumericVector x) {
  int n = x.size();
  double total = 0;
  for(int i = 0; i < n; ++i) {
    total += x[i];
  }
  return total;
}')

sumJL <- jl(sum)

sumJLCall <- function(x) jlcall("sum", x)

sumJLValueCall <- function(x) jlvalue_call("sum", x)

sumJLValueFunc <- function(x) jlvalue_func(jlvalue_eval("sum"), x)

jlv_sum <- jlvalue_eval("sum")
sumJLFuncClosure <- function(x) jlfunc(jlv_sum,x)
sumJLValueFuncClosure <- function(x) jlvalue_func(jlv_sum,x)

jl(`
function somme(x::Vector{Float64})::Float64
    tot=0.0
    for e=x
        tot += e
    end
    tot
end
`)

jl(`
function somme2(x)
    tot=zero(eltype(x))
    for e=x
        tot += e
    end
    tot
end
`)

jlv_somme <- jlvalue_eval("somme")
jlv_somme2 <- jlvalue_eval("somme2")
sommeJLValueFuncClosure <- function(x) jlvalue_func(jlv_somme,x)
somme2JLValueFuncClosure <- function(x) jlvalue_func(jlv_somme2,x)

#####################################
## change savemb to TRUE to save mb
savembs <- TRUE
ns <- c(1000, 10000, 1e5, 1e6, 1e7,1e8)
xx <- runif(max(ns))
####################################

rdatafile <- "RcppVsRulia.RData"

if(!file.exists(rdatafile)) {
    mbs <- list()
    save(mbs,file=rdatafile)
}

load(file=rdatafile)

for( n in ns) {
    x <- xx[1:n]
    # head(x,3)
    x_jl <- jl(x)
    # jl(getindex)(x_jl,`1:3`)
    jl_x <- R(x)
    # jl(getindex)(jl_x,`1:3`)
    mb <- microbenchmark(
    sum(x),
    sumC(x),
    sumR(x),
    R(sumJL(x)),
    R(sumJL(x_jl)),
    R(sumJL(jl_x)),
    R(sumJL(R(x))),
    R(sumJLCall(x_jl)),
    R(sumJLCall(jl_x)),
    R(sumJLCall(R(x))),
    R(sumJLFuncClosure(x_jl)),
    R(sumJLFuncClosure(jl_x)),
    R(sumJLFuncClosure(R(x))),
    R(sumJLValueCall(x_jl)),
    R(sumJLValueCall(jl_x)),
    R(sumJLValueCall(R(x))),
    R(sumJLValueFunc(x_jl)),
    R(sumJLValueFunc(jl_x)),
    R(sumJLValueFunc(R(x))),
    R(sumJLValueFuncClosure(x_jl)),
    R(sumJLValueFuncClosure(jl_x)),
    R(sumJLValueFuncClosure(R(x))),
    R(sommeJLValueFuncClosure(x_jl)),
    R(sommeJLValueFuncClosure(jl_x)),
    R(sommeJLValueFuncClosure(R(x))),
    R(somme2JLValueFuncClosure(x_jl)),
    R(somme2JLValueFuncClosure(jl_x)),
    R(somme2JLValueFuncClosure(R(x))),
    check='equal' 
    )

    if(savembs) {
        mbs[[paste0("n=",n)]] <- mb
        save(mbs, file = rdatafile)
    }
}