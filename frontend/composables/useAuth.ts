import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { defineStore } from 'pinia'

// 認証情報の型定義
interface User {
  id: number
  name: string
  email: string
  created?: string
  updated?: string
}

interface AuthState {
  token: string | null
  user: User | null
  loading: boolean
  error: string | null
}

// Piniaストアを使った認証情報の管理
export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    token: localStorage.getItem('auth_token') || null,
    user: null,
    loading: false,
    error: null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
    getUser: (state) => state.user,
    isLoading: (state) => state.loading,
    getError: (state) => state.error,
  },

  actions: {
    // ログイン処理
    async login(email: string, password: string) {
      this.loading = true
      this.error = null

      try {
        const response = await fetch('/api/auth/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ email, password }),
        })

        const data = await response.json()

        if (!response.ok) {
          throw new Error(data.error || 'ログインに失敗しました')
        }

        this.setAuth(data)
        return data
      } catch (error: any) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    // ユーザー登録処理
    async register(name: string, email: string, password: string, password_confirmation: string) {
      this.loading = true
      this.error = null

      try {
        const response = await fetch('/api/auth/register', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ name, email, password, password_confirmation }),
        })

        const data = await response.json()

        if (!response.ok) {
          throw new Error(data.error || 'ユーザー登録に失敗しました')
        }

        this.setAuth(data)
        return data
      } catch (error: any) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    // ログアウト処理
    async logout() {
      this.loading = true

      try {
        await fetch('/api/auth/logout', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${this.token}`,
          },
        })

        this.clearAuth()
      } catch (error) {
        console.error('ログアウト中にエラーが発生しました:', error)
      } finally {
        this.loading = false
      }
    },

    // ユーザー情報を取得
    async fetchUser() {
      if (!this.token) return null

      this.loading = true

      try {
        const response = await fetch('/api/auth/me', {
          headers: {
            Authorization: `Bearer ${this.token}`,
          },
        })

        if (!response.ok) {
          throw new Error('ユーザー情報の取得に失敗しました')
        }

        const user = await response.json()
        this.user = user
        return user
      } catch (error) {
        this.clearAuth()
        throw error
      } finally {
        this.loading = false
      }
    },

    // トークンをリフレッシュ
    async refreshToken() {
      if (!this.token) return null

      this.loading = true

      try {
        const response = await fetch('/api/auth/refresh', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${this.token}`,
          },
        })

        if (!response.ok) {
          throw new Error('トークンのリフレッシュに失敗しました')
        }

        const data = await response.json()
        this.setAuth(data)
        return data
      } catch (error) {
        this.clearAuth()
        throw error
      } finally {
        this.loading = false
      }
    },

    // 認証情報をセット
    setAuth(data: { access_token: string; user: User }) {
      this.token = data.access_token
      this.user = data.user
      localStorage.setItem('auth_token', data.access_token)
    },

    // 認証情報をクリア
    clearAuth() {
      this.token = null
      this.user = null
      localStorage.removeItem('auth_token')
    },
  },
})

// コンポーザブル関数
export function useAuth() {
  const authStore = useAuthStore()
  const router = useRouter()

  // 認証状態のチェック
  const checkAuth = async () => {
    if (authStore.isAuthenticated && !authStore.getUser) {
      try {
        await authStore.fetchUser()
      } catch (error) {
        console.error('認証エラー:', error)
      }
    }
  }

  // 認証が必要なルートへのナビゲーション前にチェック
  const requireAuth = async (to: any, from: any, next: any) => {
    if (!authStore.isAuthenticated) {
      return next({ name: 'login', query: { redirect: to.fullPath } })
    }

    if (!authStore.getUser) {
      try {
        await authStore.fetchUser()
        return next()
      } catch (error) {
        return next({ name: 'login', query: { redirect: to.fullPath } })
      }
    }

    return next()
  }

  // 認証済みユーザーがアクセスできないルート（ログイン・登録画面など）
  const redirectIfAuthenticated = (to: any, from: any, next: any) => {
    if (authStore.isAuthenticated) {
      return next({ name: 'home' })
    }

    return next()
  }

  return {
    // ストアから取得した状態と関数
    ...authStore,

    // 追加の便利な関数
    checkAuth,
    requireAuth,
    redirectIfAuthenticated,

    // ログインと同時にリダイレクト
    async loginAndRedirect(email: string, password: string, redirectPath?: string) {
      try {
        await authStore.login(email, password)
        router.push(redirectPath || '/')
      } catch (error) {
        console.error('ログインエラー:', error)
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
        console.error('登録エラー:', error)
      }
    },

    // ログアウトと同時にリダイレクト
    async logoutAndRedirect(redirectPath?: string) {
      await authStore.logout()
      router.push(redirectPath || '/login')
    },
  }
}
