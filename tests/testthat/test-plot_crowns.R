test_that("plot_crowns works", {
    res <- plot_crowns(plantation, main = "plantation plot")
    expect_true("CRWIDTH" %in% colnames(res))
    res["CRWIDTH"] <- NULL
    expect_equal(res, plantation)

    res <- plot_crowns(plantation, subplot = 4, main = "plantation subplot 4")
    expect_true("CRWIDTH" %in% colnames(res))
    res["CRWIDTH"] <- NULL
    expect_equal(res, plantation)

    res <- plot_crowns(plantation, subplot = 4, microplot = TRUE)
    expect_true("CRWIDTH" %in% colnames(res))
    res["CRWIDTH"] <- NULL
    expect_equal(res, plantation)

    metric_trees <- within(plantation, {
        CRWIDTH <- calc_crwidth(plantation) |> ft_to_m()
        rm(DIST, DIA)
        DIST <- ft_to_m(plantation$DIST)
        DIA <- in_to_cm(plantation$DIA)
    })
    res <- plot_crowns(metric_trees, linear_unit = "meter")
    expect_true("CRWIDTH" %in% colnames(res))
    expect_equal(res, metric_trees)

    res <- plot_crowns(plantation, subplot = 1, crown_col = "blue",
                       stem_col = "orange", subp_border_lwd = 1,
                       subp_border_col = "black")
    expect_true("CRWIDTH" %in% colnames(res))
    res["CRWIDTH"] <- NULL
    expect_equal(res, plantation)
})
