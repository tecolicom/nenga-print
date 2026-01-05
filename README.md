# nenga-print

年賀状宛名印刷システム。CSV ファイルから PDF を生成します。

## 特徴

- Docker で完結（環境構築不要）
- CSV を置いて実行するだけ
- 印刷用 PDF とプレビュー用 PDF を生成
- プリンタ補正オプション（OFFSET）
- Web フォント使用（Klee One）
- CSS 組版（vivliostyle）

## 必要環境

- Docker

## クイックスタート

以下のコマンドでサンプル PDF を生成できます：

```bash
docker run --rm -v "$(pwd):/work" tecolicom/nenga-print demo
```

`sample.csv`、`sample.pdf`（印刷用）、`sample.preview.pdf`（確認用）が生成されます。

## CSV フォーマット

1行目はヘッダー、2行目が差出人、3行目以降が宛先です。

| 列名 | 説明 | 別名 |
|------|------|------|
| 姓 | 姓 | |
| 名 | 名 | |
| 配偶者 | 配偶者の名前 | |
| 家族 | 家族の名前（「・」または「／」区切り） | 子供 |
| 郵便番号 | 郵便番号 | 〒 |
| 都道府県 | 都道府県 | |
| 市区町村 | 市区町村 | |
| 番地・建物 | 町名番地（空白）建物名等 | |
| 備考 | 「保留」「済」「喪中」でスキップ | |

### 補足

- 夫婦別姓：配偶者欄に「姓 名」をスペース区切りで記入
- 家族の別姓：同様に「姓 名」形式で記入可

## 使い方

[dozo](https://github.com/tecolicom/App-dozo) を使うと簡潔に実行できます：

```bash
echo '-I tecolicom/nenga-print' > .dozorc
```

dozo がない場合は以下の関数で単純な使い方なら代用できます：

```bash
dozo() { docker run --rm -v "$(pwd):/work" tecolicom/nenga-print "$@"; }
```

### PDF 生成

```bash
dozo make                    # すべての CSV から PDF を生成
dozo make address.pdf        # 特定のファイルを生成
dozo make clean              # PDF を削除
```

生成されるファイル：
- `*.pdf` - 印刷用（枠なし）
- `*.preview.pdf` - プレビュー用（枠付き）

### プリンタ補正

印刷位置のズレを補正できます：

```bash
dozo make OFFSET=-1.5mm           # 左に 1.5mm オフセット
dozo make OFFSET="-1.5mm, 0.5mm"  # 左に 1.5mm、上に 0.5mm オフセット
```

補正は印刷用 PDF のみに適用され、プレビュー用 PDF には影響しません。

### リアルタイムプレビュー

vivliostyle のプレビュー機能を使うと、ブラウザでリアルタイムに確認できます。
dozo を使う場合は `-P` オプションでポートを公開します：

```bash
dozo -P 13000 make sample.preview
```

表示された URL をブラウザで開きます。`Ctrl+C` で停止。

## カスタマイズ

`make init` でテンプレートファイルをローカルにコピーし、カスタマイズできます：

```bash
dozo make init
```

以下のファイルがコピーされます：
- `nenga.emz` - テンプレート
- `style.css` - 基本レイアウト
- `style-custom.css` - スタイル（カスタマイズ用）
- `style-zip.css` - 郵便番号配置
- `style-preview.css` - プレビュー用スタイル
- `hagaki-bg.svg` - はがき背景
- `grid.svg` - グリッド線
- `Makefile` - ローカル用 Makefile
- `sample.csv` - サンプル CSV
- `.dozorc` - dozo 設定
- `README.md` - 使い方

ローカルに vivliostyle がインストールされていれば、Docker なしで実行できます：

```bash
make sample.preview
```

## 構成技術

- [pandoc-embedz](https://github.com/tecolicom/pandoc-embedz) - テンプレートエンジン
- [vivliostyle](https://vivliostyle.org/) - CSS 組版
- [Klee One](https://fonts.google.com/specimen/Klee+One) - フォント

## ビルド

```bash
docker build -t tecolicom/nenga-print .
```

## ライセンス

MIT
