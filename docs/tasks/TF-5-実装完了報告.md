# TF-5: Googleログイン実装 - 完了報告

## 実装完了日時

2025-11-09

## 実装概要

Nuxt.js 3プロジェクトにGoogle OAuth 2.0ログイン機能を実装しました。
NextAuth.jsはNext.js専用のため、Nuxt 3向けの`@sidebase/nuxt-auth`（Nuxt版NextAuth）を使用しています。

## 実装内容

### 1. バックエンド実装 (Laravel)

#### 1.1 データベースマイグレーション

**ファイル**: `backend/database/migrations/2025_11_09_132404_add_google_auth_to_users_table.php`

- `users`テーブルに以下のカラムを追加：
  - `google_id` (VARCHAR, UNIQUE, NULL許可): Google OAuth固有のユーザーID
  - `avatar` (VARCHAR, NULL許可): プロフィール画像URL
- `password`カラムをNULL許可に変更（OAuth専用ユーザー対応）

#### 1.2 Userモデル更新

**ファイル**: `backend/app/Models/User.php`

- `$fillable`配列に`google_id`と`avatar`を追加
- OAuth専用ユーザーに対応

#### 1.3 Google認証コントローラー作成

**ファイル**: `backend/app/Http/Controllers/API/GoogleAuthController.php`

主な機能：
- Google OAuth認証後のユーザー登録/ログイン処理
- Google IDによる既存ユーザー検索
- メールアドレスによるアカウント統合
- JWTトークン生成と返却

処理フロー：
1. Google IDで既存ユーザーを検索
2. 見つからない場合、メールアドレスで検索（アカウント統合）
3. 既存ユーザーがいればGoogle IDを紐付け
4. 新規ユーザーの場合は作成
5. JWTトークンを生成して返却

#### 1.4 APIルート追加

**ファイル**: `backend/routes/api.php`

- `POST /api/auth/google/callback`: Google認証コールバック処理

### 2. フロントエンド実装 (Nuxt.js)

#### 2.1 パッケージインストール

```bash
npm install @sidebase/nuxt-auth@^0.9.0 next-auth@4.21.1
```

#### 2.2 Nuxt設定更新

**ファイル**: `frontend/nuxt.config.ts`

- `@sidebase/nuxt-auth`モジュールを追加
- Auth設定を追加（baseURL, provider, globalAppMiddleware）
- runtimeConfigに認証関連の環境変数を追加：
  - `authSecret`: Auth.jsのシークレットキー
  - `googleClientId`: GoogleクライアントID
  - `googleClientSecret`: Googleクライアントシークレット

#### 2.3 Auth.jsサーバーAPI設定

**ファイル**: `frontend/server/api/auth/[...].ts`

主な機能：
- Google OAuth Providerの設定
- JWT callbackでLaravelバックエンドと連携
- Session callbackでユーザー情報とトークンをセッションに含める
- カスタムページ設定（signIn, error）

認証フロー：
1. Google認証成功後、プロフィール情報を取得
2. LaravelバックエンドのAPIにGoogle認証情報を送信
3. LaravelからJWTトークンとユーザー情報を受け取る
4. トークンをセッションに保存

#### 2.4 認証コンポーザブル作成

**ファイル**: `frontend/composables/useGoogleAuth.ts`

提供機能：
- `loginWithGoogle()`: Googleログイン処理
- `logout()`: ログアウト処理

**ファイル**: `frontend/composables/useEmailAuth.ts`（既存のuseAuthをリネーム）

- `@sidebase/nuxt-auth`の`useAuth`との名前衝突を回避
- 既存のメール/パスワード認証機能を維持

#### 2.5 ログインページ更新

**ファイル**: `frontend/pages/login.vue`

追加機能：
- Googleログインボタン
- ローディング状態の管理
- エラーハンドリング
- 既存のメール/パスワードログインとの共存

UI改善：
- 区切り線で認証方法を視覚的に分離
- Googleアイコン付きボタン
- ローディング中は両方のボタンを無効化

#### 2.6 環境変数テンプレート更新

**ファイル**: `frontend/.env.example`

追加された環境変数：
```env
# Nuxt Auth設定
NUXT_AUTH_SECRET=your-random-secret-string-here
NUXT_AUTH_ORIGIN=http://localhost:3000

# Google OAuth設定
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

### 3. ドキュメント作成

#### 3.1 仕様要件と処理手順設計

**ファイル**: `docs/tasks/TF-5-Googleログイン実装.md`

内容：
- 技術スタック
- 実装要件（機能要件・非機能要件）
- アーキテクチャ設計（認証フロー図、データモデル）
- 詳細な実装手順（Phase 1-4）
- セキュリティ考慮事項
- トラブルシューティング
- 今後の拡張案
- 参考資料

#### 3.2 セットアップ手順

**ファイル**: `docs/tasks/TF-5-セットアップ手順.md`

内容：
- Google Cloud Consoleでの設定手順
- 環境変数の設定方法
- データベースマイグレーション実行
- アプリケーション起動方法
- 動作確認項目
- トラブルシューティング
- 本番環境へのデプロイ手順

#### 3.3 実装完了報告（本ドキュメント）

**ファイル**: `docs/tasks/TF-5-実装完了報告.md`

## 技術的な特徴

### 1. アカウント統合機能

同じメールアドレスを持つユーザーが存在する場合、自動的にGoogle IDを紐付けます。
これにより、既存のメール/パスワードユーザーがGoogleログインに移行できます。

### 2. OAuth専用ユーザー対応

`password`カラムをNULL許可にすることで、Googleログインのみで登録したユーザーに対応しています。

### 3. 既存認証との共存

既存のJWT認証（メール/パスワード）とGoogle OAuth認証が共存できる設計です。

### 4. セキュアなトークン管理

- Auth.jsによるHTTPOnly Cookie（CSRF保護付き）
- LaravelのJWTトークンとの統合
- セッション管理の永続化

## コード品質

### リンターチェック

```bash
cd frontend
npm run lint
```

結果: ✅ エラーなし

### 主な対応

- ESLintエラー修正（console.log削除、async/await適切化）
- TypeScript型定義の整合性確認
- Nuxt Authとの名前衝突解決（useAuth → useEmailAuth）

## 動作確認項目

以下の項目を確認してください：

- [ ] Googleログインボタンが表示される
- [ ] クリックでGoogle認証画面に遷移
- [ ] Google認証後、ダッシュボードにリダイレクト
- [ ] 初回ログイン時、ユーザーがDBに登録される
- [ ] 2回目以降のログイン時、既存ユーザーとして認証される
- [ ] メールアドレスが同じ場合、アカウントが統合される
- [ ] ログアウトが正常に動作する
- [ ] セッションが永続化される（ページリロード後も認証状態維持）
- [ ] 既存のメール/パスワードログインも正常に動作する

## セキュリティ対策

### 実装済み

- ✅ 環境変数による機密情報管理
- ✅ CORS設定
- ✅ CSRF保護（Auth.js標準機能）
- ✅ HTTPOnly Cookie
- ✅ JWTトークン検証
- ✅ SQL Injection対策（Eloquent ORM使用）

### 推奨事項

- [ ] 本番環境ではHTTPS必須
- [ ] `NUXT_AUTH_SECRET`は強力なランダム文字列を使用
- [ ] Google Cloud ConsoleでOAuth同意画面を本番用に設定
- [ ] レート制限の実装（将来的に）
- [ ] 2要素認証の実装（将来的に）

## 既知の制限事項

### 1. パスワードリセット機能

OAuth専用ユーザー（`password`がNULL）はパスワードリセットができません。
将来的にパスワード設定機能の追加を検討してください。

### 2. プロフィール画像の更新

Google認証時にプロフィール画像を取得しますが、ユーザーが手動で変更する機能はありません。

### 3. アカウント削除

アカウント削除機能は未実装です。

## 今後の拡張案

### 優先度: 高

- [ ] パスワードリセット機能
- [ ] メール認証機能
- [ ] ユーザープロフィール編集機能

### 優先度: 中

- [ ] 他のOAuthプロバイダー追加（GitHub, Facebook等）
- [ ] アカウント削除機能
- [ ] 2要素認証（2FA）

### 優先度: 低

- [ ] ソーシャルログイン連携解除機能
- [ ] ログイン履歴表示
- [ ] セキュリティ通知

## テスト計画

### 単体テスト（未実装）

- [ ] GoogleAuthControllerのテスト
- [ ] Userモデルのテスト
- [ ] useGoogleAuthコンポーザブルのテスト

### 統合テスト（未実装）

- [ ] Google OAuth認証フロー全体のテスト
- [ ] アカウント統合のテスト
- [ ] エラーハンドリングのテスト

### E2Eテスト（未実装）

- [ ] ログインフローのE2Eテスト
- [ ] ログアウトフローのE2Eテスト

## 参考資料

### 公式ドキュメント

- [@sidebase/nuxt-auth](https://sidebase.io/nuxt-auth/getting-started)
- [NextAuth.js](https://next-auth.js.org/)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
- [Laravel JWT Auth](https://github.com/PHP-Open-Source-Saver/jwt-auth)

### 実装ファイル一覧

#### バックエンド

- `backend/database/migrations/2025_11_09_132404_add_google_auth_to_users_table.php`
- `backend/app/Models/User.php`
- `backend/app/Http/Controllers/API/GoogleAuthController.php`
- `backend/routes/api.php`

#### フロントエンド

- `frontend/nuxt.config.ts`
- `frontend/server/api/auth/[...].ts`
- `frontend/composables/useGoogleAuth.ts`
- `frontend/composables/useEmailAuth.ts`（リネーム）
- `frontend/pages/login.vue`
- `frontend/.env.example`

#### ドキュメント

- `docs/tasks/TF-5-Googleログイン実装.md`
- `docs/tasks/TF-5-セットアップ手順.md`
- `docs/tasks/TF-5-実装完了報告.md`

## まとめ

Googleログイン機能の実装が完了しました。

### 主な成果

1. ✅ Google OAuth 2.0による認証機能
2. ✅ 既存のメール/パスワード認証との共存
3. ✅ アカウント統合機能
4. ✅ セキュアなトークン管理
5. ✅ 包括的なドキュメント作成

### 次のステップ

1. Google Cloud Consoleでの設定（クライアントID/シークレット取得）
2. 環境変数の設定
3. データベースマイグレーション実行
4. 動作確認

詳細は`docs/tasks/TF-5-セットアップ手順.md`を参照してください。
