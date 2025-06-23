import axios from 'axios'
import { useRuntimeConfig } from '#app'

export const useApi = () => {
  const config = useRuntimeConfig()

  // 開発環境ではプロキシを利用、本番環境では直接APIサーバーに接続
  const baseURL = process.env.NODE_ENV === 'development' 
    ? '' // 開発環境ではプロキシを使用するため空文字
    : (process.server ? config.public.serverApiBase : config.public.apiBase)

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
      // エラーレスポンスの詳細情報を設定
      if (error.response) {
        // サーバーからのレスポンスがある場合
        const { status, data } = error.response
        
        // 日本語エラーメッセージの統一
        switch (status) {
          case 400:
            error.message = data?.message || '不正なリクエストです'
            break
          case 401:
            error.message = data?.message || '認証に失敗しました'
            // クライアントサイドでのみ認証エラー処理（ログインページ以外）
            if (!process.server && !window.location.pathname.includes('/login')) {
              localStorage.removeItem('auth_token')
              localStorage.removeItem('refresh_token')
              window.location.href = '/login'
            }
            break
          case 403:
            error.message = data?.message || 'アクセス権限がありません'
            break
          case 404:
            error.message = data?.message || 'リソースが見つかりません'
            break
          case 422:
            error.message = data?.message || '入力内容に不備があります'
            break
          case 429:
            error.message = data?.message || 'リクエストが多すぎます。しばらく待ってから再度お試しください'
            break
          case 500:
            error.message = data?.message || 'サーバーエラーが発生しました'
            break
          case 503:
            error.message = data?.message || 'サービスが一時的に利用できません'
            break
          default:
            error.message = data?.message || 'エラーが発生しました'
            break
        }
      } else if (error.request) {
        // ネットワークエラー
        error.message = 'ネットワークに接続できません'
        error.code = 'NETWORK_ERROR'
      } else {
        // その他のエラー
        error.message = error.message || '予期しないエラーが発生しました'
      }
      
      return Promise.reject(error)
    },
  )

  return api
}
