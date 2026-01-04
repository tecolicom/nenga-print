# nenga-print: 年賀状宛名印刷システム
#
# Usage:
#   dozo -I tecolicom/nenga-print make
#   dozo -I tecolicom/nenga-print make Nenga-2026.pdf
#   dozo -I tecolicom/nenga-print make clean

APPDIR  := /app
WORKDIR := $(CURDIR)

CSVS     := $(wildcard $(WORKDIR)/*.csv)
PDFS     := $(CSVS:.csv=.pdf)
PREVIEWS := $(CSVS:.csv=-preview.pdf)

# すべての CSV から PDF を生成
all: $(PDFS) $(PREVIEWS)

# PDF 生成ルール
%.pdf: %.csv
	pandoc-embedz -s $(APPDIR)/nenga.emz < $< > $(APPDIR)/address.html
	cd $(APPDIR) && vivliostyle build --style style-printer.css -o $@

%-preview.pdf: %.csv
	pandoc-embedz -s $(APPDIR)/nenga.emz < $< > $(APPDIR)/address.html
	cd $(APPDIR) && vivliostyle build --style style-preview.css -o $@

clean:
	rm -f $(WORKDIR)/*.pdf

# デモ用 PDF を生成
demo: $(WORKDIR)/sample.csv $(WORKDIR)/sample.pdf $(WORKDIR)/sample-preview.pdf

$(WORKDIR)/sample.csv: $(APPDIR)/sample.csv
	cp $< $@

$(WORKDIR)/sample.pdf: $(APPDIR)/sample.csv
	pandoc-embedz -s $(APPDIR)/nenga.emz < $< > $(APPDIR)/address.html
	cd $(APPDIR) && vivliostyle build --style style-printer.css -o $@

$(WORKDIR)/sample-preview.pdf: $(APPDIR)/sample.csv
	pandoc-embedz -s $(APPDIR)/nenga.emz < $< > $(APPDIR)/address.html
	cd $(APPDIR) && vivliostyle build --style style-preview.css -o $@

.PHONY: all clean demo
