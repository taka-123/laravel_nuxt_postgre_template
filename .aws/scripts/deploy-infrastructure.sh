#!/bin/bash

# エラーハンドリングの設定
set -e

# カラー出力の設定
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# 環境変数の設定
ENVIRONMENT=${1:-production}
PROJECT_NAME=laravel-nuxt-template
DB_INSTANCE_CLASS=${2:-db.t3.small}
DB_NAME=${3:-laravel_nuxt_template}
DB_USERNAME=${4:-dbadmin}

# ダミーパスワードを使用
DB_PASSWORD="TemporaryPassword123"

# AWS リージョンとアカウントID
AWS_REGION=$(aws configure get region 2>/dev/null || echo "ap-northeast-1")
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CLOUDFORMATION_DIR="$SCRIPT_DIR/../cloudformation"
PARAMETERS_DIR="$SCRIPT_DIR/../parameters"

# ログ関数
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
  echo -e "${BLUE}[DEBUG]${NC} $1"
}

# スタックの状態をチェックする関数
check_stack_status() {
  local stack_name="$1"
  local status

  status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].StackStatus" --output text 2>/dev/null || echo "DOES_NOT_EXIST")

  log_debug "スタック $stack_name の現在の状態: $status"

  if [ "$status" = "CREATE_IN_PROGRESS" ] || [ "$status" = "UPDATE_IN_PROGRESS" ]; then
    log_warn "スタック $stack_name は既に作成/更新中です。完了を待機します..."
    aws cloudformation wait stack-create-complete --stack-name "$stack_name" || aws cloudformation wait stack-update-complete --stack-name "$stack_name"
    return 0
  elif [ "$status" = "ROLLBACK_COMPLETE" ]; then
    log_warn "スタック $stack_name は ROLLBACK_COMPLETE 状態です。削除して再作成します..."
    aws cloudformation delete-stack --stack-name "$stack_name"
    aws cloudformation wait stack-delete-complete --stack-name "$stack_name"
    return 0
  elif [ "$status" = "DOES_NOT_EXIST" ]; then
    log_info "スタック $stack_name は存在しません。新規作成します。"
    return 0
  fi

  return 0
}

# パラメータディレクトリが存在しない場合は作成
mkdir -p "$PARAMETERS_DIR"

# 一時ファイルを使用するように変更
TEMP_PARAMS_FILE=$(mktemp)

# スクリプト終了時に一時ファイルを削除
cleanup() {
  log_info "一時ファイルを削除しています..."
  rm -f "$TEMP_PARAMS_FILE"
}
trap cleanup EXIT

log_info "注意: ダミーパスワードを使用してデプロイします。デプロイ後、AWSコンソールからパスワードを変更してください。"
log_info "インフラストラクチャのデプロイを開始します..."

# VPCスタックのデプロイ
log_info "VPCスタックをデプロイしています..."

# VPCスタックの状態をチェック
check_stack_status "$PROJECT_NAME-vpc"

aws cloudformation deploy \
  --template-file "$CLOUDFORMATION_DIR/vpc.yaml" \
  --stack-name "$PROJECT_NAME-vpc" \
  --parameter-overrides \
  ProjectName=$PROJECT_NAME \
  Environment=$ENVIRONMENT \
  --no-fail-on-empty-changeset || {
  log_error "VPCスタックのデプロイに失敗しました"
  exit 1
}

# VPCスタックの出力を取得
log_info "VPCスタックの出力を取得しています..."
VPC_ID=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-vpc" --query "Stacks[0].Outputs[?OutputKey=='VPC'].OutputValue" --output text)
PRIVATE_SUBNET_1=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-vpc" --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet1'].OutputValue" --output text)
PRIVATE_SUBNET_2=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-vpc" --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet2'].OutputValue" --output text)

# 公開サブネットの取得 (ALB 用)
PUBLIC_SUBNET_1=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-vpc" --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet1'].OutputValue" --output text)
PUBLIC_SUBNET_2=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-vpc" --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet2'].OutputValue" --output text)

log_debug "VPC ID: $VPC_ID"
log_debug "Private Subnet 1: $PRIVATE_SUBNET_1"
log_debug "Private Subnet 2: $PRIVATE_SUBNET_2"
log_debug "Public Subnet 1: $PUBLIC_SUBNET_1"
log_debug "Public Subnet 2: $PUBLIC_SUBNET_2"

# RDSパラメータファイルの作成
echo "RDSパラメータファイルを作成しています..."
cat >"$TEMP_PARAMS_FILE" <<EOF
[
  {
    "ParameterKey": "ProjectName",
    "ParameterValue": "$PROJECT_NAME"
  },
  {
    "ParameterKey": "Environment",
    "ParameterValue": "$ENVIRONMENT"
  },
  {
    "ParameterKey": "VPCId",
    "ParameterValue": "$VPC_ID"
  },
  {
    "ParameterKey": "DBSubnet1",
    "ParameterValue": "$PRIVATE_SUBNET_1"
  },
  {
    "ParameterKey": "DBSubnet2",
    "ParameterValue": "$PRIVATE_SUBNET_2"
  },
  {
    "ParameterKey": "DBInstanceClass",
    "ParameterValue": "$DB_INSTANCE_CLASS"
  },
  {
    "ParameterKey": "DBName",
    "ParameterValue": "$DB_NAME"
  },
  {
    "ParameterKey": "DBUsername",
    "ParameterValue": "$DB_USERNAME"
  },
  {
    "ParameterKey": "DBPassword",
    "ParameterValue": "$DB_PASSWORD"
  }
]
EOF

# RDSスタックのデプロイ
echo "RDSスタックをデプロイしています..."
aws cloudformation deploy \
  --template-file "$CLOUDFORMATION_DIR/rds.yaml" \
  --stack-name "$PROJECT_NAME-rds" \
  --parameter-overrides file://"$TEMP_PARAMS_FILE" \
  --no-fail-on-empty-changeset

# ECRスタックのデプロイ
log_info "ECRスタックをデプロイしています..."

# ECRスタックの状態をチェック
check_stack_status "$PROJECT_NAME-ecr"

aws cloudformation deploy \
  --template-file "$CLOUDFORMATION_DIR/ecr.yaml" \
  --stack-name "$PROJECT_NAME-ecr" \
  --parameter-overrides \
  ProjectName=$PROJECT_NAME \
  Environment=$ENVIRONMENT \
  --no-fail-on-empty-changeset || {
  log_error "ECRスタックのデプロイに失敗しました"
  exit 1
}

# ECRリポジトリのURIを取得
log_info "ECRリポジトリのURIを取得しています..."
BACKEND_REPO=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-ecr" --query "Stacks[0].Outputs[?OutputKey=='BackendRepositoryURI'].OutputValue" --output text)
FRONTEND_REPO=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-ecr" --query "Stacks[0].Outputs[?OutputKey=='FrontendRepositoryURI'].OutputValue" --output text)

if [ -z "$BACKEND_REPO" ] || [ -z "$FRONTEND_REPO" ]; then
  log_error "ECRリポジトリのURIの取得に失敗しました"
  log_error "BACKEND_REPO=$BACKEND_REPO"
  log_error "FRONTEND_REPO=$FRONTEND_REPO"
  exit 1
fi

log_debug "BACKEND_REPO=$BACKEND_REPO"
log_debug "FRONTEND_REPO=$FRONTEND_REPO"

# ECR ログイン
log_info "ECR にログインしています..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com" || {
  log_error "ECRログインに失敗しました"
  exit 1
}

# Backend
BACKEND_REPO_NAME="$PROJECT_NAME-$ENVIRONMENT-backend"
BACKEND_IMAGE_TAG="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO_NAME:latest"

log_info "Backend イメージをビルド中..."
log_debug "Backendビルド前: BACKEND_REPO=$BACKEND_REPO"

# プラットフォーム指定を削除し、ネイティブビルドを試みる
docker build --no-cache \
  --build-arg NODE_VERSION=22 \
  --build-arg POSTGRES_VERSION=16 \
  --build-arg WWWUSER=1337 \
  --build-arg WWWGROUP=1000 \
  -t "$BACKEND_IMAGE_TAG" \
  ../../backend || {
  log_error "Backendイメージのビルドに失敗しました"
  exit 1
}

log_info "Backend イメージをプッシュ中..."
docker push "$BACKEND_IMAGE_TAG" || {
  log_error "Backendイメージのプッシュに失敗しました"
  exit 1
}

# Frontend
FRONTEND_REPO_NAME="$PROJECT_NAME-$ENVIRONMENT-frontend"
FRONTEND_IMAGE_TAG="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO_NAME:latest"

log_info "Frontend イメージをビルド中..."
log_debug "Frontendビルド前: FRONTEND_REPO=$FRONTEND_REPO"

# プラットフォーム指定を削除し、ネイティブビルドを試みる
docker build --no-cache \
  --build-arg NODE_VERSION=22 \
  --build-arg WWWUSER=1337 \
  --build-arg WWWGROUP=1000 \
  -t "$FRONTEND_IMAGE_TAG" \
  ../../frontend || {
  log_error "Frontendイメージのビルドに失敗しました"
  exit 1
}

log_info "Frontend イメージをプッシュ中..."
docker push "$FRONTEND_IMAGE_TAG" || {
  log_error "Frontendイメージのプッシュに失敗しました"
  exit 1
}

log_info "Docker イメージのプッシュ完了。"
log_debug "DEBUG直前: BACKEND_REPO=$BACKEND_REPO"
log_debug "DEBUG直前: FRONTEND_REPO=$FRONTEND_REPO"

# RDSスタックのデプロイ
log_info "RDSスタックをデプロイしています..."

# RDSスタックの状態をチェック
check_stack_status "$PROJECT_NAME-rds"

aws cloudformation deploy \
  --template-file "$CLOUDFORMATION_DIR/rds.yaml" \
  --stack-name "$PROJECT_NAME-rds" \
  --parameter-overrides \
  ProjectName=$PROJECT_NAME \
  Environment=$ENVIRONMENT \
  VPCId=$VPC_ID \
  DBSubnet1=$PRIVATE_SUBNET_1 \
  DBSubnet2=$PRIVATE_SUBNET_2 \
  DBName=$DB_NAME \
  DBUsername=$DB_USERNAME \
  DBPassword=$DB_PASSWORD \
  DBInstanceClass=$DB_INSTANCE_CLASS \
  --no-fail-on-empty-changeset || {
  log_error "RDSスタックのデプロイに失敗しました"
  exit 1
}

log_info "RDSスタックのデプロイが完了しました"

# RDS 出力取得
log_info "RDSのエンドポイントを取得しています..."
DB_HOST=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-rds" --query "Stacks[0].Outputs[?OutputKey=='DBEndpointAddress'].OutputValue" --output text)

if [ -z "$DB_HOST" ]; then
  log_error "RDSエンドポイントの取得に失敗しました"
  exit 1
fi

log_debug "DB_HOST=$DB_HOST"

# ALBスタックのデプロイ
log_info "ALBスタックをデプロイしています..."

# ALBスタックの状態をチェック
check_stack_status "$PROJECT_NAME-alb"

aws cloudformation deploy \
  --template-file "$CLOUDFORMATION_DIR/alb.yaml" \
  --stack-name "$PROJECT_NAME-alb" \
  --parameter-overrides \
  ProjectName=$PROJECT_NAME \
  Environment=$ENVIRONMENT \
  VPCId=$VPC_ID \
  PublicSubnet1=$PUBLIC_SUBNET_1 \
  PublicSubnet2=$PUBLIC_SUBNET_2 \
  --no-fail-on-empty-changeset || {
  log_error "ALBスタックのデプロイに失敗しました"
  exit 1
}

# ALB 出力取得
log_info "ALBの出力を取得しています..."
ALB_DNS=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-alb" --query "Stacks[0].Outputs[?OutputKey=='LoadBalancerDNS'].OutputValue" --output text)
TG_BE=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-alb" --query "Stacks[0].Outputs[?OutputKey=='BackendTargetGroupArn'].OutputValue" --output text)
TG_FE=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-alb" --query "Stacks[0].Outputs[?OutputKey=='FrontendTargetGroupArn'].OutputValue" --output text)
ECS_SG=$(aws cloudformation describe-stacks --stack-name "$PROJECT_NAME-alb" --query "Stacks[0].Outputs[?OutputKey=='ECSSecurityGroupId'].OutputValue" --output text)

if [ -z "$ALB_DNS" ] || [ -z "$TG_BE" ] || [ -z "$TG_FE" ] || [ -z "$ECS_SG" ]; then
  log_error "ALB出力の取得に失敗しました"
  log_error "ALB_DNS=$ALB_DNS"
  log_error "TG_BE=$TG_BE"
  log_error "TG_FE=$TG_FE"
  log_error "ECS_SG=$ECS_SG"
  exit 1
fi

log_debug "ALB_DNS=$ALB_DNS"
log_debug "TG_BE=$TG_BE"
log_debug "TG_FE=$TG_FE"
log_debug "ECS_SG=$ECS_SG"

# ECSスタックのデプロイ
log_info "ECSスタックをデプロイしています..."

# ECS スタックの状態をチェック
check_stack_status "$PROJECT_NAME-ecs"

aws cloudformation deploy \
  --template-file "$CLOUDFORMATION_DIR/ecs.yaml" \
  --stack-name "$PROJECT_NAME-ecs" \
  --parameter-overrides \
  ProjectName=$PROJECT_NAME \
  Environment=$ENVIRONMENT \
  PrivateSubnet1=$PRIVATE_SUBNET_1 \
  PrivateSubnet2=$PRIVATE_SUBNET_2 \
  ECSSecurityGroupId=$ECS_SG \
  BackendTargetGroupArn=$TG_BE \
  FrontendTargetGroupArn=$TG_FE \
  BackendImageRepository=$BACKEND_REPO \
  FrontendImageRepository=$FRONTEND_REPO \
  DBHost=$DB_HOST \
  DBUsername=$DB_USERNAME \
  DBPassword=$DB_PASSWORD \
  APIPublicURL="http://$ALB_DNS" \
  APIInternalURL="http://$ALB_DNS" \
  JWTSecret="DummySecret123456" \
  AppKey="DummyAppKey123456" \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset || {
  log_error "ECSスタックのデプロイに失敗しました"
  exit 1
}

log_info "ECSスタックのデプロイが完了しました"

# IAMスタックのデプロイ
log_info "IAMスタックをデプロイしています..."

# IAMスタックの状態をチェック
check_stack_status "$PROJECT_NAME-iam"

aws cloudformation deploy \
  --template-file "$CLOUDFORMATION_DIR/iam.yaml" \
  --stack-name "$PROJECT_NAME-iam" \
  --parameter-overrides \
  ProjectName=$PROJECT_NAME \
  Environment=$ENVIRONMENT \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset || {
  log_error "IAMスタックのデプロイに失敗しました"
  exit 1
}

log_info "IAMスタックのデプロイが完了しました"

# デプロイ完了メッセージ
log_info "\n=============================================="
log_info "インフラストラクチャのデプロイが完了しました！"
log_info "\n重要: デプロイにはダミーパスワードを使用しました。"
log_info "AWSコンソールからRDSデータベースのパスワードを変更してください。"
log_info "=============================================="
log_info "\nアクセスURL: http://$ALB_DNS"
log_info "DBエンドポイント: $DB_HOST"
