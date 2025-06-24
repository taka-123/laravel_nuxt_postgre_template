// stores/auth.ts
import { defineStore } from 'pinia'
import { useApi } from '~/composables/useApi'

interface User {
  id: number
  name: string
  email: string
}

interface AuthState {
  user: User | null
  token: string | null
  refreshToken: string | null
  isAuthenticated: boolean
  loading: boolean
  error: string | null
  initialized: boolean
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    token: null,
    refreshToken: null,
    isAuthenticated: false,
    loading: false,
    error: null,
    initialized: false,
  }),

  getters: {
    getUser: (state) => state.user,
    isLoggedIn: (state) => state.isAuthenticated,
    getToken: (state) => state.token,
    getError: (state) => state.error,
  },

  actions: {
    async login(email: string, password: string) {
      this.loading = true
      this.error = null
      const api = useApi()

      try {
        const response = await api.post('/auth/login', {
          email,
          password,
        })

        const { access_token, user } = response.data

        this.token = access_token
        this.refreshToken = access_token
        this.user = user
        this.isAuthenticated = true

        // トークンをローカルストレージに保存
        if (process.client) {
          localStorage.setItem('auth_token', access_token)
          localStorage.setItem('refresh_token', access_token)
        }

        return { success: true }
      } catch (error: any) {
        // エラーメッセージを日本語化
        let errorMessage = 'ログインに失敗しました'
        
        if (error.response?.status === 401) {
          errorMessage = 'メールアドレスまたはパスワードが正しくありません'
        } else if (error.response?.status === 422) {
          errorMessage = '入力内容に不備があります'
        } else if (error.response?.status >= 500) {
          errorMessage = 'サーバーエラーが発生しました。しばらく待ってから再度お試しください'
        } else if (error.code === 'NETWORK_ERROR') {
          errorMessage = 'ネットワークに接続できません'
        }
        
        this.error = errorMessage
        throw new Error(this.error)
      } finally {
        this.loading = false
      }
    },

    async register(name: string, email: string, password: string, password_confirmation: string) {
      this.loading = true
      const api = useApi()

      try {
        const response = await api.post('/auth/register', {
          name,
          email,
          password,
          password_confirmation,
        })

        const { access_token, user } = response.data

        this.token = access_token
        this.refreshToken = access_token
        this.user = user
        this.isAuthenticated = true

        // トークンをローカルストレージに保存
        if (process.client) {
          localStorage.setItem('auth_token', access_token)
          localStorage.setItem('refresh_token', access_token)
        }

        return { success: true }
      } catch (error: any) {
        return {
          success: false,
          message: error.response?.data?.message || '登録に失敗しました',
        }
      } finally {
        this.loading = false
      }
    },

    async logout() {
      this.loading = true
      const api = useApi()

      try {
        if (this.token) {
          await api.post('/auth/logout')
        }

        return { success: true }
      } catch (error) {
        // エラーが発生しても、ローカルのログアウト処理は続行
        return { success: true }
      } finally {
        // ローカルの認証状態をクリア
        this.token = null
        this.refreshToken = null
        this.user = null
        this.isAuthenticated = false

        // ローカルストレージからトークンを削除
        if (process.client) {
          localStorage.removeItem('auth_token')
          localStorage.removeItem('refresh_token')
        }

        this.loading = false
      }
    },

    async fetchUser() {
      if (!this.token) {
        return { success: false, message: '認証されていません' }
      }

      this.loading = true
      const api = useApi()

      try {
        const response = await api.get('/auth/me')

        this.user = response.data
        return { success: true }
      } catch (error: any) {
        if (error.response?.status === 401) {
          // 認証エラーの場合はログアウト
          this.logout()
        }

        return {
          success: false,
          message: error.response?.data?.message || 'ユーザー情報の取得に失敗しました',
        }
      } finally {
        this.loading = false
      }
    },

    // ページ読み込み時にローカルストレージからトークンを復元
    async initAuth() {
      if (process.client) {
        const token = localStorage.getItem('auth_token')
        const refreshToken = localStorage.getItem('refresh_token')

        if (token) {
          this.token = token
          this.refreshToken = refreshToken
          this.isAuthenticated = true

          // ユーザー情報を取得（エラーは内部で処理される）
          await this.fetchUser()
        }
        
        // 初期化完了をマーク
        this.initialized = true
      }
    },

    // エラーをクリア
    clearError() {
      this.error = null
    },
  },
})
