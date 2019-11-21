
#' The SticsRPacks logo, using ASCII or Unicode characters
#'
#' Use [crayon::strip_style()] to get rid of the colors.
#'
#' @param unicode Whether to use Unicode symbols. Default is `TRUE`
#'   on UTF-8 platforms.
#'
#' @md
#' @export
#' @examples
#' SticsRPacks_logo()

SticsRPacks_logo <- function(unicode = l10n_info()$`UTF-8`) {
  logo <- c(
    "  ____    _     _                ____    ____                   _           ",
    " / ___|  | |_  (_)   ___   ___  |  _ \\  |  _ \\    __ _    ___  | | __  ___  ",
    " \\___ \\  | __| | |  / __| / __| | |_) | | |_) |  / _` |  / __| | |/ / / __| ",
    "  ___) | | |_  | | | (__  \\__ \\ |  _ <  |  __/  | (_| | | (__  |   <  \\__ \\ ",
    " |____/   \\__| |_|  \\___| |___/ |_| \\_\\ |_|      \\__,_|  \\___| |_|\\_\\ |___/ "
  )


  hexa <- c("*", ".", "o", "*", ".", "*", ".", "o", ".", "*")
  if (unicode) hexa <- c("*" = "\u2b22", "o" = "\u2b21", "." = ".")[hexa]

  cols <- c("red", "yellow", "green", "magenta", "cyan",
            "yellow", "green", "white", "magenta", "cyan")

  col_hexa <- purrr::map2(hexa, cols, ~ crayon::make_style(.y)(.x))

  for (i in 0:9) {
    pat <- paste0("\\b", i, "\\b")
    logo <- sub(pat, col_hexa[[i + 1]], logo)
  }

  structure(crayon::blue(logo), class = "SticsRPacks_logo")
}

#' @export

print.SticsRPacks_logo <- function(x, ...) {
  cat(x, ..., sep = "\n")
  invisible(x)
}
