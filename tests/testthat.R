# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

fprintf <- function(...) cat(sprintf(...))

if (Sys.getenv("GITHUB_ACTIONS") == "true") {

  fprintf("RETICULATE_PYTHON: %s\n", Sys.getenv("RETICULATE_PYTHON"))
  
  Sys.setenv(RETICULATE_PYTHON = Sys.which("python")) # Set Python interpreter
  reticulate::use_python(Sys.which("python"))         # double confirm
}

library(testthat)
library(rgee2)

auth <- function() {
  # token <- paste(readLines("token.json", encoding = "UTF-8"), collapse = "")
  tryCatch({
    # use_backend()
    print(system("pip list earthengine-api | grep earthengine-api"))
    token <- Sys.getenv("EARTHENGINE_TOKEN")
    ee_auth_ci(token)
  }, error = function(e) {
    message(sprintf("%s", e$message))
  })
}

# test_check("rgee2")
test_that("auth works", {
  expect_no_error(auth())
})
