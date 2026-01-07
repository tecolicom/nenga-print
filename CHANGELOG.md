# Changelog

## [Unreleased]

### Added
- CSV に敬称フィールドを追加（デフォルト: 様）

### Changed
- CSS クラス名を変更（`to-*`/`from-*` → `addr-to-*`/`addr-from-*`）
- テンプレートのマクロを整理（都道府県, 市区町村, 姓, 名, 敬称 等を追加）

## [0.5.0] - 2025-01-06

### Added
- 軽量 Docker イメージ `nenga-print:light`（HTML 生成のみ、約 300MB）
- `make build` で Docker イメージをビルド
- キーボードショートカット: g（グリッド表示）, h（背景切替）, ?（ヘルプ）
- PageUp/PageDown/Home/End でページナビゲーション
- `?print` URL パラメータで全カード表示

### Changed
- Dockerfile をテンプレート（Dockerfile.in）から生成する方式に変更
- CSS/SVG ファイルリストを Makefile で一元管理
- grid.svg: パターンベースから line ベースに戻し PDF 品質を改善
- grid.svg: 線の太さと透明度を調整（より鮮明に）
- Makefile: ローカル用をデフォルトに（Makefile.docker は Docker 内用）
- style-printer.css を動的生成に変更（OFFSET 対応）

### Fixed
- PDF/印刷プレビューでグリッドがぼやける問題を修正

## [0.4.0] - 2025-01-05

### Added
- HTML 印刷対応（`make *.html` でブラウザ印刷用 HTML を生成）
- 矢印キーでカード切り替え機能（HTML 表示時）
- 画面表示用スタイル（グレー背景、中央配置、影）

### Changed
- SHIFT オプションを OFFSET に名称変更
- CSS を分離（style.css、style-zip.css、style-custom.css）
- 郵便番号フォント: Helvetica, font-weight: 100, サイズ縮小
- OFFSET パラメータが PDF と HTML 両方で有効に

## [0.3.0] - 2025-01-05

### Changed
- プレビューのデフォルトポートを 13000 に変更（vivliostyle デフォルト）
- PORT 変数でポート番号をカスタマイズ可能に
- ローカル実行時はブラウザが自動で開くように改善
- .dozorc のポートマッピングをコメントアウト（必要時にアンコメント）

## [0.2.0] - 2025-01-05

### Added
- リアルタイムプレビュー機能（`dozo make *.preview`）

## [0.1.2] - 2025-01-05

### Changed
- Dockerfile: デフォルト WORKDIR を /work に変更
- README: .dozorc セットアップを最初に説明、例を簡略化
- grid.svg: SVG pattern を使用して大幅に簡略化

### Fixed
- Docker を -w オプションなしで実行した場合の動作を修正

## [0.1.1] - 2025-01-05

### Fixed
- dozo でサブディレクトリから実行した場合に正しく動作しない問題を修正

## [0.1.0] - 2025-01-05

### Added
- 初期リリース
- CSV から年賀状宛名 PDF を生成
- プレビュー用 PDF（枠付き）生成
- プリンタ補正オプション（SHIFT）
- 夫婦別姓対応
- `make init` でローカルカスタマイズ
- amd64/arm64 マルチアーキテクチャ対応
