import { describe, it, expect } from 'vitest'

describe('サンプルテスト', () => {
  it('trueはtrueであること', () => {
    expect(true).toBe(true)
  })

  it('数値の計算が正しいこと', () => {
    expect(1 + 1).toBe(2)
  })
})
