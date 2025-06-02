test_that("jl eval R 1", {
  expect_jlequal(jl(1), "1.0")
})

test_that('jl eval R c("one","three","two")', {
  expect_jlequal(jl(c("one","three","two")), "3-element Vector{String}:\n \"one\"\n \"three\"\n \"two\"")
})

test_that('jl eval R jl(c(1L,3L,2L))', {
  expect_jlequal(jl(jl(c(1L,3L,2L))), "3-element Vector{Int64}:\n 1\n 3\n 2")
})

test_that('jl eval R c(TRUE,FALSE,TRUE)', {
  expect_jlequal(jl(c(TRUE,FALSE,TRUE)), "3-element Vector{Bool}:\n 1\n 0\n 1")
})

test_that('jl eval R matrix("one")', {
  expect_jlequal(jl(matrix("one")), "1×1 Matrix{String}:\n \"one\"")
})

test_that('jl eval R list(a=c(TRUE,FALSE,TRUE), b=1L)', {
  expect_jlequal(jl(list(a=c(TRUE,FALSE,TRUE), b=1L)), "(a = Bool[1, 0, 1], b = 1)")
})

test_that('jl eval R call 2 * sin(1:3)', {
  expect_jlequal(jl(2 * sin(1:3)), "3-element Vector{Float64}:\n 1.682941969615793\n 1.8185948536513634\n 0.2822400161197344")
})

jl(2 * sin(1:3))    # this is a R call