import { useRouter } from 'vue-router'
import { useAuthStore } from '~/stores/auth'

export function useAuth() {
  const authStore = useAuthStore()
  const router = useRouter()

  return {
    // ログインと同時にリダイレクト
    async loginAndRedirect(email: string, password: string, redirectPath?: string) {
      try {
        await authStore.login(email, password)
        router.push(redirectPath || '/')
      } catch (error) {
        throw error
      }
    },

    // 登録と同時にリダイレクト
    async registerAndRedirect(
      name: string,
      email: string,
      password: string,
      password_confirmation: string,
      redirectPath?: string,
    ) {
      try {
        await authStore.register(name, email, password, password_confirmation)
        router.push(redirectPath || '/')
      } catch (error) {
        throw error
      }
    },

    // ログアウトと同時にリダイレクト
    async logoutAndRedirect(redirectPath?: string) {
      await authStore.logout()
      router.push(redirectPath || '/login')
    },
  }
}
