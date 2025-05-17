#!/bin/bash

# エラーハンドリングの設定
set -e

# 環境変数の設定
PROJECT_NAME=laravel-nuxt-template
ENVIRONMENT=${ENVIRONMENT:-production}

# 関数定義
function log_info() {
  echo -e "\033[0;32m[INFO]\033[0m $1"
}

function log_warn() {
  echo -e "\033[0;33m[WARN]\033[0m $1"
}

function log_error() {
  echo -e "\033[0;31m[ERROR]\033[0m $1"
}

function handle_error() {
  log_error "エラーが発生しました: $1"
  exit 1
}

# スタックが存在するか確認する関数
function stack_exists() {
  aws cloudformation describe-stacks --stack-name "$1" >/dev/null 2>&1
  return $?
}

# RDSインスタンスの削除保護を無効化する関数
function disable_rds_deletion_protection() {
  local db_instance_id="$1"

  log_info "RDSインスタンス ${db_instance_id} の削除保護を無効化しています..."
  aws rds modify-db-instance \
    --db-instance-identifier "${db_instance_id}" \
    --no-deletion-protection \
    --apply-immediately >/dev/null 2>&1 || {
    log_warn "RDSインスタンス ${db_instance_id} の削除保護の無効化に失敗しました。インスタンスが存在しないか、すでに無効化されている可能性があります。"
    return 1
  }

  log_info "RDSインスタンス ${db_instance_id} の削除保護を無効化しました。"
  return 0
}

# ECRリポジトリのイメージを強制削除する関数
function force_delete_ecr_repository() {
  local repo_name="$1"

  log_info "ECRリポジトリ ${repo_name} を強制削除しています..."
  aws ecr delete-repository \
    --repository-name "${repo_name}" \
    --force >/dev/null 2>&1 || {
    log_warn "ECRリポジトリ ${repo_name} の強制削除に失敗しました。リポジトリが存在しない可能性があります。"
    return 1
  }

  log_info "ECRリポジトリ ${repo_name} を強制削除しました。"
  return 0
}

log_info "インフラストラクチャの削除を開始します..."
echo "警告: この操作は元に戻せません。本当に削除しますか？ (y/N)"
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  log_info "操作をキャンセルしました。"
  exit 0
fi

# スタックを逆順で削除（依存関係を考慮）

# まずECSスタックを削除
if stack_exists "$PROJECT_NAME-ecs"; then
  log_info "ECSスタックを削除しています..."
  aws cloudformation delete-stack --stack-name "$PROJECT_NAME-ecs" || log_warn "ECSスタックの削除開始に失敗しました。すでに削除中の可能性があります。"
  log_info "ECSスタックの削除を待機しています..."
  aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-ecs" || log_warn "ECSスタックの削除完了待機中にエラーが発生しました。"
else
  log_info "ECSスタックは存在しません。スキップします。"
fi

# ALBスタックを削除
if stack_exists "$PROJECT_NAME-alb"; then
  log_info "ALBスタックを削除しています..."
  aws cloudformation delete-stack --stack-name "$PROJECT_NAME-alb" || log_warn "ALBスタックの削除開始に失敗しました。すでに削除中の可能性があります。"
  log_info "ALBスタックの削除を待機しています..."
  aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-alb" || log_warn "ALBスタックの削除完了待機中にエラーが発生しました。"
else
  log_info "ALBスタックは存在しません。スキップします。"
fi

# RDSスタックを削除
if stack_exists "$PROJECT_NAME-rds"; then
  # RDSインスタンスの削除保護を無効化
  disable_rds_deletion_protection "$PROJECT_NAME-$ENVIRONMENT-db"

  log_info "RDSスタックを削除しています..."
  aws cloudformation delete-stack --stack-name "$PROJECT_NAME-rds" || log_warn "RDSスタックの削除開始に失敗しました。すでに削除中の可能性があります。"
  log_info "RDSスタックの削除を待機しています..."
  aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-rds" || {
    log_warn "RDSスタックの削除に失敗しました。RDSインスタンスの削除保護が有効になっている可能性があります。"
    log_info "RDSインスタンスの削除保護を無効化して再試行します..."
    disable_rds_deletion_protection "$PROJECT_NAME-$ENVIRONMENT-db"
    log_info "RDSスタックを再度削除しています..."
    aws cloudformation delete-stack --stack-name "$PROJECT_NAME-rds" || log_warn "RDSスタックの削除開始に失敗しました。"
    log_info "RDSスタックの削除を待機しています..."
    aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-rds" || log_warn "RDSスタックの削除完了待機中にエラーが発生しました。"
  }
else
  log_info "RDSスタックは存在しません。スキップします。"
fi

# ECRスタックを削除
if stack_exists "$PROJECT_NAME-ecr"; then
  log_info "ECRスタックを削除しています..."
  aws cloudformation delete-stack --stack-name "$PROJECT_NAME-ecr" || log_warn "ECRスタックの削除開始に失敗しました。すでに削除中の可能性があります。"
  log_info "ECRスタックの削除を待機しています..."
  aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-ecr" || {
    log_warn "ECRスタックの削除に失敗しました。ECRリポジトリにイメージが残っている可能性があります。"
    log_info "ECRリポジトリを強制削除します..."
    force_delete_ecr_repository "$PROJECT_NAME-$ENVIRONMENT-backend"
    force_delete_ecr_repository "$PROJECT_NAME-$ENVIRONMENT-frontend"
    log_info "ECRスタックを再度削除しています..."
    aws cloudformation delete-stack --stack-name "$PROJECT_NAME-ecr" || log_warn "ECRスタックの削除開始に失敗しました。"
    log_info "ECRスタックの削除を待機しています..."
    aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-ecr" || log_warn "ECRスタックの削除完了待機中にエラーが発生しました。"
  }
else
  log_info "ECRスタックは存在しません。スキップします。"
fi

# IAMスタックを削除
if stack_exists "$PROJECT_NAME-iam"; then
  log_info "IAMスタックを削除しています..."
  aws cloudformation delete-stack --stack-name "$PROJECT_NAME-iam" || log_warn "IAMスタックの削除開始に失敗しました。すでに削除中の可能性があります。"
  log_info "IAMスタックの削除を待機しています..."
  aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-iam" || log_warn "IAMスタックの削除完了待機中にエラーが発生しました。"
else
  log_info "IAMスタックは存在しません。スキップします。"
fi

# 最後にVPCスタックを削除
if stack_exists "$PROJECT_NAME-vpc"; then
  log_info "VPCスタックを削除しています..."
  aws cloudformation delete-stack --stack-name "$PROJECT_NAME-vpc" || log_warn "VPCスタックの削除開始に失敗しました。すでに削除中の可能性があります。"
  log_info "VPCスタックの削除を待機しています..."
  aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-vpc" || log_warn "VPCスタックの削除完了待機中にエラーが発生しました。"
else
  log_info "VPCスタックは存在しません。スキップします。"
fi

# 残っているスタックがないか確認
REMAINING_STACKS=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE DELETE_FAILED | grep -i "$PROJECT_NAME" || true)

if [ -n "$REMAINING_STACKS" ]; then
  log_warn "以下のスタックが残っています。手動で削除が必要な場合があります："
  echo "$REMAINING_STACKS"
else
  log_info "すべてのインフラストラクチャの削除が完了しました！"
fi
