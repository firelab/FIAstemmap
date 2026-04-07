test_that("convert_units works", {
    expect_equal(ft_to_m(1), 0.3048)
    expect_equal(ft_to_m(c(1, 10)), c(0.3048, 3.048))

    expect_equal(m_to_ft(1), 3.28084)
    expect_equal(m_to_ft(c(1, 2)), c(3.28084, 2 * 3.28084))

    expect_equal(in_to_cm(1), 2.54)
    expect_equal(in_to_cm(c(1, 10)), c(2.54, 25.4))

    expect_equal(cm_to_in(1), 0.393701)
    expect_equal(cm_to_in(c(1, 10)), c(0.393701, 3.93701))

    expect_equal(ac_to_ha(1), 0.404685642, tolerance = 1e-6)
    expect_equal(ac_to_ha(c(1, 10)), c(0.404685642, 4.04685642),
                 tolerance = 1e-6)

    x_ft <- 24
    x_m <- ft_to_m(x_ft)
    expect_equal(m_to_ft(x_m), x_ft, tolerance = 1e-4)

    x_in <- 15.1
    x_cm <- in_to_cm(x_in)
    expect_equal(cm_to_in(x_cm), x_in, tolerance = 1e-4)

    x_ac <- 6.018046
    x_ha <- ac_to_ha(x_ac)
    expect_equal(ha_to_ac(x_ha), x_ac, tolerance = 1e-4)

    x <- "non-numeric"
    expect_error(ft_to_m(x), "numeric vector")
    expect_error(m_to_ft(x), "numeric vector")
    expect_error(in_to_cm(x), "numeric vector")
    expect_error(cm_to_in(x), "numeric vector")
    expect_error(ac_to_ha(x), "numeric vector")
    expect_error(ha_to_ac(x), "numeric vector")
})
