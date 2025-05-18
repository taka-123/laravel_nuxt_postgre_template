import { describe, it, expect, vi, beforeEach } from 'vitest'
import { usePosts } from '~/composables/usePosts'

// モックデータ
const mockPosts = [
  {
    id: 1,
    title: 'テスト投稿1',
    content: 'これはテスト投稿1の内容です。',
    slug: 'test-post-1',
    status: 'published',
    user_id: 1,
    published_at: '2025-01-01T00:00:00.000Z',
    created: '2025-01-01T00:00:00.000Z',
    updated: '2025-01-01T00:00:00.000Z',
    user: {
      id: 1,
      name: 'テストユーザー',
    },
  },
  {
    id: 2,
    title: 'テスト投稿2',
    content: 'これはテスト投稿2の内容です。',
    slug: 'test-post-2',
    status: 'draft',
    user_id: 1,
    published_at: null,
    created: '2025-01-02T00:00:00.000Z',
    updated: '2025-01-02T00:00:00.000Z',
    user: {
      id: 1,
      name: 'テストユーザー',
    },
  },
]

// グローバルのfetchをモック
global.fetch = vi.fn()

describe('usePosts', () => {
  beforeEach(() => {
    vi.resetAllMocks()
  })

  describe('fetchPosts', () => {
    it('投稿一覧を正常に取得できること', async () => {
      // fetchのモック実装
      global.fetch = vi.fn().mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ data: mockPosts }),
      })

      const { fetchPosts, posts } = usePosts()
      await fetchPosts()

      expect(global.fetch).toHaveBeenCalledTimes(1)
      expect(global.fetch).toHaveBeenCalledWith('/api/posts?', expect.any(Object))
      expect(posts.value).toEqual(mockPosts)
    })

    it('エラー時に適切に処理されること', async () => {
      // エラーを返すモック
      global.fetch = vi.fn().mockResolvedValueOnce({
        ok: false,
        json: () => Promise.resolve({ error: 'エラーが発生しました' }),
      })

      const { fetchPosts, error } = usePosts()

      await expect(fetchPosts()).rejects.toThrow('投稿の取得に失敗しました')
      expect(error.value).toBe('投稿の取得に失敗しました')
    })
  })

  describe('getStatusColor', () => {
    it('ステータスに応じた正しい色を返すこと', () => {
      const { getStatusColor } = usePosts()

      expect(getStatusColor('published')).toBe('success')
      expect(getStatusColor('draft')).toBe('warning')
      expect(getStatusColor('archived')).toBe('error')
      expect(getStatusColor('unknown')).toBe('grey')
    })
  })

  describe('getStatusLabel', () => {
    it('ステータスに応じた正しいラベルを返すこと', () => {
      const { getStatusLabel } = usePosts()

      expect(getStatusLabel('published')).toBe('公開')
      expect(getStatusLabel('draft')).toBe('下書き')
      expect(getStatusLabel('archived')).toBe('アーカイブ')
      expect(getStatusLabel('unknown')).toBe('その他')
    })
  })

  describe('formatDate', () => {
    it('日付を正しくフォーマットすること', () => {
      const { formatDate } = usePosts()

      // テスト用に日付のフォーマットをモック
      const originalDateTimeFormat = Intl.DateTimeFormat
      Intl.DateTimeFormat = vi.fn().mockImplementation(() => ({
        format: () => '2025年1月1日 00:00',
      }))

      expect(formatDate('2025-01-01T00:00:00.000Z')).toBe('2025年1月1日 00:00')
      expect(formatDate(undefined)).toBe('日付なし')

      // モックを元に戻す
      Intl.DateTimeFormat = originalDateTimeFormat
    })
  })
})
