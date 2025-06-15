# [PROJECT_NAME] Laravel + Nuxt + PostgreSQL テンプレート

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 16.x を使用したモダンなウェブアプリケーションテンプレートです。

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

- **最新技術スタック**: Laravel 12、Nuxt 3、PostgreSQL 16 を使用
- **アーキテクチャ**: フロントエンドとバックエンドを分離した API ベースのアーキテクチャ
- **認証機能**: JWT を使用したトークンベースの認証
- **サンプル CRUD**: 投稿とコメントの基本的な CRUD 機能
- **TypeScript 対応**: Nuxt 3 プロジェクトでの最適化された TypeScript 設定
- **テスト環境**: PHPUnit と Vitest を使用したテスト環境
- **Docker 対応**: Docker Compose を使用した開発環境
- **CI/CD**: GitHub Actions を使用した自動テストとデプロイ
- **デプロイ設定**: Fly.io へのデプロイ設定済み
- **セキュリティ**: 安全なパスワードハッシュと CSRF 保護

## プロジェクト構成

```
/
├── backend/          # Laravel アプリケーション
├── frontend/         # Nuxt.js アプリケーション
├── docker/           # Docker 関連ファイル
├── docs/             # プロジェクトドキュメント
└── .github/          # GitHub Actions ワークフロー
```

## 開発環境のセットアップ

### 前提条件

- Docker Desktop (最新版)
- Node.js 20.x 以上
- PHP 8.3 以上
- Composer 2.x
- Git

### 開発環境の起動

```bash
# バックエンドの起動
cd backend
./vendor/bin/sail up -d

# フロントエンドの起動（別ターミナル）
cd frontend
docker-compose up -d
```

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

# コード品質チェック
npm run lint
npm run format
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

### 将来の拡張オプション

大規模なプロジェクトへの拡張時には AWS ECS/RDS/CloudFront などの利用も検討可能です。

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
docker-compose down -v

# イメージを再ビルド
docker-compose build --no-cache

# 再起動
docker-compose up -d
```

## 貢献

プロジェクトへの貢献を歓迎します。Pull Request や Issue の報告をお待ちしています。

## ライセンス

MIT License
