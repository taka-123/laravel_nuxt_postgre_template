// https://nuxt.com/docs/api/configuration/nuxt-config
import { defineNuxtConfig } from 'nuxt/config'
import vuetify, { transformAssetUrls } from 'vite-plugin-vuetify'

export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: [
    '@pinia/nuxt',
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
      exclude: ['vue-demi'],
    },
  },
  css: [
    'vuetify/lib/styles/main.sass',
    '@mdi/font/css/materialdesignicons.min.css',
  ],
  typescript: {
    strict: false,
    typeCheck: false,
    shim: false,
  },
  runtimeConfig: {
    public: {
      // クライアントサイド（ブラウザ）用API URL
      apiBase: process.env.BROWSER_API_BASE_URL || 'http://localhost:8000/api',
      // サーバーサイド（Dockerコンテナ内）用API URL
      serverApiBase:
        process.env.SERVER_API_BASE_URL || 'http://laravel.test/api',
      appEnv: (process.env.NODE_ENV || 'production') as 'development' | 'production',
    },
  },
})
