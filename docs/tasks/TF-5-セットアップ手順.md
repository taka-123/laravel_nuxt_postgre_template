# TF-5: Googleログイン実装 - セットアップ手順

## 実装完了内容

以下の実装が完了しました：

### バックエンド (Laravel)

- ✅ データベースマイグレーション作成（`google_id`, `avatar`カラム追加）
- ✅ Userモデル更新（`fillable`に`google_id`, `avatar`追加）
- ✅ GoogleAuthController作成（OAuth認証処理）
- ✅ APIルート追加（`/api/auth/google/callback`）

### フロントエンド (Nuxt.js)

- ✅ `@sidebase/nuxt-auth`パッケージインストール
- ✅ Nuxt Auth設定（`nuxt.config.ts`）
- ✅ Auth.jsサーバーAPI設定（`server/api/auth/[...].ts`）
- ✅ Google認証コンポーザブル作成（`useGoogleAuth.ts`）
- ✅ ログインページにGoogleログインボタン追加
- ✅ 環境変数テンプレート更新（`.env.example`）

## セットアップ手順

### 1. Google Cloud Consoleでの設定

#### 1.1 プロジェクト作成

1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. 新しいプロジェクトを作成（または既存プロジェクトを選択）

#### 1.2 OAuth同意画面の設定

1. 左メニューから「APIとサービス」→「OAuth同意画面」を選択
2. User Type: 「外部」を選択（テスト用）
3. アプリ情報を入力：
   - アプリ名: `Laravel Nuxt Template`（任意）
   - ユーザーサポートメール: あなたのメールアドレス
   - デベロッパーの連絡先情報: あなたのメールアドレス
4. スコープ: デフォルトのまま（`.../auth/userinfo.email`, `.../auth/userinfo.profile`）
5. テストユーザー: 開発中にログインするGoogleアカウントを追加

#### 1.3 OAuth認証情報の作成

1. 左メニューから「APIとサービス」→「認証情報」を選択
2. 「認証情報を作成」→「OAuthクライアントID」をクリック
3. アプリケーションの種類: 「ウェブアプリケーション」
4. 名前: `Nuxt Frontend`（任意）
5. 承認済みのJavaScript生成元:
   ```
   http://localhost:3000
   ```
6. 承認済みのリダイレクトURI:
   ```
   http://localhost:3000/api/auth/callback/google
   ```
7. 「作成」をクリック
8. **クライアントIDとクライアントシークレットをコピー**（次のステップで使用）

### 2. 環境変数の設定

#### 2.1 フロントエンド環境変数

`frontend/.env`ファイルを作成（または既存ファイルを編集）：

```bash
cd frontend
cp .env.example .env
```

以下の環境変数を設定：

```env
# Nuxt Auth設定
NUXT_AUTH_SECRET=生成されたランダム文字列
NUXT_AUTH_ORIGIN=http://localhost:3000

# Google OAuth設定
GOOGLE_CLIENT_ID=あなたのGoogleクライアントID
GOOGLE_CLIENT_SECRET=あなたのGoogleクライアントシークレット
```

**NUXT_AUTH_SECRETの生成方法:**

```bash
# macOS/Linux
openssl rand -base64 32

# または Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

#### 2.2 バックエンド環境変数

バックエンドは既存の設定をそのまま使用します。特別な追加設定は不要です。

### 3. データベースマイグレーション実行

#### Docker環境の場合

```bash
# Dockerコンテナに入る
docker exec -it laravel-container bash

# マイグレーション実行
php artisan migrate
```

#### ローカル環境の場合

```bash
cd backend
php artisan migrate
```

マイグレーション実行後、`users`テーブルに以下のカラムが追加されます：
- `google_id` (VARCHAR, UNIQUE, NULL許可)
- `avatar` (VARCHAR, NULL許可)
- `password` (NULL許可に変更)

### 4. アプリケーション起動

#### Docker環境

```bash
# プロジェクトルートから
docker compose up -d
```

#### ローカル環境

```bash
# バックエンド（ターミナル1）
cd backend
php artisan serve
# → http://localhost:8000

# フロントエンド（ターミナル2）
cd frontend
npm run dev
# → http://localhost:3000
```

### 5. 動作確認

1. ブラウザで `http://localhost:3000/login` にアクセス
2. 「Googleでログイン」ボタンをクリック
3. Google認証画面が表示される
4. Googleアカウントでログイン
5. 認証成功後、ダッシュボード（`/`）にリダイレクト
6. ユーザー情報が表示される

### 6. データベース確認

#### PostgreSQL（Docker環境）

```bash
docker exec -it postgres psql -U sail -d laravel_nuxt_template

# ユーザー一覧確認
SELECT id, name, email, google_id, avatar FROM users;
```

#### SQLite（ローカル環境）

```bash
sqlite3 backend/database/database.sqlite

SELECT id, name, email, google_id, avatar FROM users;
```

## トラブルシューティング

### エラー: "redirect_uri_mismatch"

**原因**: Google Cloud ConsoleのリダイレクトURIが正しく設定されていない

**解決策**:
1. Google Cloud Consoleで「認証情報」を確認
2. 承認済みのリダイレクトURIに以下を追加：
   - `http://localhost:3000/api/auth/callback/google`
   - `http://localhost:3000/api/auth/callback/google/`（末尾スラッシュあり）

### エラー: "NUXT_AUTH_SECRET is not set"

**原因**: 環境変数が設定されていない

**解決策**:
```bash
# frontend/.envファイルを確認
cat frontend/.env | grep NUXT_AUTH_SECRET

# 設定されていない場合は追加
echo "NUXT_AUTH_SECRET=$(openssl rand -base64 32)" >> frontend/.env
```

### エラー: "Backend authentication failed"

**原因**: LaravelバックエンドとNuxtフロントエンドの通信エラー

**解決策**:
1. Laravelが起動しているか確認:
   ```bash
   curl http://localhost:8000/api/auth/me
   ```
2. CORS設定を確認（`backend/config/cors.php`）
3. ネットワークタブでAPIリクエストを確認

### エラー: "Access to XMLHttpRequest has been blocked by CORS policy"

**原因**: CORS設定が正しくない

**解決策**:
`backend/config/cors.php`を確認：

```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_origins' => [
    env('FRONTEND_URL', 'http://localhost:3000'),
],
'supports_credentials' => true,
```

`backend/.env`に以下を追加：

```env
FRONTEND_URL=http://localhost:3000
```

### ユーザーが重複作成される

**原因**: メールアドレスでのアカウント統合が動作していない

**解決策**:
1. `GoogleAuthController`のロジックを確認
2. データベースの`email`カラムにユニーク制約があるか確認

### Googleログインボタンが表示されない

**原因**: パッケージがインストールされていない

**解決策**:
```bash
cd frontend
npm install
npm run dev
```

## 本番環境へのデプロイ

### 環境変数の設定

本番環境では以下の環境変数を設定してください：

```env
# Nuxt Auth
NUXT_AUTH_SECRET=強力なランダム文字列
NUXT_AUTH_ORIGIN=https://yourdomain.com

# Google OAuth
GOOGLE_CLIENT_ID=本番用クライアントID
GOOGLE_CLIENT_SECRET=本番用クライアントシークレット
```

### Google Cloud Consoleの設定

1. 本番用のOAuthクライアントIDを作成
2. 承認済みのリダイレクトURIに本番URLを追加：
   ```
   https://yourdomain.com/api/auth/callback/google
   ```

### セキュリティ設定

- `NUXT_AUTH_SECRET`は強力なランダム文字列を使用
- HTTPS必須（本番環境）
- CORS設定を本番ドメインに制限
- 環境変数は安全に管理（Fly.io Secrets等）

## 次のステップ

- [ ] 他のOAuthプロバイダー追加（GitHub, Facebook等）
- [ ] 2要素認証（2FA）の実装
- [ ] パスワードリセット機能
- [ ] メール認証機能
- [ ] ユーザープロフィール編集機能
- [ ] アカウント削除機能

## 参考資料

- [@sidebase/nuxt-auth公式ドキュメント](https://sidebase.io/nuxt-auth/getting-started)
- [NextAuth.js公式ドキュメント](https://next-auth.js.org/)
- [Google OAuth 2.0ドキュメント](https://developers.google.com/identity/protocols/oauth2)
- [Laravel JWT認証](https://github.com/PHP-Open-Source-Saver/jwt-auth)
