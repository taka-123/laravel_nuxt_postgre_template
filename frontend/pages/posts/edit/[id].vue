<template>
  <div>
    <v-row v-if="loading">
      <v-col cols="12" class="text-center">
        <v-progress-circular indeterminate color="primary" />
      </v-col>
    </v-row>

    <template v-else-if="post">
      <v-row>
        <v-col cols="12">
          <v-card>
            <v-card-title class="text-h5"> 投稿を編集 </v-card-title>
            <v-card-text>
              <v-form ref="form" @submit.prevent="updatePost">
                <v-text-field
                  v-model="post.title"
                  label="タイトル"
                  variant="outlined"
                  :rules="[
                    (v) => !!v || 'タイトルは必須です',
                    (v) => v.length <= 255 || 'タイトルは255文字以内で入力してください',
                  ]"
                  required
                ></v-text-field>

                <v-textarea
                  v-model="post.content"
                  label="内容"
                  variant="outlined"
                  rows="10"
                  :rules="[(v) => !!v || '内容は必須です']"
                  required
                ></v-textarea>

                <v-text-field
                  v-model="post.featured_image"
                  label="アイキャッチ画像URL（任意）"
                  variant="outlined"
                  hint="画像のURLを入力してください"
                  persistent-hint
                ></v-text-field>

                <v-select
                  v-model="post.status"
                  :items="statusOptions"
                  label="公開ステータス"
                  variant="outlined"
                  required
                ></v-select>

                <div class="d-flex justify-end mt-4">
                  <v-btn color="grey-darken-1" variant="text" class="mr-2" :to="`/posts/${post.slug}`">
                    キャンセル
                  </v-btn>
                  <v-btn color="primary" type="submit" :loading="submitting"> 更新する </v-btn>
                </div>
              </v-form>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- プレビュー -->
      <v-row>
        <v-col cols="12">
          <v-card>
            <v-card-title class="text-h5"> プレビュー </v-card-title>
            <v-card-text>
              <v-img
                v-if="post.featured_image"
                :src="post.featured_image"
                height="300"
                cover
                class="bg-grey-lighten-2 mb-4"
              ></v-img>

              <h2 class="text-h4 mb-2">{{ post.title || 'タイトルなし' }}</h2>

              <v-chip :color="getStatusColor(post.status)" class="mb-4">
                {{ getStatusLabel(post.status) }}
              </v-chip>

              <div class="text-body-1 post-content">
                {{ post.content || '内容なし' }}
              </div>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </template>

    <v-row v-else>
      <v-col cols="12">
        <v-alert type="error"> 投稿が見つかりませんでした </v-alert>
        <div class="text-center mt-4">
          <v-btn color="primary" to="/posts"> 投稿一覧に戻る </v-btn>
        </div>
      </v-col>
    </v-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '../../../stores/auth'
import { storeToRefs } from 'pinia'
import axios from 'axios'
import { useRoute, useRouter } from 'vue-router'

interface Post {
  id: number
  title: string
  content: string
  slug: string
  featured_image: string | null
  status: string
  published_at: string | null
  created_at: string
  user_id: number
}

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const { isLoggedIn, user } = storeToRefs(authStore)
const form = ref(null)

const postId = computed(() => route.params.id as string)
const post = ref<Post | null>(null)
const loading = ref(true)
const submitting = ref(false)

const statusOptions = [
  { title: '下書き', value: 'draft' },
  { title: '公開', value: 'published' },
  { title: 'アーカイブ', value: 'archived' },
]

// 投稿詳細を取得
const fetchPost = async () => {
  loading.value = true
  try {
    const response = await axios.get(`/api/posts/${postId.value}`)
    post.value = response.data

    // 投稿者本人または管理者でない場合はリダイレクト
    if (!isLoggedIn.value || (user.value?.id !== post.value.user_id && user.value?.email !== 'admin@example.com')) {
      router.push('/posts')
    }
  } catch (error) {
    console.error('投稿の取得に失敗しました:', error)
    post.value = null
  } finally {
    loading.value = false
  }
}

// 投稿を更新
const updatePost = async () => {
  if (!post.value) return

  // @ts-ignore
  const { valid } = await form.value.validate()

  if (!valid) return

  submitting.value = true
  try {
    await axios.put(`/api/posts/${post.value.id}`, {
      title: post.value.title,
      content: post.value.content,
      featured_image: post.value.featured_image,
      status: post.value.status,
    })

    router.push(`/posts/${post.value.slug}`)
  } catch (error) {
    console.error('投稿の更新に失敗しました:', error)
    // エラー処理
  } finally {
    submitting.value = false
  }
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

// 未ログインの場合はログインページにリダイレクト
onMounted(() => {
  if (!isLoggedIn.value) {
    router.push('/login')
  } else {
    fetchPost()
  }
})
</script>

<style scoped>
.post-content {
  white-space: pre-line;
}
</style>
