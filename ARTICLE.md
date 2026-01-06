# CLI組版で年賀状宛名印刷 ― pandoc-embedz + CSS組版による実践

## はじめに：40年間の年賀状印刷遍歴

筆者はテキストベースの住所録を40年以上使い続けている。データの形式はほとんど変わっていない。変わったのは、そのデータを印刷するためのフロントエンドだ。

最初はMac上のハガキ印刷ソフトを使っていた。その後、住所録からCSVを生成してExcelに読み込み、Wordの差し込み印刷機能を使うようになった。Word 2008をだましだまし使っていたが、ついにMacで動かなくなった。

次に見つけたのが[kon104](https://github.com/kon104/printaddr)というWebベースの宛名印刷サービスだ。ダウンロードしてローカルで改造して使っていたが、JavaScriptでの処理に限界を感じ、行き詰まっていた。

そんな折、仕事で報告書を自動生成するためのツールを開発した。[pandoc-embedz](https://github.com/tecolicom/pandoc-embedz)だ。このツールを作ったことで、年賀状の宛名印刷システムも新しく作れると思い立った。

本記事では、pandoc-embedzとCSS組版を組み合わせた、CLI完結の年賀状宛名印刷システムを紹介する。

## なぜCSS組版か

組版といえばLaTeXが定番だ。筆者もLaTeXの経験はある。一方で、CSS組版エンジンのvivliostyleを使った経験もあった。

年賀状の宛名印刷にはCSS組版が向いていると判断した。理由は単純だ。

LaTeXは出版システムとして設計されている。テキストが複数ページにわたってフローし、章立てや目次、相互参照を管理する。一方、ハガキの宛名はフローしないコンテンツだ。100mm × 148mmの固定サイズに収まるレイアウトを組むだけ。これはWebページの考え方に近い。

CSSなら`position: absolute`と`top: 12mm`で位置を指定できる。直感的だ。

## pandoc-embedz：データ駆動の文書生成

### 開発の背景

pandoc-embedzはもともと仕事の報告書を自動生成するために開発した。

報告書には図や表がたくさん出てくる。データはあるのに、Excelで手作業でグラフを作り、Wordに貼り付ける。データが更新されるたびに作り直す。これは非効率だ。

データを読み込んで図表を自動生成し、「前年比で○%増加」のような文章も自動で記述する。そのためのテンプレートエンジンとして作ったのがpandoc-embedzだ。

### 機能の概要

- CSV、JSON、YAML、SQLiteなど8種類のデータ形式に対応
- Jinja2テンプレートによる柔軟な変換
- SQLクエリによるフィルタリングや集計
- 複数データソースのJOIN
- マクロによるテンプレート再利用

年賀状の用途では、これらの機能のごく一部しか使わない。CSVを読んでHTMLに変換するだけだ。pandoc-embedzの最もシンプルな使い方だが、それでも十分に実用的だ。

```bash
# インストール
pip install pandoc-embedz

# CSV→HTML変換
pandoc-embedz -s nenga.emz < address.csv > address.html
```

## システム構成

### 処理フロー

```
テキスト住所録（40年前から同じ）
    ↓
greple -Mtel（CSV生成）
    ↓
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

40年間、データは変わらない。変わるのはフロントエンドだけだ。今回のシステムでも、CSVさえ用意できれば動作する。

### 設計思想

- **データとプレゼンテーションの分離**: 住所録の形式は変えない、印刷システムだけを更新
- **テンプレートとスタイルの分離**: HTMLの構造（nenga.emz）とCSS（style.css）を分離
- **プリンタ補正の分離**: 仕様としての位置とプリンタ固有の補正を別ファイルに

## vivliostyleについて

[vivliostyle](https://vivliostyle.org/ja/)は日本発のオープンソースCSS組版エンジンだ。

正直に言えば、今回のシステムではvivliostyleの高度な機能は使っていない。HTMLをブラウザで開いて印刷しても、おそらく同じ結果が得られる。

ただ、CLIで完結することに意味がある。`make pdf`と打てば同じPDFが生成される。ブラウザの印刷設定に依存しない。この再現性が欲しかった。

```bash
# インストール
npm install -g @vivliostyle/cli

# PDF生成
vivliostyle build address.html -o nenga.pdf
```

## CSV形式

住所録をCSVで用意する。筆者は独自ツール（greple -Mtel）で生成しているが、ExcelやGoogleスプレッドシートからエクスポートしても構わない。

### フォーマット

```csv
No,姓,名,配偶者,子供,〒,都道府県,市区町村,番地・建物,備考
0,山田,太郎,花子,一郎・次郎,178-0063,東京都,練馬区,東大泉1-2-3,
1,鈴木,一郎,,,123-4567,,港区,芝公園1-2-3 東京タワービル101,
2,佐藤,次郎,美咲,,234-5678,神奈川県,横浜市,青葉区1-1-1,保留
```

- 1行目: ヘッダー
- 2行目: 差出人情報（No=0）
- 3行目以降: 宛先

### スキップ制御

備考欄に「保留」「済」「喪中」などの文字列が含まれると、その宛先はスキップされる。印刷の進捗管理は備考欄を手動で編集する。シンプルだが確実だ。

## Jinja2テンプレート

テンプレートファイル（nenga.emz）の構造を説明する。

### フロントマター

```jinja2
---
format: csv
bind:
  差出人: data | first
preamble: |
  {%- macro 値(v) %}{{ v|default('')|string|replace('nan', '') }}{% endmacro -%}

  {%- macro スキップ対象(row) -%}
    {{ 値(row['備考'])|regex_search('保留|済|喪中') }}
  {%- endmacro -%}
---
```

- `format: csv`でCSV入力を指定
- `bind`で差出人（data[0]）を変数にバインド
- `preamble`でマクロを定義（日本語名も使える）

### テンプレート本体

```html
{%- for 宛先 in data[1:] if not スキップ対象(宛先) %}
<section class="card">
  <div class="to-zip">
    <!-- 郵便番号を7つのspanに分解 -->
  </div>
  <div class="to-address">
    <p>{{ 値(宛先['都道府県']) }}{{ 値(宛先['市区町村']) }}</p>
    <p>{{ 住所(宛先) }}</p>
  </div>
  <div class="to-names">
    <!-- 宛名（連名対応） -->
  </div>
  <div class="from-info">
    <!-- 差出人情報 -->
  </div>
</section>
{%- endfor %}
```

`for ... if not スキップ対象(宛先)`でフィルタリングしている。Jinja2の構文がそのまま使えるのがpandoc-embedzの強みだ。

## CSSレイアウト

### ページサイズ

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

### 郵便番号枠の位置

宛先の郵便番号枠は[日本郵便の公式仕様](https://www.post.japanpost.jp/zipcode/zipmanual/p05.html)に基づいている。

| 項目 | 値 |
|------|-----|
| 枠サイズ | 幅5.7mm × 高さ8mm |
| 位置（上端から） | 12.0mm |
| 枠間隔 | 1.3mm |

差出人の郵便番号枠には公式仕様がない。配達に使用されないからだ。実際の年賀はがきを定規で測って位置を決めた。

### プリンタ補正

プリンタごとの印刷位置のズレは別ファイル（style-printer.css）で補正する。

```css
/* style-printer.css */
.card {
  margin-left: -1mm;  /* 全体を1mm左にシフト */
}
```

仕様としての位置（style.css）とプリンタ固有の補正を分離しておけば、別のプリンタを使う時もstyle-printer.cssだけ変更すればよい。

## 実行方法

### Makefile

```makefile
address.html: address.csv nenga.emz
	pandoc-embedz -s nenga.emz < $< > $@

nenga.pdf: address.html style.css style-printer.css
	vivliostyle build --style style-printer.css -o $@
```

```bash
make pdf  # PDF生成
```

### Docker

環境構築なしで試したい場合はDockerを使う。

```bash
docker run --rm \
  -v "$(pwd):/work" \
  ghcr.io/tecolicom/nenga-print \
  make -f /app/Makefile CSV=/work/address.csv pdf
```

## まとめ

40年間、住所録のデータ形式は変わっていない。変わったのは印刷するためのフロントエンドだけだ。

Mac印刷ソフト、Excel/Word、Webアプリと渡り歩いて、今回ようやくCLI完結のシステムができた。`make pdf`でPDFが生成され、来年も同じコマンドで動く。

pandoc-embedzを作ったことがきっかけでこのシステムを作った。年賀状印刷はpandoc-embedzの最もシンプルな使い方だが、同じ仕組みで複雑な報告書生成にも使える。興味があれば試してほしい。

## リポジトリ

- **nenga-print**: https://github.com/tecolicom/nenga-print
- **pandoc-embedz**: https://github.com/tecolicom/pandoc-embedz
- **vivliostyle**: https://vivliostyle.org/ja/

---

本記事で紹介したシステムは実際に2026年の年賀状印刷で使用した。リポジトリをフォークして、自分の環境に合わせてカスタマイズしてほしい。
