# Claude Code 用メモ

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

## リリース管理

- セマンティックバージョニング（v0.1.0 形式）
- GitHub Actions でタグプッシュ時に Docker イメージをビルド
- amd64/arm64 マルチアーキテクチャ対応
- CHANGELOG の [Unreleased] セクションにリリース前の変更を記載
- リリース時に [Unreleased] をバージョン番号に変更
