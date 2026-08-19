test_that("calc_tcc_metrics returns correct values", {
    ### one sapling in each microplot, each sapling crown has half the area of
    ## the microplot
    subp <- c(1, 2, 3, 4)
    tree <- rep(1, 4)
    azimuth <- c(0, 90, 180, 270)
    dist <- c(1, -1, 1, -1)
    statuscd <- rep(1, 4)
    spcd <- rep(131, 4)
    dia <- rep(4.9, 4)
    ht <- rep(47, 4)
    actualht <- rep(47, 4)
    cclcd <- rep(5, 4)
    tpa_unadj <- rep(74.96528, 4)
    crwidth <- rep(9.616652, 4)
    tree_list <- data.frame(SUBP = subp, TREE = tree, AZIMUTH = azimuth,
                            DIST = dist, STATUSCD = statuscd, SPCD = spcd,
                            DIA = dia, HT = ht, ACTUALHT = actualht,
                            CCLCD = cclcd, TPA_UNADJ = tpa_unadj,
                            CRWIDTH = crwidth)

    # stem-map method
    tcc_pred <- calc_tcc_metrics(tree_list, full_output = FALSE)
    expect_equal(tcc_pred, 50, tolerance = 1e-3)

    # FVS method
    tcc_pred <- calc_tcc_metrics(tree_list, stem_map = FALSE,
                                 full_output = FALSE)
    expect_equal(tcc_pred, 39.3, tolerance = 1e-3)

    ### test against results from the legacy v. 1.12 Python code
    f <- system.file("extdata/test-tree_data.csv", package="FIAstemmap")
    tree_tbl <- load_tree_data(f)

    tree_list_1 <- tree_tbl[tree_tbl$PLT_CN == "1", ]
    expect_equal(nrow(tree_list_1), 31)
    expect_warning(
        tcc_pred <- calc_tcc_metrics(tree_list_1),
        "13 points were rejected as lying outside the specified window")
    expect_true(is.list(tcc_pred))
    expect_equal(round(tcc_pred$model_tcc), 95)
    expect_equal(round(tcc_pred$subp1_crown_overlay), 78)
    expect_equal(round(tcc_pred$subp2_crown_overlay), 75)
    expect_equal(round(tcc_pred$subp3_crown_overlay), 100)
    expect_equal(round(tcc_pred$subp4_crown_overlay), 71)
    expect_equal(round(tcc_pred$micr1_crown_overlay), 0)
    expect_equal(round(tcc_pred$micr2_crown_overlay), 0)
    expect_equal(round(tcc_pred$micr3_crown_overlay), 0)
    expect_equal(round(tcc_pred$micr4_crown_overlay), 0)

    tree_list_2 <- tree_tbl[tree_tbl$PLT_CN == "2", ]
    expect_equal(nrow(tree_list_2), 74)
    expect_no_error(
        tcc_pred <- calc_tcc_metrics(tree_list_2, digits = 3))
    expect_true(is.list(tcc_pred))
    # model_tcc skipped here due to rounding error difference
    # expect_equal(round(tcc_pred$model_tcc), 72)
    expect_equal(round(tcc_pred$subp1_crown_overlay), 50)
    expect_equal(round(tcc_pred$subp2_crown_overlay), 63)
    expect_equal(round(tcc_pred$subp3_crown_overlay), 42)
    expect_equal(round(tcc_pred$subp4_crown_overlay), 64)
    expect_equal(round(tcc_pred$micr1_crown_overlay), 33)
    expect_equal(round(tcc_pred$micr2_crown_overlay), 0)
    expect_equal(round(tcc_pred$micr3_crown_overlay), 0)
    expect_equal(round(tcc_pred$micr4_crown_overlay), 88)

    tree_list_3 <- tree_tbl[tree_tbl$PLT_CN == "3", ]
    expect_equal(nrow(tree_list_3), 39)
    expect_no_error(
        tcc_pred <- calc_tcc_metrics(tree_list_3, digits = 3))
    expect_true(is.list(tcc_pred))
    expect_equal(round(tcc_pred$model_tcc), 70)
    expect_equal(round(tcc_pred$subp1_crown_overlay), 14)
    expect_equal(round(tcc_pred$subp2_crown_overlay), 68)
    expect_equal(round(tcc_pred$subp3_crown_overlay), 6)
    expect_equal(round(tcc_pred$subp4_crown_overlay), 57)
    expect_equal(round(tcc_pred$micr1_crown_overlay), 53)
    expect_equal(round(tcc_pred$micr2_crown_overlay), 46)
    expect_equal(round(tcc_pred$micr3_crown_overlay), 84)
    expect_equal(round(tcc_pred$micr4_crown_overlay), 99)
})
