.PHONY : data test deploy

all : data overview.md

data :
	$(MAKE) -C data-raw

overview.Rmd : overview.R data/PAD_DATA.rda
	R --vanilla --quiet -e 'knitr::spin("$<", knit = FALSE)'

overview.md : overview.Rmd
	R --vanilla --quiet -e 'rmarkdown::render("$<", output_format = "github_document")'

deploy :
	Rscript deploy_app.R

test :
	docker build -t pad .
	docker run --rm -p 3838:3838 pad
