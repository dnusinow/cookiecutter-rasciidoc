.PRECIOUS: %.asciidoc sqlite/%.data sqlite/%.stamp sqlite/%.sql

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-%]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


# Knitr

clean: ## Delete the individual asciidoc and html files
	rm -f *.asciidoc *.html

rlibs:
	grep -Fh library *R | sed -r -e 's/.*library\("?//' -e 's/".*//' | sort | uniq

%.html: %.asciidoc html.conf ## Build the html file for a given filename
	asciidoc -b xhtml11 -f html.conf -a data-uri -a icons -a toc2 -a toclevels=4 -d article -o $@ $<

%.asciidoc: %.Rasciidoc %.R ## Build the asciidoc file for a given filename
	R -e 'library(knitr); opts_chunk$$set(cache.path = "cache/$(basename $(@F))_", fig.path = "figure/$(basename $(@F))_") ; knit("$<", "$@", tangle = FALSE)'

# Data to SQLite
sqlite/%.sqlite3: sqlite/%.sql sqlite/%.data
	sqlite3 $@ < $<

sqlite/%.stamp: sqlite/%.sql sqlite/%.data
	echo ".import sqlite/$*.data" >> $<
	touch $@

sqlite/%.sql: data/%.tsv bin/clean_sql.pl
	head -n1000 $< | csvsql --no-constraints --tables $(basename $<) -i sqlite | ./bin/clean_sql.pl > $@
	echo ".mode tabs" >> $@

sqlite/%.sql: data/%.csv bin/clean_sql.pl
	head -n1000 $< | csvsql --no-constraints --tables $(basename $<) -i sqlite | ./bin/clean_sql.pl > $@
	echo ".mode csv" >> $@

sqlite/%.data: data/%.tsv
	sed 1d $< > $@

sqlite/%.data: data/%.csv
	sed 1d $< > $@

