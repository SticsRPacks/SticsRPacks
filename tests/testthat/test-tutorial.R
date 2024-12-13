
#Download and transform Tutorial .RMD to .R
tmpdir <- normalizePath(tempdir(), winslash = "/", mustWork = FALSE)
tutorial_rmd <- file.path(tmpdir, "SticsRpacks.Rmd")

# file.copy(from = "./../../inst/tutorials/SticsRpacks/SticsRpacks.Rmd",
#           to = tutorial_rmd)
branch <- system("git rev-parse --abbrev-ref HEAD", intern = TRUE)
ini_dir <- getwd()
setwd(tutorial_rmd)
system(paste0("curl -OL https://raw.github.com/SticsRpacks/SticsRPacks/",
              branch,
              "/inst/tutorial/SticsRpacks/SticsRpacks.Rmd"))

setwd(ini_dir)

#download.file("https://raw.githubusercontent.com/SticsRPacks/SticsRPacks/main/inst/tutorials/SticsRpacks/SticsRpacks.Rmd",
#              tutorial_rmd)
xfun::gsub_file(file = tutorial_rmd,
                "eval=FALSE","eval=TRUE",
                fixed = TRUE)

xfun::gsub_file(file = tutorial_rmd,
                "optim_options = list(nb_rep = 3, out_dir = workspace_path)",
                "optim_options = list(nb_rep = 3, out_dir = workspace_path, maxeval = 3)",
                fixed = TRUE)

if (Sys.getenv("CI") != "") {
  xfun::gsub_file(file = tutorial_rmd,
                  "parallel = TRUE","parallel = TRUE, cores = 2",
                  fixed = TRUE)
}

tutorial_r <-file.path(tmpdir, "tutorial.R")
knitr::purl(input = tutorial_rmd,
            output = tutorial_r,
            documentation = 2)


# Test Tutorial
test_tuto_download_javastics <- function() {
  javastics_in_path <- Sys.setenv(javastics_path="")
  source(tutorial_r)
  return (TRUE)
}

test_tuto_local_javastics <- function() {
  # download_url <-
  # "https://w3.avignon.inrae.fr/forge/attachments/download/3337/JavaSTICS-1.5.2-STICS-10.2.0.zip"
  download_url <-
    "https://w3.avignon.inrae.fr/forge/attachments/download/3357/JavaSTICS-latest.zip"
  javastics_path <- download_javastics(download_url)
  Sys.setenv(javastics_path = javastics_path)
  source(tutorial_r)
  return (TRUE)
}

test_that("Test Tutorial", {
  #expect_equal(test_tuto_download_javastics(), TRUE)
  expect_equal(test_tuto_local_javastics(), TRUE)
})
