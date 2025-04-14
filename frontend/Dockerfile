# ベースイメージとして Node.js 22 を使用
FROM node:22-alpine AS base

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係をインストールするためのファイルをコピー
COPY package.json yarn.lock* ./
# If you have package-lock.json, copy that instead of yarn.lock
# COPY package.json package-lock.json* ./

# 依存関係をインストール
RUN yarn install --frozen-lockfile

# アプリケーションコードをコピー
COPY . .

# Nuxt アプリケーションをビルド
RUN yarn build

# 公開ポートを指定
EXPOSE 3000

# アプリケーションを実行（開発環境）
CMD ["yarn", "dev"]
