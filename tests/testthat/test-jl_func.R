jl_set.seed(12) # to fix the seed

test_that("jl jl(rand)(`2`)", {
  expect_jlequal(jl(rand)(`2`), "2-element Vector{Float64}:\n 0.32018269515620323\n 0.938582363311554")
})

test_that("jl jl(rand)(2L)", {
  expect_jlequal(jl(rand)(2L), "2-element Vector{Float64}:\n 0.5501748910470424\n 0.9475566588373514")
})

test_that("jl jl(sum)(1:10)", {
  expect_jlequal(jl(sum)(1:10), "55")
})

test_that("jl jl(sum)(1:10, init=12)", {
  expect_jlequal(jl(sum)(1:10, init=12), "67.0")
})