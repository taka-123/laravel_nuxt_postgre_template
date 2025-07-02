import { expect, afterEach } from 'vitest'
import * as matchers from '@testing-library/jest-dom/matchers'

// @testing-library/jest-domのmatchersを拡張
expect.extend(matchers)

// 各テスト後の処理
afterEach(() => {
  // テスト後のクリーンアップ処理をここに追加
})
