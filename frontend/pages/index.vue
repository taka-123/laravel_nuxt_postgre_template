<template>
  <div>
    <v-row>
      <v-col cols="12">
        <v-card class="mb-4">
          <v-card-title class="text-h4"> Laravel + Nuxt + PostgreSQL テンプレートへようこそ </v-card-title>
          <v-card-text>
            <p class="text-body-1">
              このテンプレートは、Laravel、Nuxt、PostgreSQLを使用したモダンなウェブアプリケーション開発の基盤を提供します。
              認証機能、CRUD操作、テスト環境、CI/CD設定などが整っています。
            </p>
            <v-alert v-if="!isLoggedIn" type="info" class="mt-4">
              投稿やコメントなどの機能を利用するには、ログインが必要です。
            </v-alert>
          </v-card-text>
          <v-card-actions v-if="!isLoggedIn">
            <v-btn color="primary" to="/login" variant="elevated"> ログイン </v-btn>
            <v-btn color="secondary" to="/register" variant="outlined" class="ml-2"> 新規登録 </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="12">
        <h2 class="text-h5 mb-4">最新の投稿</h2>
        <v-progress-circular v-if="loading" indeterminate color="primary" />
        <div v-else-if="posts.length === 0" class="text-center py-4">
          <p>投稿がまだありません</p>
        </div>
        <div v-else>
          <v-card v-for="post in posts" :key="post.id" class="mb-4">
            <v-card-title>{{ post.title }}</v-card-title>
            <v-card-subtitle>
              {{ new Date(post.published_at).toLocaleDateString() }} by {{ post.user?.name }}
            </v-card-subtitle>
            <v-card-text>
              {{ truncateContent(post.content) }}
            </v-card-text>
            <v-card-actions>
              <v-btn color="primary" :to="`/posts/${post.slug}`" variant="text"> 続きを読む </v-btn>
            </v-card-actions>
          </v-card>
        </div>
      </v-col>
    </v-row>

    <v-row v-if="isLoggedIn">
      <v-col cols="12" md="4">
        <v-card>
          <v-card-title>投稿管理</v-card-title>
          <v-card-text> 投稿の作成、編集、削除が可能です。 </v-card-text>
          <v-card-actions>
            <v-btn color="primary" to="/posts" variant="text"> 投稿一覧へ </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card>
          <v-card-title>新規投稿</v-card-title>
          <v-card-text> 新しい投稿を作成します。 </v-card-text>
          <v-card-actions>
            <v-btn color="primary" to="/posts/create" variant="text"> 投稿作成へ </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card>
          <v-card-title>プロフィール</v-card-title>
          <v-card-text> プロフィール情報の編集や、自分の投稿とコメントの管理ができます。 </v-card-text>
          <v-card-actions>
            <v-btn color="primary" to="/profile" variant="text"> プロフィールへ </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '../stores/auth'
import { storeToRefs } from 'pinia'
import { ref, onMounted } from 'vue'
import axios from 'axios'

interface Post {
  id: number
  title: string
  content: string
  slug: string
  featured_image: string | null
  status: string
  published_at: string
  user: {
    id: number
    name: string
    email: string
  }
}

const authStore = useAuthStore()
const { isLoggedIn } = storeToRefs(authStore)

const posts = ref<Post[]>([])
const loading = ref(true)

onMounted(async () => {
  try {
    const response = await axios.get('/api/posts', {
      params: {
        per_page: 5,
        sort_by: 'published_at',
        sort_order: 'desc',
      },
    })
    posts.value = response.data.data
  } catch (error) {
    console.error('投稿の取得に失敗しました:', error)
  } finally {
    loading.value = false
  }
})

/**
 * 投稿内容を適切な長さに切り詰める
 */
const truncateContent = (content: string): string => {
  if (content.length <= 150) return content
  return content.substring(0, 150) + '...'
}
</script>
