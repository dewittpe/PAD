all : ../data/PAD_DATA.rda

../data/PAD_DATA.rda : pad-data.R
	R CMD BATCH --vanilla $<

