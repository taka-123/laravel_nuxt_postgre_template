#!/bin/bash

# Laravel + Nuxt + PostgreSQL テンプレート統合セットアップスクリプト
# 使用方法: ./setup.sh [プロジェクト名]
#
# 機能:
# - 初回実行時: テンプレートのカスタマイズ + 開発環境セットアップ
# - 2回目以降: 開発環境セットアップのみ

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# プロジェクト名の取得
PROJECT_NAME="${1:-$(basename "$PWD")}"

# 初回実行かどうかの判定
IS_FIRST_RUN=false
if [ ! -f ".setup-completed" ]; then
  IS_FIRST_RUN=true
fi

# 関数: 成功メッセージ
success() {
  echo -e "${GREEN}✓ $1${NC}"
}

# 関数: 警告メッセージ
warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

# 関数: エラーメッセージ
error() {
  echo -e "${RED}✗ $1${NC}"
  exit 1
}

# 関数: 進行状況メッセージ
info() {
  echo -e "${BLUE}🔄 $1${NC}"
}

# 関数: セクションヘッダー
section() {
  echo -e "${CYAN}=====================================================${NC}"
  echo -e "${CYAN}  $1${NC}"
  echo -e "${CYAN}=====================================================${NC}"
  echo ""
}

# メインヘッダー
if [ "$IS_FIRST_RUN" = true ]; then
  section "Laravel + Nuxt テンプレート初期化"
  echo -e "プロジェクト名: ${BLUE}${PROJECT_NAME}${NC}"
  echo -e "実行内容: ${YELLOW}テンプレートカスタマイズ + 開発環境セットアップ${NC}"
else
  section "Laravel + Nuxt 開発環境セットアップ"
  echo -e "プロジェクト名: ${BLUE}${PROJECT_NAME}${NC}"
  echo -e "実行内容: ${YELLOW}開発環境セットアップのみ${NC}"
fi
echo ""

# ===========================================
# テンプレートカスタマイズ（初回のみ）
# ===========================================

if [ "$IS_FIRST_RUN" = true ]; then
  section "📝 テンプレートのカスタマイズ"

  # Gitの初期化（テンプレートの履歴をクリア）
  if [ -d ".git" ] && [ -f "template-setup.sh" ]; then
    info "Git履歴をクリアして新しいリポジトリを初期化..."
    rm -rf .git
    git init
    git add .
    git commit -m "feat: initialize project from template"
    success "Gitリポジトリを初期化しました"
  fi

  # README.mdの更新
  info "README.mdを更新中..."
  if [ -f "README.md" ]; then
    # プロジェクト名の置換
    sed -i.bak "s/\[PROJECT_NAME\]/${PROJECT_NAME}/g" README.md
    # テンプレート固有の説明を削除
    sed -i.bak '/> \*\*テンプレートから作成されたプロジェクトの場合\*\*/,+1d' README.md
    sed -i.bak '/### テンプレートから新プロジェクトを作成（推奨）/,/^### 直接クローンする場合$/c\
## 🚀 クイックスタート\
\
```bash\
# 開発環境をセットアップ\
./setup.sh\
```' README.md
    sed -i.bak '/### 直接クローンする場合/,/```$/d' README.md
    rm -f README.md.bak
    success "README.mdを更新しました"
  fi

  # package.jsonファイルの更新
  info "プロジェクト設定ファイルを更新中..."

  # フロントエンド package.json
  if [ -f "frontend/package.json" ]; then
    sed -i.bak "s/\"name\": \".*\"/\"name\": \"${PROJECT_NAME}-frontend\"/" frontend/package.json
    sed -i.bak "s/\"description\": \".*\"/\"description\": \"${PROJECT_NAME} frontend application\"/" frontend/package.json
    rm -f frontend/package.json.bak
    success "フロントエンド package.json を更新しました"
  fi

  # バックエンド package.json
  if [ -f "backend/package.json" ]; then
    sed -i.bak "s/\"name\": \".*\"/\"name\": \"${PROJECT_NAME}-backend\"/" backend/package.json
    sed -i.bak "s/\"description\": \".*\"/\"description\": \"${PROJECT_NAME} backend application\"/" backend/package.json
    rm -f backend/package.json.bak
    success "バックエンド package.json を更新しました"
  fi

  # composer.json の更新
  if [ -f "backend/composer.json" ]; then
    sed -i.bak "s/\"name\": \".*\"/\"name\": \"${PROJECT_NAME}\/backend\"/" backend/composer.json
    sed -i.bak "s/\"description\": \".*\"/\"description\": \"${PROJECT_NAME} のバックエンド部分\"/" backend/composer.json
    rm -f backend/composer.json.bak
    success "バックエンド composer.json を更新しました"
  fi

  # Docker Compose設定の更新
  if [ -f "docker-compose.yml" ]; then
    sed -i.bak "s/container_name: .*-/container_name: ${PROJECT_NAME}-/g" docker-compose.yml
    rm -f docker-compose.yml.bak
    success "Docker Compose設定を更新しました"
  fi

  # template-setup.shを削除
  if [ -f "template-setup.sh" ]; then
    rm -f template-setup.sh
    success "テンプレート設定スクリプトを削除しました"
  fi

  echo ""
fi

# ===========================================
# 開発環境セットアップ
# ===========================================

section "🚀 開発環境セットアップ"

# 環境チェック
info "必要なソフトウェアの確認中..."

# Dockerのチェック
if ! command -v docker &>/dev/null; then
  error "Docker がインストールされていません。https://docs.docker.com/get-docker/ からインストールしてください。"
fi
success "Docker が見つかりました"

# Docker Composeのチェック
if ! command -v docker-compose &>/dev/null; then
  error "Docker Compose がインストールされていません。https://docs.docker.com/compose/install/ からインストールしてください。"
fi
success "Docker Compose が見つかりました"

# .envファイルの設定
info "環境設定ファイルの準備中..."

# バックエンド .env ファイルの設定
if [ ! -f "./backend/.env" ]; then
  if [ -f "./backend/.env.example" ]; then
    cp ./backend/.env.example ./backend/.env
    # アプリケーション名の設定
    sed -i.bak "s/APP_NAME=.*/APP_NAME=\"${PROJECT_NAME}\"/" ./backend/.env
    rm -f ./backend/.env.bak
    success "バックエンド .env ファイルを作成しました"
  else
    warning "backend/.env.example が見つかりません。手動で .env ファイルを作成してください。"
  fi
else
  warning "バックエンド .env ファイルはすでに存在します。スキップします"
fi

# フロントエンド .env ファイルの設定
if [ ! -f "./frontend/.env" ]; then
  if [ -f "./frontend/.env.example" ]; then
    cp ./frontend/.env.example ./frontend/.env
    success "フロントエンド .env ファイルを作成しました"
  else
    warning "frontend/.env.example が見つかりません。手動で .env ファイルを作成してください。"
  fi
else
  warning "フロントエンド .env ファイルはすでに存在します。スキップします"
fi

# Dockerコンテナの起動
info "Dockerコンテナを起動中..."
docker-compose up -d || error "Dockerコンテナの起動に失敗しました"
success "Dockerコンテナを起動しました"

# バックエンドの依存関係インストール
info "バックエンドの依存関係をインストール中..."
docker-compose exec backend composer install || warning "Composerインストールに問題が発生しました"
success "バックエンドの依存関係をインストールしました"

# アプリケーションキーの生成
info "Laravelアプリケーションキーを生成中..."
docker-compose exec backend php artisan key:generate || warning "アプリケーションキーの生成に問題が発生しました"
success "アプリケーションキーを生成しました"

# データベースマイグレーション
info "データベースマイグレーションを実行中..."
docker-compose exec backend php artisan migrate || warning "マイグレーションに問題が発生しました"
success "データベースマイグレーションを実行しました"

# シードデータの投入
info "初期データを投入中..."
docker-compose exec backend php artisan db:seed || warning "シードデータの投入に問題が発生しました"
success "初期データを投入しました"

# フロントエンドの依存関係インストール
info "フロントエンドの依存関係をインストール中..."
docker-compose exec frontend yarn install || warning "Yarnインストールに問題が発生しました"
success "フロントエンドの依存関係をインストールしました"

# セットアップ完了フラグの作成
touch .setup-completed

# 完了メッセージ
echo ""
section "🎉 セットアップ完了"

if [ "$IS_FIRST_RUN" = true ]; then
  echo -e "${GREEN}テンプレートのカスタマイズと開発環境のセットアップが完了しました！${NC}"
else
  echo -e "${GREEN}開発環境のセットアップが完了しました！${NC}"
fi

echo ""
echo "🌐 アプリケーションURL："
echo "- フロントエンド: http://localhost:3000"
echo "- バックエンド API: http://localhost:8000"
echo "- pgAdmin: http://localhost:5050"
echo ""
echo "👤 テストユーザー："
echo "- メールアドレス: test@example.com"
echo "- パスワード: password"
echo ""
echo "🔧 開発コマンド："
echo "- バックエンドログ: docker-compose logs -f backend"
echo "- フロントエンドログ: docker-compose logs -f frontend"
echo "- 環境停止: docker-compose down"
echo ""
echo "Happy coding! 🚀"
