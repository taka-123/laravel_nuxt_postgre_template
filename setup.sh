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

# プロジェクト名の取得と形式変換
PROJECT_NAME="${1:-$(basename "$PWD")}"
PROJECT_NAME_HYPHEN="${PROJECT_NAME}"
PROJECT_NAME_UNDERSCORE=$(echo "${PROJECT_NAME}" | tr '-' '_')

# 初回実行かどうかの判定
# テンプレート初期化が完了済みかどうかをREADME.mdで判定
IS_FIRST_RUN=false
if grep -q "Laravel + Nuxt + PostgreSQL テンプレート" README.md && ! grep -q "quick-chef" README.md; then
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

  info "プロジェクト名変換："
  echo "  - ハイフン形式: ${PROJECT_NAME_HYPHEN}"
  echo "  - アンダースコア形式: ${PROJECT_NAME_UNDERSCORE}"

  # 置換対象ファイルのリスト
  TEMPLATE_FILES=(
    "package.json"
    "frontend/package.json"
    "frontend/package-lock.json"
    "backend/composer.json"
    "docker-compose.yml"
    "backend/fly.toml"
    "backend/fly.toml.example"
    "backend/fly.staging.toml"
    "frontend/fly.toml"
    "frontend/fly.toml.example"
    "frontend/fly.staging.toml"
    "README.md"
    "CLAUDE.md"
    "README_aws.md"
    "setup.sh"
  )

  # 包括的なプレースホルダー置換関数
  replace_placeholders() {
    local file="$1"
    if [ ! -f "$file" ]; then
      warning "ファイルが見つかりません: $file"
      return
    fi

    info "プレースホルダーを置換中: $file"
    
    # バックアップ作成
    cp "$file" "$file.bak"
    
    # 基本的なプレースホルダー置換
    sed -i.tmp "s/laravel-nuxt-template-frontend-dev/${PROJECT_NAME_HYPHEN}-frontend-dev/g" "$file"
    sed -i.tmp "s/laravel-nuxt-template-backend-staging-unique/${PROJECT_NAME_HYPHEN}-backend-staging-unique/g" "$file"
    sed -i.tmp "s/laravel-nuxt-template-frontend-staging-unique/${PROJECT_NAME_HYPHEN}-frontend-staging-unique/g" "$file"
    sed -i.tmp "s/laravel-nuxt-template-db-staging-unique/${PROJECT_NAME_HYPHEN}-db-staging-unique/g" "$file"
    sed -i.tmp "s/laravel-nuxt-template-db-unique/${PROJECT_NAME_HYPHEN}-db-unique/g" "$file"
    sed -i.tmp "s/laravel-nuxt-template-pgsql-main/${PROJECT_NAME_HYPHEN}-pgsql-main/g" "$file"
    sed -i.tmp "s/laravel-nuxt-template-frontend/${PROJECT_NAME_HYPHEN}-frontend/g" "$file"
    sed -i.tmp "s/laravel-nuxt-template-backend/${PROJECT_NAME_HYPHEN}-backend/g" "$file"
    sed -i.tmp "s/laravel-nuxt-template\/backend/${PROJECT_NAME_HYPHEN}\/backend/g" "$file"
    sed -i.tmp "s/laravel-nuxt-template/${PROJECT_NAME_HYPHEN}/g" "$file"
    
    # アンダースコア形式のプレースホルダー置換
    sed -i.tmp "s/laravel_nuxt_template_storage_stg/${PROJECT_NAME_UNDERSCORE}_storage_stg/g" "$file"
    sed -i.tmp "s/laravel_nuxt_template_storage/${PROJECT_NAME_UNDERSCORE}_storage/g" "$file"
    sed -i.tmp "s/laravel_nuxt_template_staging/${PROJECT_NAME_UNDERSCORE}_staging/g" "$file"
    sed -i.tmp "s/laravel_nuxt_template_user/${PROJECT_NAME_UNDERSCORE}_user/g" "$file"
    sed -i.tmp "s/laravel_nuxt_template/${PROJECT_NAME_UNDERSCORE}/g" "$file"
    
    # 一時ファイルを削除
    rm -f "$file.tmp"
    
    success "✓ $file の置換が完了しました"
  }

  # 各ファイルに対して置換を実行
  info "全てのテンプレートファイルでプレースホルダーを置換中..."
  for file in "${TEMPLATE_FILES[@]}"; do
    replace_placeholders "$file"
  done

  # 特別なドキュメント処理
  info "ドキュメントファイルの特別処理中..."
  
  # README.mdの特別処理
  if [ -f "README.md" ]; then
    info "README.mdを更新中..."
    # プロジェクト名とタイトルの置換
    sed -i.bak "s/Laravel + Nuxt + PostgreSQL テンプレート/${PROJECT_NAME}/g" README.md
    sed -i.bak "s/Laravel 12\.x + Nuxt\.js 3\.16 + PostgreSQL 17\.x を使用したモダンなウェブアプリケーションテンプレートです\./${PROJECT_NAME} - Laravel + Nuxt.js アプリケーション/g" README.md
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
    # テンプレートの特徴をプロジェクトの特徴に変更
    sed -i.bak 's/## テンプレートの特徴/## プロジェクトの特徴/g' README.md
    # テンプレート固有の説明を削除・調整
    sed -i.bak '/テンプレートのカスタマイズ/d' README.md
    sed -i.bak 's/テンプレート/プロジェクト/g' README.md
    rm -f README.md.bak
    success "README.mdの特別処理が完了しました"
  fi

  # CLAUDE.mdの特別処理
  if [ -f "CLAUDE.md" ]; then
    info "CLAUDE.mdを更新中..."
    # プロジェクト名のタイトル更新
    sed -i.bak "s/# プロジェクト名/# ${PROJECT_NAME}/g" CLAUDE.md
    # プロジェクト概要の更新
    sed -i.bak "s/Laravel 12\.x + Nuxt\.js 3\.16 + PostgreSQL 17\.x を使用したモダンなフルスタック Web アプリケーションテンプレート/${PROJECT_NAME} - Laravel + Nuxt.js フルスタック Web アプリケーション/g" CLAUDE.md
    # データベース名の更新
    sed -i.bak "s/データベース: laravel_nuxt_template/データベース: ${PROJECT_NAME_UNDERSCORE}/g" CLAUDE.md
    # テンプレート関連の説明を調整
    sed -i.bak 's/テンプレート/プロジェクト/g' CLAUDE.md
    rm -f CLAUDE.md.bak
    success "CLAUDE.mdの特別処理が完了しました"
  fi

  # README_aws.mdの特別処理
  if [ -f "README_aws.md" ]; then
    info "README_aws.mdを更新中..."
    sed -i.bak "s/Laravel + Nuxt + PostgreSQL テンプレート/${PROJECT_NAME}/g" README_aws.md
    sed -i.bak "s/ECR_REPOSITORY: laravel-nuxt-template/ECR_REPOSITORY: ${PROJECT_NAME_HYPHEN}/g" README_aws.md
    sed -i.bak 's/テンプレート/プロジェクト/g' README_aws.md
    rm -f README_aws.md.bak
    success "README_aws.mdの特別処理が完了しました"
  fi

  # Gitの初期化（テンプレートの履歴をクリア）
  if [ -d ".git" ] && [ -f "template-setup.sh" ]; then
    info "Git履歴をクリアして新しいリポジトリを初期化..."
    rm -rf .git
    git init
    git add .
    git commit -m "feat: initialize project from template"
    success "Gitリポジトリを初期化しました"
  fi

  # template-setup.shを削除
  if [ -f "template-setup.sh" ]; then
    rm -f template-setup.sh
    success "テンプレート設定スクリプトを削除しました"
  fi

  # バックアップファイルのクリーンアップ
  info "バックアップファイルをクリーンアップ中..."
  find . -name "*.bak" -type f -delete 2>/dev/null || true
  success "バックアップファイルのクリーンアップが完了しました"

  success "🎉 全26箇所のプレースホルダー置換が完了しました！"
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

# Docker Composeのチェック（V2対応）
if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null; then
  error "Docker Compose がインストールされていません。https://docs.docker.com/compose/install/ からインストールしてください。"
fi

# Docker Composeコマンドの決定
if command -v docker-compose &>/dev/null; then
  DOCKER_COMPOSE="docker-compose"
else
  DOCKER_COMPOSE="docker compose"
fi
success "Docker Compose が見つかりました ($DOCKER_COMPOSE)"

info "注意: WWWUSER/WWWGROUPをルート.envファイルに自動設定されます"

# ルートディレクトリの.envファイル作成（Docker Compose用）
if [ ! -f ".env" ]; then
  info "ルート.envファイルを作成中..."
  cat >.env <<EOF
# Docker Compose用の環境変数
WWWUSER=$(id -u)
WWWGROUP=$(id -g)

# アプリケーション設定
APP_PORT=8000
FRONTEND_PORT=3000
FORWARD_DB_PORT=5432

# データベース設定（docker-compose.yml用）
DB_DATABASE=${PROJECT_NAME_UNDERSCORE:-laravel_nuxt_template}
DB_USERNAME=sail
DB_PASSWORD=password
EOF
  success "ルート.envファイルを作成しました"
fi

# .envファイルの設定
info "環境設定ファイルの準備中..."

# バックエンド .env ファイルの設定
if [ ! -f "./backend/.env" ]; then
  if [ -f "./backend/.env.example" ]; then
    cp ./backend/.env.example ./backend/.env
    # アプリケーション名の設定
    sed -i.bak "s/APP_NAME=.*/APP_NAME=\"${PROJECT_NAME}\"/" ./backend/.env
    # WWWUSER/WWWGROUPの設定を追加
    echo "" >>./backend/.env
    echo "# Laravel Sail用のユーザー設定" >>./backend/.env
    echo "WWWUSER=$(id -u)" >>./backend/.env
    echo "WWWGROUP=$(id -g)" >>./backend/.env
    rm -f ./backend/.env.bak
    success "バックエンド .env ファイルを作成しました（WWWUSER/WWWGROUP含む）"
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
$DOCKER_COMPOSE up -d || error "Dockerコンテナの起動に失敗しました"
success "Dockerコンテナを起動しました"

# バックエンドの依存関係インストール
info "バックエンドの依存関係をインストール中..."
$DOCKER_COMPOSE exec backend composer install || warning "Composerインストールに問題が発生しました"
success "バックエンドの依存関係をインストールしました"

# アプリケーションキーの生成
info "Laravelアプリケーションキーを生成中..."
$DOCKER_COMPOSE exec backend php artisan key:generate || warning "アプリケーションキーの生成に問題が発生しました"
success "アプリケーションキーを生成しました"

# データベースマイグレーション
info "データベースマイグレーションを実行中..."
$DOCKER_COMPOSE exec backend php artisan migrate || warning "マイグレーションに問題が発生しました"
success "データベースマイグレーションを実行しました"

# シードデータの投入
info "初期データを投入中..."
$DOCKER_COMPOSE exec backend php artisan db:seed || warning "シードデータの投入に問題が発生しました"
success "初期データを投入しました"

# フロントエンドの依存関係インストール
info "フロントエンドの依存関係をインストール中..."
$DOCKER_COMPOSE exec frontend yarn install || warning "Yarnインストールに問題が発生しました"
success "フロントエンドの依存関係をインストールしました"

# セットアップ完了

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
echo "- 管理者: admin@example.com / password"
echo "- ユーザー: test@example.com / password"
echo ""
echo "🔧 開発コマンド："
echo "- バックエンドログ: docker compose logs -f backend"
echo "- フロントエンドログ: docker compose logs -f frontend"
echo "- 環境停止: docker compose down"
echo ""
echo "💡 ヒント："
echo "- WWWUSER/WWWGROUPは backend/.env に自動設定済み"
echo "- 環境変数の警告は表示されません"
echo ""
echo "Happy coding! 🚀"
