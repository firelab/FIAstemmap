test_that("calc_ht_metrics and calc_landfire_stand_ht", {
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
    expected$predomTreeHt <- 50.7
    expected$numSaplings <- 2
    expected$meanSapHt <- 34.5
    expected$maxSapHt <- 43
    expect_equal(calc_ht_metrics(plantation), expected, tolerance = 1e-3)

    # LANDFIRE stand height
    tcc_pred <- calc_tcc_metrics(plantation, digits = 3)
    standHt <- calc_landfire_stand_ht(tcc_pred$subp_overlay_mean,
                                      tcc_pred$micr_overlay_mean,
                                      tcc_pred$numTrees,
                                      tcc_pred$meanTreeHtDomBAW,
                                      tcc_pred$meanTreeHtBAW,
                                      tcc_pred$meanSapHt)
    expect_equal(standHt, tcc_pred$meanTreeHtDomBAW, tolerance = 1e-3)

    # sapling plot
    f <- system.file("extdata/test-tree_data.csv", package="FIAstemmap")
    tree_tbl <- load_tree_data(f)

    tree_list_4 <- tree_tbl[tree_tbl$PLT_CN == "4", ]
    expect_equal(nrow(tree_list_4), 21)
    expect_no_error(
        tcc_pred <- calc_tcc_metrics(tree_list_4, digits = 3))
    standHt <- calc_landfire_stand_ht(tcc_pred$subp_overlay_mean,
                                      tcc_pred$micr_overlay_mean,
                                      tcc_pred$numTrees,
                                      tcc_pred$meanTreeHtDomBAW,
                                      tcc_pred$meanTreeHtBAW,
                                      tcc_pred$meanSapHt)
    expect_equal(standHt, tcc_pred$meanSapHt, tolerance = 1e-3)
})
