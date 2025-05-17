<template>
  <div>
    <v-row>
      <v-col cols="12">
        <v-card class="mb-4">
          <v-card-title class="d-flex align-center">
            <span class="text-h5">投稿一覧</span>
            <v-spacer></v-spacer>
            <v-btn v-if="isLoggedIn" color="primary" to="/posts/create" prepend-icon="mdi-plus"> 新規投稿 </v-btn>
          </v-card-title>

          <v-card-text>
            <v-row>
              <v-col cols="12" sm="6" md="4">
                <v-text-field
                  v-model="searchQuery"
                  label="検索"
                  prepend-inner-icon="mdi-magnify"
                  variant="outlined"
                  density="compact"
                  hide-details
                  @update:model-value="debouncedSearch"
                ></v-text-field>
              </v-col>
              <v-col cols="12" sm="6" md="4" v-if="isLoggedIn">
                <v-select
                  v-model="statusFilter"
                  :items="statusOptions"
                  label="ステータス"
                  variant="outlined"
                  density="compact"
                  hide-details
                  @update:model-value="fetchPosts"
                ></v-select>
              </v-col>
            </v-row>

            <v-progress-circular v-if="loading" indeterminate color="primary" class="mt-4" />

            <div v-else-if="posts.length === 0" class="text-center py-4">
              <p>投稿が見つかりませんでした</p>
            </div>

            <div v-else>
              <v-list lines="three">
                <v-list-item v-for="post in posts" :key="post.id" :to="`/posts/${post.slug}`">
                  <template v-slot:prepend>
                    <v-avatar color="grey-lighten-1" v-if="!post.featured_image">
                      <v-icon icon="mdi-file-document-outline"></v-icon>
                    </v-avatar>
                    <v-avatar v-else>
                      <v-img :src="post.featured_image"></v-img>
                    </v-avatar>
                  </template>

                  <v-list-item-title class="text-h6 mb-1">
                    {{ post.title }}
                    <v-chip
                      v-if="post.status !== 'published'"
                      size="small"
                      :color="getStatusColor(post.status)"
                      class="ml-2"
                    >
                      {{ getStatusLabel(post.status) }}
                    </v-chip>
                  </v-list-item-title>

                  <v-list-item-subtitle>
                    <v-icon icon="mdi-account" size="small"></v-icon>
                    {{ post.user?.name }} |
                    <v-icon icon="mdi-calendar" size="small"></v-icon>
                    {{ formatDate(post.published_at || post.created_at) }}
                  </v-list-item-subtitle>

                  <v-list-item-text>
                    {{ truncateContent(post.content) }}
                  </v-list-item-text>
                </v-list-item>
              </v-list>

              <div class="d-flex justify-center mt-4">
                <v-pagination
                  v-model="currentPage"
                  :length="totalPages"
                  :total-visible="7"
                  @update:model-value="fetchPosts"
                ></v-pagination>
              </div>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '../../stores/auth'
import { storeToRefs } from 'pinia'
import axios from 'axios'
import { useRouter } from 'vue-router'

interface Post {
  id: number
  title: string
  content: string
  slug: string
  featured_image: string | null
  status: string
  published_at: string | null
  created_at: string
  user?: {
    id: number
    name: string
    email: string
  }
}

interface PostsResponse {
  data: Post[]
  current_page: number
  last_page: number
  per_page: number
  total: number
}

const router = useRouter()
const authStore = useAuthStore()
const { isLoggedIn, user } = storeToRefs(authStore)

const posts = ref<Post[]>([])
const loading = ref(true)
const currentPage = ref(1)
const totalPages = ref(1)
const searchQuery = ref('')
const statusFilter = ref('')
const perPage = ref(10)

const statusOptions = [
  { title: 'すべて', value: '' },
  { title: '公開済み', value: 'published' },
  { title: '下書き', value: 'draft' },
  { title: 'アーカイブ', value: 'archived' },
]

// 検索のデバウンス処理
let searchTimeout: NodeJS.Timeout | null = null
const debouncedSearch = () => {
  if (searchTimeout) clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    currentPage.value = 1
    fetchPosts()
  }, 500)
}

// 投稿一覧を取得
const fetchPosts = async () => {
  loading.value = true
  try {
    const params: Record<string, any> = {
      page: currentPage.value,
      per_page: perPage.value,
      sort_by: 'published_at',
      sort_order: 'desc',
    }

    if (searchQuery.value) {
      params.search = searchQuery.value
    }

    if (statusFilter.value) {
      params.status = statusFilter.value
    }

    const response = await axios.get<PostsResponse>('/api/posts', { params })
    posts.value = response.data.data
    currentPage.value = response.data.current_page
    totalPages.value = response.data.last_page
  } catch (error) {
    console.error('投稿の取得に失敗しました:', error)
  } finally {
    loading.value = false
  }
}

// 投稿内容を適切な長さに切り詰める
const truncateContent = (content: string): string => {
  if (!content) return ''
  if (content.length <= 150) return content
  return content.substring(0, 150) + '...'
}

// 日付をフォーマット
const formatDate = (dateString: string | null): string => {
  if (!dateString) return '日付なし'
  return new Date(dateString).toLocaleDateString('ja-JP')
}

// ステータスに応じた色を取得
const getStatusColor = (status: string): string => {
  switch (status) {
    case 'published':
      return 'success'
    case 'draft':
      return 'warning'
    case 'archived':
      return 'error'
    default:
      return 'grey'
  }
}

// ステータスラベルを取得
const getStatusLabel = (status: string): string => {
  switch (status) {
    case 'published':
      return '公開'
    case 'draft':
      return '下書き'
    case 'archived':
      return 'アーカイブ'
    default:
      return status
  }
}

onMounted(() => {
  fetchPosts()
})
</script>
