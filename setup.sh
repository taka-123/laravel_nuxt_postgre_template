#!/bin/bash

# Laravel + Nuxt + PostgreSQL テンプレート統合セットアップスクリプト
# 使用方法:
#   ./setup.sh [プロジェクト名]           - テンプレートカスタマイズ + 開発環境セットアップ
#   ./setup.sh [プロジェクト名] --setup-only - 開発環境セットアップのみ
#   ./setup.sh                           - 開発環境セットアップのみ
#
# 機能:
# - プロジェクト名指定時: テンプレートのカスタマイズ + 開発環境セットアップ（冪等性確保）
# - プロジェクト名なしまたは--setup-onlyフラグ: 開発環境セットアップのみ

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 実行モードの判定（引数解析を最初に実行）
# --setup-onlyフラグの確認（第1引数または第2引数どちらでも対応）
SETUP_ONLY=false
if [ "$1" = "--setup-only" ] || [ "$2" = "--setup-only" ]; then
  SETUP_ONLY=true
fi

# プロジェクト名の取得（--setup-onlyフラグを除外）
if [ "$SETUP_ONLY" = true ] && [ "$1" = "--setup-only" ]; then
  # 第1引数が--setup-onlyの場合はデフォルト名を使用
  PROJECT_NAME="$(basename "$PWD")"
elif [ "$SETUP_ONLY" = true ] && [ "$2" = "--setup-only" ]; then
  # 第2引数が--setup-onlyの場合は第1引数をプロジェクト名として使用
  PROJECT_NAME="${1:-$(basename "$PWD")}"
else
  # 通常の場合
  PROJECT_NAME="${1:-$(basename "$PWD")}"
fi

PROJECT_NAME_HYPHEN="${PROJECT_NAME}"
PROJECT_NAME_UNDERSCORE=$(echo "${PROJECT_NAME}" | tr '-' '_')

# 関数: sed用の特殊文字エスケープ
_escape_sed() {
  printf '%s' "$1" | sed -e 's#[&|/\\@]#\\&#g'
}

# sed置換用にエスケープされた変数
PROJECT_NAME_ESCAPED=$(_escape_sed "$PROJECT_NAME")
PROJECT_NAME_HYPHEN_ESCAPED=$(_escape_sed "$PROJECT_NAME_HYPHEN")
PROJECT_NAME_UNDERSCORE_ESCAPED=$(_escape_sed "$PROJECT_NAME_UNDERSCORE")

# テンプレートカスタマイズの実行判定
# プロジェクト名が指定され、かつ--setup-onlyフラグがない場合のみカスタマイズを実行
if [ -n "$1" ] && [ "$1" != "--setup-only" ] && [ "$SETUP_ONLY" != true ]; then
  CUSTOMIZE_TEMPLATE=true
else
  CUSTOMIZE_TEMPLATE=false
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
if [ "$CUSTOMIZE_TEMPLATE" = true ]; then
  section "Laravel + Nuxt テンプレートカスタマイズ"
  echo -e "プロジェクト名: ${BLUE}${PROJECT_NAME}${NC}"
  echo -e "実行内容: ${YELLOW}テンプレートカスタマイズ + 開発環境セットアップ${NC}"
else
  section "Laravel + Nuxt 開発環境セットアップ"
  echo -e "プロジェクト名: ${BLUE}${PROJECT_NAME}${NC}"
  echo -e "実行内容: ${YELLOW}開発環境セットアップのみ${NC}"
fi
echo ""

# ===========================================
# テンプレートカスタマイズ
# ===========================================

if [ "$CUSTOMIZE_TEMPLATE" = true ]; then
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
    "docs/development.md"
    "directorystructure.md"
    ".github/workflows/ci.yml"
    ".github/workflows/deploy-ecs-production.yml.disabled"
    "frontend/layouts/default.vue"
    "frontend/.env.example"
    "backend/.env.example"
    ".aws/scripts/deploy-infrastructure.sh"
    ".aws/scripts/delete-infrastructure.sh"
  )

  # 包括的なプレースホルダー置換関数
  replace_placeholders() {
    local file="$1"
    # ファイルの存在チェック（ディレクトリや壊れたシンボリックリンクを除外）
    if [ ! -f "$file" ]; then
      warning "ファイルが見つかりません: $file"
      return
    fi

    info "プレースホルダーを置換中: $file"

    # 冪等性を確保するため、元のテンプレート名と既存のプロジェクト名の両方に対応
    # 注意：より具体的なパターンを先に実行して、一般的なパターンによる誤置換を防ぐ
    sed -i.bak \
      -e "s|laravel-nuxt-template-frontend-dev|${PROJECT_NAME_HYPHEN_ESCAPED}-frontend-dev|g" \
      -e "s|laravel-nuxt-template-backend-staging-unique|${PROJECT_NAME_HYPHEN_ESCAPED}-backend-staging-unique|g" \
      -e "s|laravel-nuxt-template-frontend-staging-unique|${PROJECT_NAME_HYPHEN_ESCAPED}-frontend-staging-unique|g" \
      -e "s|laravel-nuxt-template-db-staging-unique|${PROJECT_NAME_HYPHEN_ESCAPED}-db-staging-unique|g" \
      -e "s|laravel-nuxt-template-db-unique|${PROJECT_NAME_HYPHEN_ESCAPED}-db-unique|g" \
      -e "s|laravel-nuxt-template-pgsql-main|${PROJECT_NAME_HYPHEN_ESCAPED}-pgsql-main|g" \
      -e "s|laravel_nuxt_template_storage_stg|${PROJECT_NAME_UNDERSCORE_ESCAPED}_storage_stg|g" \
      -e "s|laravel_nuxt_template_storage|${PROJECT_NAME_UNDERSCORE_ESCAPED}_storage|g" \
      -e "s|laravel_nuxt_template_staging|${PROJECT_NAME_UNDERSCORE_ESCAPED}_staging|g" \
      -e "s|laravel_nuxt_template_user|${PROJECT_NAME_UNDERSCORE_ESCAPED}_user|g" \
      -e "s|laravel_nuxt_session|${PROJECT_NAME_UNDERSCORE_ESCAPED}_session|g" \
      -e "s|laravel-nuxt-template-frontend|${PROJECT_NAME_HYPHEN_ESCAPED}-frontend|g" \
      -e "s|laravel-nuxt-template-backend|${PROJECT_NAME_HYPHEN_ESCAPED}-backend|g" \
      -e "s|laravel-nuxt-template/backend|${PROJECT_NAME_HYPHEN_ESCAPED}/backend|g" \
      -e "s|laravel_nuxt_template|${PROJECT_NAME_UNDERSCORE_ESCAPED}|g" \
      -e "s|laravel-nuxt-template|${PROJECT_NAME_HYPHEN_ESCAPED}|g" \
      "$file"

    rm -f "$file.bak"

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
    sed -i.bak "s@Laravel + Nuxt + PostgreSQL テンプレート@${PROJECT_NAME_HYPHEN_ESCAPED}@g" README.md
    sed -i.bak "s@Laravel 12\\.x + Nuxt\\.js 3\\.16 + PostgreSQL 17\\.x を使用したモダンなウェブアプリケーションテンプレートです\\.@${PROJECT_NAME_HYPHEN_ESCAPED} - Laravel + Nuxt.js アプリケーション@g" README.md
    sed -i.bak "s@\\[PROJECT_NAME\\]@${PROJECT_NAME_HYPHEN_ESCAPED}@g" README.md
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
    # GitHub テンプレート使用例の置換
    sed -i.bak "s@--template your-org/laravel-nuxt-template@--template your-org/${PROJECT_NAME_HYPHEN_ESCAPED}@g" README.md
    # git clone 例の置換
    sed -i.bak "s@laravel-nuxt-template\\.git@${PROJECT_NAME_HYPHEN_ESCAPED}.git@g" README.md
    rm -f README.md.bak
    success "README.mdの特別処理が完了しました"
  fi

  # CLAUDE.mdの特別処理
  if [ -f "CLAUDE.md" ]; then
    info "CLAUDE.mdを更新中..."
    # プロジェクト名のタイトル更新
    sed -i.bak "s@# プロジェクト名@# ${PROJECT_NAME_HYPHEN_ESCAPED}@g" CLAUDE.md
    # プロジェクト概要の更新
    sed -i.bak "s@Laravel 12\\.x + Nuxt\\.js 3\\.16 + PostgreSQL 17\\.x を使用したモダンなフルスタック Web アプリケーションテンプレート@${PROJECT_NAME_HYPHEN_ESCAPED} - Laravel + Nuxt.js フルスタック Web アプリケーション@g" CLAUDE.md
    # データベース名の更新
    sed -i.bak "s@データベース: laravel_nuxt_template@データベース: ${PROJECT_NAME_UNDERSCORE_ESCAPED}@g" CLAUDE.md
    # テンプレート関連の説明を調整
    sed -i.bak 's/テンプレート/プロジェクト/g' CLAUDE.md
    rm -f CLAUDE.md.bak
    success "CLAUDE.mdの特別処理が完了しました"
  fi

  # README_aws.mdの特別処理
  if [ -f "README_aws.md" ]; then
    info "README_aws.mdを更新中..."
    sed -i.bak "s@Laravel + Nuxt + PostgreSQL テンプレート@${PROJECT_NAME_HYPHEN_ESCAPED}@g" README_aws.md
    sed -i.bak "s@ECR_REPOSITORY: laravel-nuxt-template@ECR_REPOSITORY: ${PROJECT_NAME_HYPHEN_ESCAPED}@g" README_aws.md
    sed -i.bak 's/テンプレート/プロジェクト/g' README_aws.md
    rm -f README_aws.md.bak
    success "README_aws.mdの特別処理が完了しました"
  fi

  # backend/.env.exampleの特別処理
  if [ -f "backend/.env.example" ]; then
    info "backend/.env.exampleを更新中..."
    # より安全な置換：コメントを保持しながらAPP_NAME値のみを置換
    sed -i.bak "s@^APP_NAME=\"[^\"]*\"@APP_NAME=\"${PROJECT_NAME_ESCAPED}\"@g" backend/.env.example
    rm -f backend/.env.example.bak
    success "backend/.env.exampleの特別処理が完了しました"
  fi

  # frontend/.env.exampleの特別処理
  if [ -f "frontend/.env.example" ]; then
    info "frontend/.env.exampleを更新中..."
    # より安全な置換：コメントと引用符を保持しながらAPP_NAME値のみを置換
    # パターン1: APP_NAME="値" の形式（引用符付き）
    sed -i.bak "s@^APP_NAME=\"[^\"]*\"@APP_NAME=\"${PROJECT_NAME_ESCAPED}\"@g" frontend/.env.example
    # パターン2: APP_NAME=値 の形式（引用符なし、コメントまたはEOLまで、末尾空白を削除）
    sed -i.bak "s@^APP_NAME=[^#]*@APP_NAME=${PROJECT_NAME_ESCAPED}@g" frontend/.env.example
    rm -f frontend/.env.example.bak
    success "frontend/.env.exampleの特別処理が完了しました"
  fi

  # .github/workflows/ci.ymlの特別処理
  if [ -f ".github/workflows/ci.yml" ]; then
    info ".github/workflows/ci.ymlを更新中..."
    # PostgreSQL データベース名の置換（テスト用）
    sed -i.bak "s@POSTGRES_DB: laravel_nuxt_template_testing@POSTGRES_DB: ${PROJECT_NAME_UNDERSCORE_ESCAPED}_testing@g" .github/workflows/ci.yml
    # sed コマンド内のデータベース名置換
    sed -i.bak "s@DB_DATABASE=laravel_nuxt_template@DB_DATABASE=${PROJECT_NAME_UNDERSCORE_ESCAPED}@g" .github/workflows/ci.yml
    rm -f .github/workflows/ci.yml.bak
    success ".github/workflows/ci.ymlの特別処理が完了しました"
  fi

  # frontend/layouts/default.vueの特別処理
  if [ -f "frontend/layouts/default.vue" ]; then
    info "frontend/layouts/default.vueを更新中..."
    # より安全で精密な置換（HTML属性を保護）
    sed -i.bak "s@<title>Laravel Nuxt Template</title>@<title>${PROJECT_NAME_HYPHEN_ESCAPED}</title>@g" frontend/layouts/default.vue
    sed -i.bak "s@<title>[^<]*</title>@<title>${PROJECT_NAME_HYPHEN_ESCAPED}</title>@g" frontend/layouts/default.vue
    # アプリ名の置換（冪等性を考慮してバーコンテンツのみを対象）
    sed -i.bak "s@<v-app-bar-title>Laravel Nuxt Template</v-app-bar-title>@<v-app-bar-title>${PROJECT_NAME_HYPHEN_ESCAPED}</v-app-bar-title>@g" frontend/layouts/default.vue
    sed -i.bak "s@<v-app-bar-title>[^<]*</v-app-bar-title>@<v-app-bar-title>${PROJECT_NAME_HYPHEN_ESCAPED}</v-app-bar-title>@g" frontend/layouts/default.vue
    # スパン内のテンプレート名も置換（完全な要素マッチ）
    sed -i.bak "s@<span class=\"d-none d-sm-block\">Laravel Nuxt Template</span>@<span class=\"d-none d-sm-block\">${PROJECT_NAME_HYPHEN_ESCAPED}</span>@g" frontend/layouts/default.vue
    sed -i.bak "s@<span class=\"d-none d-sm-block\">[^<]*</span>@<span class=\"d-none d-sm-block\">${PROJECT_NAME_HYPHEN_ESCAPED}</span>@g" frontend/layouts/default.vue
    # ハードコードされた略称を変更（プロジェクト名の頭文字に基づく）
    PROJECT_INITIALS=$(echo "${PROJECT_NAME}" | sed 's/[^A-Za-z]/ /g' | awk '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1))}')
    # 空文字列の場合はデフォルト値を使用
    if [ -z "$PROJECT_INITIALS" ]; then
      PROJECT_INITIALS="APP"
    fi
    sed -i.bak "s/>LNT</>$PROJECT_INITIALS</g" frontend/layouts/default.vue
    rm -f frontend/layouts/default.vue.bak
    success "frontend/layouts/default.vueの特別処理が完了しました"
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

  # 置換数を動的に計算
  total_files=${#TEMPLATE_FILES[@]}
  success "🎉 全${total_files}ファイルのプレースホルダー置換が完了しました！"
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

# 開発環境の準備完了
success "開発環境の準備が完了しました"

# セットアップ完了

# 完了メッセージ
echo ""
section "🎉 セットアップ完了"

if [ "$CUSTOMIZE_TEMPLATE" = true ]; then
  echo -e "${GREEN}テンプレートのカスタマイズと開発環境の準備が完了しました！${NC}"
else
  echo -e "${GREEN}開発環境の準備が完了しました！${NC}"
fi

echo ""
info "🚀 次のコマンドでDockerコンテナを起動してください："
echo -e "${CYAN}${DOCKER_COMPOSE} up -d${NC}"
echo ""
info "💡 初回起動について："
echo "- 初回はイメージビルドで数分かかります"
echo "- 進捗確認: ${DOCKER_COMPOSE} logs -f"
echo "- 起動完了まで待機してください"
echo ""
echo "🌐 起動後のアプリケーションURL："
echo "- フロントエンド: http://localhost:3000"
echo "- バックエンド API: http://localhost:8000"
echo "- pgAdmin: http://localhost:5050"
echo ""
echo "👤 テストユーザー："
echo "- 管理者: admin@example.com / password"
echo "- ユーザー: test@example.com / password"
echo ""
echo "🔧 開発コマンド："
echo "- バックエンドログ: ${DOCKER_COMPOSE} logs -f backend"
echo "- フロントエンドログ: ${DOCKER_COMPOSE} logs -f frontend"
echo "- 環境停止: ${DOCKER_COMPOSE} down"
echo ""
info "💡 ヒント："
echo "- WWWUSER/WWWGROUPは backend/.env に自動設定済み"
echo "- 環境変数の警告は表示されません"
echo ""
info "起動確認スクリプト："
echo "- 起動状態確認: ${DOCKER_COMPOSE} ps"
echo "- サービス準備完了まで待機: ${DOCKER_COMPOSE} logs -f | grep -E \"(ready|listening|started)\""
echo ""
success "Happy coding! 🚀"
