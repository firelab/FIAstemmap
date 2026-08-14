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
})
