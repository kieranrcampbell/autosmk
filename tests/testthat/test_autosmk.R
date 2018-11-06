context("Correctness of autosmk output")

inputs <- c(
  'important_csv' = 'data/input_{id}.csv',
  'compressed_R_object' = 'data/input_{id}.rds'
)

outputs <- c(
  'figure' = 'figs/fig_{id}.png'
)

dir <- tempdir()


autosmk('testrule',
        inputs,
        outputs,
        dir,
        open = FALSE)

test_that("templates are correctly produced", {
  rfile <- file.path(dir, paste0('testrule.R'))
  smkfile <- file.path(dir, paste0('testrule.smk'))
  expect_true(file.exists(rfile))
  expect_true(file.exists(smkfile))

  r <- readr::read_file(rfile)
  s <- readr::read_file(smkfile)

  expect_gt(stringr::str_length(r), 5)
  expect_gt(stringr::str_length(s), 5)


})
