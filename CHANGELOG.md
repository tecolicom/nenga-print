# Changelog

## [Unreleased]

## [0.4] - 2025-01-05

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
