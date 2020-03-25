#' Update SticsRPacks packages
#'
#' This will check to see if all SticsRPacks packages are up-to-date, and install the desired version if not.
#'
#' @param ref The desired git reference. Could be a commit, tag, or branch name. Defaults to NULL
#' for the last release of the package.
#'
#' @export
#' @examples
#' \dontrun{
#' # Use the last release:
#' SticsRPacks_update()
#'
#' # Using a particular commit for one:
#' SticsRPacks_update(ref = list(SticsRFiles= "42f9333e1b1c336cf431e2e33dc13caa994a3ae9")
#' # Or a version:
#' SticsRPacks_update(ref = list(SticsRFiles= "v0.1.0.9003")
#'
#' }
SticsRPacks_update <- function(ref = list(SticsRFiles= NULL, CroptimizR= NULL,
                                          SticsOnR= NULL)) {

  if(!is.list(ref)){
    stop("ref must be a list")
  }


  default_ref= list(SticsRFiles= NULL, CroptimizR= NULL, SticsOnR= NULL)

  missing_vals= setdiff(names(default_ref),
                        match.arg(names(ref), names(default_ref), several.ok= TRUE))

  ref[missing_vals]= default_ref[missing_vals]

  # Find the last release if ref== NULL
  ref = mapply(function(x, y) {
    if (is.null(x)) {
      meta <- remotes:::parse_git_repo(file.path("SticsRPacks",
                                                 y))
      meta <- remotes:::github_resolve_ref(remotes::github_release(),
                                           meta, host = "api.github.com")
      meta$ref
    }else{
      x
    }
  }, x = ref, y = names(ref), SIMPLIFY = FALSE)

  repos= file.path("SticsRPacks",names(ref))
  mapply(function(x,y){
    remote= remotes:::github_remote(repo = x, ref = y)
    package_name= remotes:::remote_package_name(remote)
    local_sha= remotes:::local_sha(package_name)
    remote_sha= remotes:::remote_sha(remote, local_sha)
    if (!remotes:::different_sha(remote_sha = remote_sha, local_sha = local_sha)){
        message("Package ",crayon::red(package_name), " is already up-to-date")
    }else{
      remotes::install_github(repo = x, ref = y, dependencies = FALSE)
    }
  }, x= repos, y = unlist(ref), SIMPLIFY = FALSE)

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
  pkgs= utils::installed.packages()
  SticsRPacks_deps_info= pkgs[match("SticsRPacks",pkgs[,1]),2]
  remotes::dev_package_deps(file.path(SticsRPacks_deps_info,"SticsRPacks"))
}

#' Update all SticsRPacks dependencies
#'
#' @export
SticsRPacks_update_deps <- function() {
  update(SticsRPacks_deps())
}
