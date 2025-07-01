## プロジェクト構造規約

laravel_nuxt_postgre_template/
├── .claude/                 # Claude AI設定
├── .cursor/                 # Cursor IDE設定
├── .fly/                    # Fly.io デプロイ設定
├── .husky/                  # Git hooks設定
├── backend/                 # Laravel API アプリケーション
│   ├── app/                 # アプリケーションコード
│   │   ├── Http/           # コントローラー・ミドルウェア
│   │   ├── Models/         # Eloquentモデル
│   │   └── Providers/      # サービスプロバイダー
│   ├── config/             # 設定ファイル
│   ├── database/           # マイグレーション・シーダー
│   ├── docker/             # Docker設定
│   ├── resources/          # ビュー・アセット
│   ├── routes/             # ルート定義
│   ├── storage/            # ストレージディレクトリ
│   ├── tests/              # テストファイル
│   ├── composer.json       # Composer依存関係
│   ├── Dockerfile.fly      # Fly.io用Dockerfile
│   ├── fly.toml           # Fly.io設定
│   └── phpcs.xml          # コーディング規約
├── frontend/               # Nuxt.js フロントエンド
│   ├── composables/        # Vue Composables
│   ├── layouts/           # レイアウトコンポーネント
│   ├── pages/             # ページコンポーネント
│   ├── plugins/           # Nuxtプラグイン
│   ├── stores/            # Pinia状態管理
│   ├── types/             # TypeScript型定義
│   ├── package.json       # npm依存関係
│   ├── nuxt.config.ts     # Nuxt設定
│   └── tsconfig.json      # TypeScript設定
├── docker/                # Docker Compose設定
├── docs/                  # プロジェクトドキュメント
├── docker-compose.yml     # Docker Compose定義
├── package.json          # ルートレベル依存関係
├── setup.sh              # 初期セットアップスクリプト
├── git-flow.md           # Git Flow運用ガイド
├── technologystack.md    # 技術スタック説明
├── LICENSE               # MITライセンス
└── README.md             # プロジェクトメイン説明
