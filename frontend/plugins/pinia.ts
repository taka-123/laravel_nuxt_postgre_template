// plugins/pinia.ts
import { useAuthStore } from '~/stores/auth'

export default defineNuxtPlugin(() => {
  // アプリケーション起動時に認証状態を初期化
  const authStore = useAuthStore()
  authStore.initAuth()
})
