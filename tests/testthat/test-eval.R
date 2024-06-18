test_that("jl eval int64", {
  expect_jlequal(jl(`2 * 2`), "4")
})

test_that("jl eval string", {
  expect_jlequal(jl(`"2 * 2"`), '"2 * 2"')
})

test_that("jl eval symbol", {
  expect_jlequal(jlsymbol("toto"), ":toto")
})
