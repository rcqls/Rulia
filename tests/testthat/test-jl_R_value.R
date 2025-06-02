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