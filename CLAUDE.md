# Claude Code 用メモ

## プロジェクト概要

年賀状宛名印刷システム。CSV から HTML/PDF を生成する。

- **技術スタック**: Docker, vivliostyle (CSS組版), pandoc-embedz (テンプレート), Klee One (フォント)
- **レイアウト**: 横書き（kon104 の縦書きとは異なるアプローチ）
- **現行バージョン**: v0.5.0 (2025-01-06)

## Docker イメージ

### 公開イメージ
- `tecolicom/nenga-print` - フル版（PDF/HTML 生成、約 2GB）
- `tecolicom/nenga-print:light` - 軽量版（HTML のみ、約 300MB）

### ローカルビルド

Dockerfile はテンプレート（`.in` ファイル）から生成する：

```bash
make build          # Dockerfile 生成 → イメージビルド（フル版＋軽量版）
make Dockerfile     # Dockerfile のみ生成
```

開発用ビルド（`:dev` タグ）：

```bash
docker build -t tecolicom/nenga-print:dev .
docker run --rm -v "$(pwd):/work" tecolicom/nenga-print:dev make sample.pdf
```

## Makefile 構成

- `Makefile` - ローカル用（PDF/HTML 生成、Dockerfile 生成）
- `Makefile.docker` - Docker イメージ内 `/app` 用
- `Dockerfile.in` / `Dockerfile.light.in` - Dockerfile テンプレート

CSS/SVG ファイルリストは Makefile で一元管理：

```makefile
CSS_FILES := style.css style-custom.css style-zip.css style-preview.css
SVG_FILES := hagaki-bg.svg grid.svg
```

Dockerfile 生成時にプレースホルダ（`@CSS_FILES@` 等）を置換する。

## CSS 構成

- `style.css` - 基本レイアウト（@page, .card, @media screen/print）。他のCSSをインポート
- `style-zip.css` - 郵便番号配置（フォント: Helvetica, font-weight: 100）
- `style-custom.css` - カスタマイズ用（フォント、住所・氏名の配置）
- `style-preview.css` - プレビュー用（style.css をインポート、グリッド表示）
- `style-printer.css` - プリンタ補正用（OFFSET パラメータで動的生成、.PHONY）

## 出力形式

1. **PDF** (`make sample.pdf`) - vivliostyle でビルド、印刷用
2. **プレビューPDF** (`make sample.preview.pdf`) - 枠・グリッド付き確認用
3. **HTML** (`make sample.html`) - ブラウザで表示・印刷用（v0.4.0 で追加）

### HTML 表示機能
- グレー背景、カード中央配置、影付き
- タイトルバーに現在位置表示（例: 年賀状宛名 (3/10)）
- ブラウザ印刷時は全カード表示（@media print で display:none を上書き）
- `?print` URL パラメータで全カード表示

### キーボードショートカット
- `←` `→` `j` `k` - ページ切り替え
- `Home` `End` - 最初/最後のページへ
- `PageUp` `PageDown` - ページナビゲーション
- `g` - グリッド表示のトグル
- `h` - 背景画像のトグル
- `?` - ヘルプ表示のトグル

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
  - フル版（`tecolicom/nenga-print`）と軽量版（`nenga-print:light`）の両方
  - `make Dockerfile Dockerfile.light` で Dockerfile を生成してからビルド
- amd64/arm64 マルチアーキテクチャ対応
- CHANGELOG の [Unreleased] セクションにリリース前の変更を記載
- リリース時に [Unreleased] をバージョン番号に変更
- タグは v0.4.0 形式で統一（v0.4 のような省略形は使わない）

## 今後の可能性

1. **HTML へのオフセット埋め込み**
   - 現在は style-printer.css を別ファイルで生成
   - pandoc-embedz の `-c` オプションや sed で HTML に直接埋め込む方法も検討したが、現状維持

2. **kon104 との比較**
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

4. **grid.svg（プレビュー用グリッド）**
   - ラインベースで描画（パターンベースは PDF でぼやける）
   - `shape-rendering="crispEdges"` でアンチエイリアス無効化
   - 1mm/5mm/10mm 方眼、それぞれ線の太さと透明度を調整

## 開発履歴

### v0.5.0 (2025-01-06)
- 軽量 Docker イメージ `nenga-print:light` 追加（HTML のみ、約 300MB）
- Dockerfile をテンプレート（`.in` ファイル）から生成する方式に変更
- CSS/SVG ファイルリストを Makefile で一元管理
- grid.svg をパターンベースからラインベースに戻し PDF 品質改善
- キーボードショートカット追加（g/h/?/PageUp/PageDown/Home/End）
- `?print` URL パラメータで全カード表示
- `make build` でローカルビルド

### v0.4.0 (2025-01-05)
- SHIFT → OFFSET に名称変更
- CSS を分離（style.css, style-zip.css, style-custom.css）
- style-preview.css に style.css のインポート追加（ブラウザで背景表示可能に）
- 画面表示スタイル追加（グレー背景、中央配置、影）
- 矢印キーでカード切り替え機能
- HTML 印刷対応（OFFSET パラメータ対応）
