# Claude Code 用メモ

## プロジェクト概要

年賀状宛名印刷システム。CSV から HTML/PDF を生成する。

- **技術スタック**: Docker, vivliostyle (CSS組版), pandoc-embedz (テンプレート), Klee One (フォント)
- **レイアウト**: 横書き（kon104 の縦書きとは異なるアプローチ）
- **現行バージョン**: v0.4.0 (2025-01-05)

## Docker ビルド

ローカルビルドは `:dev` タグを使用する（`:latest` を上書きしない）：

```bash
docker build -t tecolicom/nenga-print:dev .
```

テストも `:dev` を使用：

```bash
docker run --rm -v "$(pwd):/work" tecolicom/nenga-print:dev make sample.pdf
```

## 2つの Makefile 構成

- `Makefile` - Docker イメージ内 `/app` 用。`make init` で初期化。
- `Makefile.local` - ローカル `/work` 用。`init` 時にコピーされる。

vivliostyle が `/work` 外の CSS ファイルを参照できない制限があるため、
`/app` で実行する方式と、ローカルにファイルをコピーする方式を分けた。

## CSS 構成 (v0.4.0)

- `style.css` - 基本レイアウト（@page, .card, @media screen/print）。他のCSSをインポート
- `style-zip.css` - 郵便番号配置（フォント: Helvetica, font-weight: 100）
- `style-custom.css` - カスタマイズ用（フォント、住所・氏名の配置）
- `style-preview.css` - プレビュー用（style.css をインポート、グリッド表示）
- `style-printer.css` - プリンタ補正用（OFFSET パラメータで動的生成）

## 出力形式

1. **PDF** (`make sample.pdf`) - vivliostyle でビルド、印刷用
2. **プレビューPDF** (`make sample.preview.pdf`) - 枠・グリッド付き確認用
3. **HTML** (`make sample.html`) - ブラウザで表示・印刷用（v0.4.0 で追加）

### HTML 表示機能
- グレー背景、カード中央配置、影付き
- 矢印キー（←→↑↓）で1枚ずつ切り替え
- タイトルバーに現在位置表示（例: 年賀状宛名 (3/10)）
- ブラウザ印刷時は全カード表示（@media print で display:none を上書き）

## OFFSET（プリンタ補正）

プリンタごとの印刷位置ずれを補正：

```bash
make OFFSET=-1.5mm sample.pdf      # PDF
make OFFSET=-1.5mm sample.html     # HTML（ブラウザ印刷用）
```

- PDF: vivliostyle に `--css "data:,..."` で渡す
- HTML: `style-printer.css` を生成して @media print で適用

## リリース管理

- セマンティックバージョニング（v0.1.0 形式）
- GitHub Actions でタグプッシュ時に Docker イメージをビルド
- amd64/arm64 マルチアーキテクチャ対応
- CHANGELOG の [Unreleased] セクションにリリース前の変更を記載
- リリース時に [Unreleased] をバージョン番号に変更
- タグは v0.4.0 形式で統一（v0.4 のような省略形は使わない）

## 今後の可能性

1. **HTML へのオフセット埋め込み**
   - 現在は style-printer.css を別ファイルで生成
   - pandoc-embedz の `-c` オプションや sed で HTML に直接埋め込む方法も検討したが、現状維持

2. **Docker イメージの軽量化**
   - 現在約 2GB（Chromium 310MB, Node modules 234MB, Python 165MB）
   - vivliostyle が Chromium を必要とするため大幅削減は困難

3. **kon104 との比較**
   - kon104: Web サービス、ブラウザ完結、縦書き、JavaScript で CSV パース
   - nenga-print: CLI ツール、Docker/ローカル、横書き、テンプレートエンジン
   - kon104 にはオフセット機能なし（プリンタドライバ依存）

## 懸念点・注意事項

1. **ブラウザ印刷とPDF印刷の差異**
   - 理論上は同じだが、ブラウザの設定（拡大率、余白、用紙サイズ）に依存
   - 印刷設定: 拡大率100%、余白なし、ヘッダー/フッターなし、はがきサイズ

2. **Brother プリンタ**
   - ドライバに位置調整機能がない
   - OFFSET 機能で対応

3. **フォント**
   - 郵便番号: Helvetica, font-weight: 100（細め、存在感を抑える）
   - 宛名: Klee One（Google Fonts、Web フォント）

## 開発履歴 (v0.4.0)

- SHIFT → OFFSET に名称変更
- CSS を分離（style.css, style-zip.css, style-custom.css）
- style-preview.css に style.css のインポート追加（ブラウザで背景表示可能に）
- 画面表示スタイル追加（グレー背景、中央配置、影）
- 矢印キーでカード切り替え機能
- HTML 印刷対応（OFFSET パラメータ対応）
