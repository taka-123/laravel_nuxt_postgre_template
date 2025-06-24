<template>
  <div class="d-flex align-center justify-center" style="min-height: 100vh">
    <v-card class="pa-8 mx-4 mx-sm-auto" max-width="450" width="100%" elevation="4">
      <v-card-title class="text-h4 mb-6 text-center">ログイン</v-card-title>

      <v-form @submit.prevent="login">
        <v-alert v-if="getError" type="error" class="mb-4">
          {{ getError }}
        </v-alert>

        <v-text-field
          v-model="email"
          label="メールアドレス"
          type="email"
          :error-messages="emailError"
          required
          autocomplete="email"
          @input="clearEmailError"
        ></v-text-field>

        <v-text-field
          v-model="password"
          label="パスワード"
          type="password"
          :error-messages="passwordError"
          required
          autocomplete="current-password"
          @input="clearPasswordError"
        ></v-text-field>

        <div class="mt-6">
          <v-btn 
            type="submit" 
            color="primary" 
            size="large" 
            :loading="loading" 
            :disabled="loading"
            block
            class="mb-4"
          >
            ログイン
          </v-btn>
          
          <div class="text-center">
            <NuxtLink to="/register" class="text-decoration-none text-body-2"> 
              アカウントをお持ちでない方は新規登録
            </NuxtLink>
          </div>
        </div>
      </v-form>
    </v-card>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAuth } from '~/composables/useAuth'
import { useAuthStore } from '~/stores/auth'
import { storeToRefs } from 'pinia'
import { useRoute, useRouter } from 'vue-router'

// 認証機能を取得
const { loginAndRedirect } = useAuth()
const authStore = useAuthStore()
const { loading, getError } = storeToRefs(authStore)
const route = useRoute()
const router = useRouter()

// フォーム状態
const email = ref('')
const password = ref('')
const emailError = ref('')
const passwordError = ref('')

// バリデーション関数
const validateForm = () => {
  let isValid = true

  // メールアドレスのバリデーション
  if (!email.value) {
    emailError.value = 'メールアドレスを入力してください'
    isValid = false
  } else if (!/\S+@\S+\.\S+/.test(email.value)) {
    emailError.value = '有効なメールアドレスを入力してください'
    isValid = false
  }

  // パスワードのバリデーション
  if (!password.value) {
    passwordError.value = 'パスワードを入力してください'
    isValid = false
  } else if (password.value.length < 8) {
    passwordError.value = 'パスワードは8文字以上である必要があります'
    isValid = false
  }

  return isValid
}

// エラーメッセージをクリア
const clearEmailError = () => {
  emailError.value = ''
  // 認証エラーは手動でクリアしない（フォーム送信時のみクリア）
}

const clearPasswordError = () => {
  passwordError.value = ''
  // 認証エラーは手動でクリアしない（フォーム送信時のみクリア）
}

// ログイン処理
const login = async () => {
  if (!validateForm()) return

  // ログイン開始時にエラーをクリア
  authStore.clearError()

  try {
    // クエリパラメータからリダイレクト先を取得（存在する場合）
    const redirectPath = route.query.redirect || '/'

    await loginAndRedirect(email.value, password.value, redirectPath)
  } catch (err) {
    // エラーは認証ストアで処理済み（UIに表示される）
  }
}
</script>
