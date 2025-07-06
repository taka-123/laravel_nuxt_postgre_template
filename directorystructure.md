## プロジェクト構造規約

root/
├── .claude/ # Claude AI 設定
├── .fly/ # Fly.io デプロイ設定
├── .husky/ # Git hooks 設定
├── backend/ # Laravel API アプリケーション
│ ├── app/ # アプリケーションコード
│ │ ├── Http/ # コントローラー・ミドルウェア
│ │ ├── Models/ # Eloquent モデル
│ │ └── Providers/ # サービスプロバイダー
│ ├── config/ # 設定ファイル
│ ├── database/ # マイグレーション・シーダー
│ ├── docker/ # Docker 設定
│ ├── resources/ # ビュー・アセット
│ ├── routes/ # ルート定義
│ ├── storage/ # ストレージディレクトリ
│ ├── tests/ # テストファイル
│ ├── composer.json # Composer 依存関係
│ ├── Dockerfile.fly # Fly.io 用 Dockerfile
│ ├── fly.toml # Fly.io 設定
│ └── phpcs.xml # コーディング規約
├── frontend/ # Nuxt.js フロントエンド
│ ├── composables/ # Vue Composables
│ ├── layouts/ # レイアウトコンポーネント
│ ├── pages/ # ページコンポーネント
│ ├── plugins/ # Nuxt プラグイン
│ ├── stores/ # Pinia 状態管理
│ ├── types/ # TypeScript 型定義
│ ├── package.json # npm 依存関係
│ ├── nuxt.config.ts # Nuxt 設定
│ └── tsconfig.json # TypeScript 設定
├── docker/ # Docker Compose 設定
├── docs/ # 技術詳細ドキュメント（デプロイ除外）
├── docker-compose.yml # Docker Compose 定義
├── package.json # ルートレベル依存関係
├── setup.sh # 初期セットアップスクリプト
├── git-flow.md # Git Flow 運用ガイド
├── directorystructure.md # プロジェクト構造説明
├── technologystack.md # 技術スタック説明
├── LICENSE # MIT ライセンス
└── README.md # プロジェクトメイン説明
