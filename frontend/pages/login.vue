<template>
  <div>
    <v-row justify="center">
      <v-col cols="12" sm="8" md="6" lg="4">
        <v-card class="mt-5">
          <v-card-title class="text-h5 text-center">
            ログイン
          </v-card-title>
          <v-card-text>
            <v-alert
              v-if="errorMessage"
              type="error"
              class="mb-4"
              closable
              @click:close="errorMessage = ''"
            >
              {{ errorMessage }}
            </v-alert>

            <v-form @submit.prevent="login" ref="form">
              <v-text-field
                v-model="email"
                label="メールアドレス"
                type="email"
                required
                :rules="[v => !!v || 'メールアドレスは必須です', v => /.+@.+\..+/.test(v) || '有効なメールアドレスを入力してください']"
                variant="outlined"
                prepend-inner-icon="mdi-email"
              ></v-text-field>

              <v-text-field
                v-model="password"
                label="パスワード"
                type="password"
                required
                :rules="[v => !!v || 'パスワードは必須です', v => v.length >= 8 || 'パスワードは8文字以上必要です']"
                variant="outlined"
                prepend-inner-icon="mdi-lock"
              ></v-text-field>

              <div class="d-flex justify-space-between align-center mt-2">
                <v-checkbox
                  v-model="rememberMe"
                  label="ログイン状態を保持"
                  hide-details
                ></v-checkbox>
                <v-btn
                  text
                  color="primary"
                  to="/forgot-password"
                  variant="text"
                  size="small"
                >
                  パスワードをお忘れですか？
                </v-btn>
              </div>
            </v-form>
          </v-card-text>

          <v-card-actions class="px-4 pb-4">
            <v-btn
              color="primary"
              block
              :loading="loading"
              @click="login"
              variant="elevated"
              size="large"
            >
              ログイン
            </v-btn>
          </v-card-actions>

          <v-card-text class="text-center pt-0">
            アカウントをお持ちでないですか？
            <v-btn
              to="/register"
              variant="text"
              color="primary"
              size="small"
            >
              新規登録
            </v-btn>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useAuthStore } from '~/stores/auth';

const authStore = useAuthStore();
const router = useRouter();

const email = ref('');
const password = ref('');
const rememberMe = ref(false);
const errorMessage = ref('');
const loading = ref(false);
const form = ref<any>(null);

const login = async () => {
  const { valid } = await form.value.validate();
  
  if (!valid) return;
  
  loading.value = true;
  
  try {
    const result = await authStore.login(email.value, password.value);
    
    if (result.success) {
      // ログイン成功
      router.push('/');
    } else {
      // ログイン失敗
      errorMessage.value = result.message || 'ログインに失敗しました。';
    }
  } catch (error: any) {
    errorMessage.value = error.message || 'エラーが発生しました。';
  } finally {
    loading.value = false;
  }
};
</script>
