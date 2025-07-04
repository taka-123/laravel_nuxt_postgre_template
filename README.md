# Laravel + Nuxt + PostgreSQL テンプレート

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 17.x を使用したモダンなウェブアプリケーションテンプレートです。

> **テンプレートから作成されたプロジェクトの場合**: `[PROJECT_NAME]`部分がプロジェクト名に置き換わり、テンプレート固有の説明が削除されます。

## 🚀 クイックスタート

### テンプレートから新プロジェクトを作成（推奨）

```bash
# 1. GitHubで「Use this template」をクリック、または：
gh repo create my-new-project --template your-org/laravel-nuxt-template --private

# 2. クローンしてセットアップ（1コマンドで完了）
git clone https://github.com/your-org/my-new-project.git
cd my-new-project
./setup.sh my-new-project
```

### 直接クローンする場合

```bash
git clone https://github.com/your-org/laravel-nuxt-template.git my-project
cd my-project
./setup.sh my-project
```

**初回実行時**: テンプレートのカスタマイズ + 開発環境セットアップを自動実行  
**2 回目以降**: 開発環境セットアップのみ実行

## ✨ テンプレートの特徴

- **最新技術スタック**: Laravel 12、Nuxt 3、PostgreSQL 17 を使用
- **アーキテクチャ**: フロントエンドとバックエンドを分離した API ベースのアーキテクチャ
- **認証機能**: JWT を使用したトークンベースの認証
- **シンプルな実装**: 認証とダッシュボードによるフロント・バック・DB 連携のサンプル
- **TypeScript 対応**: Nuxt 3 プロジェクトでの最適化された TypeScript 設定
- **テスト環境**: PHPUnit と Vitest を使用したテスト環境
- **Docker 対応**: Docker Compose を使用した開発環境
- **CI/CD**: GitHub Actions を使用した自動テストとデプロイ
- **デプロイ設定**: Fly.io へのデプロイ設定済み
- **セキュリティ**: 安全なパスワードハッシュと CSRF 保護

## 📋 前提条件

- Docker Desktop (最新版)
- Node.js 22.x 以上
- PHP 8.2 以上
- Composer 2.x
- Git

### mise を使用した開発環境管理（オプション）

[mise](https://mise.jdx.dev/) を使用することで、Node.js と PHP のバージョンを簡単に管理できます：

```bash
# mise がインストールされている場合
mise install  # .mise.toml に記載されたツールを自動インストール

# volta、asdf、nodenv、phpenv など他のバージョン管理ツールとも共存可能
# mise を使わない場合は、上記の前提条件に従って手動でインストール
```

## 🔧 開発環境の起動

```bash
# Docker環境での起動（推奨）
docker compose up -d

# または、ローカル環境での起動
# バックエンド
cd backend && php artisan serve

# フロントエンド（別ターミナル）
cd frontend && npm run dev
```

> **開発環境用 Docker 設定**: フロントエンドには開発環境用の `Dockerfile.dev` が用意されており、ホットリロードやデバッグに最適化されています。

### アクセス URL

- **フロントエンド**: http://localhost:3000
- **バックエンド API**: http://localhost:8000
- **pgAdmin**: http://localhost:5050

## 📚 実装済みサンプル機能

このテンプレートには以下の機能が完全に実装されており、すぐに動作確認できます：

### ✅ 認証システム

- ユーザー登録・ログイン・ログアウト
- JWT トークンベース認証
- プロフィール画面

### ✅ UI/UX

- Vuetify Material Design
- レスポンシブ対応
- ローディング状態表示

## 🔧 開発ツールの設定

### テンプレート用の .gitignore 設定

このテンプレートでは、以下のツールがデフォルトで `.gitignore` に含まれています：

- **claude-parallel/**: Claude Code 並列開発環境ツール
- **.coderabbit.yaml**: CodeRabbit AI コードレビューツール設定
- **.cursor/**: Cursor IDE 設定
- **.windsurfrules**: Windsurf IDE 設定
- **mise.toml**: mise バージョン管理ツール設定

これらのツールをプロジェクトで使用したい場合は、`.gitignore` から該当行を削除してください：

```bash
# claude-parallelを使用する場合
# .gitignoreから以下の行を削除
# claude-parallel/

# CodeRabbitを使用する場合
# .gitignoreから以下の行を削除
# .coderabbit.yaml
# .coderabbit.yml

# Cursor IDEを使用する場合
# .gitignoreから以下の行を削除
# .cursor/

# Windsurf IDEを使用する場合
# .gitignoreから以下の行を削除
# .windsurfrules

# miseを使用する場合
# .gitignoreから以下の行を削除
# mise.toml
```

#### claude-parallel について

[claude-parallel](https://github.com/taka-123/claude-parallel) は、Git worktree と tmux を組み合わせた並列開発環境ツールです。チーム開発で使用する場合は、Git 管理に含めることで、チーム全体で同じ並列開発環境を共有できます。

#### CodeRabbit について

CodeRabbit は AI によるコードレビューツールです。プロジェクトで使用する場合は、設定ファイルをバージョン管理に含めることで、チーム全体で一貫したレビュー基準を維持できます。

## 📖 ドキュメント

### プロジェクト情報

- **[技術スタック](technologystack.md)** - 使用技術の詳細
- **[プロジェクト構造](directorystructure.md)** - ディレクトリ構成の説明

### 開発ガイド

- **[開発ガイド](docs/development.md)** - TypeScript 設定、API 設計、開発コマンド
- **[トラブルシューティング](docs/troubleshooting.md)** - よくある問題と解決方法

### デプロイ

- **[Fly.io デプロイガイド](docs/deployment/fly-io.md)** - Fly.io への詳細なデプロイ手順

### 開発フロー

- **[git-flow.md](git-flow.md)** - GitHub Issue 作成から PR マージまでの標準的なフロー

このガイドは参考として提供していますので、プロジェクトの規模やチームの状況に応じて自由にカスタマイズしてください。

### CLAUDE.md について

このテンプレートには `CLAUDE.md` というプロジェクト仕様書が含まれています。これは以下の理由で Git 管理されています：

- **プロジェクト固有の技術仕様や設計思想を記載**
- **新メンバーのオンボーディング資料として活用可能**
- **AI 開発ツール（Claude Code 等）との連携で開発効率向上**

ただし、以下の場合は削除または `.gitignore` への追加を検討してください：

- チームで AI 開発ツールを全く使用しない
- 技術ドキュメントとしてメンテナンスする予定がない
- README.md で十分な情報が提供されている

```bash
# CLAUDE.mdを使用しない場合
# .gitignoreに追加
echo "CLAUDE.md" >> .gitignore

# または削除
rm CLAUDE.md
```

## 🤝 貢献

プロジェクトへの貢献を歓迎します。Pull Request や Issue の報告をお待ちしています。

## 📄 ライセンス

MIT License
