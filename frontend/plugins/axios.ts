// plugins/axios.ts
import axios from 'axios'

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()

  // グローバルデフォルト設定
  axios.defaults.baseURL = config.public.apiBase

  const apiClient = axios.create({
    baseURL: config.public.apiBase,
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    withCredentials: true, // CORSリクエストでCookieを送信
  })

  // リクエストインターセプター
  apiClient.interceptors.request.use(
    (config) => {
      const token = localStorage.getItem('auth_token')
      if (token) {
        config.headers['Authorization'] = `Bearer ${token}`
      }
      return config
    },
    (error) => {
      return Promise.reject(error)
    },
  )

  // レスポンスインターセプター
  apiClient.interceptors.response.use(
    (response) => {
      return response
    },
    async (error) => {
      const originalRequest = error.config

      // トークンの有効期限切れの場合（401エラー）かつリフレッシュ試行フラグがない場合
      if (error.response && error.response.status === 401 && !originalRequest._retry) {
        originalRequest._retry = true

        try {
          // トークンをリフレッシュ
          const refreshToken = localStorage.getItem('refresh_token')
          if (!refreshToken) {
            throw new Error('リフレッシュトークンがありません')
          }

          const response = await axios.post(
            `${config.public.apiBase}/auth/refresh`,
            {},
            {
              headers: {
                Authorization: `Bearer ${refreshToken}`,
              },
            },
          )

          const { access_token } = response.data
          localStorage.setItem('auth_token', access_token)

          // 元のリクエストを再試行
          originalRequest.headers['Authorization'] = `Bearer ${access_token}`
          return axios(originalRequest)
        } catch (refreshError) {
          // リフレッシュに失敗した場合はログアウト処理
          localStorage.removeItem('auth_token')
          localStorage.removeItem('refresh_token')

          // ログインページにリダイレクト
          window.location.href = '/login'
          return Promise.reject(refreshError)
        }
      }

      return Promise.reject(error)
    },
  )

  return {
    provide: {
      axios: apiClient,
    },
  }
})
