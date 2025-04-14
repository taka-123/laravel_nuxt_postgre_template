<template>
  <v-container>
    <v-card class="mb-6 pa-4">
      <v-card-title class="text-h4 font-weight-bold mb-4">バーコード生成</v-card-title>

      <v-row>
        <!-- バーコード生成フォーム -->
        <v-col cols="12" md="6">
          <v-card>
            <v-card-title class="text-h5">バーコード設定</v-card-title>
            <v-card-text>
              <v-select
                v-model="selectedBookId"
                :items="books"
                item-title="title"
                item-value="id"
                label="既存の本を選択"
                prepend-icon="mdi-book"
                return-object
                class="mb-4"
              >
                <template v-slot:prepend>
                  <v-icon color="primary">mdi-book</v-icon>
                </template>
                <template v-slot:selection="{ item }">
                  {{ item.raw.title }} ({{ item.raw.barcode || 'バーコードなし' }})
                </template>
                <template v-slot:item="{ item }">
                  {{ item.raw.title }} ({{ item.raw.barcode || 'バーコードなし' }})
                </template>
              </v-select>

              <v-radio-group v-model="format" inline label="フォーマット" class="mb-4">
                <v-radio label="PNG" value="png"></v-radio>
                <v-radio label="SVG" value="svg"></v-radio>
              </v-radio-group>

              <v-sheet class="mb-4">
                <div class="d-flex align-center mb-1">
                  <span class="text-subtitle-1 font-weight-medium">線の幅 ({{ width }})</span>
                </div>
                <v-slider v-model="width" :min="1" :max="10" :step="1" thumb-label></v-slider>
              </v-sheet>

              <v-sheet class="mb-4">
                <div class="d-flex align-center mb-1">
                  <span class="text-subtitle-1 font-weight-medium">バーコードの高さ ({{ height }}px)</span>
                </div>
                <v-slider v-model="height" :min="20" :max="150" :step="10" thumb-label></v-slider>
              </v-sheet>

              <v-btn color="primary" block size="large" :loading="isLoading" @click="generateBarcode">
                バーコードを生成
              </v-btn>
            </v-card-text>
          </v-card>
        </v-col>

        <!-- バーコード表示セクション -->
        <v-col cols="12" md="6">
          <v-card v-if="isLoading" min-height="300" class="d-flex align-center justify-center">
            <div class="text-center">
              <v-progress-circular indeterminate color="primary"></v-progress-circular>
              <div class="mt-2">生成中...</div>
            </div>
          </v-card>

          <v-card v-else-if="barcodeData">
            <v-card-title class="text-h5">生成されたバーコード</v-card-title>
            <v-card-text class="text-center">
              <img v-if="format === 'png'" :src="barcodeData.image_data" alt="バーコード" class="mx-auto mb-2" />
              <div v-else class="mx-auto mb-2" v-html="barcodeData.image_data"></div>

              <p class="text-body-1 text-grey-darken-1">{{ barcodeData.barcode }}</p>

              <v-row class="mt-4">
                <v-col>
                  <v-btn color="success" block @click="downloadBarcode">
                    <v-icon left>mdi-download</v-icon>
                    ダウンロード
                  </v-btn>
                </v-col>
                <v-col>
                  <v-btn color="secondary" block @click="printBarcode">
                    <v-icon left>mdi-printer</v-icon>
                    印刷
                  </v-btn>
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>

          <v-card v-else-if="error">
            <v-card-text>
              <v-alert type="error" border="left">
                {{ error }}
              </v-alert>
            </v-card-text>
          </v-card>

          <v-card v-else min-height="300" class="d-flex align-center justify-center">
            <span class="text-grey"
              >バーコードを生成するには左側の設定を行い、「バーコードを生成」ボタンをクリックしてください</span
            >
          </v-card>
        </v-col>
      </v-row>
    </v-card>
  </v-container>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import JSBarcode from 'jsbarcode'
import { useApi } from '~/composables/useApi'

// API設定
const api = useApi()

// 状態変数
const books = ref([])
const selectedBookId = ref('')
const format = ref('png')
const width = ref(2)
const height = ref(50)
const barcodeData = ref(null)
const isLoading = ref(false)
const error = ref(null)

// 既存の本のデータを取得する関数
const fetchBooks = async () => {
  try {
    console.log('書籍データを取得中...')
    const response = await api.get('/public/books')
    // 空のオプションを追加（新規バーコード用）
    books.value = [{ id: '', title: '新規バーコードを生成', barcode: '' }, ...(response.data.data || [])]
    console.log('書籍データを取得しました:', books.value.length)
  } catch (err) {
    console.error('書籍情報の取得に失敗しました', err)
    error.value = '書籍データの読み込みに失敗しました'
  }
}

// 初期読み込み
onMounted(async () => {
  await fetchBooks()
})

// バーコードを生成
const generateBarcode = async () => {
  try {
    isLoading.value = true
    error.value = null

    console.log('バーコード生成開始:', { format: format.value, width: width.value, height: height.value })

    const params = {
      format: format.value,
      width: width.value,
      height: height.value,
    }

    // 既存の本を選択した場合
    if (selectedBookId.value && selectedBookId.value.id) {
      params.book_id = selectedBookId.value.id
    }

    const response = await api.post('/barcode/generate', params)
    barcodeData.value = response.data
    console.log('バーコード生成成功:', barcodeData.value)
  } catch (err) {
    console.error('バーコード生成に失敗しました', err)

    if (err.response && err.response.data && err.response.data.errors) {
      error.value = Object.values(err.response.data.errors).flat().join('\n')
    } else {
      error.value = 'バーコードの生成中にエラーが発生しました'
    }
  } finally {
    isLoading.value = false
  }
}

// バーコードをダウンロード
const downloadBarcode = () => {
  if (!barcodeData.value) return

  console.log('バーコードをダウンロードします')
  const a = document.createElement('a')
  a.href = barcodeData.value.image_data
  a.download = `barcode-${barcodeData.value.barcode}.${format.value}`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
}

// バーコードを印刷
const printBarcode = () => {
  if (!barcodeData.value) return

  console.log('バーコードを印刷します')
  // 印刷用ウィンドウを作成
  const printWindow = window.open('', '_blank')
  printWindow.document.write('<html><head><title>バーコード印刷</title>')
  printWindow.document.write(
    '<style>body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }</style>',
  )
  printWindow.document.write('</head><body>')
  printWindow.document.write(
    '<div style="margin-bottom: 20px;"><img src="' + barcodeData.value.image_data + '" alt="バーコード"></div>',
  )
  printWindow.document.write('<div style="font-size: 16px;">' + barcodeData.value.barcode + '</div>')
  printWindow.document.write('</body></html>')
  printWindow.document.close()

  // 印刷を実行
  setTimeout(() => {
    printWindow.print()
    printWindow.close()
  }, 500)
}
</script>

<style scoped>
.mx-auto {
  margin-left: auto;
  margin-right: auto;
}
</style>
