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
#' @param include_self Logical, TRUE to include the SticsRPacks package
#' FALSE otherwise
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

#' Installing a JavaStics folder to a temporary folder
#'
#' @param download_url Url of the JavaStics to download
#' @param output_dir Target directory where to install Javatics folder
#'
#' @returns Th full path of the JavaStics folder
#'
#' @keywords internal
#' @noRd
#'
#'
download_javastics <- function(download_url, output_dir) {
  words <- strsplit(download_url, split = "/")[[1]]
  zip_name <- words[length(words)]
  zip_path <- file.path(tempdir(), zip_name)
  arch_name <- gsub(
    pattern = "(.*)\\.zip",
    zip_name,
    replacement = "\\1"
  )

  # javastics installation dir
  javastics_install_dir <- file.path(
    output_dir,
    arch_name
  )

  # the extracted zip does not contain a root directory named arch_name
  if (!dir.exists(javastics_install_dir)) dir.create(javastics_install_dir)

  # check content
  # if files/directories exist the install directory
  # has been preserved and prevent dowloading the zip again
  # ly return
  # creating the install dir, if needed

  if (length(list.files(javastics_install_dir)) > 0)
    return(javastics_install_dir)

  # going on downloading and installing javastics
  if (!dir.exists(output_dir)) dir.create(output_dir)

  javastics_tmp <- file.path(tempdir(), "javastics_tmp")
  if (dir.exists(javastics_tmp))
    unlink(javastics_tmp, recursive = TRUE, force = TRUE)

  # get javastics distribution
  user_passwd <- get_forge_userpass("public")
  system(paste0(
    "curl -u ",
    user_passwd,
    " ",
    "-k ",
    download_url,
    " --output ",
    zip_path
  ))

  utils::unzip(zip_path, exdir = javastics_tmp)

  unlink(zip_path)

  tmp_path <- file.path(javastics_tmp, arch_name)
  # The zip archive has not been downloaded previously and cached
  if (!dir.exists(tmp_path)) {
    # copying files/dirs from the javastics_tmp dir to the install directory
    # basename == javastics archive name
    src_path <- javastics_tmp
    file.copy(
      from = list.files(javastics_tmp, full.names = TRUE),
      javastics_install_dir,
      recursive = TRUE,
      overwrite = TRUE,
      copy.mode = TRUE
    )
  } else {
    # the javastics dir == javastics archive name is copied
    # into the install directory
    src_path <- tmp_path
  }
  # Copying either files in a javastics subdir or the javastics directory
  file.copy(
    from = list.files(src_path, full.names = TRUE),
    javastics_install_dir,
    recursive = TRUE,
    overwrite = TRUE,
    copy.mode = TRUE
  )
  if (dir.exists(tmp_path)) unlink(tmp_path, recursive = TRUE, force = TRUE)

  javastics_install_dir
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
    full.names = FALSE
  )

  return(
    gsub(
      pattern = "(jre)([0-9]*)",
      replacement = "\\2",
      x = jre_dir
    )
  )
}

check_java_version <- function(java_target) {
  java <- "java"
  java_path <- Sys.getenv("JAVA")

  if (java_path != "") java <- java_path

  java_version <- get_java_version(cmd = java)

  if (is.null(java_version)) {
    stop("A java version ", java_version, " must be installed")
  }

  if (java_version < as.numeric(java_target)) {
    stop(
      "The default system java virtual machine is ",
      system(paste(java, "-version 2>&1"), intern = TRUE)[1],
      "\nA java ",
      java_target,
      " version installation is needed for running JavaSTICS, \n",
      "or as an alternate version and the java path can be set\n",
      "in the .Renviron file, as for example: \n",
      paste0(
        "JAVA=\"/usr/lib/jvm/java-",
        java_target,
        "-openjdk-amd64/bin/java\""
      )
    )
  }

  # returning java command
  java
}
