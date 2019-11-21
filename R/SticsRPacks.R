#' @keywords internal
"_PACKAGE"

# Suppress R CMD check note
#' @importFrom broom tidy
NULL


release_bullets <- function() {
  c(
    '`usethis::use_latest_dependencies(TRUE, "CRAN")`'
  )
}
