# nenga-print

年賀状宛名印刷システム。CSV ファイルから PDF を生成します。

## 特徴

- Docker で完結（環境構築不要）
- CSV を置いて実行するだけ
- 印刷用 PDF とプレビュー用 PDF を生成
- プリンタ補正オプション（SHIFT）
- Web フォント使用（Klee One）
- CSS 組版（vivliostyle）

## 必要環境

- Docker
- [dozo](https://github.com/tecolicom/App-dozo)（推奨）

## 使い方

### 基本

```bash
# すべての CSV から PDF を生成
dozo -I tecolicom/nenga-print make

# 特定のファイルを生成
dozo -I tecolicom/nenga-print make Nenga-2026.pdf

# PDF を削除
dozo -I tecolicom/nenga-print make clean

# デモ用 PDF を生成
dozo -I tecolicom/nenga-print make demo
```

生成されるファイル：
- `*.pdf` - 印刷用（枠なし）
- `*.preview.pdf` - プレビュー用（枠付き）

### プリンタ補正

印刷位置のズレを補正できます：

```bash
# 左に 1.5mm シフト
dozo -I tecolicom/nenga-print make SHIFT=-1.5mm

# 左に 1.5mm、上に 0.5mm シフト
dozo -I tecolicom/nenga-print make SHIFT="-1.5mm, 0.5mm"
```

### カスタマイズ

`make init` でテンプレートファイルをローカルにコピーし、カスタマイズできます：

```bash
dozo -I tecolicom/nenga-print make init
```

以下のファイルがコピーされます：
- `nenga.emz` - テンプレート
- `style.css` - 基本スタイル
- `style-preview.css` - プレビュー用スタイル
- `hagaki-bg.svg` - はがき背景
- `grid.svg` - グリッド線
- `Makefile` - ローカル用 Makefile
- `.dozorc` - dozo 設定ファイル

以降は `dozo make` だけで実行できます：

```bash
dozo make                        # PDF を生成
dozo make SHIFT=-1.5mm           # シフト指定
dozo make clean                  # PDF を削除
```

### リアルタイムプレビュー

vivliostyle のプレビュー機能を使うと、ブラウザでリアルタイムに確認できます。

`make init` 後（または `.dozorc` にポートマッピングを追加後）：

```bash
dozo -L sh -c "cp /app/style*.css /app/*.svg /work/ 2>/dev/null; \
  pandoc-embedz -s nenga.emz < *.csv > address.html && \
  vivliostyle preview address.html --style style-preview.css \
  --port 8000 --host 0.0.0.0 --no-open-viewer"
```

ブラウザで以下を開く：

```
http://localhost:8000/__vivliostyle-viewer/index.html#src=http://localhost:8000/vivliostyle/address.html&bookMode=true&renderAllPages=true&style=/vivliostyle/style-preview.css
```

停止：

```bash
dozo -K
```

### Docker を直接使用

```bash
# PDF を生成
docker run --rm -v "$PWD:/work" tecolicom/nenga-print

# プリンタ補正
docker run --rm -v "$PWD:/work" tecolicom/nenga-print make SHIFT=-1.5mm

# デモ
docker run --rm -v "$PWD:/work" tecolicom/nenga-print demo

# クリーン
docker run --rm -v "$PWD:/work" tecolicom/nenga-print clean
```

## ビルド

```bash
docker build -t tecolicom/nenga-print .
```

## CSV フォーマット

1行目が差出人、2行目以降が宛先です。

| 列名 | 説明 | 必須 |
|------|------|------|
| 姓 | 姓 | ○ |
| 名 | 名 | ○ |
| 配偶者 | 配偶者の名前 | |
| 子供 または 家族 | 家族の名前（・区切り） | |
| 〒 または 郵便番号 | 郵便番号 | ○ |
| 都道府県 | 都道府県 | |
| 市区町村 | 市区町村 | ○ |
| 住所 | 番地等 | △ |
| 町域 + 番地 | 住所の別形式 | △ |
| 建物 | 建物名・部屋番号 | |
| 備考 | 「保留」「済」「喪中」でスキップ | |

住所は以下のいずれかの形式で指定：
- `住所` 列
- `住所・建物` 列（スペース区切り）
- `番地・建物` 列（スペース区切り）
- `町域` + `番地` 列

## 構成技術

- [pandoc-embedz](https://github.com/tecolicom/pandoc-embedz) - テンプレートエンジン
- [vivliostyle](https://vivliostyle.org/) - CSS 組版
- [Klee One](https://fonts.google.com/specimen/Klee+One) - フォント

## ライセンス

MIT
