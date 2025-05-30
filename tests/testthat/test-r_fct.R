test_that("R(jl(1))", {
  expect_equal(R(jl(1)), 1)
})

test_that("R(jl(`[1,2,3]`))", {
  expect_equal(R(jl(`[1,2,3]`)), c(1L, 2L, 3L))
})

test_that("R(jl(`[1,2,3]`)) not c(1,2,3)", {
  !expect_equal(R(jl(`[1,2,3]`)), c(1, 2, 3))
})
