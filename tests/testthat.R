library(testthat)
library(oysteR)

test_check("oysteR",
           reporter = JunitReporter$new(file = "junit_result.xml"))
