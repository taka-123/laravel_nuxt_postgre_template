import { useRouter } from 'vue-router'
import { useAuthStore } from '~/stores/auth'

export function useAuth() {
  const authStore = useAuthStore()
  const router = useRouter()

  return {
    // ログインと同時にリダイレクト
    async loginAndRedirect(
      email: string,
      password: string,
      redirectPath?: string
    ) {
      await authStore.login(email, password)
      router.push(redirectPath || '/')
    },

    // 登録と同時にリダイレクト
    async registerAndRedirect(
      name: string,
      email: string,
      password: string,
      passwordConfirmation: string,
      redirectPath?: string
    ) {
      await authStore.register(name, email, password, passwordConfirmation)
      router.push(redirectPath || '/')
    },

    // ログアウトと同時にリダイレクト
    async logoutAndRedirect(redirectPath?: string) {
      await authStore.logout()
      router.push(redirectPath || '/login')
    },
  }
}
