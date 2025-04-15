<template>
  <div>
    <v-row>
      <v-col cols="12">
        <v-card class="mb-4">
          <v-card-title class="text-h4">
            図書管理システムへようこそ
          </v-card-title>
          <v-card-text>
            <p class="text-body-1">
              このシステムでは、書籍の管理、貸出・返却の記録、蔵書検索などの機能を提供しています。
            </p>
            <v-alert
              v-if="!isLoggedIn"
              type="info"
              class="mt-4"
            >
              システムの全機能を利用するには、ログインが必要です。
            </v-alert>
          </v-card-text>
          <v-card-actions v-if="!isLoggedIn">
            <v-btn
              color="primary"
              to="/login"
              variant="elevated"
            >
              ログイン
            </v-btn>
            <v-btn
              color="secondary"
              to="/register"
              variant="outlined"
              class="ml-2"
            >
              新規登録
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>

    <v-row v-if="isLoggedIn">
      <v-col cols="12" md="4">
        <v-card>
          <v-card-title>書籍管理</v-card-title>
          <v-card-text>
            システム内の書籍を管理します。新規登録、編集、削除が可能です。
          </v-card-text>
          <v-card-actions>
            <v-btn color="primary" to="/books" variant="text">
              書籍一覧へ
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card>
          <v-card-title>貸出管理</v-card-title>
          <v-card-text>
            書籍の貸出・返却を管理します。貸出履歴の確認も可能です。
          </v-card-text>
          <v-card-actions>
            <v-btn color="primary" to="/loans" variant="text">
              貸出管理へ
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card>
          <v-card-title>ユーザー管理</v-card-title>
          <v-card-text>
            システムを利用するユーザーを管理します。権限設定も可能です。
          </v-card-text>
          <v-card-actions>
            <v-btn color="primary" to="/users" variant="text">
              ユーザー管理へ
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '../stores/auth';
import { storeToRefs } from 'pinia';

const authStore = useAuthStore();
const { isLoggedIn } = storeToRefs(authStore);
</script>
