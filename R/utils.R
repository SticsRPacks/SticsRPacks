msg <- function(..., startup = FALSE) {
  if (startup) {
    if (!isTRUE(getOption("SticsRPacks.quiet"))) {
      packageStartupMessage(text_col(...))
    }
  } else {
    message(text_col(...))
  }
}

text_col <- function(x) {
  # If RStudio not available, messages already printed in black
  if (!rstudioapi::isAvailable()) {
    return(x)
  }

  if (!rstudioapi::hasFun("getThemeInfo")) {
    return(x)
  }

  theme <- rstudioapi::getThemeInfo()

  if (isTRUE(theme$dark)) crayon::white(x) else crayon::black(x)

}

#' List all packages in SticsRPacks
#'
#' @param include_self Include SticsRPacks in the list?
#' @export
#' @examples
#' SticsRPacks_packages()
SticsRPacks_packages <- function(include_self = TRUE) {
  raw <- utils::packageDescription("SticsRPacks")$Imports
  imports <- strsplit(raw, ",")[[1]]
  parsed <- gsub("^\\s+|\\s+$", "", imports)
  names <- vapply(strsplit(parsed, "\\s+"), "[[", 1, FUN.VALUE = character(1))

  if (include_self) {
    names <- c(names, "SticsRPacks")
  }

  names
}

invert <- function(x) {
  if (length(x) == 0) return()
  stacked <- utils::stack(x)
  tapply(as.character(stacked$ind), stacked$values, list)
}


style_grey <- function(level, ...) {
  crayon::style(
    paste0(...),
    crayon::make_style(grDevices::grey(level), grey = TRUE)
  )
}


get_forge_userpass <- function(type = "public") {
  # public or internal (EPS)

  if(type == "public") return("stics_user:w10lptr6405")

  if(type == "internal") return("stics_eps:w10lptr6405")

}

download_javastics <- function(download_url, output_dir = tempdir()) {

  # get javastics last version
  user_passwd <- SticsRPacks:::get_forge_userpass("public")

  javastics_dir <-  gsub(pattern = "(.*)/(.*)\\.zip$",
                         x = download_url, replacement = "\\2")


  zip_path <- file.path(output_dir, paste0(javastics_dir, ".zip"))
  #output_path <- file.path(output_dir, javastics_dir)
  if (!dir.exists(file.path(output_dir, javastics_dir))) {
    system(paste0("curl -u ",
                  user_passwd,
                  " ",
                  "-k ",
                  download_url,
                  " --output ",
                  zip_path))
    unzip(zip_path, exdir = output_dir)
  }

  if (file.exists(zip_path)) unlink(zip_path)

  return(file.path(output_dir, javastics_dir))

}
