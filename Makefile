all : overview.md

overview.Rmd : overview.R data/PAD_DATA.rda
	R --vanilla --quiet -e 'knitr::spin("$<", knit = FALSE)'

overview.md : overview.Rmd
	R --vanilla --quiet -e 'rmarkdown::render("$<", output_format = "github_document")'
