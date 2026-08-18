test_that("calc_crown_overlay is calculated correctly", {
    tree_list <- data.frame(DIST = 0, AZIMUTH = 0, CRWIDTH = 4)
    res <- calc_crown_overlay(tree_list, sample_radius = 2)
    expect_equal(res, 100)
    res <- calc_crown_overlay(tree_list, sample_radius = 10, digits = 0)
    expect_equal(res, round((pi * 2^2) / (pi * 10^2) * 100, 0))

    tree_list <- data.frame(DIST = 10, AZIMUTH = 180, CRWIDTH = 4)
    res <- calc_crown_overlay(tree_list, sample_radius = 10, digits = 0)
    expect_equal(res, round((pi * 2^2) / (pi * 10^2) * 100 / 2, 0))

    tree_list <- data.frame(DIST = c(0, 10), AZIMUTH = c(0, 180),
                            CRWIDTH = c(4, 4))
    expected <- round((pi * 2^2) / (pi * 10^2) * 100, 0) +
                round((pi * 2^2) / (pi * 10^2) * 100 / 2, 0)
    res <- calc_crown_overlay(tree_list, sample_radius = 10, digits = 0)
    expect_equal(res, expected)

    # test tree list used in the original subp_crcov.c
    trees <- c(117,22.1,7.71,72,19.4,10.0,66,17.3,8.94,258,13.2,17.28) |>
        matrix(nrow = 4, ncol = 3, byrow = TRUE) |>
        as.data.frame()
    colnames(trees) <- c("AZIMUTH", "DIST", "CRWIDTH")
    expect_equal(calc_crown_overlay(trees, 24, digits = 0), 20)

    # one tree with half the area of a subplot
    tree_list <- data.frame(DIST = 1, AZIMUTH = 0, CRWIDTH = 33.94113)
    expect_equal(calc_crown_overlay(tree_list, 24), 50, tolerance = 1e-3)
})
