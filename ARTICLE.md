# CLI組版で年賀状宛名印刷 ― vivliostyle + Jinja2 による実践

## はじめに：なぜ年賀状の宛名印刷で苦労するのか

LaTeXのような優れた組版システムが何十年も前から存在するのに、なぜ年賀状の宛名印刷のような「簡単なこと」に良いツールがないのだろうか。

市販の年賀状ソフトは高機能だが重い。年に一度しか使わないソフトの使い方を毎年思い出すのは面倒だ。Webベースのツールもあるが、ブラウザの印刷設定に依存し、再現性に難がある。

Unix/Linux技術者なら、こう考えるはずだ：

- 住所録はCSVで管理したい
- テンプレートで変換したい
- コマンド一発でPDFを生成したい
- 環境に依存せず、毎年同じ結果を得たい

本記事では、**vivliostyle**（CSS組版エンジン）と**Jinja2テンプレート**を組み合わせて、CLI完結の年賀状宛名印刷システムを構築した事例を紹介する。

## システム概要

### 処理フロー

```
CSV（住所録）
    ↓
pandoc-embedz（Jinja2テンプレート）
    ↓
HTML
    ↓
vivliostyle（CSS組版）
    ↓
PDF → 印刷
```

シンプルなパイプライン構成だ。各コンポーネントは独立しており、Unix哲学に沿った設計になっている。

### 設計思想

- **テンプレートとスタイルの分離**: HTMLの構造（nenga.emz）とCSS（style.css）を分離
- **プリンタ補正の分離**: 仕様としての位置（style.css）とプリンタ固有の補正（style-printer.css）を分離
- **スキップ制御**: 備考欄の記述でフィルタリング（「保留」「済」「喪中」など）

## 使用ツール

### vivliostyle

[vivliostyle](https://vivliostyle.org/ja/)は日本発のオープンソースCSS組版エンジンだ。

**選定理由**:
- W3C JLREQ（日本語組版処理の要件）準拠
- 縦書き、禁則処理、ルビなど日本語組版に最適
- CLIでPDF生成可能（vivliostyle-cli）
- Docker版あり（環境構築が容易）
- 活発に開発が続いている

```bash
# インストール
npm install -g @vivliostyle/cli

# PDF生成
vivliostyle build input.html -o output.pdf
```

### pandoc-embedz

[pandoc-embedz](https://github.com/tecolicom/pandoc-embedz)は筆者が開発したJinja2テンプレートエンジンのラッパーだ。

もともとPandocのフィルターとして開発したが、`-s`（スタンドアロン）オプションでPandocなしでも動作する。CSV、JSON、YAMLなどのデータを読み込み、Jinja2テンプレートで変換してテキストを出力する。

```bash
# インストール
pip install pandoc-embedz

# スタンドアロンモードでCSV→HTML変換
pandoc-embedz -s template.emz < data.csv > output.html
```

### greple -Mtel（参考）

筆者は住所録を独自形式のテキストファイルで管理しており、[greple](https://github.com/kaz-utashiro/greple)のtelモジュールでCSVを生成している。読者は各自の方法でCSVを用意すればよい。Excelからエクスポートしても、Googleスプレッドシートでも構わない。

## CSV形式の設計

### ヘッダー

```csv
No,姓,名,配偶者,子供,〒,都道府県,市区町村,番地・建物,備考
```

### フィールド仕様

| # | フィールド | 必須 | 説明 |
|---|-----------|------|------|
| 1 | No | ○ | 連番（0は差出人） |
| 2 | 姓 | ○ | 世帯主の姓 |
| 3 | 名 | ○ | 世帯主の名 |
| 4 | 配偶者 | - | 配偶者の名（連名表示） |
| 5 | 子供 | - | 子供の名（「・」区切りで複数可） |
| 6 | 〒 | ○ | 郵便番号 |
| 7 | 都道府県 | - | 省略可 |
| 8 | 市区町村 | ○ | 市区町村名 |
| 9 | 番地・建物 | ○ | スペース区切りで建物名を分離 |
| 10 | 備考 | - | スキップ制御用 |

### データ構造

- **1行目**: ヘッダー
- **2行目**: 差出人情報（No=0）
- **3行目以降**: 宛先（No=1, 2, 3...）

### サンプル

```csv
No,姓,名,配偶者,子供,〒,都道府県,市区町村,番地・建物,備考
0,山田,太郎,花子,一郎・次郎,178-0063,東京都,練馬区,東大泉1-2-3,
1,鈴木,一郎,,,123-4567,,港区,芝公園1-2-3 東京タワービル101,
2,佐藤,次郎,美咲,,234-5678,神奈川県,横浜市,青葉区1-1-1,保留
```

### スキップ制御

備考欄に以下の文字列が含まれる場合、その宛先はスキップされる：

- `保留` - 一時的に送付を保留
- `済` - 印刷済み
- `喪中` - 喪中のため送付しない

印刷の進捗管理は、備考欄を手動で編集することで行う。シンプルだが確実な方法だ。

## Jinja2テンプレート（nenga.emz）

### 構造

テンプレートファイルは3つの部分から構成される：

1. **YAMLフロントマター**: 入力形式の指定、変数バインド
2. **preamble**: マクロ定義
3. **HTMLテンプレート本体**

### フロントマターとpreamble

```jinja2
---
format: csv
bind:
  差出人: data | first
preamble: |
  {%- macro 値(v) %}{{ v|default('')|string|replace('nan', '') }}{% endmacro -%}

  {#- 郵便番号を7つのspanに分解 -#}
  {%- macro 郵便番号欄(郵便番号) -%}
    {%- for i in range(7) %}
    <span class="zip-digit zip-{{ i + 1 }}">{{ 郵便番号[i] if i < 郵便番号|length else '' }}</span>
    {%- endfor -%}
  {%- endmacro -%}

  {#- スキップ判定 -#}
  {%- macro スキップ対象(row) -%}
    {{ 値(row['備考'])|regex_search('保留|済|喪中') }}
  {%- endmacro -%}
---
```

**ポイント**:
- `format: csv`でCSV入力を指定
- `bind`で差出人（data[0]）を変数にバインド
- マクロは日本語で定義可能（可読性向上）
- `{%- -%}`で空白制御（出力の余分な改行を除去）

### 複数CSV形式への対応

他のシステムからエクスポートしたCSVでも使えるよう、カラム名の正規化マクロを用意している：

```jinja2
{#- 住所の正規化：複数のカラム名に対応 -#}
{%- macro 住所(row) -%}
  {%- if   '住所・建物' in row %}{{ 値(row['住所・建物']).split(' ', 1)[0] }}
  {%- elif '番地・建物' in row %}{{ 値(row['番地・建物']).split(' ', 1)[0] }}
  {%- elif '住所'       in row %}{{ 値(row['住所']) }}
  {%- endif -%}
{%- endmacro -%}
```

「住所・建物」「番地・建物」「住所」のいずれのカラム名でも動作する。

### HTMLテンプレート本体

```html
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>年賀状宛名</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
{%- for 宛先 in data[1:] if not スキップ対象(宛先) %}
<section class="card">
  <div class="to-zip">
{{- 郵便番号欄(郵便番号(宛先).replace('-', '')) }}
  </div>
  <div class="to-address">
    <p class="addr-line1">{{ 値(宛先['都道府県']) }}{{ 値(宛先['市区町村']) }}</p>
    <p class="addr-line2">{{ 住所(宛先) }}</p>
    {%- if 建物(宛先) %}
    <p class="addr-line3">{{ 建物(宛先) }}</p>
    {%- endif %}
  </div>
  <div class="to-names">
    <table class="name-table">
      <tr><td class="sei">{{ 姓 }}</td><td class="mei">{{ 名 }}</td><td class="title">様</td></tr>
      {%- if 配偶者 %}
      <tr><td class="sei"></td><td class="mei">{{ 配偶者 }}</td><td class="title">様</td></tr>
      {%- endif %}
    </table>
  </div>
  <!-- 差出人情報 -->
  ...
</section>
{%- endfor %}
</body>
</html>
```

**ポイント**:
- `for ... if not スキップ対象(宛先)`でフィルタリング
- 各宛先が`<section class="card">`として出力される
- 連名はテーブルレイアウトで「名」の位置を揃える

## CSSレイアウト（style.css）

### ページ設定

```css
@page {
  size: 100mm 148mm;  /* ハガキサイズ */
  margin: 0;
}

.card {
  width: 100mm;
  height: 148mm;
  position: relative;
  page-break-after: always;
}
```

vivliostyleは`@page`ルールを正しく解釈し、指定サイズでPDFを生成する。

### 郵便番号枠の位置

宛先の郵便番号枠は[日本郵便の公式仕様](https://www.post.japanpost.jp/zipcode/zipmanual/p05.html)に基づいている：

| 項目 | 値 |
|------|-----|
| 枠サイズ | 幅5.7mm × 高さ8mm |
| 位置（上端から） | 12.0mm |
| 位置（右端から） | 8.0mm |
| 枠間隔 | 1.3mm |

```css
.to-zip {
  position: absolute;
  top: 12mm;
  height: 8mm;
  line-height: 8mm;
}

.to-zip .zip-digit {
  position: absolute;
  font-size: 16pt;
  width: 5.7mm;
  text-align: center;
}

/* 各桁の位置 */
.to-zip .zip-1 { left: 44.4mm; }
.to-zip .zip-2 { left: 51.7mm; }
/* ... */
```

差出人の郵便番号枠には公式仕様がない（配達に使用されないため）。実際の年賀はがきを測定して位置を決定した。

### プリンタ補正の分離

仕様としての位置と、プリンタ固有の補正を別ファイルに分離している：

```css
/* style-printer.css */
/* Brotherレーザープリンタ用：全体を1mm左にシフト */
.card {
  margin-left: -1mm;
}
```

これにより：
- 別のプリンタを使う場合はstyle-printer.cssのみ変更
- プレビュー用PDFはプリンタ補正なしで生成可能

## 実行方法

### Makefileによる自動化

```makefile
# HTML生成
address.html: 2026-address.csv nenga.emz
	pandoc-embedz -s nenga.emz < $< > $@

# PDF生成（印刷用）
nenga.pdf: address.html style.css style-printer.css
	vivliostyle build --style style-printer.css -o $@

# PDF生成（プレビュー用：郵便番号枠を表示）
nenga-preview.pdf: address.html style.css style-preview.css
	vivliostyle build --style style-preview.css -o $@
```

### コマンド実行

```bash
# 印刷用 + プレビュー用PDFを生成
make pdf

# ブラウザでプレビュー（リアルタイム確認）
make preview
```

### Docker実行

環境構築なしで実行したい場合はDockerを使う：

```bash
docker run --rm \
  -v "$(pwd)/address.csv:/app/2026-address.csv:ro" \
  -v "$(pwd):/app/output" \
  tecolicom/nenga-print \
  sh -c "make pdf && cp *.pdf output/"
```

Dockerイメージには以下が含まれている：
- Node.js + vivliostyle-cli
- Python + pandoc-embedz
- Chromium（PDF生成用）
- 日本語ロケール設定

## 出力例

![プレビューPDF](nenga-preview-sample.png)
*プレビュー用PDF：グリッドとガイド枠付き*

プレビュー用PDFでは以下の要素が確認できる：

- **グリッド**: 10mm単位のガイド線
- **STAMP**: 切手貼付位置
- **SEAL**: 年賀マーク位置
- **LOTTERY**: お年玉くじ番号位置
- **郵便番号枠**: 宛先（上部）と差出人（下部）

### 確認できる機能

1. **郵便番号の枠内配置**: 7桁がそれぞれ正しい位置に収まる
2. **連名表示**: 配偶者の名前が揃って表示される（テーブルレイアウト）
3. **建物名の分離**: 番地と建物名が別行で表示される
4. **差出人情報**: 下部に氏名・住所・郵便番号が配置

印刷用PDFではこれらのガイドは除去され、宛名のみが印刷される。

**注意**: 記事に掲載する画像は、プライバシー保護のためサンプルデータを使用するか、個人情報を隠す加工が必要。

## まとめ

### このアプローチの利点

- **CLI完結**: GUIを開く必要がない
- **再現性**: 同じCSVから同じPDFが生成される
- **環境非依存**: Dockerで環境を固定できる
- **保守性**: テンプレートとスタイルが分離され、変更が容易
- **拡張性**: 同じ仕組みで封筒、名刺なども対応可能

### 年に一度の作業に最適

年賀状印刷は年に一度の作業だ。複雑なGUIソフトの使い方を毎年思い出すより、シンプルなCLIツールとMakefileの方が確実だ。設定ファイルとともにGitで管理しておけば、来年も迷わない。

## リポジトリ

- **GitHub**: https://github.com/tecolicom/nenga-print
- **Docker Hub**: https://hub.docker.com/r/tecolicom/nenga-print
- **pandoc-embedz**: https://github.com/tecolicom/pandoc-embedz
- **vivliostyle**: https://vivliostyle.org/ja/

---

本記事で紹介したシステムは実際に2026年の年賀状印刷で使用している。興味があればリポジトリをフォークして、自分の環境に合わせてカスタマイズしてほしい。
