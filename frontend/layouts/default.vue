<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      <v-app-bar-title>図書管理システム</v-app-bar-title>
      <v-spacer></v-spacer>
      <v-btn to="/" text>ホーム</v-btn>
      <v-btn to="/books" text>書籍一覧</v-btn>
      <template v-if="isLoggedIn">
        <v-btn to="/profile" text>プロフィール</v-btn>
        <v-btn @click="logout" text>ログアウト</v-btn>
      </template>
      <template v-else>
        <v-btn to="/login" text>ログイン</v-btn>
        <v-btn to="/register" text>登録</v-btn>
      </template>
    </v-app-bar>

    <v-main>
      <v-container>
        <slot />
      </v-container>
    </v-main>

    <v-footer app color="primary" dark>
      <v-row justify="center" no-gutters>
        <span>&copy; {{ new Date().getFullYear() }} - 図書管理システム</span>
      </v-row>
    </v-footer>
  </v-app>
</template>

<script setup lang="ts">
import { useAuthStore } from '~/stores/auth';
import { storeToRefs } from 'pinia';

const authStore = useAuthStore();
const { isLoggedIn } = storeToRefs(authStore);

const logout = async () => {
  await authStore.logout();
  navigateTo('/login');
};
</script>
