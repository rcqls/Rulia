test_that("jl(typeof)(1.0) %<:% Number works", {
  expect_jlequal(jl(typeof)(1.0) %<:% Number, "true")
})

test_that("1.0 %isa% Number works", {
  expect_jlequal(1.0 %isa% Number, "true")
})

test_that('"1.0" %isa% Number works', {
  expect_jlequal("1.0" %isa% Number, "false")
})
