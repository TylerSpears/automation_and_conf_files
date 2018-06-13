# Makefile
# 
# Converts Markdown to other formats (HTML, PDF, DOCX, RTF, ODT, EPUB) using Pandoc
# <http://johnmacfarlane.net/pandoc/>
#
# Run "make" (or "make all") to convert to all other formats
#
# Run "make clean" to delete converted files

# Convert all files in this directory that have a .md suffix
#
# Based on Makefile found at kristopherjohnson/Makefile


SOURCE_DOCS := $(wildcard *.md)

# variable for what type of files to create
type ?= document

RM=/bin/rm
PANDOC=/usr/bin/pandoc

PANDOC_OPTIONS= --standalone

PRESENTATION_TYPES= pres presentation reveal.js present
DOCUMENT_TYPES= document doc docs article

# helper functions for equality and inequality
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)

neq = $(if $(call eq $(1), $(2)), , 1)

# general all and clean rules
.PHONY: all clean


# -------------------------------------------------------------
# if type is one of the presentation types
ifneq ($(findstring $(type), $(PRESENTATION_TYPES)),  )


# define whether or not to use decktape for pdf conversion
 ifndef DECKTAPE
  ifneq ($(shell which decktape),  )
DECKTAPE = $(shell which decktape)
  else ifneq ($(shell which `npm bin`/decktape), )
DECKTAPE = $(shell which `npm bin`/decktape)
  endif
 endif


# if a decktape install was found, export to pdf
 ifdef DECKTAPE
EXPORTED_DOCS=\
 $(SOURCE_DOCS:.md=.html) \
 $(SOURCE_DOCS:.md=.pdf) 

DECKTAPE_PDF_OPTIONS=--no-sandbox

# otherwise, just export to html
 else
EXPORTED_DOCS=\
 $(SOURCE_DOCS:.md=.html) 
 endif


all : $(EXPORTED_DOCS)

clean:
	- $(RM) $(EXPORTED_DOCS) 2> /dev/null || true

# define where make will look for reveal.js 
 ifndef REVEAL_JS_LINK
# check if local dir has a reveal.js dir
  ifneq ($(wildcard ./reveal.js),  )
REVEAL_JS_LINK = ./reveal.js
# check if npm is installed, and if reveal.js is installed in it
  else ifneq ($(and $(call neq $(shell which npm), "" ), $(call neq $(shell pwd), $(shell npm ls reveal.js -p))),"" ) 
REVEAL_JS_LINK = $(shell npm ls reveal.js -p)
# otherwise go online
# requires internet connection
  else
REVEAL_JS_LINK = http://lab.hakim.se/reveal-js
  endif
 endif

PANDOC_REVEAL_JS_OPTIONS = --to revealjs -V revealjs-url=$(REVEAL_JS_LINK)

# synonyms for making presentation
.PHONY: $(PRESENTATION_TYPES)


pres: all


presentation: all


reveal.js: all 


present: all


# html rule for all reveal.js presentations
%.html: %.md
	@echo [Info:] --- Using --revealjs-url=$(REVEAL_JS_LINK)
	$(PANDOC) $(PANDOC_OPTIONS) $(PANDOC_REVEAL_JS_OPTIONS) -o $(basename $<).html $<

# if decktape is available, make pdf copies
 ifdef DECKTAPE
%.pdf: %.html
	@echo [Info:] --- Using decktape at $(DECKTAPE)
	$(DECKTAPE) $< $(basename $<).pdf $(DECKTAPE_PDF_OPTIONS)
 endif



# -------------------------------------------------------------
# else if type is one of document types, make all document types
else ifneq ($(findstring $(type), $(DOCUMENT_TYPES)),  )

PANDOC_HTML_OPTIONS=--to html5
PANDOC_PDF_OPTIONS=
PANDOC_DOCX_OPTIONS=
PANDOC_RTF_OPTIONS=
PANDOC_ODT_OPTIONS=
PANDOC_EPUB_OPTIONS=--to epub3

EXPORTED_DOCS=\
 $(SOURCE_DOCS:.md=.html) \
 $(SOURCE_DOCS:.md=.pdf) \
 $(SOURCE_DOCS:.md=.docx) \
 $(SOURCE_DOCS:.md=.rtf) \
 $(SOURCE_DOCS:.md=.odt) \
 $(SOURCE_DOCS:.md=.epub)


all : $(EXPORTED_DOCS)

clean:
	- $(RM) $(EXPORTED_DOCS) 2> /dev/null || true


.PHONY: pdf html docx rtf odt epub 

html: $(SOURCE_DOCS:.md=.html)
	

pdf: $(SOURCE_DOCS:.md=.pdf)
	

docx: $(SOURCE_DOCS:.md=.docx)
	

rtf: $(SOURCE_DOCS:.md=.rtf) 
	

odt: $(SOURCE_DOCS:.md=.odt)
	

epub: $(SOURCE_DOCS:.md=.epub)
	

%.html : %.md
	$(PANDOC) $(PANDOC_OPTIONS) $(PANDOC_HTML_OPTIONS) -o $@ $<

%.pdf : %.md 
	$(PANDOC) $(PANDOC_OPTIONS) $(PANDOC_PDF_OPTIONS) -o $@ $<

%.docx : %.md
	$(PANDOC) $(PANDOC_OPTIONS) $(PANDOC_DOCX_OPTIONS) -o $@ $<

%.rtf : %.md
	$(PANDOC) $(PANDOC_OPTIONS) $(PANDOC_RTF_OPTIONS) -o $@ $<

%.odt : %.md
	$(PANDOC) $(PANDOC_OPTIONS) $(PANDOC_ODT_OPTIONS) -o $@ $<

%.epub : %.md
	$(PANDOC) $(PANDOC_OPTIONS) $(PANDOC_EPUB_OPTIONS) -o $@ $<

endif


