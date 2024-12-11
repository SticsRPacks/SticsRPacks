context("test-utils.R")

test_that("SticsRPacks packages returns character vector of package names", {
  out <- SticsRPacks_packages()
  expect_type(out, "character")
  expect_true(all(c("CroptimizR", "SticsRFiles", "SticsOnR", "CroPlotR", "SticsRPacks") %in%
    out))
})
