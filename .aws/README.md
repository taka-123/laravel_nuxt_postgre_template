# AWS ECS デプロイ設定

本プロジェクトのAWS ECS（Elastic Container Service）へのデプロイに関する情報を記載しています。

## 目次

1. [アーキテクチャ概要](#アーキテクチャ概要)
2. [必要なAWSリソース](#必要なawsリソース)
3. [デプロイフロー](#デプロイフロー)
4. [初期セットアップ手順](#初期セットアップ手順)
5. [環境変数と設定](#環境変数と設定)
6. [トラブルシューティング](#トラブルシューティング)

## アーキテクチャ概要

本プロジェクトは以下のAWSサービスを利用しています：

- **ECR (Elastic Container Registry)**: Dockerイメージの保存
- **ECS (Elastic Container Service)**: コンテナの実行環境
  - Fargateを使用（サーバーレスコンテナ実行環境）
- **ALB (Application Load Balancer)**: トラフィックの分散
- **RDS (Relational Database Service)**: PostgreSQLデータベース
- **S3**: 静的ファイルの保存
- **CloudWatch**: ログとメトリクスの収集
- **IAM**: 権限管理

### システム構成図

```
Internet --> ALB --> ECS Fargate (Frontend) --> ECS Fargate (Backend) --> RDS
                                             |
                                             v
                                             S3 (Static Files)
```

## 必要なAWSリソース

### ECR リポジトリ
- `book-management-frontend`: フロントエンドのDockerイメージ用
- `book-management-backend`: バックエンドのDockerイメージ用

### ECS リソース
- **クラスター**: `book-management-cluster`
- **サービス**: 
  - `book-management-frontend-service`
  - `book-management-backend-service`
- **タスク定義**:
  - `.aws/task-definitions/frontend.json`
  - `.aws/task-definitions/backend.json`

### その他のリソース
- **VPC** と **サブネット**
- **セキュリティグループ**
- **IAMロール**
- **RDSインスタンス**
- **ALB**
- **S3バケット**

## デプロイフロー

GitHub Actionsを使用して、以下の流れでデプロイを行います：

1. `main`ブランチへのプッシュをトリガーに、ワークフローが開始
2. テストの実行
3. Dockerイメージのビルド
4. ECRへのイメージのプッシュ
5. ECSタスク定義の更新（新しいイメージを参照）
6. ECSサービスの更新（ローリングデプロイによるゼロダウンタイム）

詳細なフローは `.github/workflows/deploy-ecs-production.yml` を参照してください。

## 初期セットアップ手順

### 1. AWSリソースのプロビジョニング

以下のリソースを事前に作成する必要があります：

- VPC、サブネット、ルートテーブル
- ECRリポジトリ
- ECSクラスター
- RDSインスタンス
- IAMロールとポリシー
- ALB
- S3バケット

これらのリソースはAWS CloudFormation、Terraform、またはAWSコンソールを使用して作成できます。

### 2. GitHubシークレットの設定

GitHub Actionsで使用するために、以下のシークレットをリポジトリに設定してください：

- `AWS_ACCESS_KEY_ID`: AWSアクセスキーID
- `AWS_SECRET_ACCESS_KEY`: AWSシークレットアクセスキー
- `AWS_REGION`: AWSリージョン
- `ECR_REPOSITORY_FRONTEND`: フロントエンドECRリポジトリ名
- `ECR_REPOSITORY_BACKEND`: バックエンドECRリポジトリ名
- `ECS_CLUSTER`: ECSクラスター名
- `ECS_SERVICE_FRONTEND`: フロントエンドECSサービス名
- `ECS_SERVICE_BACKEND`: バックエンドECSサービス名

### 3. タスク定義ファイルの準備

`.aws/task-definitions/` ディレクトリ内のJSONファイルを環境に合わせて更新してください。

## 環境変数と設定

### バックエンド環境変数

バックエンドのタスク定義には、以下の環境変数を設定する必要があります：

```json
"environment": [
  { "name": "APP_ENV", "value": "production" },
  { "name": "APP_DEBUG", "value": "false" },
  { "name": "DB_CONNECTION", "value": "pgsql" },
  { "name": "DB_HOST", "value": "YOUR_RDS_ENDPOINT" },
  { "name": "DB_PORT", "value": "5432" },
  { "name": "DB_DATABASE", "value": "book_management" },
  { "name": "DB_USERNAME", "value": "username" },
  { "name": "CACHE_DRIVER", "value": "redis" },
  { "name": "SESSION_DRIVER", "value": "redis" },
  { "name": "REDIS_HOST", "value": "YOUR_REDIS_ENDPOINT" }
]
```

**注意**: パスワードなどの機密情報は、AWS Secrets Managerを使用して管理することを推奨します。

### フロントエンド環境変数

フロントエンドのタスク定義には、以下の環境変数を設定する必要があります：

```json
"environment": [
  { "name": "API_URL", "value": "https://api.yourdomain.com" },
  { "name": "NODE_ENV", "value": "production" }
]
```

## トラブルシューティング

### よくある問題と解決策

1. **デプロイ失敗**
   - CloudWatchログを確認して、エラーの詳細を確認してください
   - GitHub Actionsのログも確認してください

2. **コンテナの起動失敗**
   - ヘルスチェックの設定を確認してください
   - 必要な環境変数が正しく設定されているか確認してください

3. **データベース接続エラー**
   - セキュリティグループの設定を確認してください
   - データベースの認証情報が正しいか確認してください

4. **ロードバランサーのエラー**
   - ターゲットグループの設定を確認してください
   - ヘルスチェックのパスが正しいか確認してください

### サポートリソース

- [AWS ECSドキュメント](https://docs.aws.amazon.com/ecs/)
- [AWS ECRドキュメント](https://docs.aws.amazon.com/ecr/)
- [GitHub Actions ドキュメント](https://docs.github.com/actions)
