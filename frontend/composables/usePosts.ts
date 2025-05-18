import { ref, computed } from 'vue'
import { useAuthStore } from '~/stores/auth'

// 投稿の型定義
export interface Post {
  id: number
  title: string
  content: string
  slug: string
  status: string
  user_id: number
  published_at: string | null
  created: string
  updated: string
  user?: {
    id: number
    name: string
  }
}

export const usePosts = () => {
  const authStore = useAuthStore()
  const posts = ref<Post[]>([])
  const post = ref<Post | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * 投稿一覧を取得する
   */
  const fetchPosts = async (params = {}) => {
    loading.value = true
    error.value = null

    try {
      const response = await fetch('/api/posts?' + new URLSearchParams(params as any), {
        headers: {
          'Content-Type': 'application/json',
          ...(authStore.token ? { Authorization: `Bearer ${authStore.token}` } : {}),
        },
      })

      if (!response.ok) {
        throw new Error('投稿の取得に失敗しました')
      }

      const data = await response.json()
      posts.value = data.data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('投稿の取得エラー:', e)
      throw e
    } finally {
      loading.value = false
    }
  }

  /**
   * 特定の投稿を取得する
   */
  const fetchPost = async (slug: string) => {
    loading.value = true
    error.value = null

    try {
      const response = await fetch(`/api/posts/${slug}`, {
        headers: {
          'Content-Type': 'application/json',
          ...(authStore.token ? { Authorization: `Bearer ${authStore.token}` } : {}),
        },
      })

      if (!response.ok) {
        throw new Error('投稿の取得に失敗しました')
      }

      const data = await response.json()
      post.value = data
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('投稿の取得エラー:', e)
      throw e
    } finally {
      loading.value = false
    }
  }

  /**
   * 新規投稿を作成する
   */
  const createPost = async (postData: Partial<Post>) => {
    if (!authStore.token) {
      throw new Error('認証が必要です')
    }

    loading.value = true
    error.value = null

    try {
      const response = await fetch('/api/posts', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify(postData),
      })

      if (!response.ok) {
        throw new Error('投稿の作成に失敗しました')
      }

      const data = await response.json()
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('投稿の作成エラー:', e)
      throw e
    } finally {
      loading.value = false
    }
  }

  /**
   * 投稿を更新する
   */
  const updatePost = async (id: number, postData: Partial<Post>) => {
    if (!authStore.token) {
      throw new Error('認証が必要です')
    }

    loading.value = true
    error.value = null

    try {
      const response = await fetch(`/api/posts/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify(postData),
      })

      if (!response.ok) {
        throw new Error('投稿の更新に失敗しました')
      }

      const data = await response.json()
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('投稿の更新エラー:', e)
      throw e
    } finally {
      loading.value = false
    }
  }

  /**
   * 投稿を削除する
   */
  const deletePost = async (id: number) => {
    if (!authStore.token) {
      throw new Error('認証が必要です')
    }

    loading.value = true
    error.value = null

    try {
      const response = await fetch(`/api/posts/${id}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
      })

      if (!response.ok) {
        throw new Error('投稿の削除に失敗しました')
      }

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('投稿の削除エラー:', e)
      throw e
    } finally {
      loading.value = false
    }
  }

  /**
   * 投稿ステータスに応じた色を返す
   */
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'published':
        return 'success'
      case 'draft':
        return 'warning'
      case 'archived':
        return 'error'
      default:
        return 'grey'
    }
  }

  /**
   * 投稿ステータスのラベルを返す
   */
  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'published':
        return '公開'
      case 'draft':
        return '下書き'
      case 'archived':
        return 'アーカイブ'
      default:
        return 'その他'
    }
  }

  /**
   * 日付をフォーマットする
   */
  const formatDate = (dateString?: string) => {
    if (!dateString) return '日付なし'
    const date = new Date(dateString)
    return new Intl.DateTimeFormat('ja-JP', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(date)
  }

  return {
    posts,
    post,
    loading,
    error,
    fetchPosts,
    fetchPost,
    createPost,
    updatePost,
    deletePost,
    getStatusColor,
    getStatusLabel,
    formatDate,
  }
}
