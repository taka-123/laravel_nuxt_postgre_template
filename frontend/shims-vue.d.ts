declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}

// Vueテンプレート内でのTypeScript型チェックを改善するための設定
declare module 'vue' {
  interface ComponentCustomProperties {
    $refs: {
      [key: string]: HTMLElement | any
    }
    // 共通で使用される変数
    loading: boolean
    user: any
    formatDate: (date: string) => string
    isLoggedIn: boolean
  }
}
