# CLI組版で年賀状宛名印刷 ― vivliostyle + Jinja2 による実践

## はじめに：40年間の年賀状印刷遍歴

私はテキストベースの住所録を40年以上使い続けています。データの形式はほとんど変わっていません。変わったのは、そのデータを扱うツールと印刷システムの方です。

住所録の管理には、最初は`tel`というシェルスクリプトを使っていました。その後Perlで書き直し、さらに[greple](https://github.com/kaz-utashiro/greple)のモジュールになりました。端末で住所録を検索したり、年賀状の宛先リストをCSV形式で出力したり、用途に応じて出力形式を切り替えられます。

印刷システムの方も変遷してきました。最初はMac上のハガキ印刷ソフトを使っていました。その後、住所録からCSVを生成してExcelに読み込み、Wordの差し込み印刷機能を使うようになりました。Word 2008をだましだまし使っていたのですが、ついにMacで動かなくなってしまいました。

次に見つけたのがWebベースの年賀状宛名印刷サービスでした（現在はサービス終了）。ダウンロードしてローカルで改造して使っていたのですが、JavaScriptでの処理に限界を感じて行き詰まっていました。

そんな折、別の業務で報告書を自動生成するためのツールを開発しました。[pandoc-embedz](https://github.com/tecolicom/pandoc-embedz)です。このツールを作ったことで、年賀状の宛名印刷システムも新しく作れると思い立ちました。

この記事では、pandoc-embedzとCSS組版を組み合わせた、CLI完結の年賀状宛名印刷システムを紹介します。

## なぜCSS組版なのか

組版の経験はそれなりにあります。最初はroffでした。コマンドのマニュアルはもちろんroffで書きますし、技術書の翻訳版を出版したこともあります。一方で、CSS組版エンジンのvivliostyleを使った経験もありました。

年賀状の宛名印刷にはCSS組版が向いていると考えました。理由は単純です。

LaTeXは出版システムとして設計されています。テキストが複数ページにわたってフローし、章立てや目次、相互参照を管理します。一方、ハガキの宛名はフローしないコンテンツです。100mm × 148mmの固定サイズに収まるレイアウトを組むだけ。これはWebページの考え方に近いです。

CSSなら`position: absolute`と`top: 12mm`で位置を指定できます。直感的でわかりやすいです。

## pandoc-embedz：データ駆動の文書生成

### 開発の背景

pandoc-embedzはもともと別の業務で報告書を自動生成するために開発したものです。

報告書には図や表がたくさん出てきます。データはあるのに、Excelで手作業でグラフを作って、Wordに貼り付ける。データが更新されるたびに作り直す。これは非効率です。

データを読み込んで図表を自動生成し、「前年比で○%増加」のような文章も自動で記述する。そのためのテンプレートエンジンとして作ったのがpandoc-embedzです。

### 機能の概要

- CSV、JSON、YAML、SQLiteなど8種類のデータ形式に対応
- Jinja2テンプレートによる柔軟な変換
- SQLクエリによるフィルタリングや集計
- 複数データソースのJOIN
- マクロによるテンプレート再利用

年賀状の用途では、これらの機能のごく一部しか使いません。CSVを読んでHTMLに変換するだけです。pandoc-embedzの最もシンプルな使い方ですが、それでも十分実用的です。

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

40年間、データは変わっていません。変わるのはフロントエンドだけです。今回のシステムでも、CSVさえ用意できれば動作します。

### 設計思想

- **データとプレゼンテーションの分離**: 住所録の形式は変えない、印刷システムだけを更新
- **テンプレートとスタイルの分離**: HTMLの構造（nenga.emz）とCSS（style.css）を分離
- **プリンタ補正の分離**: 仕様としての位置とプリンタ固有の補正を別ファイルに

## vivliostyleについて

[vivliostyle](https://vivliostyle.org/ja/)は日本発のオープンソースCSS組版エンジンです。CSS組版エンジンには[weasyprint](https://weasyprint.org/)という選択肢もあります。

実際のところ、今回のシステムではvivliostyleの高度な機能は使っていません。HTMLをブラウザで開いて印刷しても、おそらく同じ結果が得られると思います。

ただ、CLIで完結することに意味があります。`make pdf`と打てば同じPDFが生成される。ブラウザの印刷設定に依存しない。この再現性が欲しかったのです。

```bash
# インストール
npm install -g @vivliostyle/cli

# PDF生成
vivliostyle build address.html -o nenga.pdf
```

## CSV形式

住所録をCSVで用意します。私は独自ツール（greple -Mtel）で生成していますが、ExcelやGoogleスプレッドシートからエクスポートしても構いません。

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

ヘッダー名は以前使っていたサービスのフォーマットを流用しています。「番地・建物」のように町名・番地・建物名を一つの欄にまとめていますが、内部的にはより細かく分けた形式にも対応しています。

### スキップ制御

備考欄に「保留」「済」「喪中」などの文字列が含まれていると、その宛先はスキップされます。印刷済みの宛先には「済」と入力しておけば、次回の印刷対象から外れます。

## Jinja2テンプレート

テンプレートファイル（nenga.emz）の構造を説明します。

### フロントマター

```jinja2
---
format: csv
bind:
  差出人: data | first
  宛先リスト: data[1:]
preamble: |
  {%- macro 値(v) %}{{ v|default('')|string|replace('nan', '') }}{% endmacro -%}

  {%- macro スキップ対象(row) -%}
    {{ 値(row['備考'])|regex_search('保留|済|喪中') }}
  {%- endmacro -%}

  {%- macro 姓(名前) -%}
    {%- set 姓名 = 名前.split(' ', 1) -%}
    {{ 姓名[0] if 姓名|length > 1 else '' }}
  {%- endmacro -%}

  {%- macro 名(名前) -%}
    {%- set 姓名 = 名前.split(' ', 1) -%}
    {{ 姓名[1] if 姓名|length > 1 else 名前 }}
  {%- endmacro -%}

  {%- macro 宛名一覧(row) -%}
    {%- set 筆頭者 = 値(row['姓']) ~ ' ' ~ 値(row['名']) -%}
    {%- set 家族 = (値(row['配偶者']) ~ '／' ~ 値(row['子供']) ~ '／' ~ 値(row['家族'])).replace('・', '／') -%}
    {%- set names = ([筆頭者] + 家族.split('／')) | select | list -%}
    {{ names | join('／') }}
  {%- endmacro -%}
---
```

- `format: csv`でCSV入力を指定
- `bind`で差出人（data[0]）と宛先リスト（data[1:]）を変数にバインド
- `preamble`でマクロを定義（日本語名も使えます）

`姓`と`名`マクロは「姓 名」形式の文字列からそれぞれを取り出します。`宛名一覧`マクロは筆頭者・配偶者・子供・家族を「／」で連結した文字列を返します。

### テンプレート本体

```html
{%- for 宛先 in 宛先リスト if not スキップ対象(宛先) %}
<section class="card">
  <div class="addr-to-zip">...</div>
  <div class="addr-to">
    <div class="addr-to-address">...</div>
    {%- set 名前リスト = 宛名一覧(宛先).split('／') %}
    <div class="addr-to-name">
      <table class="name-table">
        {%- for 名前 in 名前リスト %}
        <tr><td class="name-sei">{{ 姓(名前) }}</td><td class="name-mei">{{ 名(名前) }}</td><td class="name-title">様</td></tr>
        {%- endfor %}
      </table>
    </div>
  </div>
</section>
{%- endfor %}
```

`宛名一覧`マクロで全員の名前を取得し、`姓`と`名`マクロで分割しています。

### 生成されるHTML

テンプレートから生成されるHTMLは以下のようになります（1件分）。

```html
<section class="card">
  <div class="addr-to-zip">
    <span class="zip-digit zip-1">8</span>
    <span class="zip-digit zip-2">1</span>
    ...
  </div>
  <div class="addr-to">
    <div class="addr-to-address">
      <p class="addr-line1">奈良県奈良市</p>
      <p class="addr-line2">春日野町15</p>
      <p class="addr-line3">メゾン竹林815号室</p>
    </div>
    <div class="addr-to-name">
      <table class="name-table">
        <tr><td class="name-sei">竹取</td><td class="name-mei">翁</td><td class="name-title">様</td></tr>
        <tr><td class="name-sei"></td><td class="name-mei">媼</td><td class="name-title">様</td></tr>
        <tr><td class="name-sei"></td><td class="name-mei">かぐや</td><td class="name-title">様</td></tr>
      </table>
    </div>
  </div>
  <div class="addr-from-zip">...</div>
  <div class="addr-from">...</div>
</section>
```

クラス名は`addr-to-*`（宛先）と`addr-from-*`（差出人）で統一しています。

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

宛先の郵便番号枠は[日本郵便の公式仕様](https://www.post.japanpost.jp/zipcode/zipmanual/p05.html)に基づいています。

| 項目 | 値 |
|------|-----|
| 枠サイズ | 幅5.7mm × 高さ8mm |
| 位置（上端から） | 12.0mm |
| 枠間隔 | 1.3mm |

差出人の郵便番号枠には公式仕様がありません。配達に使用されないためです。実際の年賀はがきを定規で測って位置を決めました。

### 配置の例

郵便番号と宛名欄の配置例です。

```css
/* 宛先郵便番号 */
.addr-to-zip {
  position: absolute;
  top: 12mm;
  height: 8mm;
}

.addr-to-zip .zip-1 { left: 44.4mm; }
.addr-to-zip .zip-2 { left: 51.7mm; }
/* ... */

/* 宛名欄（住所・氏名） */
.addr-to {
  position: absolute;
  bottom: 46mm;
  left: 5mm;
  right: 5mm;
  text-align: center;
}
```

宛名欄は`bottom`で下端からの位置を指定し、中に含まれる住所と氏名は自然に上から並びます。

### プリンタ補正

プリンタごとの印刷位置のズレはOFFSETパラメータで補正します。

```bash
make OFFSET=-1.5mm nenga.pdf           # 左に1.5mmオフセット
make OFFSET="-1.5mm, 0.5mm" nenga.pdf  # 左に1.5mm、上に0.5mm
```

仕様としての位置（style.css）とプリンタ固有の補正を分離しています。OFFSETは印刷用PDFにのみ適用され、プレビュー用PDFには影響しません。

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

環境構築なしで試したい場合はDockerを使えます。

```bash
# サンプルCSVからPDFを生成（デモ）
docker run --rm -v "$(pwd):/work" tecolicom/nenga-print demo

# テンプレート一式を取得してカスタマイズ
docker run --rm -v "$(pwd):/work" tecolicom/nenga-print make init
```

`demo`はサンプルのCSVを使ってPDFを生成します。`make init`を実行すると、テンプレートファイル一式がカレントディレクトリに展開されるので、自分の環境に合わせてカスタマイズできます。

展開されるファイルには`.dozorc`も含まれています。[dozo](https://github.com/tecolicom/dozo)は Docker 実行を簡略化するラッパーで、これを使えば以降は `dozo make` だけでPDFを生成できます。

## まとめ

40年間、住所録のデータ形式は変わっていません。変わったのは印刷するためのフロントエンドだけです。

Mac印刷ソフト、Excel/Word、Webアプリと渡り歩いて、今回ようやくCLI完結のシステムができました。`make pdf`でPDFが生成され、来年も同じコマンドで動きます。

pandoc-embedzを作ったことがきっかけで、このシステムを作ることができました。年賀状印刷はpandoc-embedzの最もシンプルな使い方ですが、同じ仕組みで複雑な報告書の自動生成にも応用できます。興味があれば試してみてください。

## 今後の展望

現在はCLI完結のツールですが、将来的にはブラウザ上でプレビューしながら位置調整ができるUIを検討しています。YAMLでレイアウトパラメータを宣言的に定義し、スライダーで調整した結果がそのまま印刷に反映される仕組みです。

## リポジトリ

- **nenga-print**: https://github.com/tecolicom/nenga-print
- **pandoc-embedz**: https://github.com/tecolicom/pandoc-embedz
- **vivliostyle**: https://vivliostyle.org/ja/

---

この記事で紹介したシステムは実際に2026年の年賀状印刷で使用しました。リポジトリをフォークして、自分の環境に合わせてカスタマイズしてみてください。
