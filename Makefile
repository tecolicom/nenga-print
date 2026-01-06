# nenga-print: 年賀状宛名印刷システム（ローカル用）
#
# Usage:
#   dozo make                        # PDF生成
#   dozo make OFFSET=-1.5mm          # 左オフセット
#   dozo make OFFSET="-1.5mm 0.5mm"  # X,Yオフセット
#   dozo make clean                  # PDF削除

# プリンタ補正用オフセット transform: translate(X, Y)
OFFSET ?=
ifneq ($(OFFSET),)
  OFFSET_CSS := --css "data:,.card{transform:translate($(OFFSET))}"
endif

# すべての CSV から PDF を生成
CSVS     := $(wildcard *.csv)
PDFS     := $(CSVS:.csv=.pdf)
PREVIEWS := $(CSVS:.csv=.preview.pdf)
HTMLS    := $(CSVS:.csv=.html)

all: $(PDFS) $(PREVIEWS)

# style-printer.css を生成（OFFSET があれば適用）
style-printer.css:
	@printf '@media print {\n  .card {\n    transform: translate(%s);\n  }\n}\n' \
		"$(if $(OFFSET),$(OFFSET),0)" > style-printer.css

# HTML 生成ルール
%.html: %.csv nenga.emz style.css style-custom.css style-zip.css style-printer.css
	pandoc-embedz -s nenga.emz < $< > $@

# PDF 生成ルール（/work で実行）
%.pdf: %.csv nenga.emz style.css style-custom.css style-zip.css
	pandoc-embedz -s nenga.emz < $< > $*.html
	vivliostyle build $*.html --style style.css $(OFFSET_CSS) -o $@

%.preview.pdf: %.csv nenga.emz style.css style-custom.css style-zip.css style-preview.css hagaki-bg.svg grid.svg
	pandoc-embedz -s nenga.emz < $< > $*.html
	vivliostyle build $*.html --style style-preview.css -o $@

clean:
	rm -f $(PDFS) $(PREVIEWS) $(HTMLS) style-printer.css

# リアルタイムプレビュー（make *.preview または dozo -P $(PORT) make *.preview で実行）
PORT ?= 13000
%.preview:
	pandoc-embedz -s nenga.emz < $*.csv > $*.html
	@if [ -f /.dockerenv ]; then \
		vivliostyle preview $*.html --style style-preview.css --port $(PORT) --host 0.0.0.0 --no-open-viewer; \
	else \
		vivliostyle preview $*.html --style style-preview.css; \
	fi

.PHONY: all clean
