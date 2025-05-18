import { ref } from 'vue'
import { useAuthStore } from '~/stores/auth'

// コメントの型定義
export interface Comment {
  id: number
  content: string
  post_id: number
  user_id: number
  created: string
  updated: string
  user?: {
    id: number
    name: string
  }
  post?: {
    id: number
    title: string
    slug: string
  }
}

export const useComments = () => {
  const authStore = useAuthStore()
  const comments = ref<Comment[]>([])
  const loading = ref(false)
  const submitting = ref(false)
  const error = ref<string | null>(null)

  /**
   * 投稿に対するコメント一覧を取得する
   */
  const fetchComments = async (postId: number) => {
    loading.value = true
    error.value = null

    try {
      const response = await fetch(`/api/posts/${postId}/comments`, {
        headers: {
          'Content-Type': 'application/json',
          ...(authStore.token ? { Authorization: `Bearer ${authStore.token}` } : {}),
        },
      })

      if (!response.ok) {
        throw new Error('コメントの取得に失敗しました')
      }

      const data = await response.json()
      comments.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('コメントの取得エラー:', e)
      throw e
    } finally {
      loading.value = false
    }
  }

  /**
   * ユーザーのコメント一覧を取得する
   */
  const fetchUserComments = async () => {
    if (!authStore.token) {
      throw new Error('認証が必要です')
    }

    loading.value = true
    error.value = null

    try {
      const response = await fetch('/api/user/comments', {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
      })

      if (!response.ok) {
        throw new Error('コメントの取得に失敗しました')
      }

      const data = await response.json()
      comments.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('コメントの取得エラー:', e)
      throw e
    } finally {
      loading.value = false
    }
  }

  /**
   * 新規コメントを投稿する
   */
  const submitComment = async (postId: number, content: string) => {
    if (!authStore.token) {
      throw new Error('コメントを投稿するには、ログインが必要です')
    }

    submitting.value = true
    error.value = null

    try {
      const response = await fetch(`/api/posts/${postId}/comments`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify({ content }),
      })

      if (!response.ok) {
        throw new Error('コメントの投稿に失敗しました')
      }

      const data = await response.json()
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('コメント投稿エラー:', e)
      throw e
    } finally {
      submitting.value = false
    }
  }

  /**
   * コメントを更新する
   */
  const updateComment = async (commentId: number, content: string) => {
    if (!authStore.token) {
      throw new Error('認証が必要です')
    }

    submitting.value = true
    error.value = null

    try {
      const response = await fetch(`/api/comments/${commentId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
        body: JSON.stringify({ content }),
      })

      if (!response.ok) {
        throw new Error('コメントの更新に失敗しました')
      }

      const data = await response.json()
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('コメント更新エラー:', e)
      throw e
    } finally {
      submitting.value = false
    }
  }

  /**
   * コメントを削除する
   */
  const deleteComment = async (commentId: number) => {
    if (!authStore.token) {
      throw new Error('認証が必要です')
    }

    submitting.value = true
    error.value = null

    try {
      const response = await fetch(`/api/comments/${commentId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authStore.token}`,
        },
      })

      if (!response.ok) {
        throw new Error('コメントの削除に失敗しました')
      }

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('コメント削除エラー:', e)
      throw e
    } finally {
      submitting.value = false
    }
  }

  /**
   * コメント内容を切り詰める
   */
  const truncateContent = (content: string, maxLength = 100) => {
    if (!content) return ''
    if (content.length <= maxLength) return content
    return content.substring(0, maxLength) + '...'
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
    comments,
    loading,
    submitting,
    error,
    fetchComments,
    fetchUserComments,
    submitComment,
    updateComment,
    deleteComment,
    truncateContent,
    formatDate,
  }
}
