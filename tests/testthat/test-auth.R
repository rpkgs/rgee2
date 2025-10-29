test_that("auth works", {
  # ci_auth()
  if (Sys.getenv("GITHUB_ACTIONS") == "true") {
    print("GitHub Actions 环境下执行认证")
    # ci_auth()
  }

  # token <- paste(readLines("token.json", encoding = "UTF-8"), collapse = "")
  token <- Sys.getenv("EARTHENGINE_TOKEN")

  tryCatch({
    python <- system("which python")
    print(python)

    # use_backend()
    Sys.setenv(RETICULATE_PYTHON = python)
    reticulate::py_config()

    print(system("pip list earthengine-api | grep earthengine-api"))
    ee_auth_ci(token)
  }, error = function(e) {
    message(sprintf("%s", e$message))
  })
})
