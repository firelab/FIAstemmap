test_that("calc_crwidth work", {
    f <- system.file("extdata/test-tree_data.csv", package="FIAstemmap")
    test_trees <- read.csv(f)
    res <- calc_crwidth(test_trees[test_trees$STATUSCD == 1, ], digits = 3)
    expect_equal(res, test_trees$crwidth_est[test_trees$STATUSCD == 1],
                 tolerance = 1e-2)
})
