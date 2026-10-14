test_that("calc_cbh_metrics returns correct values", {
    f <- system.file("extdata/dfir_plot.csv", package="FIAstemmap")
    test_trees <- read.csv(f)
    res <- calc_cbh_metrics(test_trees)
    expect_equal(res$cbh_mean, 29.1)
    expect_equal(res$cbh_median, 29.4)
    expect_equal(res$cbh_pct20, 9)
    expect_equal(res$cbh_min, 0.9)

    test_trees$PLT_CN <- 101
    test_trees_2 <- rbind(test_trees, read.csv(f))
    res <- calc_cbh_metrics(test_trees_2)
    expect_equal(nrow(res), 2)
})
