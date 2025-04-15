<template>
  <div class="d-flex align-center justify-center" style="height: 100vh">
    <v-card class="pa-8 mx-auto" max-width="500">
      <v-card-title class="text-h4 mb-4">ログイン</v-card-title>

      <v-form @submit.prevent="login">
        <v-alert v-if="error" type="error" class="mb-4">
          {{ error }}
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

        <div class="d-flex justify-space-between align-center mt-4">
          <v-btn type="submit" color="primary" size="large" :loading="isLoading" :disabled="isLoading">
            ログイン
          </v-btn>
          <NuxtLink to="/register" class="text-decoration-none"> 新規登録はこちら </NuxtLink>
        </div>
      </v-form>
    </v-card>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAuth } from '~/composables/useAuth'
import { useRoute, useRouter } from 'vue-router'

// 認証機能を取得
const { loginAndRedirect, isLoading, getError } = useAuth()
const route = useRoute()
const router = useRouter()

// フォーム状態
const email = ref('')
const password = ref('')
const emailError = ref('')
const passwordError = ref('')

// エラーメッセージ
const error = computed(() => getError)

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
}

const clearPasswordError = () => {
  passwordError.value = ''
}

// ログイン処理
const login = async () => {
  if (!validateForm()) return

  try {
    // クエリパラメータからリダイレクト先を取得（存在する場合）
    const redirectPath = route.query.redirect || '/'

    await loginAndRedirect(email.value, password.value, redirectPath)
  } catch (err) {
    console.error('ログインエラー:', err)
  }
}
</script>
