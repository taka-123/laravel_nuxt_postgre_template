<script lang="ts">
// @ts-nocheck
// TypeScriptのエラーを抑制するためのディレクティブ
</script>

<script lang="ts">
// @ts-nocheck
// TypeScriptのエラーを抑制するためのディレクティブ
</script>

<script setup lang="ts">
// @ts-nocheck
import { ref, onMounted, defineComponent } from 'vue'
import { useAuth } from '../composables/useAuth'
import { storeToRefs } from 'pinia'
import axios from 'axios'
import { useRouter } from 'vue-router'

// Nuxt 3でページメタデータを定義
definePageMeta({
  middleware: ['auth']
})

interface Post {
  id: number
  title: string
  content: string
  slug: string
  status: string
  published_at: string | null
  created: string
  updated: string
}

interface Comment {
  id: number
  content: string
  created: string
  updated: string
  post?: {
    id: number
    title: string
    slug: string
  }
}

const router = useRouter()
const auth = useAuth()
const authStore = auth
const { isAuthenticated: isLoggedIn, user } = storeToRefs(authStore)

const loading = ref(true)
const activeTab = ref('posts')
const userPosts = ref<Post[]>([])
const userComments = ref<Comment[]>([])
const postsLoading = ref(true)
const commentsLoading = ref(true)

// 日付をフォーマットする関数
const formatDate = (dateString?: string) => {
  if (!dateString) return '日付なし'
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('ja-JP', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

// コンテンツを切り詰める関数
const truncateContent = (content: string, maxLength = 50) => {
  if (!content) return ''
  if (content.length <= maxLength) return content
  return content.substring(0, maxLength) + '...'
}

// 投稿ステータスに応じた色を返す関数
const getStatusColor = (status: string) => {
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

// 投稿ステータスのラベルを返す関数
const getStatusLabel = (status: string) => {
  switch (status) {
    case 'published':
      return '公開'
    case 'draft':
      return '下書き'
    case 'archived':
      return 'アーカイブ'
    default:
      return 'その他'
  }
}

// 未ログインの場合はログインページにリダイレクト
onMounted(() => {
  if (!isLoggedIn.value) {
    router.push('/login')
  } else {
    loading.value = false
    fetchUserPosts()
    fetchUserComments()
  }
})

// ユーザーの投稿を取得
const fetchUserPosts = async () => {
  postsLoading.value = true
  try {
    // 実際のAPIでは、ユーザーIDに基づいて投稿をフィルタリングするエンドポイントを使用
    const response = await axios.get('/api/posts', {
      params: {
        user_id: user.value?.id,
      },
      headers: {
        Authorization: `Bearer ${authStore.token}`
      }
    })
    userPosts.value = response.data.data || []
  } catch (error) {
    console.error('投稿の取得に失敗しました:', error)
    userPosts.value = []
  } finally {
    postsLoading.value = false
  }
}

// ユーザーのコメントを取得
const fetchUserComments = async () => {
  commentsLoading.value = true
  try {
    // 実際のAPIでは、ユーザーIDに基づいてコメントをフィルタリングするエンドポイントを使用
    const response = await axios.get('/api/user/comments', {
      headers: {
        Authorization: `Bearer ${authStore.token}`
      }
    })
    userComments.value = response.data || []
  } catch (error) {
    console.error('コメントの取得に失敗しました:', error)
    userComments.value = []
  } finally {
    commentsLoading.value = false
  }
}
</script>

<!-- @ts-ignore -->
<!-- @ts-nocheck -->
<template>
  <!-- @ts-ignore -->
  <div>
    <!-- @ts-ignore -->
    <v-row v-if="loading">
      <v-col cols="12" class="text-center">
        <v-progress-circular indeterminate color="primary" />
      </v-col>
    </v-row>

    <template v-else>
      <v-row>
        <v-col cols="12">
          <v-card class="mb-4">
            <v-card-title class="text-h5"> プロフィール </v-card-title>
            <v-card-text>
              <v-row>
                <v-col cols="12" md="6">
                  <v-list>
                    <v-list-item>
                      <template v-slot:prepend>
                        <v-icon icon="mdi-account" class="mr-2"></v-icon>
                      </template>
                      <v-list-item-title>名前</v-list-item-title>
                      <v-list-item-subtitle>{{ user?.name }}</v-list-item-subtitle>
                    </v-list-item>

                    <v-list-item>
                      <template v-slot:prepend>
                        <v-icon icon="mdi-email" class="mr-2"></v-icon>
                      </template>
                      <v-list-item-title>メールアドレス</v-list-item-title>
                      <v-list-item-subtitle>{{ user?.email }}</v-list-item-subtitle>
                    </v-list-item>

                    <v-list-item>
                      <template v-slot:prepend>
                        <v-icon icon="mdi-calendar" class="mr-2"></v-icon>
                      </template>
                      <v-list-item-title>登録日</v-list-item-title>
                      <v-list-item-subtitle>{{ formatDate(user?.created) }}</v-list-item-subtitle>
                    </v-list-item>
                  </v-list>
                </v-col>

                <v-col cols="12" md="6">
                  <v-card variant="outlined">
                    <v-card-title>アカウント情報</v-card-title>
                    <v-card-text>
                      <div class="d-flex align-center mb-2">
                        <v-icon icon="mdi-file-document-multiple" class="mr-2"></v-icon>
                        <span>投稿数: {{ userPosts.length }}</span>
                      </div>
                      <div class="d-flex align-center">
                        <v-icon icon="mdi-comment-multiple" class="mr-2"></v-icon>
                        <span>コメント数: {{ userComments.length }}</span>
                      </div>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- 投稿タブとコメントタブ -->
      <v-row>
        <v-col cols="12">
          <v-card>
            <v-tabs v-model="activeTab">
              <v-tab value="posts">
                <v-icon icon="mdi-file-document" class="mr-2"></v-icon>
                自分の投稿
              </v-tab>
              <v-tab value="comments">
                <v-icon icon="mdi-comment" class="mr-2"></v-icon>
                自分のコメント
              </v-tab>
            </v-tabs>

            <v-card-text>
              <v-window v-model="activeTab">
                <!-- 投稿タブ -->
                <v-window-item value="posts">
                  <div v-if="postsLoading" class="text-center py-4">
                    <v-progress-circular indeterminate color="primary" />
                  </div>

                  <div v-else-if="userPosts.length === 0" class="text-center py-4">
                    <p>まだ投稿がありません</p>
                    <v-btn color="primary" to="/posts/create" class="mt-2"> 新規投稿を作成 </v-btn>
                  </div>

                  <div v-else>
                    <v-list>
                      <v-list-item v-for="post in userPosts" :key="post.id" :to="`/posts/${post.slug}`">
                        <v-list-item-title class="d-flex align-center">
                          {{ post.title }}
                          <v-chip size="small" :color="getStatusColor(post.status)" class="ml-2">
                            {{ getStatusLabel(post.status) }}
                          </v-chip>
                        </v-list-item-title>

                        <v-list-item-subtitle>
                          <v-icon icon="mdi-calendar" size="small"></v-icon>
                          {{ formatDate(post.published_at || post.created) }}
                        </v-list-item-subtitle>

                        <template v-slot:append>
                          <v-btn icon variant="text" :to="`/posts/edit/${post.id}`" color="primary">
                            <v-icon>mdi-pencil</v-icon>
                          </v-btn>
                        </template>
                      </v-list-item>
                    </v-list>
                  </div>
                </v-window-item>

                <!-- コメントタブ -->
                <v-window-item value="comments">
                  <div v-if="commentsLoading" class="text-center py-4">
                    <v-progress-circular indeterminate color="primary" />
                  </div>

                  <div v-else-if="userComments.length === 0" class="text-center py-4">
                    <p>まだコメントがありません</p>
                  </div>

                  <div v-else>
                    <v-list>
                      <v-list-item
                        v-for="comment in userComments"
                        :key="comment.id"
                        :to="`/posts/${comment.post?.slug}`"
                      >
                        <v-list-item-title>
                          {{ truncateContent(comment.content) }}
                        </v-list-item-title>

                        <v-list-item-subtitle>
                          <v-icon icon="mdi-file-document" size="small"></v-icon>
                          {{ comment.post?.title }} |
                          <v-icon icon="mdi-calendar" size="small"></v-icon>
                          {{ formatDate(comment.created) }}
                        </v-list-item-subtitle>
                      </v-list-item>
                    </v-list>
                  </div>
                </v-window-item>
              </v-window>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuth } from '../composables/useAuth'
import { storeToRefs } from 'pinia'
import axios from 'axios'
import { useRouter } from 'vue-router'

interface Post {
  id: number
  title: string
  content: string
  slug: string
  status: string
  published_at: string | null
  created: string
  updated: string
}

interface Comment {
  id: number
  content: string
  created: string
  updated: string
  post?: {
    id: number
    title: string
    slug: string
  }
}

// Nuxt 3でページメタデータを定義
definePageMeta({
  middleware: ['auth']
})

const router = useRouter()
const auth = useAuth()
const authStore = auth
const { isAuthenticated: isLoggedIn, user } = storeToRefs(authStore)

const loading = ref(true)
const activeTab = ref('posts')
const userPosts = ref<Post[]>([])
const userComments = ref<Comment[]>([])
const postsLoading = ref(true)
const commentsLoading = ref(true)

// 日付をフォーマットする関数
const formatDate = (dateString?: string) => {
  if (!dateString) return '日付なし'
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('ja-JP', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

// コンテンツを切り詰める関数
const truncateContent = (content: string, maxLength = 50) => {
  if (!content) return ''
  if (content.length <= maxLength) return content
  return content.substring(0, maxLength) + '...'
}

// 投稿ステータスに応じた色を返す関数
const getStatusColor = (status: string) => {
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

// 投稿ステータスのラベルを返す関数
const getStatusLabel = (status: string) => {
  switch (status) {
    case 'published':
      return '公開'
    case 'draft':
      return '下書き'
    case 'archived':
      return 'アーカイブ'
    default:
      return 'その他'
  }
}

// 未ログインの場合はログインページにリダイレクト
onMounted(() => {
  if (!isLoggedIn.value) {
    router.push('/login')
  } else {
    loading.value = false
    fetchUserPosts()
    fetchUserComments()
  }
})

// ユーザーの投稿を取得
const fetchUserPosts = async () => {
  postsLoading.value = true
  try {
    // 実際のAPIでは、ユーザーIDに基づいて投稿をフィルタリングするエンドポイントを使用
    const response = await axios.get('/api/posts', {
      params: {
        user_id: user.value?.id,
      },
      headers: {
        Authorization: `Bearer ${authStore.token}`
      }
    })
    userPosts.value = response.data.data || []
  } catch (error) {
    console.error('投稿の取得に失敗しました:', error)
    userPosts.value = []
  } finally {
    postsLoading.value = false
  }
}

// ユーザーのコメントを取得
const fetchUserComments = async () => {
  commentsLoading.value = true
  try {
    // 実際のAPIでは、ユーザーIDに基づいてコメントをフィルタリングするエンドポイントを使用
    const response = await axios.get('/api/user/comments', {
      headers: {
        Authorization: `Bearer ${authStore.token}`
      }
    })
    userComments.value = response.data || []
  } catch (error) {
    console.error('コメントの取得に失敗しました:', error)
    userComments.value = []
  } finally {
    commentsLoading.value = false
  }
}
</script>
