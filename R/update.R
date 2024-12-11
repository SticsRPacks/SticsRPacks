#' Update SticsRPacks packages
#'
#' This will check to see if all SticsRPacks packages are up-to-date, and install the desired version if not.
#'
#' @param ref The desired git reference. Could be a commit, tag, or branch name. Defaults to NULL
#' for the latest release of the package.
#'
#' @export
#' @examples
#' \dontrun{
#' # Use the latest release:
#' SticsRPacks_update()
#'
#' # Using a particular commit for one:
#' SticsRPacks_update(ref = list(SticsRFiles = "42f9333e1b1c336cf431e2e33dc13caa994a3ae9"))
#' # Or a version:
#' SticsRPacks_update(ref = list(SticsRFiles = "v0.1.0.9003"))
#' }
SticsRPacks_update <- function(ref = list(
                                 SticsRFiles = NULL, CroptimizR = NULL,
                                 SticsOnR = NULL, CroPlotR = NULL
                               )) {
  if (!is.list(ref)) {
    stop("ref must be a list")
  }

  default_ref <- list(SticsRFiles = NULL, CroptimizR = NULL, SticsOnR = NULL, CroPlotR = NULL)

  missing_vals <- setdiff(
    names(default_ref),
    match.arg(names(ref), names(default_ref), several.ok = TRUE)
  )

  ref[missing_vals] <- default_ref[missing_vals]

  repos <- file.path("SticsRPacks", names(ref))

  for (i in seq_along(ref)) {
    if (is.null(ref[[i]])) {
      # If the user does not give anything, we take the latest release:
      out <- utils::capture.output(remotes::install_github(repo = paste0(repos[i], "@*release"), dependencies = FALSE), type = "message")
      if (any(grepl("Skipping install", out))) {
        message("Package ", crayon::red(gsub("SticsRPacks/", "", names(ref)[i])), " is already up-to-date")
      }
    } else {
      remotes::install_github(repo = repos[i], ref = ref[[i]], dependencies = FALSE)
    }
  }

  invisible()
}

#' Get a situation report on SticsRPacks
#'
#' This function gives a quick overview of the versions of R and RStudio as
#' well as all SticsRPacks packages. It's primarily designed to help you get
#' a quick idea of what's going on when you're helping someone else debug
#' a problem.
#'
#' @export
SticsRPacks_sitrep <- function() {
  cli::cat_rule("R & RStudio")
  if (rstudioapi::isAvailable()) {
    cli::cat_bullet("RStudio: ", rstudioapi::getVersion())
  }
  cli::cat_bullet("R: ", getRversion())

  deps <- SticsRPacks_deps()
  package_pad <- format(deps$package)
  packages <- ifelse(
    deps$behind,
    paste0(cli::col_yellow(cli::style_bold(package_pad)), " (", deps$local, " < ", deps$cran, ")"),
    paste0(package_pad, " (", deps$cran, ")")
  )

  cli::cat_rule("Core packages")
  cli::cat_bullet(packages[deps$package %in% core])
  cli::cat_rule("Non-core packages")
  cli::cat_bullet(packages[!deps$package %in% core])
}

#' List all SticsRPacks dependencies
#'
#' @export
SticsRPacks_deps <- function() {
  pkgs <- utils::installed.packages()
  SticsRPacks_deps_info <- pkgs[match("SticsRPacks", pkgs[, 1]), 2]
  df <- remotes::dev_package_deps(file.path(SticsRPacks_deps_info, "SticsRPacks"))

  df$behind <-
    base::package_version(df$available, strict = FALSE) <
      base::package_version(df$installed, strict = FALSE)

  df
}

#' Update all SticsRPacks dependencies
#'
#' @export
SticsRPacks_update_deps <- function() {
  remotes::update_packages(SticsRPacks_deps()$package)
}
