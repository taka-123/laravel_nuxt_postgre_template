<template>
  <v-container>
    <v-card class="mb-6 pa-4">
      <v-card-title class="text-h4 font-weight-bold mb-4">バーコード・ISBN読み取り</v-card-title>

      <v-row>
        <!-- カメラセクション -->
        <v-col cols="12" md="6">
          <v-card>
            <v-card-title class="text-h5">カメラ読み取り</v-card-title>
            <v-card-text>
              <!-- ZXing用のビデオコンテナ -->
              <div v-show="isCameraActive" class="video-container position-relative mb-4">
                <video id="video-element" class="w-100 h-100"></video>
                <div class="scan-area"></div>
              </div>

              <!-- カメラ非アクティブ表示 -->
              <div
                v-show="!isCameraActive"
                class="video-container position-relative mb-4 d-flex align-center justify-center"
                style="min-height: 300px; background-color: #f5f5f5"
              >
                <span class="text-grey">カメラが起動していません</span>
              </div>

              <v-row>
                <v-col>
                  <v-btn block color="primary" :disabled="isCameraActive" @click="startCamera"> カメラを起動 </v-btn>
                </v-col>
                <v-col>
                  <v-btn block color="error" :disabled="!isCameraActive" @click="stopCamera"> カメラを停止 </v-btn>
                </v-col>
              </v-row>

              <v-alert v-if="isCameraActive" type="info" class="mt-4" variant="tonal">
                <div class="font-weight-medium">読み取りのヒント:</div>
                <ul class="ps-4 mb-0">
                  <li>ISBNバーコードにカメラを近づけてください（10-20cm程度）</li>
                  <li>バーコードが明るい場所にあることを確認してください</li>
                  <li>バーコードを画面の中央に合わせてください</li>
                </ul>
              </v-alert>

              <v-alert v-if="lastScannedCode" type="success" class="mt-4">
                <div class="font-weight-medium">読み取り結果:</div>
                <div class="text-body-1 word-break">{{ lastScannedCode }}</div>
                <div v-if="isIsbn" class="text-caption text-success">ISBN形式で読み取りました</div>
              </v-alert>
            </v-card-text>
          </v-card>
        </v-col>

        <!-- 結果セクション -->
        <v-col cols="12" md="6">
          <v-card v-if="isLoading" min-height="300" class="d-flex align-center justify-center">
            <div class="text-center">
              <v-progress-circular indeterminate color="primary"></v-progress-circular>
              <div class="mt-2">読み取り中...</div>
            </div>
          </v-card>

          <v-card v-else-if="bookInfo">
            <v-card-title class="text-h5">書籍情報</v-card-title>
            <v-card-text>
              <v-row>
                <v-col v-if="bookInfo.cover_image" cols="4">
                  <v-img :src="bookInfo.cover_image" alt="表紙" class="rounded-lg" cover></v-img>
                </v-col>

                <v-col>
                  <h3 class="text-h6 font-weight-bold">{{ bookInfo.title }}</h3>
                  <p v-if="bookInfo.author" class="text-body-1">著者: {{ bookInfo.author }}</p>
                  <p v-if="bookInfo.publisher" class="text-body-1">出版社: {{ bookInfo.publisher }}</p>
                  <p v-if="bookInfo.publication_year" class="text-body-1">出版年: {{ bookInfo.publication_year }}</p>
                  <p v-if="bookInfo.isbn" class="text-body-1">ISBN: {{ bookInfo.isbn }}</p>

                  <div v-if="bookInfo.description" class="mt-4">
                    <h4 class="font-weight-medium mb-1">概要:</h4>
                    <p class="text-body-2">{{ bookInfo.description }}</p>
                  </div>

                  <v-btn color="success" class="mt-4" @click="registerBook"> この本を登録する </v-btn>
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>

          <v-card v-else-if="error">
            <v-card-text>
              <v-alert type="error" variant="tonal">
                {{ error }}
              </v-alert>
            </v-card-text>
          </v-card>

          <v-card v-else min-height="300" class="d-flex align-center justify-center flex-column pa-4">
            <div class="text-grey text-h4 mb-4">📚</div>
            <span class="text-grey text-center">ISBNを読み取るか、手動で入力してください</span>

            <!-- 手動入力オプション -->
            <v-divider class="my-4 w-100"></v-divider>
            <p class="text-grey mb-2">ISBNを手動で入力:</p>
            <v-form @submit.prevent="searchManualIsbn">
              <v-row>
                <v-col cols="8">
                  <v-text-field
                    v-model="manualIsbn"
                    label="ISBN"
                    placeholder="例: 9784167158057"
                    variant="outlined"
                    density="compact"
                  ></v-text-field>
                </v-col>
                <v-col cols="4">
                  <v-btn
                    color="primary"
                    block
                    @click="searchManualIsbn"
                    :disabled="!manualIsbn || manualIsbn.length < 10"
                  >
                    検索
                  </v-btn>
                </v-col>
              </v-row>
            </v-form>
          </v-card>
        </v-col>
      </v-row>
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

    // ISBNの場合は書籍情報を取得
    if (isIsbn.value) {
      // 一時的にカメラを停止して書籍情報を取得
      stopCamera()
      fetchBookInfo(scannedCode)
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

// 手動入力されたISBNを検索
const searchManualIsbn = () => {
  if (!manualIsbn.value) return

  isIsbn.value = isValidIsbn(manualIsbn.value)

  if (isIsbn.value) {
    fetchBookInfo(manualIsbn.value)
    lastScannedCode.value = manualIsbn.value
  } else {
    error.value = '有効なISBN形式ではありません'
  }
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

// 本を登録する
const registerBook = async () => {
  if (!bookInfo.value) return

  try {
    isLoading.value = true
    error.value = null

    const { data } = await api.post('/books', bookInfo.value)

    // 登録成功
    alert('書籍を登録しました！')

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
</script>

<style scoped>
.video-container {
  position: relative;
  overflow: hidden;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  min-height: 300px;
}

#scanner-container {
  position: relative;
  overflow: hidden;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  min-height: 300px;
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
  border: 2px solid #1976d2;
  border-radius: 8px;
  box-shadow: 0 0 0 4000px rgba(0, 0, 0, 0.1);
  animation: pulse 2s infinite;
  z-index: 1;
  pointer-events: none;
}

@keyframes pulse {
  0% {
    border-color: rgba(25, 118, 210, 0.5);
  }
  50% {
    border-color: rgba(25, 118, 210, 1);
  }
  100% {
    border-color: rgba(25, 118, 210, 0.5);
  }
}
</style>
