import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mountSuspended } from '@nuxt/test-utils/runtime'
import { createTestingPinia } from '@pinia/testing'
import IndexPage from '../../pages/index.vue'

// Pinia ストアのモック
vi.mock('../../stores/auth', () => ({
  useAuthStore: () => ({
    isLoggedIn: false
  })
}))

describe('IndexPage', () => {
  it('未ログイン状態で正しくレンダリングされること', async () => {
    const wrapper = await mountSuspended(IndexPage, {
      global: {
        plugins: [
          createTestingPinia({
            createSpy: vi.fn,
            initialState: {
              auth: {
                isLoggedIn: false
              }
            }
          })
        ]
      }
    })

    // タイトルが表示されていることを確認
    expect(wrapper.text()).toContain('図書管理システムへようこそ')
    
    // 未ログイン時のアラートが表示されていることを確認
    expect(wrapper.text()).toContain('システムの全機能を利用するには、ログインが必要です')
    
    // ログインボタンが表示されていることを確認
    const loginButton = wrapper.find('a[href="/login"]')
    expect(loginButton.exists()).toBe(true)
    expect(loginButton.text()).toContain('ログイン')
    
    // 新規登録ボタンが表示されていることを確認
    const registerButton = wrapper.find('a[href="/register"]')
    expect(registerButton.exists()).toBe(true)
    expect(registerButton.text()).toContain('新規登録')
  })

  it('ログイン状態で正しくレンダリングされること', async () => {
    // ログイン状態のモック
    vi.mock('../../stores/auth', () => ({
      useAuthStore: () => ({
        isLoggedIn: true
      })
    }))

    const wrapper = await mountSuspended(IndexPage, {
      global: {
        plugins: [
          createTestingPinia({
            createSpy: vi.fn,
            initialState: {
              auth: {
                isLoggedIn: true
              }
            }
          })
        ]
      }
    })

    // タイトルが表示されていることを確認
    expect(wrapper.text()).toContain('図書管理システムへようこそ')
    
    // ログイン時のカードが表示されていることを確認
    expect(wrapper.text()).toContain('書籍管理')
    expect(wrapper.text()).toContain('貸出管理')
    expect(wrapper.text()).toContain('ユーザー管理')
    
    // 書籍一覧へのリンクが表示されていることを確認
    const booksLink = wrapper.find('a[href="/books"]')
    expect(booksLink.exists()).toBe(true)
  })
})