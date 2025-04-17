# 書籍管理システム

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 16.x を使用した書籍管理システムです。

## 開発環境のセットアップ

### 前提条件

- Docker Desktop がインストールされていること
- Node.js 18.0 以上がインストールされていること
- Git がインストールされていること
- Composer がインストールされていること（オプション、Docker 内で実行も可）

### ポート設定

| サービス               | ポート |
| ---------------------- | ------ |
| Laravel バックエンド   | 8000   |
| Nuxt.js フロントエンド | 3000   |
| PostgreSQL             | 5432   |
| pgAdmin                | 5050   |

## Docker 環境の起動方法

本プロジェクトでは 2 つの Docker Compose 設定があります：

1. **プロジェクトルートの`docker-compose.yml`**：

   - フロントエンド、バックエンド、データベースを一括で起動
   - 開発環境全体の構築に使用

2. **`backend/docker-compose.yml`**：
   - バックエンドのみ（Laravel + PostgreSQL）を起動
   - バックエンド単体の開発に使用

### 重要: 同時に両方の環境を起動しないでください

これらの設定には同じポートを使用するサービスが含まれるため、**どちらか一方のみを起動**してください。
両方を同時に起動するとポート競合が発生します。

### 正しい起動方法

```bash
# 全体環境を起動する場合
docker compose up -d

# または、バックエンドのみを起動する場合
cd backend
docker compose up -d
```

### 正しい停止方法

```bash
# 起動したのと同じディレクトリで停止する
docker compose down
```

既存の環境をすべて停止するには：

```bash
# 既存のコンテナをすべて確認
docker ps -a

# 特定のコンテナを停止・削除
docker stop [コンテナID] && docker rm [コンテナID]
```

## 開発サーバーの起動

### Docker を使用した起動（推奨）

1. Docker Desktop を起動します
2. 以下のコマンドを実行します：

```bash
docker compose up -d --build
```

### 個別の起動方法

#### バックエンド（Laravel）の起動

```bash
cd backend
php artisan serve
```

#### フロントエンド（Nuxt.js）の起動

```bash
cd frontend
npm run dev
```

## コード品質管理とテスト

### Linter と Formatter

本プロジェクトでは以下の Linter と Formatter を使用しています：

#### バックエンド

- **PHP_CodeSniffer (PSR-12)** - コーディング規約チェック
- **PHPStan/Larastan** - 静的解析

コマンドラインで実行：

```bash
cd backend
composer lint    # PHPCSによるコード規約チェック
composer analyze # PHPStanによる静的解析
```

#### フロントエンド

- **ESLint** - コード品質チェック
- **Prettier** - コードフォーマッター

コマンドラインで実行：

```bash
cd frontend
npm run lint     # リントチェック
npm run lint:fix # リントとフォーマット修正
```

**自動フォーマット**: VSCode (または互換エディタ) を使用している場合、ファイル保存時に自動フォーマットが適用されます。

### テスト実行

#### バックエンド

```bash
cd backend
php artisan test  # すべてのテストを実行
```

#### フロントエンド

```bash
cd frontend
npm run test  # すべてのテストを実行
```

## Git ワークフロー

本プロジェクトでは以下のようなシンプルなGitワークフローを採用しています：

### ブランチ戦略

- **`main`**: 本番環境用のブランチ。常に安定した状態を維持する。
- **`develop`**: （オプション）開発環境用のブランチ。ECS検証環境がある場合に使用。

### 開発プロセス

1. **機能開発・バグ修正**:
   - 新機能開発は `feature/機能名` ブランチ（例：`feature/barcode-generator`）
   - バグ修正は `fix/修正内容` ブランチ（例：`fix/login-error`）
   - 基本的に`main`から分岐し、プルリクエスト後に`main`へマージ

2. **コミットメッセージ規約**:
   ```
   タイプ: 簡潔な説明
   
   詳細な説明（オプション）
   
   関連する問題やPR（オプション）
   ```

   **タイプ例:** 
   - `feat`: 新機能
   - `fix`: バグ修正
   - `docs`: ドキュメント変更
   - `style`: フォーマットの変更
   - `refactor`: リファクタリング
   - `test`: テスト関連の変更
   - `chore`: その他の変更

## テストユーザー

- メールアドレス: test@example.com
- パスワード: password

## CI/CD 環境

プロジェクトには以下の CI/CD 設定が含まれています：

- **CI** (`.github/workflows/ci.yml`): コードプッシュ時に自動的に Lint とテストを実行
- **プロダクションデプロイ** (`.github/workflows/deploy-ecs-production.yml`): `main`ブランチへのプッシュ時に AWS ECS へ自動デプロイ

### テスト自動化

- プルリクエスト時: 自動的に CI ワークフローが実行され、コード品質とテストをチェック
- プロダクションデプロイ前: テストが自動的に実行され、成功した場合のみデプロイが行われる

## 開発者向けドキュメント

開発を始める前に、以下のドキュメントを確認してください：

- [開発環境ガイド](./DEVELOPMENT.md) - コーディング規約、品質管理ツール、Git ワークフロー

## 本番環境へのデプロイ

本番環境へのデプロイは、AWS の ECS を使用して自動化されています。

### ECS デプロイの前提条件

1. AWS ECS クラスター、サービス、およびタスク定義が作成されていること
2. Amazon ECR リポジトリが作成されていること
3. 必要な IAM ロールとポリシーが設定されていること
4. GitHub Actions 用のシークレットが設定されていること

### GitHub Secrets の設定

以下のシークレット値を GitHub リポジトリの設定で追加してください：

- `AWS_ACCESS_KEY_ID` - AWS アクセスキー ID
- `AWS_SECRET_ACCESS_KEY` - AWS シークレットアクセスキー
- `AWS_REGION` - AWS リージョン
- `ECR_REPOSITORY_BACKEND` - バックエンド用 ECR リポジトリ名
- `ECR_REPOSITORY_FRONTEND` - フロントエンド用 ECR リポジトリ名
- `BACKEND_SERVICE_NAME` - バックエンド ECS サービス名
- `FRONTEND_SERVICE_NAME` - フロントエンド ECS サービス名
- `ECS_CLUSTER` - ECS クラスター名
- `DB_HOST` - データベースホスト
- `DB_DATABASE` - データベース名
- `DB_USERNAME` - データベースユーザー
- `PRODUCTION_API_URL` - 本番 API のパブリック URL
- `PRODUCTION_INTERNAL_API_URL` - ECS 内部での API 通信用 URL

### デプロイフロー

1. `main`ブランチにプッシュまたはマージすると、GitHub Actions が起動します
2. テストが実行され、問題がなければデプロイが開始されます
3. Docker イメージがビルドされ、Amazon ECR にプッシュされます
4. 新しい ECS タスク定義が作成され、サービスが更新されます
5. アプリケーションが本番環境にデプロイされます

詳細な ECS 設定については、`.aws/`ディレクトリのファイルを参照してください。
