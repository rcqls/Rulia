jl(`struct A; a::Int; b::Vector{Float64};end`)
a_jl <- jl(A)(1,1:3)

test_that("constructor jl(A)(1,1:3)", {
  expect_jlequal(jl(A)(1,1:3), "A(1, [1.0, 2.0, 3.0])")
})

a_jl_R <- list(a=1,b=c(1,2,3))
class(a_jl_R) <- c("jlStruct", "jlA")
test_that("a_jl <- jl(A)(1,1:3); R(a_jl)", {
  expect_equal(R(a_jl), a_jl_R)
})

test_that("a_jl$a", {
  expect_jlequal(a_jl$a, "1")
})

test_that("R(a_jl$a)", {
  expect_equal(R(a_jl$a), 1)
})