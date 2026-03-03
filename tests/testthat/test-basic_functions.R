library(testthat)
library(aCePrep)
library(data.table)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Simple sine-wave pulse table (Relative_time x Pressure)
make_dt <- function(n = 30) {
  data.table(
    Relative_time = seq_len(n),
    Pressure      = 80 + 40 * sin(seq_len(n) / 3)
  )
}

# Pulse-wave table matching the structure of predpulsewave
make_predpulse <- function(n = 100) {
  t  <- seq_len(n)
  sys <- 100 + 20 * sin(t / 10)
  dia <-  60 + 10 * sin(t / 10 + 1)
  data.table(
    Relative_time   = t,
    Systolic_Maxima = sys,
    Diastolic_Minima = dia,
    Pulse_Wave      = sys - dia
  )
}

# Wipe globals written by pipeline functions after each test
cleanup_globals <- function() {
  vars <- c("data2", "MaximaRows", "MinimaRows", "FinalMaxima4", "FinalMinima4",
            "FinalMinima3", "predpulsewave", "newvals2", "dapulsewave",
            "inflection_points")
  existing <- vars[sapply(vars, exists, envir = globalenv())]
  if (length(existing) > 0) rm(list = existing, envir = globalenv())
}

# ---------------------------------------------------------------------------
# localMaxima
# ---------------------------------------------------------------------------

test_that("localMaxima returns correct indices for a simple wave", {
  x      <- c(1, 3, 2, 4, 1, 5, 2)
  result <- localMaxima(x)
  expect_type(result, "integer")
  expect_true(2L %in% result)  # peak at index 2 (value 3)
  expect_true(4L %in% result)  # peak at index 4 (value 4)
  expect_true(6L %in% result)  # peak at index 6 (value 5)
})

test_that("localMaxima returns last index for monotone increasing input", {
  # Use numeric (double) to avoid integer overflow in diff(c(-.Machine$integer.max, x))
  result <- localMaxima(as.numeric(1:10))
  expect_equal(result, 10L)
})

test_that("localMaxima returns correct index for two-element input", {
  # Ascending: peak at index 2
  expect_true(2L %in% localMaxima(as.numeric(c(3, 5))))
})

test_that("localMaxima returns only valid row indices (within bounds)", {
  x      <- c(2, 5, 3, 7, 4, 9, 6)
  result <- localMaxima(x)
  expect_true(all(result >= 1L & result <= length(x)))
})

# ---------------------------------------------------------------------------
# calcLocalMax
# ---------------------------------------------------------------------------

test_that("calcLocalMax assigns MaximaRows to global env", {
  on.exit(cleanup_globals())
  dt <- make_dt()
  suppressWarnings(expect_no_error(calcLocalMax(dt)))
  expect_true(exists("MaximaRows", envir = globalenv()))
  mr <- get("MaximaRows", envir = globalenv())
  expect_true(nrow(mr) > 0)
  expect_true(all(c("Pressure", "Relative_time") %in% names(mr)))
})

test_that("calcLocalMax MaximaRows contains only rows from original data", {
  on.exit(cleanup_globals())
  dt <- make_dt()
  suppressWarnings(calcLocalMax(dt))
  mr <- get("MaximaRows", envir = globalenv())
  expect_true(all(mr$Relative_time %in% dt$Relative_time))
})

# ---------------------------------------------------------------------------
# calcLocalMin
# ---------------------------------------------------------------------------

test_that("calcLocalMin assigns MinimaRows to global env", {
  on.exit(cleanup_globals())
  dt <- make_dt()
  suppressWarnings(expect_no_error(calcLocalMin(dt)))
  expect_true(exists("MinimaRows", envir = globalenv()))
  mr <- get("MinimaRows", envir = globalenv())
  expect_true(nrow(mr) > 0)
  expect_true(all(c("Pressure", "Relative_time") %in% names(mr)))
})

# ---------------------------------------------------------------------------
# localvalremoveMax
# ---------------------------------------------------------------------------

test_that("localvalremoveMax assigns FinalMaxima4 with no large pressure jumps", {
  on.exit(cleanup_globals())
  dt <- make_dt(30)
  suppressWarnings(calcLocalMax(dt))
  mr <- get("MaximaRows", envir = globalenv())
  suppressWarnings(expect_no_error(localvalremoveMax(mr)))
  expect_true(exists("FinalMaxima4", envir = globalenv()))
  fm4 <- get("FinalMaxima4", envir = globalenv())
  expect_true(is.data.frame(fm4))
  if (nrow(fm4) > 1) {
    diffs <- abs(diff(fm4$Pressure))
    expect_true(all(diffs <= 100))
  }
})

# ---------------------------------------------------------------------------
# localvalremoveMin
# ---------------------------------------------------------------------------

test_that("localvalremoveMin assigns FinalMinima4 with no large pressure jumps", {
  on.exit(cleanup_globals())
  dt <- make_dt(30)
  suppressWarnings(calcLocalMin(dt))
  mr <- get("MinimaRows", envir = globalenv())
  suppressWarnings(expect_no_error(localvalremoveMin(mr)))
  expect_true(exists("FinalMinima4", envir = globalenv()))
  fm4 <- get("FinalMinima4", envir = globalenv())
  expect_true(is.data.frame(fm4))
  if (nrow(fm4) > 1) {
    diffs <- abs(diff(fm4$Pressure))
    expect_true(all(diffs <= 100))
  }
})

# ---------------------------------------------------------------------------
# nonparam
# ---------------------------------------------------------------------------

test_that("nonparam assigns predpulsewave with correct columns", {
  on.exit(cleanup_globals())
  maxima <- data.table(
    Relative_time = c(10, 30, 50, 70, 90, 110, 130, 150),
    Pressure      = c(120, 125, 118, 130, 122, 128, 115, 132)
  )
  minima <- data.table(
    Relative_time = c(5, 20, 40, 60, 80, 100, 120, 140),
    Pressure      = c(70, 72, 68, 75, 71, 73, 69, 74)
  )
  suppressWarnings(expect_no_error(nonparam(maxima, minima, "test")))
  expect_true(exists("predpulsewave", envir = globalenv()))
  ppw <- get("predpulsewave", envir = globalenv())
  expect_true(all(c("Relative_time", "Pulse_Wave",
                    "Systolic_Maxima", "Diastolic_Minima") %in% names(ppw)))
})

test_that("nonparam Pulse_Wave equals Systolic_Maxima minus Diastolic_Minima", {
  on.exit(cleanup_globals())
  maxima <- data.table(
    Relative_time = c(10, 30, 50, 70, 90, 110, 130, 150),
    Pressure      = c(120, 125, 118, 130, 122, 128, 115, 132)
  )
  minima <- data.table(
    Relative_time = c(5, 20, 40, 60, 80, 100, 120, 140),
    Pressure      = c(70, 72, 68, 75, 71, 73, 69, 74)
  )
  suppressWarnings(nonparam(maxima, minima, "test"))
  ppw <- get("predpulsewave", envir = globalenv())
  expect_equal(ppw$Pulse_Wave,
               ppw$Systolic_Maxima - ppw$Diastolic_Minima,
               tolerance = 1e-10)
})

# ---------------------------------------------------------------------------
# firstdev
# ---------------------------------------------------------------------------

test_that("firstdev assigns dapulsewave with a 'da' column and writes PNG", {
  on.exit(cleanup_globals())
  ppw <- make_predpulse(100)
  withr::with_tempdir({
    suppressWarnings(expect_no_error(firstdev(ppw, "test")))
    expect_true(exists("dapulsewave", envir = globalenv()))
    da <- get("dapulsewave", envir = globalenv())
    expect_true("da" %in% names(da))
    expect_true(file.exists("FirstDev_test.png"))
  })
})

test_that("firstdev dapulsewave has one fewer row than input (first row dropped)", {
  on.exit(cleanup_globals())
  ppw <- make_predpulse(100)
  withr::with_tempdir({
    suppressWarnings(firstdev(ppw, "test"))
    da <- get("dapulsewave", envir = globalenv())
    expect_equal(nrow(da), nrow(ppw) - 1L)
  })
})

# ---------------------------------------------------------------------------
# initialslope
# ---------------------------------------------------------------------------

test_that("initialslope writes a file containing linear regression output", {
  ppw <- make_predpulse(100)
  withr::with_tempdir({
    suppressWarnings(expect_no_error(initialslope(ppw, "test")))
    expect_true(file.exists("test_linearregression"))
    content <- readLines("test_linearregression")
    expect_true(any(grepl("Coefficients", content)))
  })
})

# ---------------------------------------------------------------------------
# inflecpoints
# ---------------------------------------------------------------------------

test_that("inflecpoints assigns inflection_points to global env", {
  on.exit(cleanup_globals())
  ppw    <- make_predpulse(100)
  da_tbl <- copy(ppw)
  da_tbl[, da := c(0, diff(Pulse_Wave))]
  suppressWarnings(expect_no_error(inflecpoints(da_tbl)))
  expect_true(exists("inflection_points", envir = globalenv()))
  ip <- get("inflection_points", envir = globalenv())
  expect_true(is.data.frame(ip))
})

test_that("inflecpoints result excludes first and last Relative_time values", {
  on.exit(cleanup_globals())
  ppw    <- make_predpulse(100)
  da_tbl <- copy(ppw)
  da_tbl[, da := c(0, diff(Pulse_Wave))]
  suppressWarnings(inflecpoints(da_tbl))
  ip <- get("inflection_points", envir = globalenv())
  a  <- min(da_tbl$Relative_time)
  b  <- max(da_tbl$Relative_time)
  expect_false(a %in% ip$Relative_time)
  expect_false(b %in% ip$Relative_time)
})
