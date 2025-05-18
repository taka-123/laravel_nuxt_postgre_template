# Laravel + Nuxt + PostgreSQL テンプレート

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 16.x を使用したモダンなウェブアプリケーションテンプレートです。認証機能、CRUD 操作、テスト環境、CI/CD 設定など、プロジェクト開始に必要な基盤が整っています。

## 目次

- [Laravel + Nuxt + PostgreSQL テンプレート](#laravel--nuxt--postgresql-テンプレート)
  - [目次](#目次)
  - [テンプレートの特徴](#テンプレートの特徴)
  - [プロジェクト構成](#プロジェクト構成)
  - [開発環境のセットアップ](#開発環境のセットアップ)
    - [前提条件](#前提条件)
    - [推奨エディタとプラグイン](#推奨エディタとプラグイン)
      - [必須拡張機能](#必須拡張機能)
    - [ポート設定](#ポート設定)
  - [Docker 環境の起動方法](#docker-環境の起動方法)
    - [重要: 同時に両方の環境を起動しないでください](#重要-同時に両方の環境を起動しないでください)
    - [正しい起動方法](#正しい起動方法)
    - [正しい停止方法](#正しい停止方法)
  - [開発サーバーの起動](#開発サーバーの起動)
    - [Docker を使用した起動（推奨）](#docker-を使用した起動推奨)
    - [個別の起動方法](#個別の起動方法)
  - [TypeScript 設定](#typescript-設定)
    - [フロントエンド TypeScript 設定](#フロントエンド-typescript-設定)
    - [VSCode 設定](#vscode-設定)
  - [コード品質管理とテスト](#コード品質管理とテスト)
    - [Linter と Formatter](#linter-と-formatter)
    - [テスト実行](#テスト実行)
  - [API 連携サンプル](#api-連携サンプル)
    - [認証フロー](#認証フロー)
    - [CRUD 操作サンプル](#crud-操作サンプル)
  - [デプロイ設定](#デプロイ設定)
  - [トラブルシューティング](#トラブルシューティング)

## テンプレートの特徴

- **最新技術スタック**: Laravel 12、Nuxt 3、PostgreSQL 16 を使用
- **アーキテクチャ**: フロントエンドとバックエンドを分離した API ベースのアーキテクチャ
- **認証機能**: JWT を使用したトークンベースの認証
- **サンプル CRUD**: 投稿とコメントの基本的な CRUD 機能
- **TypeScript 対応**: Nuxt 3 プロジェクトでの最適化された TypeScript 設定
- **テスト環境**: PHPUnit と Vitest を使用したテスト環境
- **Docker 対応**: Docker Compose を使用した開発環境
- **CI/CD**: GitHub Actions を使用した自動テストとデプロイ
- **デプロイ設定**: AWS ECS へのデプロイ設定済み
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

### 推奨エディタとプラグイン

Visual Studio Code を推奨エディタとして使用します。以下の拡張機能をインストールすることで、開発効率が向上します。

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

フロントエンドディレクトリには、推奨拡張機能を自動的に提案する `.vscode/extensions.json` が含まれています。

### ポート設定

| サービス                 | ポート |
| ------------------------ | ------ |
| バックエンド (Laravel)   | 8000   |
| フロントエンド (Nuxt.js) | 3000   |
| PostgreSQL               | 5432   |
| pgAdmin                  | 5050   |

## Docker 環境の起動方法

### 重要: 同時に両方の環境を起動しないでください

バックエンドとフロントエンドの Docker 環境は、同時に起動すると競合する可能性があります。

### 正しい起動方法

**バックエンド環境の起動**:

```bash
cd backend
./vendor/bin/sail up -d
```

**フロントエンド環境の起動**:

```bash
cd frontend
docker-compose up -d
```

### 正しい停止方法

**バックエンド環境の停止**:

```bash
cd backend
./vendor/bin/sail down
```

**フロントエンド環境の停止**:

```bash
cd frontend
docker-compose down
```

## 開発サーバーの起動

### Docker を使用した起動（推奨）

```bash
# バックエンドの起動
cd backend
./vendor/bin/sail up -d

# フロントエンドの起動
cd frontend
docker-compose up -d
```

### 個別の起動方法

**バックエンド（Laravel）**:

```bash
cd backend
composer install
php artisan serve
```

**フロントエンド（Nuxt.js）**:

```bash
cd frontend
npm install
npm run dev
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

### VSCode 設定

`.vscode/settings.json`には、TypeScript と Vue の連携に関する最適な設定が含まれています：

```json
{
  "typescript.validate.enable": false,
  "javascript.validate.enable": false,
  "volar.takeOverMode.enabled": false
}
```

これらの設定により、言語サービスのクラッシュを防止し、スムーズな開発体験を提供します。

## コード品質管理とテスト

### Linter と Formatter

**バックエンド**:

- PHP_CodeSniffer: PSR-12 準拠のコーディング規約チェック
- Laravel Pint: コードフォーマッター

```bash
cd backend
./vendor/bin/phpcs
./vendor/bin/pint
```

**フロントエンド**:

- ESLint: コード品質チェック
- Prettier: コードフォーマッター

```bash
cd frontend
npm run lint
npm run format
```

### テスト実行

**バックエンド**:

```bash
cd backend
./vendor/bin/sail test
```

**フロントエンド**:

```bash
cd frontend
npm run test
```

## API 連携サンプル

### 認証フロー

本テンプレートには、JWT を使用した認証フローのサンプルが含まれています：

1. **ログイン処理**:

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

2. **認証状態の管理**:
   ```typescript
   // frontend/stores/auth.ts
   export const useAuthStore = defineStore("auth", {
     state: () => ({
       user: null,
       token: null,
       isAuthenticated: false,
     }),
     actions: {
       // 認証アクション
     },
   });
   ```

### CRUD 操作サンプル

投稿（Posts）とコメント（Comments）の基本的な CRUD 操作サンプル：

1. **データ取得**:

   ```typescript
   // 投稿一覧の取得
   const fetchPosts = async () => {
     const { data } = await useFetch("/api/posts");
     return data.value;
   };
   ```

2. **データ作成**:

   ```typescript
   // 新規投稿の作成
   const createPost = async (postData) => {
     const { data } = await useFetch("/api/posts", {
       method: "POST",
       body: postData,
     });
     return data.value;
   };
   ```

3. **データ更新と削除**:

   ```typescript
   // 投稿の更新
   const updatePost = async (id, postData) => {
     const { data } = await useFetch(`/api/posts/${id}`, {
       method: "PUT",
       body: postData,
     });
     return data.value;
   };

   // 投稿の削除
   const deletePost = async (id) => {
     await useFetch(`/api/posts/${id}`, {
       method: "DELETE",
     });
   };
   ```

## デプロイ設定

本テンプレートには、Fly.io へのデプロイ設定が含まれています：

1. **GitHub Actions**:

   - `.github/workflows/` ディレクトリに CI/CD パイプラインの設定
   - テスト、ビルド、デプロイの自動化

2. **Fly.io 設定**:
   - Fly.io プラットフォームを使用したコンテナデプロイ
   - Fly Postgres を使用したデータベース
   - グローバルエッジネットワークによる高速配信

詳細な設定は `.fly/README.md` を参照してください。

3. **将来の拡張オプション**:
   - 大規模なプロジェクトへの拡張時には AWS ECS/RDS/CloudFront などの利用も検討可能

## トラブルシューティング

**TypeScript 言語サービスのクラッシュ**:

VSCode で TypeScript 言語サービスがクラッシュする場合は、以下の対処法を試してください：

1. VSCode を再起動する
2. コマンドパレット（Cmd+Shift+P）から「TypeScript: Restart TS Server」を実行する
3. `.vscode/settings.json` の設定を確認する

**Docker 環境の問題**:

Docker 環境で問題が発生した場合：

1. コンテナとボリュームを完全に削除してリセット

   ```bash
   docker-compose down -v
   ```

2. イメージを再ビルド

   ```bash
   docker-compose build --no-cache
   ```

3. 再起動
   ```bash
   docker-compose up -d
   ```

**その他の問題**:

問題が解決しない場合は、GitHub Issues に報告するか、プロジェクトのメンテナーにお問い合わせください。
