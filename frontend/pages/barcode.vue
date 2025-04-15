<template>
  <v-container>
    <v-card class="mb-6 elevation-2 rounded-lg">
      <v-card-title class="text-h4 font-weight-bold pa-4 pb-2">
        <v-icon size="x-large" color="primary" class="me-2">mdi-barcode-scan</v-icon>
        バーコード・ISBN読み取り
      </v-card-title>
      <v-card-subtitle class="px-4 pb-0">ISBNから書籍情報を検索できます</v-card-subtitle>

      <v-card-text class="pt-4">
        <v-row>
          <!-- カメラセクション -->
          <v-col cols="12" md="6">
            <v-card class="mb-4 elevation-1 rounded-lg">
              <v-card-title class="text-h5 d-flex align-center">
                <v-icon color="primary" class="me-2">mdi-camera</v-icon>
                カメラ読み取り
              </v-card-title>
              <v-card-text>
                <!-- ZXing用のビデオコンテナ -->
                <div v-show="isCameraActive" class="video-container position-relative mb-4">
                  <video id="video-element" class="w-100 h-100"></video>
                  <div class="scan-area"><span></span></div>
                  <v-overlay
                    v-if="isInitializing"
                    :model-value="isInitializing"
                    class="align-center justify-center"
                    persistent
                  >
                    <v-progress-circular indeterminate color="primary"></v-progress-circular>
                    <div class="mt-2 text-white">カメラ起動中...</div>
                  </v-overlay>
                </div>

                <!-- カメラ非アクティブ表示 -->
                <div
                  v-show="!isCameraActive"
                  class="video-container position-relative mb-4 d-flex align-center justify-center"
                  style="min-height: 300px; background-color: #f0f2f5; border-radius: 8px; border: 1px dashed #ccc"
                >
                  <div class="text-center">
                    <v-icon size="x-large" color="grey-lighten-1" class="mb-2">mdi-camera-off</v-icon>
                    <div class="text-grey">カメラが起動していません</div>
                    <v-btn
                      color="primary"
                      variant="outlined"
                      class="mt-3"
                      prepend-icon="mdi-camera"
                      @click="startCamera"
                    >
                      カメラを起動
                    </v-btn>
                  </div>
                </div>

                <v-row>
                  <v-col cols="12">
                    <v-btn-group variant="outlined" class="w-100">
                      <v-btn
                        color="primary"
                        :variant="isCameraActive ? 'outlined' : 'elevated'"
                        prepend-icon="mdi-camera"
                        class="flex-grow-1"
                        :disabled="isCameraActive"
                        @click="startCamera"
                      >
                        カメラを起動
                      </v-btn>
                      <v-btn
                        color="error"
                        :variant="!isCameraActive ? 'outlined' : 'elevated'"
                        prepend-icon="mdi-camera-off"
                        class="flex-grow-1"
                        :disabled="!isCameraActive"
                        @click="stopCamera"
                      >
                        カメラを停止
                      </v-btn>
                    </v-btn-group>
                  </v-col>
                </v-row>

                <v-alert v-if="isCameraActive" type="info" class="mt-4" variant="tonal" border="start">
                  <div class="font-weight-medium">読み取りのヒント:</div>
                  <ul class="ps-4 mb-0">
                    <li>ISBNバーコードにカメラを近づけてください（10-20cm程度）</li>
                    <li>バーコードが明るい場所にあることを確認してください</li>
                    <li>バーコードを画面の中央に合わせてください</li>
                  </ul>
                </v-alert>

                <v-alert v-if="lastScannedCode" type="success" class="mt-4" border="start">
                  <div class="font-weight-medium">読み取り結果:</div>
                  <div class="text-body-1 word-break">{{ lastScannedCode }}</div>
                  <div class="text-caption" :class="isIsbn ? 'text-success' : 'text-primary'">
                    {{ isIsbn ? 'ISBN形式で読み取りました' : '独自バーコードとして読み取りました' }}
                  </div>
                </v-alert>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- 結果セクション -->
          <v-col cols="12" md="6">
            <v-card v-if="isLoading" min-height="300" class="d-flex align-center justify-center elevation-1 rounded-lg">
              <div class="text-center">
                <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
                <div class="mt-4 text-body-1">読み取り中...</div>
              </div>
            </v-card>

            <v-card v-else-if="bookInfo" class="elevation-1 rounded-lg">
              <v-card-title class="text-h5 d-flex align-center">
                <v-icon color="primary" class="me-2">mdi-book-open-page-variant</v-icon>
                書籍情報
              </v-card-title>
              <v-card-text class="pt-2">
                <v-row>
                  <v-col v-if="bookInfo.cover_image" cols="4">
                    <v-img
                      :src="bookInfo.cover_image"
                      alt="表紙"
                      class="rounded-lg elevation-1"
                      contain
                      height="250"
                    ></v-img>
                  </v-col>

                  <v-col>
                    <h3 class="text-h6 font-weight-bold">{{ bookInfo.title }}</h3>
                    <v-chip v-if="bookInfo.isbn" size="small" color="primary" variant="outlined" class="mt-1">
                      ISBN: {{ bookInfo.isbn }}
                    </v-chip>

                    <v-list density="compact" class="pa-0 mt-2 bg-transparent">
                      <v-list-item v-if="bookInfo.author" prepend-icon="mdi-account">
                        <template v-slot:title>{{ bookInfo.author }}</template>
                        <template v-slot:subtitle>著者</template>
                      </v-list-item>

                      <v-list-item v-if="bookInfo.publisher" prepend-icon="mdi-office-building">
                        <template v-slot:title>{{ bookInfo.publisher }}</template>
                        <template v-slot:subtitle>出版社</template>
                      </v-list-item>

                      <v-list-item v-if="bookInfo.publication_year" prepend-icon="mdi-calendar">
                        <template v-slot:title>{{ bookInfo.publication_year }}</template>
                        <template v-slot:subtitle>出版年</template>
                      </v-list-item>
                    </v-list>

                    <div v-if="bookInfo.description" class="mt-4">
                      <h4 class="font-weight-medium mb-1">概要:</h4>
                      <p class="text-body-2">{{ bookInfo.description }}</p>
                    </div>

                    <v-btn
                      color="success"
                      class="mt-4"
                      prepend-icon="mdi-plus-circle"
                      variant="elevated"
                      @click="registerBook"
                    >
                      この本を登録する
                    </v-btn>
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>

            <v-card v-else-if="error" class="elevation-1 rounded-lg">
              <v-card-text>
                <v-alert type="error" variant="tonal" border="start">
                  <template v-slot:prepend>
                    <v-icon>mdi-alert-circle</v-icon>
                  </template>
                  {{ error }}
                </v-alert>
              </v-card-text>
            </v-card>

            <v-card v-else class="d-flex align-center justify-center flex-column pa-6 elevation-1 rounded-lg">
              <v-icon size="x-large" color="primary" class="mb-3">mdi-book-search</v-icon>
              <span class="text-h6 text-center mb-3">バーコードを読み取るか、手動で入力してください</span>

              <!-- 手動入力オプション -->
              <v-divider class="my-4 w-100"></v-divider>
              <v-form @submit.prevent="searchManualIsbn" class="w-100">
                <v-text-field
                  v-model="manualIsbn"
                  label="ISBNまたはバーコードを手動で入力"
                  placeholder="例: 9784167158057 または LIBxxxxx"
                  variant="outlined"
                  prepend-inner-icon="mdi-barcode"
                  class="mb-3"
                ></v-text-field>
                <v-btn
                  color="primary"
                  block
                  @click="searchManualIsbn"
                  :disabled="!manualIsbn || manualIsbn.length < 3"
                  prepend-icon="mdi-magnify"
                >
                  検索
                </v-btn>
              </v-form>
            </v-card>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { BrowserMultiFormatReader, NotFoundException } from '@zxing/library'
import { useApi } from '~/composables/useApi'

// API設定
const api = useApi()

// 状態変数
const isCameraActive = ref(false)
const isInitializing = ref(false)
const scannerInitialized = ref(false)
const lastScannedCode = ref('')
const isIsbn = ref(false)
const bookInfo = ref(null)
const manualIsbn = ref('')
const isLoading = ref(false)
const error = ref(null)

// ZXing用の変数
const codeReader = ref(null)
const videoElement = ref(null)

// カメラを起動
const startCamera = async () => {
  try {
    if (isCameraActive.value) return
    isInitializing.value = true
    error.value = null

    // DOMが更新されるのを待つ
    await nextTick()

    // バーコードスキャナーを初期化
    await initializeBarcodeScanner()
  } catch (err) {
    console.error('カメラ起動エラー:', err)
    error.value = 'カメラの起動に失敗しました: ' + err.message
    isCameraActive.value = false
  } finally {
    isInitializing.value = false
  }
}

const initializeBarcodeScanner = async () => {
  try {
    // ZXingのBrowserMultiFormatReaderを初期化
    codeReader.value = new BrowserMultiFormatReader()

    // video要素を取得
    videoElement.value = document.getElementById('video-element')
    if (!videoElement.value) {
      throw new Error('Video要素が見つかりません')
    }

    // カメラの制約を設定（リアカメラを優先）
    const constraints = {
      video: {
        facingMode: 'environment',
        width: { ideal: 1280 },
        height: { ideal: 720 },
      },
      audio: false,
    }

    // デコード結果を処理するコールバック
    await codeReader.value
      .decodeFromConstraints(constraints, videoElement.value, (result, err) => {
        if (result) {
          const barcode = result.getText()
          handleBarcodeDetected(barcode)
        }
        if (err && !(err instanceof NotFoundException)) {
          console.error('Decode error:', err)
        }
      })
      .catch((err) => {
        console.error('Error accessing camera:', err)
        error.value = 'カメラへのアクセスに失敗しました: ' + err.message
        isCameraActive.value = false
      })

    scannerInitialized.value = true
    isCameraActive.value = true
  } catch (err) {
    console.error('バーコードスキャナー初期化エラー:', err)
    error.value = 'スキャナーの初期化に失敗しました: ' + err.message
    isCameraActive.value = false
  }
}

// 検出されたバーコードを処理
const handleBarcodeDetected = (scannedCode) => {
  if (!scannedCode) return

  // 同じコードの連続スキャンを防止
  if (lastScannedCode.value !== scannedCode) {
    lastScannedCode.value = scannedCode

    // スキャンされたコードがISBNかどうかを判定
    isIsbn.value = isValidIsbn(scannedCode)

    // カメラを一時停止
    stopCamera()

    // ISBNの場合は書籍情報を取得
    if (isIsbn.value) {
      fetchBookInfo(scannedCode)
    } else {
      // ISBNでない場合は独自バーコードとして処理
      fetchBookByBarcode(scannedCode)
    }
  }
}

// カメラを停止
const stopCamera = () => {
  if (codeReader.value && scannerInitialized.value) {
    codeReader.value.reset()
    scannerInitialized.value = false
    isCameraActive.value = false
  }
  isLoading.value = false
}

// コンポーネント破棄時にカメラを停止
onBeforeUnmount(() => {
  stopCamera()
})

// ISBNが有効かどうかを判定
const isValidIsbn = (code) => {
  // 数字とハイフン以外の文字を削除
  const cleanedCode = code.replace(/[^0-9X-]/g, '')

  // ハイフンを削除
  const isbn = cleanedCode.replace(/-/g, '')

  // ISBN-10またはISBN-13の長さチェック
  return isbn.length === 10 || isbn.length === 13
}

// 手動入力されたバーコードを検索
const searchManualIsbn = () => {
  if (!manualIsbn.value) return

  isIsbn.value = isValidIsbn(manualIsbn.value)

  if (isIsbn.value) {
    fetchBookInfo(manualIsbn.value)
  } else {
    // ISBNでない場合は独自バーコードとして検索を試みる
    fetchBookByBarcode(manualIsbn.value)
  }
  lastScannedCode.value = manualIsbn.value
}

// ISBN情報を取得
const fetchBookInfo = async (isbn) => {
  try {
    isLoading.value = true
    error.value = null
    bookInfo.value = null

    // ハイフンを削除したISBNを使用
    const cleanIsbn = isbn.replace(/-/g, '')

    const { data } = await api.post('/isbn/fetch', {
      isbn: cleanIsbn,
    })

    bookInfo.value = data
  } catch (err) {
    console.error('ISBN情報の取得に失敗しました', err)

    if (err.response?.status === 404) {
      error.value = 'この ISBN に該当する書籍が見つかりませんでした'
    } else if (err.response?.status === 422) {
      error.value = 'ISBN形式が正しくありません'
    } else {
      error.value = `書籍情報の取得中にエラーが発生しました: ${err.message || 'Unknown error'}`
    }
  } finally {
    isLoading.value = false
  }
}

// 独自バーコードから書籍情報を取得
const fetchBookByBarcode = async (barcode) => {
  try {
    isLoading.value = true
    error.value = null
    bookInfo.value = null

    const { data } = await api.post('/barcode/search', {
      barcode: barcode,
    })

    bookInfo.value = data
    // ISBNのフラグは偽にする（独自バーコードとして処理）
    isIsbn.value = false
  } catch (err) {
    console.error('バーコードからの書籍情報の取得に失敗しました', err)

    if (err.response?.status === 404) {
      error.value = 'このバーコードに該当する書籍が見つかりませんでした'
    } else if (err.response?.status === 422) {
      error.value = 'バーコード形式が正しくありません'
    } else {
      error.value = `書籍情報の取得中にエラーが発生しました: ${err.message || 'Unknown error'}`
    }
  } finally {
    isLoading.value = false
  }
}

// 本を登録する
const registerBook = async () => {
  if (!bookInfo.value) return

  try {
    isLoading.value = true
    error.value = null

    const { data } = await api.post('/books', bookInfo.value)

    // 登録成功
    showSuccessMessage('書籍を登録しました！')

    // フォームをリセット
    bookInfo.value = null
    lastScannedCode.value = ''
    manualIsbn.value = ''
  } catch (err) {
    console.error('書籍の登録に失敗しました', err)

    if (err.response?.data?.errors) {
      error.value = Object.values(err.response.data.errors).flat().join('\n')
    } else {
      error.value = '書籍の登録中にエラーが発生しました'
    }
  } finally {
    isLoading.value = false
  }
}

// 成功メッセージを表示（実際の実装はプロジェクトによって異なる）
const showSuccessMessage = (message) => {
  // ここではシンプルなアラートを使用
  // 実際のプロジェクトではスナックバーやトーストコンポーネントを使うことを推奨
  alert(message)
}
</script>

<style scoped>
.video-container {
  position: relative;
  overflow: hidden;
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  min-height: 300px;
  background-color: #000;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

#video-element {
  position: relative;
  width: 100%;
  height: 100%;
  min-height: 300px;
  object-fit: cover;
}

.word-break {
  word-break: break-all;
}

.scan-area {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 70%;
  height: 40%;
  border: 3px solid #1976d2;
  border-radius: 12px;
  box-shadow: 0 0 0 4000px rgba(0, 0, 0, 0.3);
  animation: pulse 2s infinite;
  z-index: 1;
  pointer-events: none;
}

/* 四隅のコーナーマーカー */
.scan-area::before,
.scan-area::after,
.scan-area > span::before,
.scan-area > span::after {
  content: '';
  position: absolute;
  width: 20px;
  height: 20px;
  border-color: #1976d2;
  border-style: solid;
}

/* 左上 */
.scan-area::before {
  top: -3px;
  left: -3px;
  border-width: 3px 0 0 3px;
  border-radius: 8px 0 0 0;
}

/* 右上 */
.scan-area::after {
  top: -3px;
  right: -3px;
  border-width: 3px 3px 0 0;
  border-radius: 0 8px 0 0;
}

/* 左下 */
.scan-area > span::before {
  bottom: -3px;
  left: -3px;
  border-width: 0 0 3px 3px;
  border-radius: 0 0 0 8px;
}

/* 右下 */
.scan-area > span::after {
  bottom: -3px;
  right: -3px;
  border-width: 0 3px 3px 0;
  border-radius: 0 0 8px 0;
}

@keyframes pulse {
  0% {
    border-color: rgba(25, 118, 210, 0.5);
    box-shadow: 0 0 0 4000px rgba(0, 0, 0, 0.2);
  }
  50% {
    border-color: rgba(25, 118, 210, 1);
    box-shadow: 0 0 0 4000px rgba(0, 0, 0, 0.35);
  }
  100% {
    border-color: rgba(25, 118, 210, 0.5);
    box-shadow: 0 0 0 4000px rgba(0, 0, 0, 0.2);
  }
}
</style>
