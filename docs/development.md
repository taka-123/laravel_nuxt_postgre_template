# 開発ガイド

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

## 推奨エディタとプラグイン

Visual Studio Code を推奨エディタとして使用します。

### 必須拡張機能

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
- CodeRabbit（AI コードレビュー）

## バックエンド開発

### よく使うコマンド

```bash
cd backend

# 開発
php artisan serve                 # 開発サーバー起動
php artisan migrate              # マイグレーション実行
php artisan db:seed              # シーディング実行
php artisan make:controller      # コントローラー作成
php artisan make:job             # ジョブ作成

# テスト・品質チェック
php artisan test                 # テスト実行
./vendor/bin/phpunit            # PHPUnitテスト
./vendor/bin/pint               # Laravel Pintフォーマッター
composer analyze                # PHPStan解析
```

### コード品質基準

- Laravel Pint によるコーディング標準
- PHPStan 静的解析（レベル 3）
- PHPUnit によるテスト
- PHPCS による追加のコードスタイルチェック

## フロントエンド開発

### よく使うコマンド

```bash
cd frontend

# 開発
npm run dev                      # 開発サーバー起動
npm run build                    # プロダクションビルド
npm run generate                 # 静的サイト生成

# テスト・品質チェック
npm run test                     # Vitestテスト実行
npm run test:coverage            # カバレッジ付きテスト
npm run lint                     # ESLintチェック
npm run lint:fix                 # ESLint自動修正
```

### コード品質基準

- TypeScript と Vue 3 ルールを含む ESLint
- Prettier によるコードフォーマット
- Vitest によるユニットテスト
- 開発効率のため TypeScript strict モードは無効

## データベース設定

### 開発用データベース

- **Docker**: PostgreSQL 17 コンテナ（ポート 5432）
- **ローカル**: SQLite データベース
- **管理ツール**: pgAdmin (http://localhost:5050)

### 接続情報（Docker）

- ホスト: localhost、ポート: 5432
- データベース: laravel_nuxt_template
- ユーザー名: sail、パスワード: password

### ポート設定

| サービス                 | ポート | URL                   |
| ------------------------ | ------ | --------------------- |
| バックエンド (Laravel)   | 8000   | http://localhost:8000 |
| フロントエンド (Nuxt.js) | 3000   | http://localhost:3000 |
| PostgreSQL               | 5432   | -                     |
| pgAdmin                  | 5050   | http://localhost:5050 |

## API 設計

### 認証エンドポイント

- `POST /api/auth/register` - ユーザー登録
- `POST /api/auth/login` - ログイン
- `POST /api/auth/logout` - ログアウト
- `GET /api/auth/me` - 現在のユーザー取得

### JWT トークンフロー

- フロントエンドの状態管理（Pinia）にトークン保存
- Authorization ヘッダーで API リクエストを認証
- コンポーザブルパターンで認証機能を提供（`useAuth.ts`, `useApi.ts`）

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

## エラーハンドリング

- try/catch ブロックを使用し、適切なエラーログを記録
- API エラーは統一されたフォーマットで返却
- フロントエンドでは axios インターセプターでグローバルエラー処理

## mise を使用した開発環境管理（オプション）

[mise](https://mise.jdx.dev/) を使用することで、Node.js と PHP のバージョンを簡単に管理できます：

```bash
# mise がインストールされている場合
mise install  # .mise.toml に記載されたツールを自動インストール

# volta、asdf、nodenv、phpenv など他のバージョン管理ツールとも共存可能
# mise を使わない場合は、上記の前提条件に従って手動でインストール
```