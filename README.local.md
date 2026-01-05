# 年賀状宛名印刷

[nenga-print](https://github.com/tecolicom/nenga-print) を使用した年賀状宛名印刷環境です。

## 使い方

[dozo](https://github.com/tecolicom/App-dozo) がインストールされていればそのまま使えます。
ない場合は以下の関数を定義してください：

```bash
dozo() { docker run --rm -v "$(pwd):/work" tecolicom/nenga-print "$@"; }
```

```bash
dozo make                        # PDF を生成
dozo make SHIFT=-1.5mm           # プリンタ補正（左に 1.5mm）
dozo make SHIFT="-1.5mm, 0.5mm"  # X,Y 両方指定
dozo make clean                  # PDF を削除
```

## 生成ファイル

- `*.pdf` - 印刷用（枠なし）
- `*.preview.pdf` - プレビュー用（枠付き）

## カスタマイズ

以下のファイルを編集できます：

- `nenga.emz` - テンプレート
- `style.css` - 基本スタイル
- `style-preview.css` - プレビュー用スタイル
- `hagaki-bg.svg` - はがき背景
- `grid.svg` - グリッド線

## CSV フォーマット

1行目が差出人、2行目以降が宛先です。

| 列名 | 説明 |
|------|------|
| 姓 | 姓（必須） |
| 名 | 名（必須） |
| 配偶者 | 配偶者の名前 |
| 子供 または 家族 | 家族の名前（・区切り） |
| 〒 または 郵便番号 | 郵便番号（必須） |
| 都道府県 | 都道府県 |
| 市区町村 | 市区町村（必須） |
| 住所 または 町域+番地 | 番地等 |
| 建物 | 建物名・部屋番号 |
| 備考 | 「保留」「済」「喪中」でスキップ |

- 夫婦別姓の場合は、配偶者欄に「姓 名」をスペース区切りで記入
- 子供も同様に、名前にスペースがあれば姓と名に分けて表示
- 子供の区切りは「・」または「／」
- 姓を空にして名にフルネームを記入する方法もあります

## 構成技術

- [Jinja2](https://jinja.palletsprojects.com/) - テンプレート言語
- [pandoc-embedz](https://github.com/tecolicom/pandoc-embedz) - Jinja2 テンプレート処理
- [vivliostyle](https://vivliostyle.org/) - CSS 組版
- [Klee One](https://fonts.google.com/specimen/Klee+One) - フォント

詳細は [nenga-print README](https://github.com/tecolicom/nenga-print#readme) を参照。
