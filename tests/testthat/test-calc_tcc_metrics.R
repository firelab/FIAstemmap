test_that("calc_tcc_metrics works", {
    # one sapling in each microplot
    # each sapling crown has half the area of the microplot
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

    # test against results from the legacy v. 1.12 Python code
    f <- system.file("extdata/test_tree_data.csv", package="FIAstemmap")
    tree_tbl <- load_tree_data(f)

    tree_list_1 <- tree_tbl[tree_tbl$PLT_CN == "1", ]
    expect_equal(nrow(tree_list_1), 31)
    expect_warning(
        tcc_pred <- calc_tcc_metrics(tree_list_1),
        "13 points were rejected as lying outside the specified window")
    expect_true(is.list(tcc_pred))



})
