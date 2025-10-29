# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

if (Sys.getenv("GITHUB_ACTIONS") == "true") {
  print("GitHub Actions 环境下执行认证")
}


Sys.getenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON = Sys.which("python"))

reticulate::use_python(Sys.which("python"))


tryCatch({
  print(Sys.which("python"))
  print(Sys.which("python3"))

  Sys.setenv(RETICULATE_PYTHON = Sys.which("python"))
  # print(python)
}, error = function(e) {
  message(sprintf('%s', e$message))
})


library(testthat)
library(rgee2)

# test_check("rgee2")
test_that("auth works", {
  # token <- paste(readLines("token.json", encoding = "UTF-8"), collapse = "")
  tryCatch({
    reticulate::py_config()
  }, error = function(e) {
    message(sprintf('%s', e$message))
  })


  tryCatch({
    # use_backend()
    # Sys.setenv(RETICULATE_PYTHON = python)
    print(system("pip list earthengine-api | grep earthengine-api"))
    token <- Sys.getenv("EARTHENGINE_TOKEN")
    ee_auth_ci(token)
  }, error = function(e) {
    message(sprintf("%s", e$message))
  })
  
})
