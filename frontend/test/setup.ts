import { expect, afterEach } from 'vitest'
import { cleanup } from '@vue/test-utils'
import * as matchers from '@testing-library/jest-dom/matchers'

// @testing-library/jest-domのmatchersを拡張
expect.extend(matchers)

// 各テスト後にコンポーネントのマウントを解除
afterEach(() => {
  cleanup()
})
