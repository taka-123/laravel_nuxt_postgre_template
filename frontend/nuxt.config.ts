// https://nuxt.com/docs/api/configuration/nuxt-config
import { defineNuxtConfig } from 'nuxt/config'
import vuetify, { transformAssetUrls } from 'vite-plugin-vuetify'

export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: [
    '@nuxt/image',
    '@pinia/nuxt',
    // テスト環境の統合（本番ビルド時は除外）
    ...(process.env.NODE_ENV !== 'production' ? ['@nuxt/test-utils/module'] : []),
    (_options, nuxt) => {
      nuxt.hooks.hook('vite:extendConfig', (config) => {
        // @ts-expect-error
        config.plugins.push(vuetify({ autoImport: true }))
      })
    },
  ],
  build: {
    transpile: ['vuetify'],
  },
  vite: {
    vue: {
      template: {
        transformAssetUrls,
      },
    },
    optimizeDeps: {
      include: ['vue', 'vue-router', 'pinia', '@vueuse/core', '@vueuse/head'],
      exclude: [],
    },
  },
  // APIリクエストのプロキシ設定
  nitro: {
    devProxy: {
      '/api': {
        target: 'http://localhost:8000/api',
        changeOrigin: true,
        prependPath: false,
      },
    },
  },
  css: ['vuetify/lib/styles/main.sass', '@mdi/font/css/materialdesignicons.min.css'],
  typescript: {
    strict: false,
    typeCheck: false,
    shim: false
  },
  vite: {
    optimizeDeps: {
      exclude: ['vue-demi']
    }
  },
  runtimeConfig: {
    public: {
      // クライアントサイド（ブラウザ）用API URL
      apiBase: process.env.BROWSER_API_BASE_URL || 'http://localhost:8000/api',
      // サーバーサイド（Dockerコンテナ内）用API URL
      serverApiBase: process.env.SERVER_API_BASE_URL || 'http://laravel.test/api',
      appEnv: process.env.APP_ENV || 'development',
    },
  },
})
