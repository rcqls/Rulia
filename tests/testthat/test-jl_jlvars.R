jl_set.seed(12)
jl(a=jl(rand)(2L), b=1:3, c=`1:3`)

test_that("jl jlvars jl(a)", {
  expect_jlequal(jl(a), "2-element Vector{Float64}:\n 0.32018269515620323\n 0.938582363311554")
})

test_that("jl jlvars jl(b)", {
  expect_jlequal(jl(b), "3-element Vector{Int64}:\n 1\n 2\n 3")
})

test_that("jl jlvars jl(c)", {
  expect_jlequal(jl(c), "1:3")
})

test_that("jl jlvars jl(`c.start`)", {
  expect_jlequal(jl(`c.start`), "1")
})

test_that("jl jlvars jl(`c.stop`)", {
  expect_jlequal(jl(`c.stop`), "3")
})