library(testthat)
library(aCePrep)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

cleanup_globals <- function() {
  vars <- c("data2", "MaximaRows", "MinimaRows", "FinalMaxima4", "FinalMinima4",
            "FinalMinima3", "predpulsewave", "newvals2", "dapulsewave",
            "inflection_points", "Pre", "Post", "Line")
  existing <- vars[sapply(vars, exists, envir = globalenv())]
  if (length(existing) > 0) rm(list = existing, envir = globalenv())
}

testdata_path <- function(filename) {
  system.file("testdata", filename, package = "aCePrep")
}

# ---------------------------------------------------------------------------
# Test data layout (inst/testdata/)
#
#  MadhavRamesh_PreT.png   -- pre-exercise,  treatment group
#  MadhavRamesh_PostT.png  -- post-exercise, treatment group
#  MadhavRamesh_PreC.png   -- pre-exercise,  control group
#  MadhavRamesh_PostC.png  -- post-exercise, control group
#  MadhaveRamesh_Pre.png   -- full-size pre-exercise screenshot
#  MadhaveRamesh_Post.png  -- full-size post-exercise screenshot
#
# All tests are skipped automatically if the relevant file is absent.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Image_Process
# ---------------------------------------------------------------------------

test_that("Image_Process extracts black-pixel coordinates from a pre PNG", {
  png_path <- testdata_path("MadhavRamesh_PreT.png")
  skip_if(nchar(png_path) == 0, "MadhavRamesh_PreT.png not found in inst/testdata/")

  withr::with_tempdir({
    suppressWarnings(
      expect_no_error(Image_Process(png_path, "MadhavRamesh_Pre", "T"))
    )
    expect_true(file.exists("MadhavRamesh_PreT.csv"))
    dat <- read.csv("MadhavRamesh_PreT.csv", header = FALSE)
    expect_equal(ncol(dat), 2)   # x and y columns only
    expect_true(nrow(dat) > 0)   # at least some black pixels found
  })
})

test_that("Image_Process extracts black-pixel coordinates from a post PNG", {
  png_path <- testdata_path("MadhavRamesh_PostT.png")
  skip_if(nchar(png_path) == 0, "MadhavRamesh_PostT.png not found in inst/testdata/")

  withr::with_tempdir({
    suppressWarnings(
      expect_no_error(Image_Process(png_path, "MadhavRamesh_Post", "T"))
    )
    expect_true(file.exists("MadhavRamesh_PostT.csv"))
    dat <- read.csv("MadhavRamesh_PostT.csv", header = FALSE)
    expect_equal(ncol(dat), 2)
    expect_true(nrow(dat) > 0)
  })
})

# ---------------------------------------------------------------------------
# aCe_pre  (Image_Process -> aCe_pre)
# ---------------------------------------------------------------------------

test_that("aCe_pre pipeline completes on treatment pre-exercise data", {
  png_path <- testdata_path("MadhavRamesh_PreT.png")
  skip_if(nchar(png_path) == 0, "MadhavRamesh_PreT.png not found in inst/testdata/")

  on.exit(cleanup_globals())

  withr::with_tempdir({
    # Step 1: image extraction
    suppressWarnings(Image_Process(png_path, "MadhavRamesh_Pre", "T"))

    # Step 2: pulse-wave analysis
    suppressWarnings(
      expect_no_error(aCe_pre("MadhavRamesh_PreT.csv", "MadhavRamesh"))
    )

    # Global intermediates
    expect_true(exists("predpulsewave",     envir = globalenv()))
    expect_true(exists("dapulsewave",       envir = globalenv()))
    expect_true(exists("inflection_points", envir = globalenv()))

    ppw <- get("predpulsewave", envir = globalenv())
    expect_true(all(c("Relative_time", "Pulse_Wave") %in% names(ppw)))
    expect_true(nrow(ppw) > 0)

    # Output files
    expect_true(file.exists("inflectionpointsMadhavRamesh_Pre.csv"))
    expect_true(file.exists("FirstDev_MadhavRamesh_Pre.png"))
    expect_true(file.exists("MadhavRamesh_Pre_linearregression"))

    # Corrected_time = Relative_time / 2.16
    ip_csv <- read.csv("inflectionpointsMadhavRamesh_Pre.csv",
                       check.names = FALSE)
    expect_equal(ip_csv$Corrected_time,
                 ip_csv$Relative_time / 2.16,
                 tolerance = 1e-6)
  })
})

# ---------------------------------------------------------------------------
# aCe_post  (Image_Process -> aCe_post)
# ---------------------------------------------------------------------------

test_that("aCe_post pipeline completes on treatment post-exercise data", {
  png_path <- testdata_path("MadhavRamesh_PostT.png")
  skip_if(nchar(png_path) == 0, "MadhavRamesh_PostT.png not found in inst/testdata/")

  on.exit(cleanup_globals())

  withr::with_tempdir({
    suppressWarnings(Image_Process(png_path, "MadhavRamesh_Post", "T"))

    suppressWarnings(
      expect_no_error(aCe_post("MadhavRamesh_PostT.csv", "MadhavRamesh"))
    )

    expect_true(exists("predpulsewave",     envir = globalenv()))
    expect_true(exists("dapulsewave",       envir = globalenv()))
    expect_true(exists("inflection_points", envir = globalenv()))

    expect_true(file.exists("inflectionpointsMadhavRamesh_Post.csv"))
    expect_true(file.exists("FirstDev_MadhavRamesh_Post.png"))
    expect_true(file.exists("MadhavRamesh_Post_linearregression"))
  })
})

# ---------------------------------------------------------------------------
# aCe_demo  (full pre + post pipeline with overlay graph)
# ---------------------------------------------------------------------------

test_that("aCe_demo produces overlay graph for treatment group", {
  pre_path  <- testdata_path("MadhavRamesh_PreT.png")
  post_path <- testdata_path("MadhavRamesh_PostT.png")
  skip_if(nchar(pre_path) == 0 || nchar(post_path) == 0,
          "Treatment PNG files not found in inst/testdata/")

  on.exit(cleanup_globals())

  withr::with_tempdir({
    suppressWarnings(Image_Process(pre_path,  "MadhavRamesh_Pre",  "T"))
    suppressWarnings(Image_Process(post_path, "MadhavRamesh_Post", "T"))

    suppressWarnings(
      expect_no_error(
        aCe_demo("MadhavRamesh_PreT.csv", "MadhavRamesh_PostT.csv", "MadhavRamesh")
      )
    )

    # Clientgraph saves the overlay PNG
    expect_true(file.exists("ClientGraph_MadhavRamesh.png"))
  })
})

test_that("aCe_demo produces overlay graph for control group", {
  pre_path  <- testdata_path("MadhavRamesh_PreC.png")
  post_path <- testdata_path("MadhavRamesh_PostC.png")
  skip_if(nchar(pre_path) == 0 || nchar(post_path) == 0,
          "Control PNG files not found in inst/testdata/")

  on.exit(cleanup_globals())

  withr::with_tempdir({
    suppressWarnings(Image_Process(pre_path,  "MadhavRamesh_Pre",  "C"))
    suppressWarnings(Image_Process(post_path, "MadhavRamesh_Post", "C"))

    suppressWarnings(
      expect_no_error(
        aCe_demo("MadhavRamesh_PreC.csv", "MadhavRamesh_PostC.csv", "MadhavRamesh")
      )
    )

    expect_true(file.exists("ClientGraph_MadhavRamesh.png"))
  })
})
