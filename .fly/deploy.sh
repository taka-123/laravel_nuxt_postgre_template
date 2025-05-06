#!/bin/bash
set -e

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ヘルパー関数
log_info() {
  echo -e "${GREEN}INFO:${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}WARNING:${NC} $1"
}

log_error() {
  echo -e "${RED}ERROR:${NC} $1"
  exit 1
}

# 引数の解析
DEPLOY_DB=true
DEPLOY_BACKEND=true
DEPLOY_FRONTEND=true
NON_INTERACTIVE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-db)
      DEPLOY_DB=false
      shift
      ;;
    --skip-backend)
      DEPLOY_BACKEND=false
      shift
      ;;
    --skip-frontend)
      DEPLOY_FRONTEND=false
      shift
      ;;
    --non-interactive)
      NON_INTERACTIVE=true
      shift
      ;;
    --help)
      echo "使用方法: $0 [オプション]"
      echo "オプション:"
      echo "  --skip-db        データベースのデプロイをスキップ"
      echo "  --skip-backend   バックエンドのデプロイをスキップ"
      echo "  --skip-frontend  フロントエンドのデプロイをスキップ"
      echo "  --non-interactive 対話なしでデプロイ（自動的に全ての質問にデフォルト回答）"
      echo "  --help           このヘルプメッセージを表示"
      exit 0
      ;;
    *)
      log_error "不明な引数: $1"
      ;;
  esac
done

# Fly CLIがインストールされているか確認
if ! command -v fly &> /dev/null; then
  log_error "Fly CLI (fly) がインストールされていません。https://fly.io/docs/hands-on/install-flyctl/ を参照してインストールしてください。"
fi

# Fly.ioにログインしているか確認
if ! fly auth whoami &> /dev/null; then
  log_warn "Fly.ioにログインしていません。ログインします..."
  fly auth login
fi

# プロジェクトのルートディレクトリに移動
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

# データベース名と接続情報
DB_NAME="book-management-db"
DB_PASSWORD="qbVG7JFC7DrpZ2T" # 既に作成済みのデータベースのパスワード
DB_CONNECTION_STRING="postgres://postgres:${DB_PASSWORD}@${DB_NAME}.internal:5432/postgres"

# データベースのデプロイ
if [ "$DEPLOY_DB" = true ]; then
  log_info "PostgreSQLデータベースをデプロイします..."
  
  # データベースクラスタが存在するか確認
  if fly pg list | grep -q "$DB_NAME"; then
    log_info "既存のデータベースクラスタを使用します: $DB_NAME"
    
    # 既存のデータベースの接続情報を取得
    if [ "$NON_INTERACTIVE" = false ]; then
      log_info "既存のデータベースの接続情報を入力してください。"
      log_info "パスワードは初回デプロイ時に表示されたものを使用してください。"
      read -p "データベースパスワード: " DB_PASSWORD
      DB_CONNECTION_STRING="postgres://postgres:${DB_PASSWORD}@${DB_NAME}.internal:5432/postgres"
    else
      log_warn "非対話モードでは既存のデータベースパスワードを自動取得できません。"
      log_warn "--non-interactive オプションを使用する場合は、--skip-db オプションも使用するか、"
      log_warn "または先に対話モードでデプロイを実行してパスワードを設定してください。"
      exit 1
    fi
  else
    log_info "新しいデータベースクラスタを作成します: $DB_NAME"
    
    # 非対話モードの場合、自動的に回答を提供
    if [ "$NON_INTERACTIVE" = true ]; then
      # 最新のFly.io CLIではManaged PostgreSQL (MPG)を使用
      echo "10" | fly pg create --name "$DB_NAME" --region nrt --vm-size shared-cpu-1x
    else
      # 対話モードでデータベースを作成
      fly pg create --name "$DB_NAME" --region nrt --vm-size shared-cpu-1x
    fi
    
    # 作成されたデータベースの情報を取得
    DB_INFO=$(fly pg status "$DB_NAME")
    DB_PASSWORD=$(echo "$DB_INFO" | grep -oP 'Password:\s+\K[^\s]+')
    
    if [ -z "$DB_PASSWORD" ]; then
      log_warn "データベースパスワードを自動取得できませんでした。"
      if [ "$NON_INTERACTIVE" = false ]; then
        read -p "データベースパスワードを入力してください: " DB_PASSWORD
      else
        log_error "非対話モードではデータベースパスワードを手動で入力できません。"
      fi
    fi
    
    DB_CONNECTION_STRING="postgres://postgres:${DB_PASSWORD}@${DB_NAME}.internal:5432/postgres"
    log_info "データベース接続情報: $DB_CONNECTION_STRING"
    log_info "このパスワードは安全な場所に保存してください！"
  fi
fi

# バックエンドのデプロイ
if [ "$DEPLOY_BACKEND" = true ]; then
  log_info "バックエンドをデプロイします..."
  cd "$PROJECT_ROOT/backend"
  
  # fly.tomlファイルを確認
  if [ ! -f "fly.toml" ]; then
    log_info "fly.tomlをコピーします"
    cp "$PROJECT_ROOT/backend/fly.toml" .
  fi
  
  # Dockerfileを確認
  if [ ! -f "Dockerfile.fly" ]; then
    log_error "Dockerfile.flyが見つかりません"
  fi
  
  # アプリケーションが存在するか確認
  if fly apps list | grep -q "book-management-backend"; then
    log_info "既存のアプリケーションを更新します: book-management-backend"
    
    # 環境変数を設定
    if [ "$DEPLOY_DB" = true ]; then
      fly secrets set DATABASE_URL="$DB_CONNECTION_STRING" -a book-management-backend
    fi
    
    # デプロイ
    fly deploy --dockerfile Dockerfile.fly -a book-management-backend
  else
    log_info "新しいアプリケーションを作成します: book-management-backend"
    
    # 非対話モードの場合、自動的に回答を提供
    if [ "$NON_INTERACTIVE" = true ]; then
      # 非対話モードでlaunchを実行
      echo -e "book-management-backend\nnrt\nY\n" | fly launch --dockerfile Dockerfile.fly --no-deploy
    else
      # 対話モードでlaunchを実行
      fly launch --dockerfile Dockerfile.fly --no-deploy
    fi
    
    # 環境変数を設定
    if [ "$DEPLOY_DB" = true ]; then
      fly secrets set DATABASE_URL="$DB_CONNECTION_STRING" -a book-management-backend
    fi
    
    # デプロイ
    fly deploy --dockerfile Dockerfile.fly -a book-management-backend
  fi
fi

# フロントエンドのデプロイ
if [ "$DEPLOY_FRONTEND" = true ]; then
  log_info "フロントエンドをデプロイします..."
  cd "$PROJECT_ROOT/frontend"
  
  # fly.tomlファイルを確認
  if [ ! -f "fly.toml" ]; then
    log_info "fly.tomlをコピーします"
    cp "$PROJECT_ROOT/frontend/fly.toml" .
  fi
  
  # Dockerfileを確認
  if [ ! -f "Dockerfile.fly" ]; then
    log_error "Dockerfile.flyが見つかりません"
  fi
  
  # バックエンドのURLを環境変数として設定
  BACKEND_URL="https://book-management-backend.fly.dev"
  
  # アプリケーションが存在するか確認
  if fly apps list | grep -q "book-management-frontend"; then
    log_info "既存のアプリケーションを更新します: book-management-frontend"
    
    # 環境変数を設定
    fly secrets set BROWSER_API_BASE_URL="$BACKEND_URL/api" SERVER_API_BASE_URL="$BACKEND_URL/api" -a book-management-frontend
    
    # デプロイ
    fly deploy --dockerfile Dockerfile.fly -a book-management-frontend
  else
    log_info "新しいアプリケーションを作成します: book-management-frontend"
    
    # 非対話モードの場合、自動的に回答を提供
    if [ "$NON_INTERACTIVE" = true ]; then
      # 非対話モードでlaunchを実行
      echo -e "book-management-frontend\nnrt\nY\n" | fly launch --dockerfile Dockerfile.fly --no-deploy
    else
      # 対話モードでlaunchを実行
      fly launch --dockerfile Dockerfile.fly --no-deploy
    fi
    
    # 環境変数を設定
    fly secrets set BROWSER_API_BASE_URL="$BACKEND_URL/api" SERVER_API_BASE_URL="$BACKEND_URL/api" -a book-management-frontend
    
    # デプロイ
    fly deploy --dockerfile Dockerfile.fly -a book-management-frontend
  fi
fi

log_info "デプロイが完了しました！"
log_info "フロントエンド: https://book-management-frontend.fly.dev"
log_info "バックエンド: https://book-management-backend.fly.dev"