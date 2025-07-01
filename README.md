# Laravel + Nuxt + PostgreSQL テンプレート

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 17.x を使用したモダンなウェブアプリケーションテンプレートです。

> **テンプレートから作成されたプロジェクトの場合**: `[PROJECT_NAME]`部分がプロジェクト名に置き換わり、テンプレート固有の説明が削除されます。

## 🚀 クイックスタート

### テンプレートから新プロジェクトを作成（推奨）

```bash
# 1. GitHubで「Use this template」をクリック、または：
gh repo create my-new-project --template your-org/laravel-nuxt-template --private

# 2. クローンしてセットアップ（1コマンドで完了）
git clone https://github.com/your-org/my-new-project.git
cd my-new-project
./setup.sh my-new-project
```

### 直接クローンする場合

```bash
git clone https://github.com/your-org/laravel-nuxt-template.git my-project
cd my-project
./setup.sh my-project
```

**初回実行時**: テンプレートのカスタマイズ + 開発環境セットアップを自動実行  
**2 回目以降**: 開発環境セットアップのみ実行

## テンプレートの特徴

- **最新技術スタック**: Laravel 12、Nuxt 3、PostgreSQL 17 を使用
- **アーキテクチャ**: フロントエンドとバックエンドを分離した API ベースのアーキテクチャ
- **認証機能**: JWT を使用したトークンベースの認証
- **シンプルな実装**: 認証とダッシュボードによるフロント・バック・DB 連携のサンプル
- **TypeScript 対応**: Nuxt 3 プロジェクトでの最適化された TypeScript 設定
- **テスト環境**: PHPUnit と Vitest を使用したテスト環境
- **Docker 対応**: Docker Compose を使用した開発環境
- **CI/CD**: GitHub Actions を使用した自動テストとデプロイ
- **デプロイ設定**: Fly.io へのデプロイ設定済み
- **セキュリティ**: 安全なパスワードハッシュと CSRF 保護

## プロジェクト構成

```
laravel_nuxt_postgre_template/
├── .claude/                 # Claude AI設定
├── .fly/                    # Fly.io デプロイ設定
├── .husky/                  # Git hooks設定
├── backend/                 # Laravel API アプリケーション
│   ├── app/                 # アプリケーションコード
│   ├── config/             # 設定ファイル
│   ├── database/           # マイグレーション・シーダー
│   ├── resources/          # ビュー・アセット
│   ├── routes/             # ルート定義
│   ├── tests/              # テストファイル
│   └── fly.toml           # Fly.io設定
├── frontend/               # Nuxt.js フロントエンド
│   ├── composables/        # Vue Composables
│   ├── layouts/           # レイアウトコンポーネント
│   ├── pages/             # ページコンポーネント
│   ├── stores/            # Pinia状態管理
│   └── nuxt.config.ts     # Nuxt設定
├── docker/                # Docker Compose設定
├── docs/                  # プロジェクトドキュメント
├── docker-compose.yml     # Docker Compose定義
├── setup.sh              # 初期セットアップスクリプト
├── git-flow.md           # Git Flow運用ガイド
└── README.md             # プロジェクトメイン説明
```

## 開発環境のセットアップ

### 前提条件

- Docker Desktop (最新版)
- Node.js 22.x 以上
- PHP 8.3 以上
- Composer 2.x
- Git

#### mise を使用した開発環境管理（オプション）

[mise](https://mise.jdx.dev/) を使用することで、Node.js と PHP のバージョンを簡単に管理できます：

```bash
# mise がインストールされている場合
mise install  # .mise.toml に記載されたツールを自動インストール

# volta、asdf、nodenv、phpenv など他のバージョン管理ツールとも共存可能
# mise を使わない場合は、上記の前提条件に従って手動でインストール
```

### 開発環境の起動

```bash
# Docker環境での起動（推奨）
docker compose up -d

# または、ローカル環境での起動
# バックエンド
cd backend && php artisan serve

# フロントエンド（別ターミナル）
cd frontend && npm run dev
```

> **開発環境用 Docker 設定**: フロントエンドには開発環境用の `Dockerfile.dev` が用意されており、ホットリロードやデバッグに最適化されています。

アプリケーションにアクセス：

- **フロントエンド**: http://localhost:3000
- **バックエンド API**: http://localhost:8000
- **pgAdmin**: http://localhost:5050

### 推奨エディタとプラグイン

Visual Studio Code を推奨エディタとして使用します。

#### 必須拡張機能

**バックエンド (Laravel)**:

- PHP Intelephense
- Laravel Blade Formatter
- Laravel Snippets
- PHP DocBlocker

**フロントエンド (Nuxt/Vue)**:

- ESLint
- Prettier
- Volar（Vue Language Features）
- TypeScript Vue Plugin

**その他**:

- GitLens
- Docker
- DotENV
- PostgreSQL

### ポート設定

| サービス                 | ポート |
| ------------------------ | ------ |
| バックエンド (Laravel)   | 8000   |
| フロントエンド (Nuxt.js) | 3000   |
| PostgreSQL               | 5432   |
| pgAdmin                  | 5050   |

## 開発ガイド

### バックエンド（Laravel）

```bash
cd backend

# マイグレーション実行
php artisan migrate

# シーダー実行
php artisan db:seed

# テスト実行
php artisan test

# コード品質チェック
./vendor/bin/phpcs
./vendor/bin/pint
```

### フロントエンド（Nuxt）

```bash
cd frontend

# 開発サーバー起動
npm run dev

# ビルド
npm run build

# テスト実行
npm run test

# カバレッジ付きテスト
npm run test:coverage

# コード品質チェック
npm run lint
npm run lint:fix
```

## TypeScript 設定

### フロントエンド TypeScript 設定

本テンプレートでは、Nuxt 3 と Vue 3 の組み合わせで最適な TypeScript 体験を提供するために、以下の設定が行われています：

1. **tsconfig.json**

   ```json
   {
     "compilerOptions": {
       "strict": false,
       "skipLibCheck": true,
       "noImplicitAny": false,
       "noImplicitThis": false,
       "verbatimModuleSyntax": false,
       "suppressImplicitAnyIndexErrors": true
     },
     "vueCompilerOptions": {
       "target": 3,
       "experimentalDisableTemplateSupport": true
     }
   }
   ```

2. **型定義ファイル**

   - `shims-vue.d.ts` - Vue コンポーネントの型定義
   - `env.d.ts` - 環境変数の型定義

3. **ESLint 設定**
   - TypeScript と Vue 3 の連携に最適化されたルール設定

## 実装済みサンプル機能

このテンプレートには以下の機能が完全に実装されており、すぐに動作確認できます：

### ✅ 認証システム

- ユーザー登録・ログイン・ログアウト
- JWT トークンベース認証
- プロフィール画面

### ✅ UI/UX

- Vuetify Material Design
- レスポンシブ対応
- ローディング状態表示

## API 連携サンプル

### 認証フロー

JWT を使用した認証フローのサンプルが含まれています：

```typescript
// frontend/composables/useAuth.ts
const login = async (email: string, password: string) => {
  try {
    const response = await $fetch("/api/login", {
      method: "POST",
      body: { email, password },
    });
    // トークンの保存とユーザー情報の取得
  } catch (error) {
    // エラー処理
  }
};
```

### CRUD 操作サンプル

投稿（Posts）とコメント（Comments）の基本的な CRUD 操作サンプル：

```typescript
// 投稿一覧の取得
const fetchPosts = async () => {
  const { data } = await useFetch("/api/posts");
  return data.value;
};

// 新規投稿の作成
const createPost = async (postData) => {
  const { data } = await useFetch("/api/posts", {
    method: "POST",
    body: postData,
  });
  return data.value;
};
```

## デプロイ設定

### Fly.io へのデプロイ

本テンプレートには、Fly.io へのデプロイ設定が含まれています：

1. **GitHub Actions**: `.github/workflows/` ディレクトリに CI/CD パイプラインの設定
2. **Fly.io 設定**: コンテナデプロイと Fly Postgres の利用

#### デプロイ手順

1. **Fly.io CLI のインストール**

   ```bash
   curl -L https://fly.io/install.sh | sh
   fly auth login
   ```

2. **API Token の取得**

   ```bash
   fly tokens create
   ```

3. **GitHub Secrets の設定**
   以下の環境変数をリポジトリの GitHub Secrets に設定：

   - `FLY_API_TOKEN`: 上記で取得した API Token

4. **アプリ名の変更**
   `backend/fly.toml` と `frontend/fly.toml` の app 名を変更：

   ```toml
   app = "your-app-name-backend"  # 任意の名前に変更
   ```

   参考用に `fly.toml.example` ファイルも提供しているため、必要に応じて利用してください。

5. **詳細なセットアップ手順**
   より詳細な手順については [`docs/fly-setup.md`](docs/fly-setup.md) を参照してください。
6. **本番環境変数の確認**
   PostgreSQL 17 アップグレード時の注意事項：[PR #28](https://github.com/taka-123/laravel_nuxt_postgre_template/pull/28) を参照

## 開発ツールの設定

### テンプレート用の .gitignore 設定

このテンプレートでは、以下のツールがデフォルトで `.gitignore` に含まれています：

- **claude-parallel/**: Claude Code 並列開発環境ツール
- **.coderabbit.yaml**: CodeRabbit AI コードレビューツール設定
- **.cursor/**: Cursor IDE設定
- **.windsurfrules**: Windsurf IDE設定
- **mise.toml**: mise バージョン管理ツール設定

これらのツールをプロジェクトで使用したい場合は、`.gitignore` から該当行を削除してください：

```bash
# claude-parallelを使用する場合
# .gitignoreから以下の行を削除
# claude-parallel/

# CodeRabbitを使用する場合
# .gitignoreから以下の行を削除
# .coderabbit.yaml
# .coderabbit.yml

# Cursor IDEを使用する場合
# .gitignoreから以下の行を削除
# .cursor/

# Windsurf IDEを使用する場合
# .gitignoreから以下の行を削除
# .windsurfrules

# miseを使用する場合
# .gitignoreから以下の行を削除
# mise.toml
```

#### claude-parallel について

[claude-parallel](https://github.com/taka-123/claude-parallel) は、Git worktree と tmux を組み合わせた並列開発環境ツールです。チーム開発で使用する場合は、Git 管理に含めることで、チーム全体で同じ並列開発環境を共有できます。

#### CodeRabbit について

CodeRabbit は AI によるコードレビューツールです。プロジェクトで使用する場合は、設定ファイルをバージョン管理に含めることで、チーム全体で一貫したレビュー基準を維持できます。

### 開発フローの参考ガイド

このテンプレートには、チーム開発で活用できる Git Flow ベースの開発フローガイドが含まれています：

- [`git-flow.md`](git-flow.md) - GitHub Issue 作成から PR マージまでの標準的なフロー

このガイドは参考として提供していますので、プロジェクトの規模やチームの状況に応じて自由にカスタマイズしてください。

### CLAUDE.md について

このテンプレートには `CLAUDE.md` というプロジェクト仕様書が含まれています。これは以下の理由でGit管理されています：

- **プロジェクト固有の技術仕様や設計思想を記載**
- **新メンバーのオンボーディング資料として活用可能**
- **AI開発ツール（Claude Code等）との連携で開発効率向上**

ただし、以下の場合は削除または `.gitignore` への追加を検討してください：

- チームでAI開発ツールを全く使用しない
- 技術ドキュメントとしてメンテナンスする予定がない
- README.md で十分な情報が提供されている

```bash
# CLAUDE.mdを使用しない場合
# .gitignoreに追加
echo "CLAUDE.md" >> .gitignore

# または削除
rm CLAUDE.md
```

## トラブルシューティング

### TypeScript 言語サービスのクラッシュ

VSCode で問題が発生した場合：

1. VSCode を再起動する
2. コマンドパレット（Cmd+Shift+P）から「TypeScript: Restart TS Server」を実行する
3. `.vscode/settings.json` の設定を確認する

### Docker 環境の問題

Docker 環境で問題が発生した場合：

```bash
# コンテナとボリュームを完全に削除してリセット
docker compose down -v

# イメージを再ビルド
docker compose build --no-cache

# 再起動
docker compose up -d
```

## 貢献

プロジェクトへの貢献を歓迎します。Pull Request や Issue の報告をお待ちしています。

## ライセンス

MIT License
