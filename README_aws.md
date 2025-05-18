# AWS デプロイガイド

このドキュメントでは、Laravel + Nuxt + PostgreSQL テンプレートを AWS 環境にデプロイするための設定と手順について説明します。

## 目次

1. [概要](#概要)
2. [AWS 環境構成](#aws-環境構成)
3. [デプロイパイプライン](#デプロイパイプライン)
4. [必要な IAM 設定](#必要な-iam-設定)
5. [CI/CD 設定](#cicd-設定)
6. [トラブルシューティング](#トラブルシューティング)

## 概要

本テンプレートは、AWS の以下のサービスを使用してデプロイすることができます：

- **ECS (Elastic Container Service)**: コンテナオーケストレーション
- **ECR (Elastic Container Registry)**: コンテナイメージの保存
- **RDS (PostgreSQL)**: データベース
- **CloudFront**: CDN 配信
- **S3**: 静的アセットの保存
- **ALB (Application Load Balancer)**: ロードバランシング
- **Route 53**: DNS 管理

## AWS 環境構成

### インフラストラクチャ構成

```
                    +---------------+
                    |  CloudFront   |
                    +-------+-------+
                            |
                    +-------v-------+
                    |      S3       |
                    | (静的アセット) |
                    +---------------+
                            |
+---------------+    +------v------+    +---------------+
|   Route 53    +--->+     ALB     +--->+  ECS Service  |
+---------------+    +-------------+    +-------+-------+
                                                |
                                        +-------v-------+
                                        |     RDS      |
                                        | (PostgreSQL)  |
                                        +---------------+
```

### 主要コンポーネント

1. **ECS クラスター**:

   - バックエンド (Laravel) とフロントエンド (Nuxt.js) の 2 つのサービス
   - Fargate 起動タイプ（サーバーレス）

2. **RDS インスタンス**:

   - PostgreSQL 16.x
   - マルチ AZ 配置（本番環境）

3. **ネットワーク**:
   - VPC、サブネット、セキュリティグループ
   - プライベートサブネットでのデータベース配置

## デプロイパイプライン

AWS へのデプロイは GitHub Actions を使用した CI/CD パイプラインで自動化されています：

1. **テスト実行**
2. **Docker イメージのビルド**
3. **ECR へのイメージプッシュ**
4. **ECS タスク定義の更新**
5. **ECS サービスの更新**（ゼロダウンタイムデプロイ）
6. **CloudFront キャッシュの無効化**（必要に応じて）
7. **Slack 通知**（成功/失敗）

## 必要な IAM 設定

GitHub Actions から AWS リソースにアクセスするには、以下の IAM 設定が必要です：

### OIDC プロバイダー設定（推奨）

GitHub Actions と AWS の間で OpenID Connect (OIDC) を使用した認証を設定することで、長期的なアクセスキーを使用せずにデプロイが可能になります。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:ORGANIZATION/REPOSITORY:*"
        }
      }
    }
  ]
}
```

### 必要な IAM 権限

デプロイに必要な最小限の IAM 権限は以下の通りです：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["iam:PassRole"],
      "Resource": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole"
    },
    {
      "Effect": "Allow",
      "Action": ["cloudfront:CreateInvalidation"],
      "Resource": "arn:aws:cloudfront::ACCOUNT_ID:distribution/DISTRIBUTION_ID"
    }
  ]
}
```

## CI/CD 設定

### GitHub Actions ワークフロー

以下は AWS ECS へのデプロイを行う GitHub Actions ワークフローの例です：

```yaml
name: Deploy to AWS ECS

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::ACCOUNT_ID:role/GitHubActionsRole
          aws-region: ap-northeast-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: laravel-nuxt-template
          IMAGE_TAG: ${{ github.sha }}
        run: |
          # バックエンドイメージのビルドとプッシュ
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:backend-$IMAGE_TAG ./backend
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:backend-$IMAGE_TAG

          # フロントエンドイメージのビルドとプッシュ
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:frontend-$IMAGE_TAG ./frontend
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:frontend-$IMAGE_TAG

          echo "::set-output name=backend-image::$ECR_REGISTRY/$ECR_REPOSITORY:backend-$IMAGE_TAG"
          echo "::set-output name=frontend-image::$ECR_REGISTRY/$ECR_REPOSITORY:frontend-$IMAGE_TAG"

      - name: Update ECS task definition and service
        run: |
          # バックエンドタスク定義の更新
          aws ecs register-task-definition \
            --cli-input-json file://aws/task-definition-backend.json \
            --family laravel-nuxt-template-backend

          # フロントエンドタスク定義の更新
          aws ecs register-task-definition \
            --cli-input-json file://aws/task-definition-frontend.json \
            --family laravel-nuxt-template-frontend

          # バックエンドサービスの更新
          aws ecs update-service \
            --cluster laravel-nuxt-template \
            --service backend \
            --task-definition laravel-nuxt-template-backend \
            --force-new-deployment

          # フロントエンドサービスの更新
          aws ecs update-service \
            --cluster laravel-nuxt-template \
            --service frontend \
            --task-definition laravel-nuxt-template-frontend \
            --force-new-deployment

      - name: Invalidate CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id DISTRIBUTION_ID \
            --paths "/*"
```

## トラブルシューティング

### よくある問題と解決策

1. **デプロイ失敗**:

   - ECR リポジトリの存在確認
   - IAM 権限の確認
   - タスク定義の有効性確認

2. **コンテナ起動失敗**:

   - CloudWatch Logs でエラーを確認
   - 環境変数の設定確認
   - ヘルスチェック設定の確認

3. **データベース接続エラー**:

   - セキュリティグループの設定確認
   - 接続文字列の確認
   - RDS インスタンスのステータス確認

4. **CloudFront キャッシュの問題**:
   - 手動でキャッシュ無効化を実行
   - TTL 設定の確認
   - オリジンの設定確認

### デバッグ方法

1. **ECS タスクのデバッグ**:

   ```bash
   aws ecs describe-tasks --cluster laravel-nuxt-template --tasks TASK_ID
   ```

2. **CloudWatch Logs の確認**:

   ```bash
   aws logs get-log-events --log-group-name /ecs/laravel-nuxt-template --log-stream-name STREAM_NAME
   ```

3. **RDS インスタンスのステータス確認**:
   ```bash
   aws rds describe-db-instances --db-instance-identifier laravel-nuxt-template
   ```

---

このドキュメントは将来的に AWS 環境へ移行する際の参考資料として保存されています。現在のプロジェクトは Fly.io にデプロイされており、詳細は `.fly/README.md` を参照してください。
