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

### セットアップ

`.dozorc` ファイルを作成して使用するイメージを指定します：

```bash
echo '-I tecolicom/nenga-print' > .dozorc
```

以降の例は `.dozorc` があることを前提にしています。

### 基本

```bash
dozo make                        # すべての CSV から PDF を生成
dozo make Nenga-2026.pdf         # 特定のファイルを生成
dozo make clean                  # PDF を削除
dozo make demo                   # デモ用 PDF を生成
```

生成されるファイル：
- `*.pdf` - 印刷用（枠なし）
- `*.preview.pdf` - プレビュー用（枠付き）

### プリンタ補正

印刷位置のズレを補正できます：

```bash
dozo make SHIFT=-1.5mm           # 左に 1.5mm シフト
dozo make SHIFT="-1.5mm, 0.5mm"  # 左に 1.5mm、上に 0.5mm シフト
```

### カスタマイズ

`make init` でテンプレートファイルをローカルにコピーし、カスタマイズできます：

```bash
dozo make init
```

以下のファイルがコピーされます：
- `nenga.emz` - テンプレート
- `style.css` - 基本スタイル
- `style-preview.css` - プレビュー用スタイル
- `hagaki-bg.svg` - はがき背景
- `grid.svg` - グリッド線
- `Makefile` - ローカル用 Makefile
- `sample.csv` - サンプル CSV
- `README.md` - 使い方

### リアルタイムプレビュー

vivliostyle のプレビュー機能を使うと、ブラウザでリアルタイムに確認できます。
`.dozorc` にポートマッピングを追加してください：

```
-P 8000:8000
```

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
docker run --rm -v "$(pwd):/work" tecolicom/nenga-print

# プリンタ補正
docker run --rm -v "$(pwd):/work" tecolicom/nenga-print make SHIFT=-1.5mm

# デモ
docker run --rm -v "$(pwd):/work" tecolicom/nenga-print demo

# クリーン
docker run --rm -v "$(pwd):/work" tecolicom/nenga-print clean
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

- 夫婦別姓の場合は、配偶者欄に「姓 名」をスペース区切りで記入
- 子供も同様に、名前にスペースがあれば姓と名に分けて表示
- 子供の区切りは「・」または「／」
- 姓を空にして名にフルネームを記入する方法もあります

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
