test_that("crown_overlay_pct works", {
    # test tree list used in the original subp_crcov.c
    trees <- c(117,22.1,7.71,72,19.4,10.0,66,17.3,8.94,258,13.2,17.28) |>
        matrix(nrow = 4, ncol = 3, byrow = TRUE) |>
        as.data.frame()
    colnames(trees) <- c("AZIMUTH", "DIST", "CRWIDTH")
    expect_equal(round(crown_overlay_pct(trees, 24)), 20)
})
