# nenga-print

年賀状宛名印刷システム。CSV ファイルから PDF を生成します。

## 特徴

- Docker で完結（環境構築不要）
- CSV を置いて実行するだけ
- 印刷用 PDF とプレビュー用 PDF を生成
- Web フォント使用（Klee One）
- CSS 組版（vivliostyle）

## 必要環境

- Docker

## 使い方

[dozo](https://github.com/tecolicom/App-dozo) を使用：

```bash
# すべての CSV から PDF を生成
dozo -I tecolicom/nenga-print

# または
dozo -I tecolicom/nenga-print make

# 特定のファイルを生成
dozo -I tecolicom/nenga-print make Nenga-2026.pdf

# PDF を削除
dozo -I tecolicom/nenga-print make clean
```

### .dozorc を使用

作業ディレクトリに `.dozorc` ファイルを作成しておくと、コマンドが簡潔になります：

```bash
echo '-I tecolicom/nenga-print' > .dozorc
```

以降は以下のコマンドで実行できます：

```bash
dozo make          # PDF を生成
dozo make clean    # PDF を削除
dozo make demo     # デモ用 PDF を生成
dozo make Makefile # Makefile をコピー（カスタマイズ用）
```

`Makefile` が作業ディレクトリにある場合は、そちらが優先されます。

生成されるファイル：
- `*.pdf` - 印刷用（枠なし）
- `*-preview.pdf` - プレビュー用（枠付き）

### デモ

`make demo` でサンプルデータから PDF を生成できます：

```bash
dozo -I tecolicom/nenga-print make demo
```

`sample.csv`、`sample.pdf`、`sample-preview.pdf` が生成されます。

### リアルタイムプレビュー

vivliostyle のプレビュー機能を使うと、ブラウザでリアルタイムに確認できます。

`.dozorc` にポートマッピングを追加：

```bash
cat > .dozorc <<'EOF'
-I tecolicom/nenga-print
-P 8000:8000
EOF
```

プレビューサーバーを起動：

```bash
dozo -L sh -c "cp /app/style*.css /app/*.svg /work/ && \
  pandoc-embedz -s /app/nenga.emz < /work/*.csv > /work/address.html && \
  vivliostyle preview /work/address.html --style /work/style-preview.css \
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
docker run --rm -v "$PWD:/work" -w /work tecolicom/nenga-print

# デモ
docker run --rm -v "$PWD:/work" -w /work tecolicom/nenga-print demo

# クリーン
docker run --rm -v "$PWD:/work" -w /work tecolicom/nenga-print clean
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
| 〒 または 郵便番号 | 郵便番号 | ○ |
| 都道府県 | 都道府県 | ○ |
| 市区町村 | 市区町村 | ○ |
| 住所 | 番地等 | △ |
| 町域 + 番地 | 住所の別形式 | △ |
| 建物 | 建物名・部屋番号 | |
| 配偶者 | 配偶者の名前 | |
| 子供 または 家族 | 家族の名前（・区切り） | |
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
