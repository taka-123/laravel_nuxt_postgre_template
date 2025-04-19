# AWS ECS デプロイ設定

本プロジェクトの AWS ECS（Elastic Container Service）へのデプロイに関する情報を記載しています。

## 目次

- [アーキテクチャ概要](#アーキテクチャ概要)
- [デプロイフロー](#デプロイフロー)
- [初期設定](#初期設定)
  - [AWS 認証情報を GitHub シークレットとして設定](#aws認証情報をgithubシークレットとして設定)
  - [AWS 環境のプロビジョニング](#aws環境のプロビジョニング)
- [CloudFormation によるデプロイ](#cloudformationによるデプロイ)
  - [デプロイ準備](#デプロイ準備)
  - [スタックのデプロイ順序](#スタックのデプロイ順序)
  - [スタックのデプロイコマンド](#スタックのデプロイコマンド)
  - [スタックの更新と削除](#スタックの更新と削除)
- [IAM 権限設定](#iam権限設定)
  - [デプロイ用 IAM ユーザー/ロールの設定](#デプロイ用iamユーザーロールの設定)
  - [CloudFormation サービスロールの設定](#cloudformationサービスロールの設定)
  - [ECS タスク実行ロールの設定](#ecsタスク実行ロールの設定)
  - [CI/CD パイプライン用 IAM ユーザーの設定](#cicdパイプライン用iamユーザーの設定)
  - [IAM 管理のベストプラクティス](#iam管理のベストプラクティス)
- [環境変数の設定](#環境変数の設定)
  - [バックエンドタスク](#バックエンドタスク)
  - [フロントエンドタスク](#フロントエンドタスク)
- [トラブルシューティング](#トラブルシューティング)
- [サポートとリソース](#サポートとリソース)

## アーキテクチャ概要

本プロジェクトは以下の AWS サービスを利用しています：

- **ECR (Elastic Container Registry)**: Docker イメージの保存
- **ECS (Elastic Container Service)**: コンテナの実行環境
  - Fargate を使用（サーバーレスコンテナ実行環境）
- **ALB (Application Load Balancer)**: トラフィックの分散
- **RDS (Relational Database Service)**: PostgreSQL データベース
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

## 必要な AWS リソース

### ECR リポジトリ

- `book-management-frontend`: フロントエンドの Docker イメージ用
- `book-management-backend`: バックエンドの Docker イメージ用

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
- **IAM ロール**
- **RDS インスタンス**
- **ALB**
- **S3 バケット**

## デプロイフロー

GitHub Actions を使用して、以下の流れでデプロイを行います：

1. `main`ブランチへのプッシュをトリガーに、ワークフローが開始
2. テストの実行
3. Docker イメージのビルド
4. ECR へのイメージのプッシュ
5. ECS タスク定義の更新（新しいイメージを参照）
6. ECS サービスの更新（ローリングデプロイによるゼロダウンタイム）

詳細なフローは `.github/workflows/deploy-ecs-production.yml` を参照してください。

## 初期設定

### AWS 認証情報を GitHub シークレットとして設定

CI/CD パイプラインで AWS リソースにアクセスするには、以下の GitHub シークレットを設定する必要があります：

1. GitHub リポジトリの「Settings」→「Secrets and variables」→「Actions」に移動
2. 「New repository secret」をクリックし、以下のシークレットを追加：
   - `AWS_ACCESS_KEY_ID`: IAM スタックデプロイ後に作成された CI/CD ユーザーのアクセスキー ID
   - `AWS_SECRET_ACCESS_KEY`: IAM スタックデプロイ時に表示された（または後で作成した）シークレットアクセスキー
   - `AWS_REGION`: 使用する AWS リージョン（例：`ap-northeast-1`）
   - `ECR_REPOSITORY_FRONTEND`: フロントエンド ECR リポジトリ名
   - `ECR_REPOSITORY_BACKEND`: バックエンド ECR リポジトリ名
   - `ECS_CLUSTER`: ECS クラスター名
   - `ECS_SERVICE_FRONTEND`: フロントエンド ECS サービス名
   - `ECS_SERVICE_BACKEND`: バックエンド ECS サービス名

これらの認証情報は、GitHub Actions ワークフローファイル内で環境変数として利用され、AWS リソースへのアクセスに使用されます。

**重要**: IAM 認証情報（アクセスキーとシークレットキー）は機密情報です。GitHub シークレットとして安全に保存し、コードやコミットメッセージに記載しないでください。

#### IAM 認証情報のローテーション

セキュリティのベストプラクティスとして、定期的に（90 日ごとなど）IAM 認証情報をローテーションすることをお勧めします：

1. AWS コンソールで CI/CD パイプライン用 IAM ユーザーの新しいアクセスキーを作成
2. GitHub シークレットを新しい認証情報で更新
3. デプロイが正常に機能することを確認
4. 古いアクセスキーを無効化し、確認後に削除

### AWS 環境のプロビジョニング

## CloudFormation によるデプロイ

CloudFormation を使用して、インフラストラクチャをコードとして管理し、デプロイします。

#### 準備

1. AWS CLI をインストールし、設定する

   ```bash
   # AWS CLIのインストール（macOS）
   brew install awscli

   # AWS CLIの設定
   aws configure
   ```

2. 必要なパラメータを準備する
   - スタック名
   - 環境名（dev, staging, prod）
   - リージョン
   - その他スタック固有のパラメータ

#### デプロイ順序

スタック間の依存関係があるため、以下の順序でデプロイする必要があります：

1. IAM（最初に権限を設定）
2. VPC（ネットワーク）
3. ECR（コンテナレジストリ）
4. RDS（データベース）
5. S3（静的ファイル）
6. ALB（ロードバランサー）
7. ECS（コンテナサービス）

#### IAM スタックのデプロイ

IAM スタックには、他のリソースをデプロイするための権限が含まれるため、最初にデプロイします。

```bash
aws cloudformation deploy \
  --template-file .aws/cloudformation/iam.yaml \
  --stack-name book-management-iam \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    Environment=dev \
    ProjectName=book-management
```

`CAPABILITY_NAMED_IAM`フラグは、IAM リソースを作成する権限を CloudFormation に付与するために必要です。

デプロイ後、以下の IAM リソースが作成されます：

- CloudFormation サービスロール
- ECS タスク実行ロール
- CI/CD パイプライン用 IAM ユーザー（アクセスキーとシークレットキーを取得）

アクセスキーとシークレットキーは、出力タブで確認できます：

```bash
aws cloudformation describe-stacks \
  --stack-name book-management-iam \
  --query "Stacks[0].Outputs"
```

#### VPC スタックのデプロイ

```bash
aws cloudformation deploy \
  --template-file .aws/cloudformation/vpc.yaml \
  --stack-name book-management-vpc \
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/BookManagementCloudFormationServiceRole \
  --parameter-overrides \
    Environment=dev \
    ProjectName=book-management \
    VpcCidr=10.0.0.0/16 \
    PublicSubnet1Cidr=10.0.1.0/24 \
    PublicSubnet2Cidr=10.0.2.0/24 \
    PrivateSubnet1Cidr=10.0.3.0/24 \
    PrivateSubnet2Cidr=10.0.4.0/24
```

#### ECR スタックのデプロイ

```bash
aws cloudformation deploy \
  --template-file .aws/cloudformation/ecr.yaml \
  --stack-name book-management-ecr \
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/BookManagementCloudFormationServiceRole \
  --parameter-overrides \
    Environment=dev \
    ProjectName=book-management
```

#### RDS スタックのデプロイ

```bash
aws cloudformation deploy \
  --template-file .aws/cloudformation/rds.yaml \
  --stack-name book-management-rds \
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/BookManagementCloudFormationServiceRole \
  --parameter-overrides \
    Environment=dev \
    ProjectName=book-management \
    VpcStackName=book-management-vpc \
    DBInstanceClass=db.t3.micro \
    DBName=bookmanagement \
    DBUsername=admin \
    DBPassword=<データベースパスワード>
```

#### ALB スタックのデプロイ

```bash
aws cloudformation deploy \
  --template-file .aws/cloudformation/alb.yaml \
  --stack-name book-management-alb \
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/BookManagementCloudFormationServiceRole \
  --parameter-overrides \
    Environment=dev \
    ProjectName=book-management \
    VpcStackName=book-management-vpc \
    CertificateArn=<SSL証明書のARN>
```

#### ECS スタックのデプロイ

```bash
aws cloudformation deploy \
  --template-file .aws/cloudformation/ecs.yaml \
  --stack-name book-management-ecs \
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/BookManagementCloudFormationServiceRole \
  --parameter-overrides \
    Environment=dev \
    ProjectName=book-management \
    VpcStackName=book-management-vpc \
    EcrStackName=book-management-ecr \
    RdsStackName=book-management-rds \
    AlbStackName=book-management-alb \
    TaskExecutionRoleArn=arn:aws:iam::<ACCOUNT_ID>:role/BookManagementEcsTaskExecutionRole \
    BackendTaskRoleArn=arn:aws:iam::<ACCOUNT_ID>:role/BookManagementBackendTaskRole \
    FrontendTaskRoleArn=arn:aws:iam::<ACCOUNT_ID>:role/BookManagementFrontendTaskRole
```

#### スタックの更新

既存のスタックを更新する場合は、同じデプロイコマンドを使用します。CloudFormation は変更のあるリソースのみを更新します。

#### スタックの削除

不要になったスタックを削除するには、以下のコマンドを使用します：

```bash
aws cloudformation delete-stack --stack-name <スタック名>
```

**注意**: スタックを削除すると、そのスタックで作成されたすべてのリソースも削除されます。本番環境では十分注意してください。

また、依存関係があるため、削除は作成と逆の順序で行います：

1. ECS
2. ALB
3. S3
4. RDS
5. ECR
6. VPC
7. IAM

## IAM 権限設定

本プロジェクトでは、最小権限の原則に従って IAM 権限を設定します。

### 必要な IAM リソース

1. **CloudFormation サービスロール**

   - CloudFormation がユーザーに代わってリソースを作成・更新・削除するために使用します
   - 必要なポリシー：各スタックが操作する AWS サービスに対する権限

2. **ECS タスク実行ロール**

   - ECR からのイメージプル、CloudWatch へのログ書き込みなどの ECS 基本操作用
   - SecretsManager や SSM からの環境変数取得用

3. **ECS タスクロール**

   - バックエンドタスクロール：RDS、S3、SES、その他必要なサービスへのアクセス用
   - フロントエンドタスクロール：S3、CloudFront、その他必要なサービスへのアクセス用

4. **CI/CD パイプライン用 IAM ユーザー**
   - GitHub Actions などのパイプラインがデプロイに使用する IAM ユーザー
   - ECR へのイメージプッシュ、ECS サービスの更新権限

### CloudFormation サービスロールの設定

CloudFormation サービスロールは、CloudFormation スタックの作成・更新・削除時に使用されます。
以下は、サービスロール用の信頼ポリシーとアクセス許可ポリシーの例です。

#### 信頼ポリシー（Trust Policy）

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudformation.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### アクセス許可ポリシー（Permissions Policy）

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "ecs:*",
        "ecr:*",
        "rds:*",
        "logs:*",
        "s3:*",
        "secretsmanager:*",
        "iam:GetRole",
        "iam:PassRole",
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*"
    }
  ]
}
```

**注意**: プロダクション環境では、上記のポリシーをさらに制限して、特定のリソースに対してのみ権限を付与することをおすすめします。

### ECS タスク実行ロールの設定

ECS タスク実行ロールは、ECS サービスが ECR からのイメージプルや CloudWatch へのログ書き込みなどの基本操作を行うために使用します。

#### 信頼ポリシー

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### アクセス許可ポリシー

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
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Resource": "*"
    }
  ]
}
```

### CI/CD パイプライン用 IAM 設定

GitHub Actions などのパイプラインでは、AWS リソースにアクセスするための IAM ユーザーが必要です。
このユーザーには、ECR へのイメージプッシュと ECS サービスの更新権限を与えます。

#### アクセス許可ポリシー

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
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": [
        "arn:aws:iam::*:role/BookManagementEcsTaskExecutionRole",
        "arn:aws:iam::*:role/BookManagementBackendTaskRole",
        "arn:aws:iam::*:role/BookManagementFrontendTaskRole"
      ]
    }
  ]
}
```

### IAM 認証情報のローテーション

セキュリティ強化のため、IAM 認証情報は定期的にローテーションすることをおすすめします。特に CI/CD パイプライン用のアクセスキーは、3 ヶ月ごとなど定期的に更新すべきです。

#### アクセスキーのローテーション手順

1. AWS コンソールで新しいアクセスキーを作成します

   ```bash
   aws iam create-access-key --user-name BookManagementCICDUser
   ```

2. 新しいアクセスキーを GitHub シークレットに登録します

   - GitHub リポジトリの Settings > Secrets > Actions に移動
   - `AWS_ACCESS_KEY_ID` と `AWS_SECRET_ACCESS_KEY` の値を更新

3. デプロイが正常に動作することを確認します

   - テストデプロイを実行して問題ないことを確認

4. 古いアクセスキーを無効化します

   ```bash
   aws iam update-access-key --access-key-id OLD_ACCESS_KEY_ID --status Inactive --user-name BookManagementCICDUser
   ```

5. 問題がないことを確認後、古いアクセスキーを削除します
   ```bash
   aws iam delete-access-key --access-key-id OLD_ACCESS_KEY_ID --user-name BookManagementCICDUser
   ```

### IAM セキュリティのベストプラクティス

1. **最小権限の原則を適用する**

   - 各ロールには必要最小限の権限のみを付与
   - ワイルドカード（\*）の使用を最小限に抑える
   - 特定のリソース ARN を指定して権限を制限

2. **IAM ポリシーのレビューと監査**

   - AWS IAM Access Analyzer を使用してポリシーを定期的に監査
   - 使用されていない権限を特定し、削除

3. **MFA の有効化**

   - 特に管理者アカウントには MFA（多要素認証）を必須に
   - プログラムによるアクセスには一時的な認証情報の使用を推奨

4. **アクセスキーのセキュリティ**

   - アクセスキーを定期的にローテーション
   - アクセスキーをソースコードにハードコーディングしない
   - 特に本番環境のアクセスキーは厳重に管理

5. **AWS 認証情報レポートの定期確認**

   ```bash
   aws iam generate-credential-report
   aws iam get-credential-report
   ```

6. **権限昇格の制限**
   - 権限昇格パスを特定し、制限するポリシーを実装
   - サービスロールには特定のサービスのみが引き受け可能な信頼ポリシーを設定

## 環境変数の設定

### バックエンドタスク

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

**注意**: パスワードなどの機密情報は、AWS Secrets Manager を使用して管理することを推奨します。

### フロントエンドタスク

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

   - CloudWatch ログを確認して、エラーの詳細を確認してください
   - GitHub Actions のログも確認してください

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

- [AWS ECS ドキュメント](https://docs.aws.amazon.com/ecs/)
- [AWS ECR ドキュメント](https://docs.aws.amazon.com/ecr/)
- [AWS CloudFormation ドキュメント](https://docs.aws.amazon.com/cloudformation/)
- [GitHub Actions ドキュメント](https://docs.github.com/actions)
