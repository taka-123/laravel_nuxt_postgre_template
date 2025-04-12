# 書籍管理システム

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 16.x を使用した書籍管理システムです。

## 開発環境のセットアップ

### 前提条件

- Docker Desktop がインストールされていること
- Node.js 18.0 以上がインストールされていること
- Git がインストールされていること
- Composer がインストールされていること（オプション、Docker 内で実行も可）

### ポート設定

| サービス               | ポート |
| ---------------------- | ------ |
| Laravel バックエンド   | 8000   |
| Nuxt.js フロントエンド | 3000   |
| PostgreSQL             | 5432   |
| pgAdmin                | 5050   |

## 開発サーバーの起動

### Dockerを使用した起動（推奨）

1. Docker Desktopを起動します
2. 以下のコマンドを実行します：

```bash
docker compose up -d --build
```

### 個別の起動方法

#### バックエンド（Laravel）の起動

```bash
cd backend
php artisan serve
```

#### フロントエンド（Nuxt.js）の起動

```bash
cd frontend
npm run dev
```

## テストユーザー

- メールアドレス: test@example.com
- パスワード: password

## 本番環境へのデプロイ

本番環境へのデプロイ方法については、[Nuxtのデプロイメントドキュメント](https://nuxt.com/docs/getting-started/deployment)を参照してください。
