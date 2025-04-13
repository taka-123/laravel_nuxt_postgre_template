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
              <!-- QuaggaJSコンテナ -->
              <div v-show="isCameraActive" id="scanner-container" class="position-relative mb-4" style="min-height: 300px;">
                <div id="scanner" class="w-100 h-100"></div>
                <div class="scan-area"></div>
              </div>

              <!-- カメラ非アクティブ表示 -->
              <div v-show="!isCameraActive" class="video-container position-relative mb-4 d-flex align-center justify-center" style="min-height: 300px; background-color: #f5f5f5;">
                <span class="text-grey">カメラが起動していません</span>
              </div>

              <v-row>
                <v-col>
                  <v-btn
                    block
                    color="primary"
                    :disabled="isCameraActive"
                    @click="startCamera"
                  >
                    カメラを起動
                  </v-btn>
                </v-col>
                <v-col>
                  <v-btn
                    block
                    color="error"
                    :disabled="!isCameraActive"
                    @click="stopCamera"
                  >
                    カメラを停止
                  </v-btn>
                </v-col>
              </v-row>

              <v-alert
                v-if="isCameraActive"
                type="info"
                class="mt-4"
                variant="tonal"
              >
                <div class="font-weight-medium">読み取りのヒント:</div>
                <ul class="ps-4 mb-0">
                  <li>ISBNバーコードにカメラを近づけてください（10-20cm程度）</li>
                  <li>バーコードが明るい場所にあることを確認してください</li>
                  <li>バーコードを画面の中央に合わせてください</li>
                </ul>
              </v-alert>

              <v-alert
                v-if="lastScannedCode"
                type="success"
                class="mt-4"
              >
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
                  <v-img
                    :src="bookInfo.cover_image"
                    alt="表紙"
                    class="rounded-lg"
                    cover
                  ></v-img>
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

                  <v-btn
                    color="success"
                    class="mt-4"
                    @click="registerBook"
                  >
                    この本を登録する
                  </v-btn>
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>

          <v-card v-else-if="error">
            <v-card-text>
              <v-alert
                type="error"
                variant="tonal"
              >
                {{ error }}
              </v-alert>
            </v-card-text>
          </v-card>

          <v-card v-else min-height="300" class="d-flex align-center justify-center flex-column pa-4">
            <v-icon size="x-large" color="grey" class="mb-4">mdi-barcode</v-icon>
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
import { ref, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import Quagga from '@ericblade/quagga2'

// RuntimeConfigからAPIベースURLを取得
const config = useRuntimeConfig()
// axiosインスタンスを作成
const api = axios.create({
  baseURL: 'http://localhost:8000/api'  // ローカルホストのURLを使用
})

// 状態変数
const isCameraActive = ref(false)
const lastScannedCode = ref('')
const isIsbn = ref(false)
const bookInfo = ref(null)
const isLoading = ref(false)
const error = ref(null)
const manualIsbn = ref('')
const scannerInitialized = ref(false)

// カメラを開始（Quagga.jsを使用）
const startCamera = async () => {
  try {
    error.value = null
    console.log('カメラを起動します...')

    Quagga.init({
      inputStream: {
        name: "Live",
        type: "LiveStream",
        target: document.querySelector("#scanner"),
        constraints: {
          facingMode: "environment", // バックカメラを使用
          width: { min: 640 },
          height: { min: 480 },
          aspectRatio: { min: 1, max: 2 }
        },
      },
      frequency: 10, // スキャン頻度を高く設定
      locator: {
        patchSize: "medium",
        halfSample: true
      },
      numOfWorkers: 4, // ワーカースレッド数を増やす
      decoder: {
        readers: [
          "ean_reader", // EAN-13（ISBN-13に対応）
          "ean_8_reader", // EAN-8
          "code_39_reader", // CODE-39
          "code_128_reader" // CODE-128
        ],
        debug: {
          showCanvas: true,
          showPatches: true,
          showFoundPatches: true,
          showSkeleton: true,
          showLabels: true,
          showPatchLabels: true,
          showRemainingPatchLabels: true,
          boxFromPatches: {
            showTransformed: true,
            showTransformedBox: true,
            showBB: true
          }
        }
      },
      locate: true
    }, function(err) {
      if (err) {
        console.error('Quagga初期化エラー:', err)
        error.value = 'カメラの初期化に失敗しました: ' + err
        return
      }

      scannerInitialized.value = true
      isCameraActive.value = true
      console.log('Quagga初期化成功')
      Quagga.start()
    })

    // バーコード検出イベントハンドラ
    Quagga.onDetected(handleBarcodeDetected)
    Quagga.onProcessed(handleBarcodeProcessed)
  } catch (err) {
    console.error('カメラの起動に失敗しました', err)
    error.value = 'カメラへのアクセスに失敗しました。カメラへのアクセス許可を確認してください。'
  }
}

// 検出されたバーコードを処理
const handleBarcodeDetected = (result) => {
  if (result && result.codeResult) {
    const scannedCode = result.codeResult.code
    console.log('バーコード検出:', scannedCode)

    // 信頼性の確認（確信度が高いコードのみを受け入れる）
    if (result.codeResult.startInfo.error < 0.25) {
      // 同じコードの連続スキャンを防止
      if (lastScannedCode.value !== scannedCode) {
        lastScannedCode.value = scannedCode

        // スキャンされたコードがISBNかどうかを判定
        isIsbn.value = isValidIsbn(scannedCode)
        console.log('ISBN判定:', isIsbn.value)

        // ISBNの場合は書籍情報を取得
        if (isIsbn.value) {
          // 一時的にカメラを停止して書籍情報を取得
          stopCamera()
          fetchBookInfo(scannedCode)
        }
      }
    }
  }
}

// バーコード処理過程の視覚化
const handleBarcodeProcessed = (result) => {
  if (!result) return

  try {
    const drawingCanvas = Quagga.canvas.dom.overlay
    const drawingCtx = Quagga.canvas.ctx.overlay

    if (result) {
      if (result.boxes) {
        drawingCtx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height)

        // 検出されたバーコードボックスを描画
        result.boxes.filter(box => box !== result.box).forEach(box => {
          Quagga.ImageDebug.drawPath(box, { x: 0, y: 1 }, drawingCtx, { color: "yellow", lineWidth: 2 })
        })
      }

      if (result.box) {
        // 最も確からしいバーコードボックスを強調表示
        Quagga.ImageDebug.drawPath(result.box, { x: 0, y: 1 }, drawingCtx, { color: "green", lineWidth: 2 })
      }

      if (result.codeResult && result.codeResult.code) {
        // 読み取ったコードを表示
        drawingCtx.font = "24px Arial"
        drawingCtx.fillStyle = "green"
        drawingCtx.fillText(result.codeResult.code, 10, 50)
      }
    }
  } catch (err) {
    console.error('キャンバス描画エラー:', err)
  }
}

// カメラを停止
const stopCamera = () => {
  if (scannerInitialized.value) {
    Quagga.offDetected(handleBarcodeDetected)
    Quagga.offProcessed(handleBarcodeProcessed)
    Quagga.stop()
    scannerInitialized.value = false
    isCameraActive.value = false
    console.log('カメラを停止しました')
  }
}

// コンポーネント破棄時にカメラを停止
onUnmounted(() => {
  stopCamera()
})

// ISBNが有効かどうかを判定
const isValidIsbn = (code) => {
  // 数字とハイフン以外の文字を削除
  const cleanedCode = code.replace(/[^0-9X-]/g, '')

  // ハイフンを削除
  const isbn = cleanedCode.replace(/-/g, '')

  console.log('ISBN検証:', isbn, isbn.length)

  // ISBN-10またはISBN-13の長さチェック
  return isbn.length === 10 || isbn.length === 13
}

// 手動入力されたISBNを検索
const searchManualIsbn = () => {
  if (!manualIsbn.value) return

  console.log('手動ISBN検索:', manualIsbn.value)
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

    console.log('ISBN情報を取得中:', cleanIsbn)

    const response = await api.post('/isbn/fetch', {
      isbn: cleanIsbn
    })

    bookInfo.value = response.data
  } catch (err) {
    console.error('ISBN情報の取得に失敗しました', err)

    if (err.response && err.response.status === 404) {
      error.value = 'この ISBN に該当する書籍が見つかりませんでした'
    } else if (err.response && err.response.status === 422) {
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

    console.log('書籍を登録します:', bookInfo.value)

    const response = await api.post('/books', bookInfo.value)

    // 登録成功
    alert('書籍を登録しました！')

    // フォームをリセット
    bookInfo.value = null
    lastScannedCode.value = ''
    manualIsbn.value = ''
  } catch (err) {
    console.error('書籍の登録に失敗しました', err)

    if (err.response && err.response.data && err.response.data.errors) {
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

#scanner {
  position: relative;
  width: 100%;
  height: 100%;
  min-height: 300px;
  overflow: hidden;
}

#scanner video, #scanner canvas {
  width: 100%;
  height: auto;
}

.drawingBuffer {
  position: absolute;
  top: 0;
  left: 0;
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
  border: 2px solid #1976D2;
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
