#!/bin/bash

# Laravel + Nuxt + PostgreSQL テンプレート初期セットアップスクリプト
# 使用方法: ./setup.sh

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
  echo -e "🔄 $1"
}

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
  cp ./backend/.env.example ./backend/.env
  success "バックエンド .env ファイルを作成しました"
else
  warning "バックエンド .env ファイルはすでに存在します。スキップします"
fi

# フロントエンド .env ファイルの設定
if [ ! -f "./frontend/.env" ]; then
  cp ./frontend/.env.example ./frontend/.env
  success "フロントエンド .env ファイルを作成しました"
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

# 完了メッセージ
echo ""
echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}  セットアップが完了しました！${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo ""
echo "以下のURLでアプリケーションにアクセスできます："
echo "- バックエンドAPI: http://localhost:8000"
echo "- フロントエンド: http://localhost:3000"
echo ""
echo "テストユーザー："
echo "- メールアドレス: test@example.com"
echo "- パスワード: password"
echo ""
echo "開発を開始するには以下のコマンドを使用してください："
echo "- バックエンドのログを表示: docker-compose logs -f backend"
echo "- フロントエンドのログを表示: docker-compose logs -f frontend"
echo ""
echo "Happy coding! 🚀"
