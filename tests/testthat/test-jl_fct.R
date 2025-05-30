test_that("jl(`1`)", {
  expect_jlequal(jl(`1`), "1")
})

test_that("jl(1)", {
  expect_jlequal(jl(1), "1.0")
})
