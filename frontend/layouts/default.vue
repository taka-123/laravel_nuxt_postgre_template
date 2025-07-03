<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      <!-- レスポンシブなタイトル表示 -->
      <v-app-bar-title class="d-flex align-center">
        <NuxtLink
          to="/"
          class="text-decoration-none text-white d-flex align-center"
        >
          <span class="d-none d-sm-block">Laravel Nuxt Template</span>
          <span class="d-block d-sm-none">LNT</span>
        </NuxtLink>
      </v-app-bar-title>

      <v-spacer></v-spacer>

      <!-- デスクトップ用ナビゲーション -->
      <div class="d-none d-md-flex">
        <v-btn to="/" variant="text">ホーム</v-btn>
        <ClientOnly>
          <template v-if="isAuthenticated">
            <v-btn variant="text" @click="handleLogout">ログアウト</v-btn>
          </template>
          <template v-else>
            <v-btn to="/login" variant="text">ログイン</v-btn>
            <v-btn to="/register" variant="text">登録</v-btn>
          </template>
        </ClientOnly>
      </div>

      <!-- モバイル用ハンバーガーメニュー -->
      <v-menu class="d-flex d-md-none">
        <template #activator="{ props }">
          <v-btn icon v-bind="props">
            <v-icon>mdi-menu</v-icon>
          </v-btn>
        </template>
        <v-list>
          <v-list-item to="/">
            <v-list-item-title>ホーム</v-list-item-title>
          </v-list-item>
          <ClientOnly>
            <template v-if="isAuthenticated">
              <v-list-item @click="handleLogout">
                <v-list-item-title>ログアウト</v-list-item-title>
              </v-list-item>
            </template>
            <template v-else>
              <v-list-item to="/login">
                <v-list-item-title>ログイン</v-list-item-title>
              </v-list-item>
              <v-list-item to="/register">
                <v-list-item-title>登録</v-list-item-title>
              </v-list-item>
            </template>
          </ClientOnly>
        </v-list>
      </v-menu>
    </v-app-bar>

    <v-main>
      <v-container>
        <slot />
      </v-container>
    </v-main>

    <v-footer app color="primary" dark>
      <v-row justify="center" no-gutters>
        <span>&copy; {{ new Date().getFullYear() }} - Sample App</span>
      </v-row>
    </v-footer>
  </v-app>
</template>

<script setup>
import { storeToRefs } from 'pinia'
import { useAuthStore } from '~/stores/auth'

const authStore = useAuthStore()
const { isAuthenticated } = storeToRefs(authStore)

const config = useRuntimeConfig()

// ログアウト処理
const handleLogout = async () => {
  try {
    await authStore.logout()
  } catch (error) {
    // 開発環境のみconsole.errorを出力
    if (config.public.appEnv === 'development') {
      // eslint-disable-next-line no-console
      console.error('ログアウトエラー:', error)
    } else {
      // 本番環境でのエラー処理
      // エラー監視サービスへの送信やユーザー通知を実装
      console.warn('ログアウト中にエラーが発生しました')
      // TODO: 本番環境用のエラー監視サービスとの連携を実装
      // await $errorReporting.captureException(error)
      // await $toast.error('ログアウト中にエラーが発生しました')
    }
  }
}
</script>
