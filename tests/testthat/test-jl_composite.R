test_that("jl eval `[1,3,2]`", {
  expect_jlequal(jl(`[1,3,2]`), "3-element Vector{Int64}:\n 1\n 3\n 2")
})

test_that("jl eval `[1.0,3.0,2.0]`", {
  expect_jlequal(jl(`[1.0,3.0,2.0]`), "3-element Vector{Float64}:\n 1.0\n 3.0\n 2.0")
})

test_that("jl eval `[\n1.0\n,3.0\n,2.0\n]`", {
  expect_jlequal(jl(`[\n1.0\n,3.0\n,2.0\n]`), "3-element Vector{Float64}:\n 1.0\n 3.0\n 2.0")
})

test_that("jl eval `(a=1,b=[1,3])`", {
  expect_jlequal(jl(`(a=1,b=[1,3])`), "(a = 1, b = [1, 3])")
})
