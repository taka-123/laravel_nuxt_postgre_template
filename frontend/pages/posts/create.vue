<template>
  <div>
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-card-title class="text-h5"> 新規投稿 </v-card-title>
          <v-card-text>
            <v-form ref="form" @submit.prevent="submitPost">
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
                <v-btn color="grey-darken-1" variant="text" class="mr-2" to="/posts"> キャンセル </v-btn>
                <v-btn color="primary" type="submit" :loading="submitting"> 投稿する </v-btn>
              </div>
            </v-form>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- プレビュー -->
    <v-row v-if="post.title || post.content">
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
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../../stores/auth'
import { storeToRefs } from 'pinia'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const authStore = useAuthStore()
const { isLoggedIn, user } = storeToRefs(authStore)
const form = ref(null)
const submitting = ref(false)

// 未ログインの場合はログインページにリダイレクト
onMounted(() => {
  if (!isLoggedIn.value) {
    router.push('/login')
  }
})

const post = ref({
  title: '',
  content: '',
  featured_image: '',
  status: 'draft',
})

const statusOptions = [
  { title: '下書き', value: 'draft' },
  { title: '公開', value: 'published' },
  { title: 'アーカイブ', value: 'archived' },
]

// 投稿を送信
const submitPost = async () => {
  // @ts-ignore
  const { valid } = await form.value.validate()

  if (!valid) return

  submitting.value = true
  try {
    const response = await axios.post('/api/posts', post.value)
    router.push(`/posts/${response.data.slug}`)
  } catch (error) {
    console.error('投稿の作成に失敗しました:', error)
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
</script>

<style scoped>
.post-content {
  white-space: pre-line;
}
</style>
