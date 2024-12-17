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
  if (length(x) == 0) {
    return()
  }
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

  if (type == "public") {
    return("stics_user:w10lptr6405")
  }

  if (type == "internal") {
    return("stics_eps:w10lptr6405")
  }
}

download_javastics <- function(download_url, output_dir = tempdir()) {

  javastics_dir <- list.files(output_dir,
                              recursive = FALSE,
                              full.names = FALSE,
                              pattern = "^JavaSTICS")
  if (length(javastics_dir) == 0) {
    # get javastics lastest version
    s <- strsplit(download_url, split = "/")[[1]]
    zip_name <- s[length(s)]
    zip_path <- file.path(output_dir, zip_name)
    user_passwd <- get_forge_userpass("public")
    system(paste0("curl -u ",
                  user_passwd,
                  " ",
                  "-k ",
                  download_url,
                  " --output ",
                  zip_path))
    utils::unzip(zip_path, exdir = output_dir)

    if (file.exists(zip_path)) unlink(zip_path)

  }


  # javastics_dir <-  gsub(pattern = "(.*)/(.*)\\.zip$",
  #                        x = download_url, replacement = "\\2")


  #zip_path <- file.path(output_dir, paste0(javastics_dir, ".zip"))
  #output_path <- file.path(output_dir, javastics_dir)
  # if (!dir.exists(file.path(output_dir, javastics_dir))) {
  #
  # }

  #if (file.exists(zip_path)) unlink(zip_path)

  javastics_dir <- list.files(output_dir,
                              recursive = FALSE,
                              full.names = FALSE,
                              pattern = "^JavaSTICS")

  return(file.path(output_dir, javastics_dir))

}

get_java_version <- function(cmd = "java") {
  version <- NULL
  if (SticsRFiles:::is_unix()) {
    version_str <-
      suppressWarnings(
        system(
          paste(
            cmd,
            '-version 2>&1 | head -n 1 | cut -d\\" -f 2'
          ),
          intern = TRUE
        )
      )
    if (grepl("1\\.8", version_str)) {
      field <- 2
    } else {
      field <- 1
    }

    version_str <-
      suppressWarnings(
        system(
          paste0("echo ", "'", version_str, "'", " | cut -d\\. -f ", field),
          intern = TRUE
        )
      )

    if (length(grep("not found", version_str)) > 0) {
      version <- NULL
    } else {
      version <- as.numeric(version_str)
    }
  }
  if (length(version) == 0) version <- NULL
  return(version)
}

get_javastics_java_version <- function(javastics_path) {
  jre_dir <- list.dirs(
    file.path(javastics_path, "bin"),
    recursive = FALSE,
    full.names = FALSE)

  return(
    gsub(pattern = "(jre)([0-9]*)",
         replacement = "\\2",
         x = jre_dir)
  )
}

check_java_version <- function(java_target) {
  java <- "java"
  java_path <- Sys.getenv("JAVA")

  if (java_path != "") java <- java_path

  java_version <- get_java_version(cmd = java)

  if (is.null(java_version)) {
    stop("A java version 11 must be installed")
  }


  if (java_version < as.numeric(java_target)) {
    stop(
      "The default system java virtual machine is ",
      system(paste(java, "-version 2>&1"),
             intern = TRUE
      )[1],
      "\nA java ", java_target, " version installation is needed for running JavaSTICS, \n",
      "or as an alternate version and the java path can be set\n",
      "in the .Renviron file, as for example: \n",
      paste0("JAVA=\"/usr/lib/jvm/java-", java_target, "-openjdk-amd64/bin/java\"")
    )
  }

  # returning java command
  return(java)
}
