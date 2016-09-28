SHELL:=bash
TEXFILE:=main
NOTESFILE:=notes
SLIDES:=2016-DDD-Skype

all: $(SLIDES).pdf; make clean

.PHONY: all clean

## Slides compilation
$(SLIDES).pdf: $(TEXFILE).tex 
	pdflatex -shell-escape -jobname $(SLIDES) $(TEXFILE)
	@if(grep "Citation" $(SLIDES).log > /dev/null);\
	then \
		bibtex -jobname $(SLIDES) $(TEXFILE);\
		pdflatex -shell-escape -jobname $(SLIDES) $(TEXFILE); \
	fi
	@if(grep "Rerun" $(SLIDES).log > /dev/null);\
		then \
		pdflatex -shell-escape -jobname $(SLIDES) $(TEXFILE); \
	fi

## Remove unnecessary files
clean:
	command rm -f $(SLIDES).*{log,aux,out,blg,bbl,nav,snm,toc,listing,vrb}
