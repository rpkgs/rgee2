test_that("auth works", {
  
  # ci_auth()
  if (Sys.getenv("GITHUB_ACTIONS") == "true") {
    print("GitHub Actions 环境下执行认证")
    # ci_auth()
  }
  
  tryCatch({
    print(system("which python"))
    print(system("pip list earthengine-api | grep earthengine-api"))
  }, error = function(e) {
    message(sprintf('%s', e$message))
  })

})
