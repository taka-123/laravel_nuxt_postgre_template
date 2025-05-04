# ==================
# = ビルドステージ =
# ==================
ARG NODE_VERSION=22

# ビルダーイメージ (開発依存関係を含む)
FROM node:${NODE_VERSION} AS builder

# 作業ディレクトリを設定
WORKDIR /app

# パッケージマネージャーがyarnなのでyarnを使用
# package.json のみを先にコピー（.dockerignore により yarn.lock は除外される）
COPY package.json ./

# 依存関係をインストール (yarn.lock がなければ生成される)
RUN yarn install

# アプリケーションコードをコピー
COPY . .

# 環境変数の設定（ビルド時に使用）
ARG BROWSER_API_BASE_URL
ENV BROWSER_API_BASE_URL=${BROWSER_API_BASE_URL:-http://localhost:8000/api}
ARG SERVER_API_BASE_URL
ENV SERVER_API_BASE_URL=${SERVER_API_BASE_URL:-http://backend:80/api}
ARG NODE_ENV
ENV NODE_ENV=${NODE_ENV:-production}
ENV HOST=0.0.0.0

# Nuxt アプリケーションをビルド
RUN yarn build

# ===================
# = 実行ステージ =
# ===================
FROM nginx:stable-alpine AS production

# Nginxの設定
COPY docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# ビルドステージから静的ファイルをコピー
COPY --from=builder /app/.output/public /usr/share/nginx/html

# Nginxを非rootユーザーで実行するための設定
RUN chown -R nginx:nginx /usr/share/nginx/html && \
  chown -R nginx:nginx /var/cache/nginx && \
  chown -R nginx:nginx /var/log/nginx && \
  chown -R nginx:nginx /etc/nginx/conf.d && \
  touch /var/run/nginx.pid && \
  chown -R nginx:nginx /var/run/nginx.pid

# セキュリティのためにrootユーザーではなくnginxユーザーで実行
USER nginx

# ヘルスチェック用のファイル
RUN echo "OK" > /usr/share/nginx/html/health.txt

# 公開ポートを指定
EXPOSE 8080

# コンテナのヘルスチェック設定
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost:8080/health.txt || exit 1

# Nginxを起動
CMD ["nginx", "-g", "daemon off;"]
