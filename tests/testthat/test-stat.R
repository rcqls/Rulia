test_that("data.frame works", {
  expect_jlequal(jl(data.frame(a=1:2, b=c(TRUE,FALSE))), "2×2 DataFrame\n Row │ a      b\n     │ Int64  Bool\n─────┼──────────────\n   1 │     1   true\n   2 │     2  false")
})

test_that("factor works", {
  expect_jlequal(jl(factor(c("titi","toto","titi"))),"3-element CategoricalArray{String,1,UInt32}:\n \"titi\"\n \"toto\"\n \"titi\"")
})