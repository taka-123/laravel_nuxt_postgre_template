<template>
  <div>
    <v-row>
      <v-col cols="12">
        <v-card class="mb-4">
          <v-card-title class="text-h4">
            Laravel + Nuxt + PostgreSQL テンプレート
          </v-card-title>
          <v-card-text>
            <p class="text-body-1">
              このテンプレートは、Laravel（バックエンド）、Nuxt（フロントエンド）、PostgreSQL（データベース）を使用したシンプルな認証システムのサンプルです。
            </p>
            <ClientOnly>
              <v-alert v-if="!isAuthenticated" type="info" class="mt-4">
                ダッシュボードを表示するには、ログインしてください。
              </v-alert>
            </ClientOnly>
          </v-card-text>
          <ClientOnly>
            <v-card-actions v-if="!isAuthenticated">
              <v-btn color="primary" to="/login" variant="elevated"
                >ログイン</v-btn
              >
              <v-btn
                color="secondary"
                to="/register"
                variant="outlined"
                class="ml-2"
                >新規登録</v-btn
              >
            </v-card-actions>
          </ClientOnly>
        </v-card>
      </v-col>
    </v-row>

    <!-- ログイン時のみ表示するダッシュボード -->
    <ClientOnly>
      <v-row v-if="isAuthenticated">
        <v-col cols="12">
          <v-card>
            <v-card-title class="text-h5">ダッシュボード</v-card-title>
            <v-card-text>
              <v-alert type="success" class="mb-4">
                ログインに成功しました！
              </v-alert>

              <h3 class="text-h6 mb-3">ユーザー情報</h3>
              <v-list>
                <v-list-item>
                  <v-list-item-title>名前</v-list-item-title>
                  <v-list-item-subtitle>{{ user?.name }}</v-list-item-subtitle>
                </v-list-item>
                <v-list-item>
                  <v-list-item-title>メールアドレス</v-list-item-title>
                  <v-list-item-subtitle>{{ user?.email }}</v-list-item-subtitle>
                </v-list-item>
                <v-list-item>
                  <v-list-item-title>登録日</v-list-item-title>
                  <v-list-item-subtitle>{{
                    formatDate(user?.created_at)
                  }}</v-list-item-subtitle>
                </v-list-item>
              </v-list>

              <v-divider class="my-4"></v-divider>

              <p class="text-body-2">
                これは、フロントエンド・バックエンド・データベースが正常に連携していることを示すシンプルなダッシュボードです。
              </p>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </ClientOnly>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const { isAuthenticated, user } = storeToRefs(authStore)

// 日付をフォーマット
const formatDate = (dateString?: string): string => {
  if (!dateString) return '未設定'
  return new Date(dateString).toLocaleDateString('ja-JP', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}
</script>
