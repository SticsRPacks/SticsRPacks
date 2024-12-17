options(warn=-1)

import::from(xfun, gsub_file)
import::from(knitr, purl)
#Download and transform Tutorial .RMD to .R
# tmpdir <- normalizePath(tempdir(), winslash = "/", mustWork = FALSE)
# tutorial_rmd <- file.path(tmpdir, "SticsRpacks.Rmd")


#branch <- system("git rev-parse --abbrev-ref HEAD", intern = TRUE)

# download.file(url = paste0("https://raw.githubusercontent.com/SticsRPacks/SticsRPacks/",
#                            branch,
#                            "/inst/tutorials/SticsRpacks/SticsRpacks.Rmd"), destfile = tutorial_rmd)
#download.file("https://raw.githubusercontent.com/SticsRPacks/SticsRPacks/main/inst/tutorials/SticsRpacks/SticsRpacks.Rmd",
#              tutorial_rmd)

#print(list.files(getwd()))

# tutorial_rmd <- normalizePath(
#   path = "./../../inst/tutorials/SticsRpacks/SticsRpacks.Rmd"
# )
tutorial_rmd <- normalizePath(
  system.file("tutorials/SticsRpacks/SticsRpacks.Rmd", package = "SticsRPacks"),
  mustWork = TRUE
)


#tutorial_test_rmd <- file.path(dirname(tutorial_rmd), "SticsRpacks_test.Rmd")

tutorial_test_rmd <- "SticsRpacks_test.Rmd"
file.copy(from = tutorial_rmd,
          to = tutorial_test_rmd)

# print(tmpdir)
# print(list.files(tmpdir))
# #stop("debug download in test", branch)
# stop("debug")

gsub_file(file = tutorial_test_rmd,
                "eval=FALSE","eval=TRUE",
                fixed = TRUE)

gsub_file(file = tutorial_test_rmd,
                "optim_options = list(nb_rep = 3, out_dir = workspace_path)",
                "optim_options = list(nb_rep = 3, out_dir = workspace_path, maxeval = 3)",
                fixed = TRUE)

if (Sys.getenv("CI") != "") {
  gsub_file(file = tutorial_test_rmd,
                  "parallel = TRUE","parallel = TRUE, cores = 2",
                  fixed = TRUE)
}

# removing outputs from get_sim
gsub_file(file = tutorial_test_rmd,
                "get_sim(workspace = workspace_path)",
                "x <- get_sim(workspace = workspace_path)",
                fixed = TRUE)

gsub_file(file = tutorial_test_rmd,
                'get_sim(workspace = workspace_path, usm = c("banana", "Turmeric"))',
                'x <- get_sim(workspace = workspace_path, usm = c("banana", "Turmeric"))',
                fixed = TRUE)

gsub_file(file = tutorial_test_rmd,
                'get_sim(workspace = workspace_path, usm = c("wheat", "maize"), var = "lai_n")',
                'x <- get_sim(workspace = workspace_path, usm = c("wheat", "maize"), var = "lai_n")',
                fixed = TRUE)

gsub_file(file = tutorial_test_rmd,
                "print(sim)",
                "",
                fixed = TRUE)

gsub_file(file = tutorial_test_rmd,
                "print(p)",
                "",
                fixed = TRUE)


gsub_file(file = tutorial_test_rmd,
                "print(res1)",
                "",
                fixed = TRUE)

gsub_file(file = tutorial_test_rmd,
                "print(res2)",
                "",
                fixed = TRUE)

#tutorial_r <- file.path(tmpdir, "tutorial.R")
# Creating a R script from the tutorial Rmd file
#tutorial_test_r <- file.path(dirname(tutorial_test_rmd), "tutorial.R")
tutorial_test_r <- "tutorial_test.R"

purl(input = tutorial_test_rmd,
            output = tutorial_test_r,
            documentation = 2)


# Running the Tutorial script for
# Default use case with downloading JavaStics from the forge
test_tuto_download_javastics <- function() {
  javastics_in_path <- Sys.setenv(javastics_path="")
  source(tutorial_test_r)
  return (TRUE)
}
# Local JavaStics installation use case
test_tuto_local_javastics <- function() {
  # download_url <-
  # "https://w3.avignon.inrae.fr/forge/attachments/download/3337/JavaSTICS-1.5.2-STICS-10.2.0.zip"
  download_url <-
    "https://w3.avignon.inrae.fr/forge/attachments/download/3357/JavaSTICS-latest.zip"
  javastics_path <- download_javastics(download_url)
  Sys.setenv(javastics_path = javastics_path)
  source(tutorial_test_r)
  return (TRUE)
}

test_that("Test Tutorial", {
  #expect_equal(test_tuto_download_javastics(), TRUE)
  expect_equal(test_tuto_local_javastics(), TRUE)
})

unlink(tutorial_test_rmd)

unlink(tutorial_test_r)
