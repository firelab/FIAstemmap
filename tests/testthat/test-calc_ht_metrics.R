test_that("calc_ht_metrics works", {
    expected <- vector(mode = "list", length = 8)
    names(expected) <- c("meanTreeHt", "meanTreeHtBAW", "meanTreeHtDom",
                         "meanTreeHtDomBAW", "maxTreeHt", "predomTreeHt",
                         "meanSapHt", "maxSapHt")
    expected$meanTreeHt <- 45
    expected$meanTreeHtBAW <- 45.4
    expected$meanTreeHtDom <- 45
    expected$meanTreeHtDomBAW <- 45.4
    expected$maxTreeHt <- 51
    expected$predomTreeHt <- 50.3
    expected$meanSapHt <- 33.5
    expected$maxSapHt <- 42
    expect_equal(calc_ht_metrics(plantation), expected, tolerance = 0.1)
})
