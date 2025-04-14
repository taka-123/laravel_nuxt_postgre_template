# Laravel + Nuxt.js + PostgreSQL プロジェクトセットアップ手順

## 概要

本ドキュメントでは、Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 16.x を使用した開発環境セットアップ手順を説明します。モノレポ構成を採用し、JWT 認証を実装します。

## 前提条件

- Docker Desktop がインストールされていること
- Node.js 18.0 以上がインストールされていること
- Git がインストールされていること
- Composer がインストールされていること（オプション、Docker 内で実行も可）

## ポート設定

| サービス               | ポート |
| ---------------------- | ------ |
| Laravel バックエンド   | 8000   |
| Nuxt.js フロントエンド | 3000   |
| PostgreSQL             | 5432   |
| pgAdmin                | 5050   |

## セットアップ手順

### フェーズ 1: プロジェクト基盤構築

#### 1.1 プロジェクト構造の作成

モノレポ構成で、以下のディレクトリ構造を作成します：

```
book-management/
├── backend/          # Laravel アプリケーション
├── frontend/         # Nuxt.js アプリケーション
├── docker/           # Docker 関連ファイル
├── docs/             # プロジェクトドキュメント
└── .github/          # GitHub Actions ワークフロー
```

#### 1.2 バックエンド (Laravel) の初期設定

1. Laravel プロジェクトの作成
2. Laravel Sail の設定
3. PostgreSQL データベース接続の設定
4. 基本的な API 構造の定義
5. JWT 認証の設定

#### 1.2.1 Laravel プロジェクトの作成

```bash
# backend ディレクトリで実行
composer create-project laravel/laravel .
```

#### 1.2.2 Laravel Sail のセットアップ

Laravel 12.x では、Sail のセットアップ方法が変更されている可能性があります。公式ドキュメント（https://laravel.com/docs/12.x/sail）を参照してください。

```bash
# backend ディレクトリで実行
composer require laravel/sail --dev
php artisan sail:install
```

#### 1.2.3 PostgreSQL データベース接続の設定

`.env` ファイルを編集して PostgreSQL の接続情報を設定します：

```
DB_CONNECTION=pgsql
DB_HOST=pgsql
DB_PORT=5432
DB_DATABASE=book_management
DB_USERNAME=sail
DB_PASSWORD=password
```

#### 1.2.4 JWT 認証パッケージのインストール

Laravel 12.x での最新の JWT 認証パッケージを使用します。公式ドキュメント（https://laravel.com/docs/12.x/authentication）を参照してください。

```bash
# backend ディレクトリで実行
composer require php-open-source-saver/jwt-auth
```

#### 1.2.5 JWT 認証コントローラーとルートの設定

認証ロジックを処理するコントローラーを作成します。

```bash
# backend ディレクトリで実行
php artisan make:controller AuthController
```

作成された `app/Http/Controllers/AuthController.php` に、ユーザー登録、ログイン、ログアウト、トークンリフレッシュ、ユーザー情報取得のメソッドを実装します。

```php
// app/Http/Controllers/AuthController.php の実装例
// (登録、ログイン、ログアウト、リフレッシュ、me メソッドを含む)
```

API ルートを設定します。`routes/api.php` を編集して、認証関連のエンドポイントを定義します。

```php
// routes/api.php
use App\Http\Controllers\AuthController;

Route::group([
    'middleware' => 'api',
    'prefix' => 'auth'
], function ($router) {
    Route::post('register', [AuthController::class, 'register'])->name('register');
    Route::post('login', [AuthController::class, 'login'])->name('login');
    Route::post('logout', [AuthController::class, 'logout'])->name('logout');
    Route::post('refresh', [AuthController::class, 'refresh'])->name('refresh');
    Route::get('me', [AuthController::class, 'me'])->name('me');
});
```

#### 1.3 フロントエンド (Nuxt.js) の初期設定

#### 1.3.1 Nuxt.js プロジェクトの作成

```bash
# frontend ディレクトリで実行
npx nuxi@latest init .
```

初期化時の質問には以下のように回答します：

- Which package manager would you like to use? → **npm**
- Initialize git repository? → **No** （すでにルートで初期化済み）
- モジュール選択では **ESLint integration** のみを選択

#### 1.3.2 Vuetify 3 のインストールと設定

UI フレームワークとして Vuetify をインストールし、Nuxt プロジェクトに設定します。

```bash
# frontend ディレクトリで実行
npm add vuetify@^3.7.0 @mdi/font
npm add -D vite-plugin-vuetify@^2.0.0
```

`nuxt.config.ts` を編集して Vuetify を有効にします。

```typescript
// frontend/nuxt.config.ts
import vuetify, { transformAssetUrls } from "vite-plugin-vuetify";

export default defineNuxtConfig({
  devtools: { enabled: true },
  build: {
    transpile: ["vuetify"],
  },
  modules: [
    (_options, nuxt) => {
      nuxt.hooks.hook("vite:extendConfig", (config) => {
        // @ts-expect-error
        config.plugins.push(vuetify({ autoImport: true }));
      });
    },
    // Piniaの追加
    "@pinia/nuxt",
  ],
  vite: {
    vue: {
      template: {
        transformAssetUrls,
      },
    },
  },
  // CSSの追加
  css: [
    "vuetify/lib/styles/main.sass",
    "@mdi/font/css/materialdesignicons.min.css",
  ],
  // Piniaの設定
  pinia: {
    autoImports: [
      // automatically import `defineStore`
      "defineStore", // import { defineStore } from 'pinia'
      ["defineStore", "definePiniaStore"], // import { defineStore as definePiniaStore } from 'pinia'
    ],
  },
});
```

また、Vuetify で Sass を使用するため、Sass もインストールします。

```bash
# frontend ディレクトリで実行
npm add -D sass
```

#### 1.3.3 状態管理 (Pinia) の設定

状態管理ライブラリとして Pinia を導入します。（`nuxt.config.ts` の設定は 1.3.2 で実施済み）

```bash
# frontend ディレクトリで実行
npm add @pinia/nuxt pinia
```

認証情報を管理するストアを作成します。

```bash
# frontend ディレクトリにストア用のディレクトリを作成
mkdir -p stores
touch stores/auth.ts
```

`stores/auth.ts` に認証ロジック（ログイン、ログアウト、ユーザー情報保持など）を実装します。

```typescript
// frontend/stores/auth.ts の実装例
// (ログイン状態、ユーザートークン、ユーザー情報などを管理)
```

#### 1.3.4 API 通信 (Axios) の設定

バックエンド API と通信するために Axios をインストールし、設定します。

```bash
# frontend ディレクトリで実行
npm add axios
```

Axios のインスタンス設定やリクエスト/レスポンスインターセプター（JWT トークン付与など）を定義するプラグインを作成します。

```bash
# frontend ディレクトリにプラグイン用のディレクトリを作成
mkdir -p plugins
touch plugins/axios.ts
```

`plugins/axios.ts` に Axios の設定を記述します。

```typescript
// frontend/plugins/axios.ts の実装例
// (baseURL, interceptors の設定)
```

#### 1.3.5 基本レイアウトとページの作成

アプリケーションの基本的な構造となるレイアウトファイルと、初期ページ（ホーム、ログインなど）を作成します。

```bash
# frontend ディレクトリにレイアウトとページ用のディレクトリを作成
mkdir -p layouts pages
touch layouts/default.vue pages/index.vue pages/login.vue
```

`layouts/default.vue` に共通ヘッダー、フッター、コンテンツ表示エリアなどを定義します。
`pages/index.vue` にホームページの内容を記述します。
`pages/login.vue` にログインフォームを実装します。

```vue
<!-- frontend/layouts/default.vue の例 -->
<template>
  <v-app>
    <v-app-bar app>
      <v-toolbar-title>Book Management</v-toolbar-title>
      <v-spacer></v-spacer>
      <!-- ナビゲーションリンクなど -->
    </v-app-bar>
    <v-main>
      <v-container fluid>
        <NuxtPage />
      </v-container>
    </v-main>
    <v-footer app>
      <span>&copy; {{ new Date().getFullYear() }}</span>
    </v-footer>
  </v-app>
</template>

<!-- frontend/pages/index.vue の例 -->
<template>
  <div>
    <h1>Welcome to Book Management</h1>
    <!-- コンテンツ -->
  </div>
</template>

<!-- frontend/pages/login.vue の例 -->
<template>
  <v-container>
    <v-row justify="center">
      <v-col cols="12" sm="8" md="4">
        <v-card>
          <v-card-title class="text-center">Login</v-card-title>
          <v-card-text>
            <!-- ログインフォーム -->
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
```

### 1.4 Docker 環境の統合

#### 1.4.1 Docker Compose ファイルの作成

プロジェクトルートに `docker-compose.yml` を作成し、バックエンド (Laravel/Sail)、フロントエンド (Nuxt)、データベース (PostgreSQL)、およびオプションで pgAdmin のサービスを定義します。

```yaml
# docker-compose.yml
version: "3.8"

services:
  # Laravel バックエンド (Sail を利用)
  laravel.test:
    # ... (Sail の設定をベースに記述)

  # Nuxt.js フロントエンド
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    image: book-management-frontend
    ports:
      - "${FRONTEND_PORT:-3000}:3000"
    volumes:
      - "./frontend:/app"
      - "/app/node_modules"
    environment:
      HOST: "0.0.0.0"
      # ブラウザからアクセスするバックエンドAPI URL
      BROWSER_API_BASE_URL: "http://localhost:8000/api"
      # Dockerコンテナ内部での通信用バックエンドAPI URL
      SERVER_API_BASE_URL: "http://laravel.test:${APP_PORT:-8000}/api"
    networks:
      - sail
    depends_on:
      - laravel.test

  # PostgreSQL データベース
  pgsql:
    # ... (Sail の設定をベースに記述)

  # pgAdmin (オプション)
  pgadmin:
    # ... (pgAdmin の設定)

networks:
  sail:
    driver: bridge

volumes:
  sail-pgsql:
    driver: local
  sail-pgadmin:
    driver: local
```

#### 1.4.2 フロントエンド用 Dockerfile の作成

`frontend` ディレクトリに `Dockerfile` を作成し、Nuxt アプリケーションをビルドして実行する手順を定義します。

```dockerfile
# frontend/Dockerfile
FROM node:22-alpine AS base
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "start"]
```

#### 1.4.3 ルート .env ファイルの作成

Docker Compose で使用する環境変数を定義するため、プロジェクトルートに `.env` ファイルを作成します。
**注意:** この `.env` はバックエンド (`backend/.env`) とは別物です。

```env
# .env (プロジェクトルート)
APP_PORT=8000
VITE_PORT=5173
WWWUSER=1000
WWWGROUP=1000
FRONTEND_PORT=3000
DB_PORT=5432
FORWARD_DB_PORT=5432
DB_DATABASE=book_management
DB_USERNAME=sail
DB_PASSWORD=password
```

#### 1.4.4 開発サーバー起動

以下のコマンドで、定義したすべてのサービスを Docker コンテナとして起動します。

```bash
# プロジェクトルートで実行
docker-compose up -d --build
```

これで、バックエンド (例: http://localhost:8000)、フロントエンド (例: http://localhost:3000)、pgAdmin (例: http://localhost:5050) にアクセスできるようになります。

### フェーズ 2: 品質管理ツールの導入

#### 2.1 バックエンド品質管理

#### 2.1.1 PHP_CodeSniffer の設定

```bash
# backend ディレクトリで実行
composer require --dev squizlabs/php_codesniffer
```

`phpcs.xml` ファイルを作成します：

```xml
<?xml version="1.0"?>
<ruleset name="Laravel Standards">
    <description>Laravel Coding Standards</description>

    <file>app</file>
    <file>config</file>
    <file>database</file>
    <file>routes</file>
    <file>tests</file>

    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/storage/*</exclude-pattern>
    <exclude-pattern>*/bootstrap/cache/*</exclude-pattern>

    <arg name="colors"/>
    <arg value="p"/>

    <rule ref="PSR12"/>
</ruleset>
```

#### 2.1.2 PHPStan/Larastan の設定

```bash
# backend ディレクトリで実行
composer require --dev nunomaduro/larastan
```

`phpstan.neon` ファイルを作成します：

```yaml
includes:
  - ./vendor/nunomaduro/larastan/extension.neon

parameters:
  paths:
    - app
  level: 5
  checkMissingIterableValueType: false
```

#### 2.1.3 PHPUnit テスト環境の構築

Laravel には PHPUnit が最初から含まれています。テスト用の環境変数を設定します：

`.env.testing` ファイルを作成します：

```
APP_ENV=testing
DB_CONNECTION=pgsql
DB_HOST=pgsql
DB_PORT=5432
DB_DATABASE=book_management_testing
DB_USERNAME=sail
DB_PASSWORD=password
```

#### 2.2 フロントエンド品質管理

#### 2.2.1 ESLint + Prettier の設定

初期化時に ESLint を選択している場合は、Prettier を追加で設定します：

```bash
# frontend ディレクトリで実行
npm install --save-dev prettier eslint-plugin-prettier eslint-config-prettier
```

`.eslintrc.js` ファイルを編集します：

```javascript
module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
  },
  extends: ["@nuxtjs/eslint-config-typescript", "plugin:prettier/recommended"],
  rules: {
    "vue/multi-word-component-names": "off",
    "prettier/prettier": [
      "error",
      {
        singleQuote: true,
        semi: false,
        printWidth: 100,
      },
    ],
  },
};
```

`.prettierrc` ファイルを作成します：

```json
{
  "semi": false,
  "singleQuote": true,
  "printWidth": 100,
  "trailingComma": "es5"
}
```

#### 2.2.2 Vitest テスト環境の構築

```bash
# frontend ディレクトリで実行
npm install --save-dev vitest @vue/test-utils happy-dom
```

`vitest.config.ts` ファイルを作成します：

```typescript
import { defineConfig } from "vitest/config";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: "happy-dom",
    globals: true,
  },
});
```

#### 2.3 Git ワークフローの設定

#### 2.3.1 Husky によるコミット前チェックの設定

プロジェクトルートに戻ります：

```bash
# プロジェクトルートで実行
npm init -y
npm install --save-dev husky lint-staged
npx husky install
npm pkg set scripts.prepare="husky install"
```

コミット前のチェックを設定します：

```bash
# プロジェクトルートで実行
npx husky add .husky/pre-commit "npx lint-staged"
```

`lint-staged.config.js` ファイルを作成します：

```javascript
module.exports = {
  "backend/**/*.php": ["cd backend && ./vendor/bin/phpcs"],
  "frontend/**/*.{js,ts,vue}": ["cd frontend && npm run lint"],
};
```

#### 2.3.2 コミットメッセージのテンプレート作成

`.github/commit-template.txt` ファイルを作成します：

```
# タイプ(必須): 簡潔な説明(必須)
# |<----  タイプは次のいずれかを使用: feat, fix, docs, style, refactor, test, chore  ---->|

# 本文(オプション): 変更の詳細な説明
# |<----   --------   ------   --------   --------   --------   --------   ------>|

# フッター(オプション): 関連する問題やPR
# |<----   --------   ------   --------   --------   --------   --------   ------>|
```

Git の設定を更新します：

```bash
# プロジェクトルートで実行
git config --local commit.template .github/commit-template.txt
```

#### 2.3.3 ブランチ戦略の定義

`docs/git-workflow.md` ファイルを作成します：

```markdown
# Git ワークフロー

本プロジェクトでは以下のブランチ戦略を採用します：

## メインブランチ

- `main`: 本番環境用のブランチ。常に安定した状態を維持する。
- `develop`: 開発環境用のブランチ。機能開発が完了したものをマージする。

## 作業ブランチ

- `feature/*`: 新機能開発用のブランチ。`develop`から分岐し、`develop`にマージする。
- `fix/*`: バグ修正用のブランチ。`develop`から分岐し、`develop`にマージする。
- `release/*`: リリース準備用のブランチ。`develop`から分岐し、`main`と`develop`にマージする。
- `hotfix/*`: 緊急バグ修正用のブランチ。`main`から分岐し、`main`と`develop`にマージする。

## ブランチの命名規則

- `feature/issue-{番号}-{機能名}`
- `fix/issue-{番号}-{修正内容}`
- `release/v{バージョン}`
- `hotfix/v{バージョン}-{修正内容}`

## コミットメッセージの規則

コミットメッセージは以下の形式に従ってください：
```

{タイプ}: {簡潔な説明}

{詳細な説明（オプション）}

{関連する問題や PR（オプション）}

```

タイプは以下のいずれかを使用してください：
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響を与えない変更（空白、フォーマット、セミコロンの欠落など）
- `refactor`: バグ修正でも機能追加でもないコード変更
- `test`: テストの追加または修正
- `chore`: ビルドプロセスやツールの変更
```

### 3.1 GitHub Actions ワークフローの設定

`.github/workflows/ci.yml` ファイルを作成します：

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  backend-tests:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: book_management_testing
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: "8.3"
          extensions: mbstring, pgsql, pdo_pgsql

      - name: Install Composer dependencies
        working-directory: ./backend
        run: composer install --prefer-dist --no-progress

      - name: Copy .env
        working-directory: ./backend
        run: cp .env.example .env.testing

      - name: Generate key
        working-directory: ./backend
        run: php artisan key:generate --env=testing

      - name: Run migrations
        working-directory: ./backend
        run: php artisan migrate --env=testing
        env:
          DB_CONNECTION: pgsql
          DB_HOST: localhost
          DB_PORT: 5432
          DB_DATABASE: book_management_testing
          DB_USERNAME: postgres
          DB_PASSWORD: postgres

      - name: Run PHPStan
        working-directory: ./backend
        run: ./vendor/bin/phpstan analyse

      - name: Run PHP_CodeSniffer
        working-directory: ./backend
        run: ./vendor/bin/phpcs

      - name: Run tests
        working-directory: ./backend
        run: php artisan test --env=testing
        env:
          DB_CONNECTION: pgsql
          DB_HOST: localhost
          DB_PORT: 5432
          DB_DATABASE: book_management_testing
          DB_USERNAME: postgres
          DB_PASSWORD: postgres

  frontend-tests:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: ./frontend/package-lock.json

      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci

      - name: Run ESLint
        working-directory: ./frontend
        run: npm run lint

      - name: Run tests
        working-directory: ./frontend
        run: npm run test
```
