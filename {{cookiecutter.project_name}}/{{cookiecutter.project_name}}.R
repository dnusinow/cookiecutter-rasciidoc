#### @knitr load-libraries

## Wrap this so we don't leak variables to the working namespace. We'll use the
## dot prefix convention that the tidyverse uses
.top.level <- (function() {
    cur.dir <- path.expand(getwd())
    while (TRUE) {
        if (".git" %in% dir(cur.dir, all.files = TRUE)) {
            return(cur.dir)
        }
        next.up <- dirname(cur.dir)
        if (next.up == cur.dir) {
            stop("Couldn't find .git directory")
        }
        cur.dir <- next.up
    }
})()

renv::activate(.top.level)

library("tidyverse")
suppressMessages(library("magrittr"))
library("ggplot2")
library("RColorBrewer")
library("ggrepel")
library("broom")
library("pheatmap")

source(file.path(.top.level, "analysis", "common", "theme_dpn_bw.R"))
source(file.path(.top.level, "analysis", "common", "sized_ggsave.R"))

#### @knitr init-no-cache
## Initialize things that we don't want knitr to cache here. That includes
## things like setting up the workspace and initializing database handles

## Wrap this so we don't leak variables to the working namespace
(function() {
    for (project.dir in c("data", "export", "figure", "Rdata")) {
        if (!dir.exists(project.dir)) {
            dir.create(project.dir)
        }
    }
})()

#### @knitr metadata

analysis.fname.pfx <- "{{cookiecutter.project_name}}_"
figure.pfx <- file.path("figure", analysis.fname.pfx)
export.pfx <- file.path("export", analysis.fname.pfx)

#### @knitr infrastructure

#### @knitr data

#### @knitr cleanup-no-cache
## Cleanup that we want executed every time, so we don't want knitr to cache it.
## This includes things like closing database handles and files

renv::snapshot()
