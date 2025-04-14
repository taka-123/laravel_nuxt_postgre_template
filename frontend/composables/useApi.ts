import axios from 'axios'
import { useRuntimeConfig } from '#app'

export const useApi = () => {
  const config = useRuntimeConfig()

  // サーバーサイドではserverApiBase、クライアントサイドではapiBaseを使用
  const baseURL = process.server ? config.public.serverApiBase : config.public.apiBase

  const api = axios.create({
    baseURL,
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    withCredentials: false,
    timeout: 10000,
  })

  // リクエストインターセプター
  api.interceptors.request.use(
    (config) => {
      // クライアントサイドでのみトークンを取得
      if (!process.server) {
        const token = localStorage.getItem('auth_token')
        if (token) {
          config.headers['Authorization'] = `Bearer ${token}`
        }
      }
      return config
    },
    (error) => {
      return Promise.reject(error)
    },
  )

  // レスポンスインターセプター
  api.interceptors.response.use(
    (response) => {
      return response
    },
    async (error) => {
      // クライアントサイドでのみ認証エラー処理
      if (!process.server && error.response?.status === 401) {
        // 認証エラーの場合の処理
        localStorage.removeItem('auth_token')
        window.location.href = '/login'
      }
      return Promise.reject(error)
    },
  )

  return api
}
