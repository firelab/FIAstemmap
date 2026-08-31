test_that("process_tree_data works", {
    f <- system.file("extdata/test-tree_data.csv", package="FIAstemmap")
    tree_in <- load_tree_data(f)
    # spatstat warning due to points outside window, from PNW macroplot trees
    suppressWarnings({
        expect_warning(out <- process_tree_data(tree_in))
    })
    expect_true(is.data.frame(out))
    expect_equal(out$model_tcc[1:4], c(95.0, 71.4, 70.1, 25.3), tolerance = 1e-1)
})
