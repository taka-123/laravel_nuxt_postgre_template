<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      <v-app-bar-title>図書管理システム</v-app-bar-title>
      <v-spacer></v-spacer>
      <v-btn to="/" text>ホーム</v-btn>
      <v-btn to="/books" text>書籍一覧</v-btn>
      <v-btn to="/barcode" text>バーコード読取</v-btn>
      <v-btn to="/generate-barcode" text>バーコード生成</v-btn>
      <template v-if="isAuthenticated">
        <v-btn to="/profile" text>プロフィール</v-btn>
        <v-btn @click="handleLogout" text>ログアウト</v-btn>
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

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';

// 認証状態（実際には適切な認証システムと連携する）
const isAuthenticated = ref(false);
const router = useRouter();

// ログアウト処理
const handleLogout = async () => {
  // ここに実際のログアウト処理を実装
  isAuthenticated.value = false;
  router.push('/login');
};
</script>
