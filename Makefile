# nenga-print: 年賀状宛名印刷システム（/app 用）
#
# Usage:
#   dozo make                        # PDF生成
#   dozo make SHIFT=-1.5mm           # 左シフト
#   dozo make SHIFT="-1.5mm 0.5mm"   # X,Yシフト
#   dozo make init                   # カスタマイズ用にファイルをコピー
#   dozo make clean                  # PDF削除

APPDIR  := /app

# プリンタ補正用シフト transform: translate(X, Y)
SHIFT ?=
ifneq ($(SHIFT),)
  SHIFT_CSS := --css "data:,.card{transform:translate($(SHIFT))}"
endif

# すべての CSV から PDF を生成
CSVS     := $(wildcard *.csv)
PDFS     := $(CSVS:.csv=.pdf)
PREVIEWS := $(CSVS:.csv=.preview.pdf)

all: $(PDFS) $(PREVIEWS)

# PDF 生成ルール（/app で実行）
%.pdf: %.csv
	cd $(APPDIR) && pandoc-embedz -s nenga.emz < $(CURDIR)/$< > $*.html
	cd $(APPDIR) && vivliostyle build $*.html --style style.css $(SHIFT_CSS) -o $(CURDIR)/$@
	rm -f $(APPDIR)/$*.html

%.preview.pdf: %.csv
	cd $(APPDIR) && pandoc-embedz -s nenga.emz < $(CURDIR)/$< > $*.html
	cd $(APPDIR) && vivliostyle build $*.html --style style-preview.css -o $(CURDIR)/$@
	rm -f $(APPDIR)/$*.html

clean:
	rm -f $(PDFS) $(PREVIEWS)

# カスタマイズ用にファイルをコピー（既存は上書きしない）
init:
	cp -n $(APPDIR)/nenga.emz .
	cp -n $(APPDIR)/style.css .
	cp -n $(APPDIR)/style-preview.css .
	cp -n $(APPDIR)/hagaki-bg.svg .
	cp -n $(APPDIR)/grid.svg .
	cp -n $(APPDIR)/Makefile.local Makefile
	@test -f .dozorc || printf '%s\n' '-I tecolicom/nenga-print' '-P 8000:8000' > .dozorc
	@echo "初期化完了。dozo make で PDF を生成できます。"

# デモ用 PDF を生成
demo:
	cp $(APPDIR)/sample.csv .
	$(MAKE) -f $(APPDIR)/Makefile sample.pdf sample.preview.pdf

.PHONY: all clean init demo
