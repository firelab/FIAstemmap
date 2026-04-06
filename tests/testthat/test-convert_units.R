test_that("convert_units works", {
    expect_equal(ft_to_m(1), 0.3048)
    expect_equal(ft_to_m(c(1, 10)), c(0.3048, 3.048))

    expect_equal(m_to_ft(1), 3.28084)
    expect_equal(m_to_ft(c(1, 2)), c(3.28084, 2 * 3.28084))

    expect_equal(in_to_cm(1), 2.54)
    expect_equal(in_to_cm(c(1, 10)), c(2.54, 25.4))

    expect_equal(cm_to_in(1), 0.393701)
    expect_equal(cm_to_in(c(1, 10)), c(0.393701, 3.93701))

    x_ft <- 24
    x_m <- ft_to_m(x_ft)
    expect_equal(m_to_ft(x_m), x_ft, tolerance = 1e-4)
    expect_equal(ft_to_m(x_ft), x_m, tolerance = 1e-4)

    x_in <- 15.1
    x_cm <- in_to_cm(x_in)
    expect_equal(cm_to_in(x_cm), x_in, tolerance = 1e-4)
    expect_equal(in_to_cm(x_in), x_cm, tolerance = 1e-4)

    x <- "char"
    expect_error(ft_to_m(x), "numeric vector")
    expect_error(m_to_ft(x), "numeric vector")
    expect_error(in_to_cm(x), "numeric vector")
    expect_error(cm_to_in(x), "numeric vector")
})
