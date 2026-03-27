test_that("calc_ht_metrics works", {
    expected <- vector(mode = "list", length = 10)
    names(expected) <- c("numTrees", "meanTreeHt", "meanTreeHtBAW",
                         "meanTreeHtDom", "meanTreeHtDomBAW", "maxTreeHt",
                         "predomTreeHt", "numSaplings", "meanSapHt",
                         "maxSapHt")

    expected$numTrees <- 89
    expected$meanTreeHt <- 44.8
    expected$meanTreeHtBAW <- 45.3
    expected$meanTreeHtDom <- 44.8
    expected$meanTreeHtDomBAW <- 45.3
    expected$maxTreeHt <- 51
    expected$predomTreeHt <- 51
    expected$numSaplings <- 2
    expected$meanSapHt <- 34.5
    expected$maxSapHt <- 43
    expect_equal(calc_ht_metrics(plantation), expected, tolerance = 0.1)
})
