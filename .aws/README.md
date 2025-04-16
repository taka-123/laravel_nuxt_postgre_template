# AWS ECSデプロイ設定

このディレクトリには、AWS ECSへのデプロイに必要な設定ファイルが含まれています。

## ディレクトリ構成

```
.aws/
├── backend-container-dockerfile # バックエンド用Dockerfile
├── frontend-container-dockerfile # フロントエンド用Dockerfile
├── backend-task-definition.json # バックエンドECSタスク定義
├── frontend-task-definition.json # フロントエンドECSタスク定義
├── nginx/ # Nginx設定ファイル
│   ├── nginx.conf
│   └── default.conf
├── php/ # PHP設定ファイル
│   └── php.ini
└── supervisord.conf # Supervisor設定ファイル
```

## AWS ECS環境構築手順

### 1. ECRリポジトリの作成

```bash
aws ecr create-repository --repository-name book-management-backend
aws ecr create-repository --repository-name book-management-frontend
```

### 2. IAMロールの作成

以下のロールが必要です：

- `ecsTaskExecutionRole` - タスク実行時に必要な権限
- `ecsBookManagementTaskRole` - アプリケーション実行時に必要なAWSサービスへのアクセス権限

### 3. ECSクラスターの作成

```bash
aws ecs create-cluster --cluster-name book-management-cluster
```

### 4. セキュリティグループの設定

アプリケーションに必要なポートを開放したセキュリティグループを作成します：

- バックエンド: 80ポート
- フロントエンド: 3000ポート

### 5. ロードバランサーの設定

アプリケーションロードバランサー(ALB)を作成し、ターゲットグループを設定します。

### 6. パラメータストアでシークレット管理

以下のシークレットをAWS Systems Manager Parameter Storeに保存します：

```bash
aws ssm put-parameter --name "/book-management/app-key" --type "SecureString" --value "APP_KEYの値"
aws ssm put-parameter --name "/book-management/db-password" --type "SecureString" --value "DBパスワード"
aws ssm put-parameter --name "/book-management/jwt-secret" --type "SecureString" --value "JWT_SECRETの値"
```

### 7. ECSサービスの作成

バックエンドとフロントエンドのサービスを作成します：

```bash
aws ecs create-service --cluster book-management-cluster --service-name book-management-backend-service --task-definition book-management-backend --desired-count 1 --launch-type FARGATE [他のオプション]
aws ecs create-service --cluster book-management-cluster --service-name book-management-frontend-service --task-definition book-management-frontend --desired-count 1 --launch-type FARGATE [他のオプション]
```

## GitHub Actionsのセットアップ

リポジトリのシークレット設定で以下の値を設定します：

- `AWS_ACCESS_KEY_ID` - IAMユーザーのアクセスキー
- `AWS_SECRET_ACCESS_KEY` - IAMユーザーのシークレットキー
- `AWS_REGION` - AWSリージョン (例: `ap-northeast-1`)
- `ECR_REPOSITORY_BACKEND` - バックエンドのECRリポジトリ名
- `ECR_REPOSITORY_FRONTEND` - フロントエンドのECRリポジトリ名
- `BACKEND_SERVICE_NAME` - バックエンドのECSサービス名
- `FRONTEND_SERVICE_NAME` - フロントエンドのECSサービス名
- `ECS_CLUSTER` - ECSクラスター名
- `DB_HOST` - データベースのホスト名
- `DB_DATABASE` - データベース名
- `DB_USERNAME` - データベースユーザー名
- `PRODUCTION_API_URL` - 外部公開用APIのURL (例: `https://api.example.com`)
- `PRODUCTION_INTERNAL_API_URL` - ECS内部通信用APIのURL (例: `http://backend.internal`)

## デプロイフロー

1. GitHub Actionsのワークフローが実行されます (`.github/workflows/deploy-ecs-production.yml`)
2. テストが実行され、成功するとDockerイメージがビルドされます
3. イメージがECRにプッシュされます
4. ECSタスク定義が更新されます
5. サービスがデプロイされます

## ECSサービスの管理

サービスの更新や停止は、AWS管理コンソールかAWS CLIを使用して行うことができます：

```bash
# サービスの更新
aws ecs update-service --cluster book-management-cluster --service book-management-backend-service --force-new-deployment

# サービスの停止
aws ecs update-service --cluster book-management-cluster --service book-management-backend-service --desired-count 0
```

## スケーリング

アプリケーションの負荷に応じて、タスク数やCPU/メモリ割り当てを調整できます。 
