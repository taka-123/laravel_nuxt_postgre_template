// plugins/vuetify.ts
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { md3 } from 'vuetify/blueprints'
// mdi-svgのインポートを削除し、mdi/fontを使用する設定に変更
import '@mdi/font/css/materialdesignicons.css'

export default defineNuxtPlugin(nuxtApp => {
  const vuetify = createVuetify({
    ssr: true,
    components,
    directives,
    // Material Design 3 を使用
    blueprint: md3,
    // アイコンセット - MDI フォントに変更
    icons: {
      defaultSet: 'mdi',
    },
    // カスタムテーマ
    theme: {
      defaultTheme: 'light',
      themes: {
        light: {
          dark: false,
          colors: {
            primary: '#1976D2', // メインカラー
            secondary: '#673AB7', // セカンダリー
            accent: '#FF5722', // アクセント
            error: '#F44336', // エラー
            warning: '#FFC107', // 警告
            info: '#00BCD4', // 情報
            success: '#4CAF50', // 成功
            background: '#F5F5F5', // 背景色
          },
        },
        dark: {
          dark: true,
          colors: {
            primary: '#2196F3',
            secondary: '#9C27B0',
            accent: '#FF9800',
            error: '#FF5252',
            warning: '#FFC107',
            info: '#00BCD4',
            success: '#4CAF50',
            background: '#121212',
          },
        },
      },
    },
    // デフォルトプロパティ
    defaults: {
      VCard: {
        elevation: 2,
        rounded: 'lg',
      },
      VBtn: {
        rounded: 'lg',
        elevation: 2,
        fontWeight: 'medium',
      },
      VAlert: {
        borderRadius: 'lg',
      },
      VTextField: {
        variant: 'outlined',
        density: 'comfortable',
        rounded: 'lg',
      },
      VSelect: {
        variant: 'outlined',
        density: 'comfortable',
        rounded: 'lg',
      },
    },
  })

  nuxtApp.vueApp.use(vuetify)
})
