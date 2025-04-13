# 書籍管理システム フロントエンド

このディレクトリには書籍管理システムのフロントエンド（Nuxt.js 3.16）が含まれています。

## フロントエンド技術スタック

- **フレームワーク**: Nuxt.js 3.16
- **UIフレームワーク**: Vuetify 3.7
- **状態管理**: Pinia
- **HTTP通信**: Axios
- **コード品質**: ESLint + Prettier
- **テスト**: Vitest + Vue Test Utils

## セットアップ

依存関係をインストールします：

```bash
# npm
npm install
```

## 開発サーバー

開発サーバーを起動します（http://localhost:3000）：

```bash
# npm
npm run dev
```

## コマンド一覧

```bash
# 開発サーバー起動
npm run dev

# 本番用ビルド
npm run build

# 本番ビルドのプレビュー
npm run preview

# コード品質チェック
npm run lint

# コード品質チェックと自動修正
npm run lint:fix

# テスト実行
npm test

# テスト（ウォッチモード）
npm run test:watch

# テストカバレッジ
npm run test:coverage
```

## ディレクトリ構造

```
frontend/
├── assets/           # 静的ファイル（SCSS, 画像など）
├── components/       # 再利用可能なVueコンポーネント
├── composables/      # 再利用可能なVue Composables
├── layouts/          # レイアウトコンポーネント
├── pages/            # ページコンポーネント（ルーティング）
├── plugins/          # Nuxtプラグイン
├── public/           # 公開ファイル
├── stores/           # Piniaストア
└── test/             # テストファイル
```

## 詳細情報

詳細については、以下を参照してください：

- [Nuxt 3 ドキュメント](https://nuxt.com/docs/getting-started/introduction)
- [Vuetify 3 ドキュメント](https://vuetifyjs.com/en/introduction/why-vuetify/)
- [プロジェクト開発環境ガイド](../DEVELOPMENT.md)
