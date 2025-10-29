test_that("auth works", {
  
  ci_auth()
  
  if (Sys.getenv("GITHUB_ACTIONS") == "true") {
    ci_auth()
  }
})


