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
```

生成されるファイル：
- `Nenga-2026.pdf` - 印刷用（枠なし）
- `Nenga-2026-preview.pdf` - プレビュー用（枠付き）

### Docker を直接使用

```bash
docker run --rm -v "$PWD:/work" -w /work tecolicom/nenga-print
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
| 子供 | 子供の名前（・区切り） | |
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
