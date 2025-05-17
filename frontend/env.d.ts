/// <reference types="vite/client" />
/// <reference types="vue/macros-global" />

// Vueファイル内でのTypeScriptエラーを抑制するための設定
declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}

// テンプレート内の変数に関するTypeScriptエラーを抑制
declare module '@vue/runtime-core' {
  interface ComponentCustomProperties {
    $refs: {
      [key: string]: HTMLElement | any
    }
  }
}
