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
              <!-- モード選択タブ -->
              <v-tabs v-model="activeTab" centered class="mb-4">
                <v-tab value="existing">既存書籍のバーコード</v-tab>
                <v-tab value="new">新規書籍＋バーコード</v-tab>
              </v-tabs>

              <v-window v-model="activeTab" class="mb-4">
                <!-- 既存書籍モード -->
                <v-window-item value="existing">
                  <v-alert v-if="!books.length" type="info" class="mb-3">
                    登録済み書籍がありません。新規書籍タブから登録してください。
                  </v-alert>
                  <div v-else>
                    <!-- 書籍選択 -->
                    <label for="book-select" class="text-subtitle-1 font-weight-bold mb-2 d-block">書籍を選択:</label>
                    <v-select
                      id="book-select"
                      v-model="selectedBookId"
                      :items="books"
                      item-title="title"
                      item-value="id"
                      variant="outlined"
                      clearable
                      class="mb-4"
                    >
                      <template v-slot:selection="{ item }">
                        <div v-if="item">{{ item.raw.title || '' }}</div>
                        <div v-else>（書籍未選択）</div>
                      </template>
                      <template v-slot:item="{ item, props }">
                        <v-list-item
                          v-bind="props"
                          :title="item.raw.title"
                          :subtitle="item.raw.barcode || 'バーコード未登録'"
                        ></v-list-item>
                      </template>
                      <template v-slot:no-data>
                        <div class="pa-2">選択可能な書籍がありません</div>
                      </template>
                    </v-select>
                  </div>
                </v-window-item>

                <!-- 新規書籍モード -->
                <v-window-item value="new">
                  <v-form ref="bookForm" class="mb-4">
                    <v-text-field
                      v-model="newBook.title"
                      label="書籍タイトル"
                      required
                      :rules="[(v) => !!v || 'タイトルは必須です']"
                      placeholder="タイトルを入力"
                      prepend-icon="mdi-book-open-variant"
                      class="mb-3"
                    ></v-text-field>

                    <v-text-field
                      v-model="newBook.author"
                      label="著者"
                      placeholder="著者名を入力"
                      prepend-icon="mdi-account"
                      class="mb-3"
                    ></v-text-field>

                    <v-text-field
                      v-model="newBook.isbn"
                      label="ISBN (任意)"
                      placeholder="ISBN番号 (例: 9784167158057)"
                      prepend-icon="mdi-barcode"
                      hint="ISBNがある場合は入力してください"
                      class="mb-3"
                    ></v-text-field>

                    <v-row>
                      <v-col cols="6">
                        <v-text-field
                          v-model="newBook.publisher"
                          label="出版社"
                          placeholder="出版社名"
                          prepend-icon="mdi-office-building"
                        ></v-text-field>
                      </v-col>
                      <v-col cols="6">
                        <v-text-field
                          v-model="newBook.publication_year"
                          label="出版年"
                          placeholder="西暦 (例: 2023)"
                          prepend-icon="mdi-calendar"
                          type="number"
                        ></v-text-field>
                      </v-col>
                    </v-row>

                    <v-select
                      v-model="newBook.status"
                      :items="[
                        { title: '貸出可能', value: 'available' },
                        { title: '貸出中', value: 'borrowed' },
                        { title: '紛失', value: 'lost' },
                        { title: '除籍', value: 'retired' },
                      ]"
                      item-title="title"
                      item-value="value"
                      label="ステータス"
                      prepend-icon="mdi-tag"
                      class="mb-2"
                    ></v-select>
                  </v-form>
                </v-window-item>
              </v-window>

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

              <v-btn
                color="primary"
                block
                size="large"
                :loading="isLoading"
                @click="generateBarcode"
                :disabled="activeTab === 'existing' && !selectedBookId"
              >
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

              <div v-if="barcodeData.bookInfo" class="mt-3 mb-4 text-left">
                <div class="font-weight-medium">書籍情報:</div>
                <div class="text-body-2">
                  {{ barcodeData.bookInfo.title }} ({{ barcodeData.bookInfo.author || '著者不明' }})
                </div>
              </div>

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
              <v-alert type="error" border-color="error" elevation="2">
                {{ error }}
              </v-alert>
            </v-card-text>
          </v-card>

          <v-card v-else min-height="300" class="d-flex align-center justify-center">
            <div class="text-center text-grey pa-4">
              <v-icon size="large" color="grey-lighten-1" class="mb-2">mdi-barcode</v-icon>
              <p class="text-body-1 px-4">
                バーコードを生成するには設定を行い、<br />
                「バーコードを生成」ボタンをクリックしてください
              </p>
              <div v-if="activeTab === 'new'" class="mt-4 text-body-2">
                <v-divider class="mb-3"></v-divider>
                <v-icon size="small" color="info" class="mr-1">mdi-information</v-icon>
                <span class="text-info">新規書籍情報を入力して、オリジナルバーコードを生成できます</span>
              </div>
            </div>
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

// モード選択用タブ
const activeTab = ref('new') // デフォルトで新規書籍モードに設定

// 状態変数
const books = ref([])
const selectedBookId = ref(null)
const format = ref('png')
const width = ref(2)
const height = ref(50)
const barcodeData = ref(null)
const isLoading = ref(false)
const error = ref(null)
const bookForm = ref(null)

// 新規書籍情報
const newBook = ref({
  title: '',
  author: '',
  isbn: '',
  publisher: '',
  publication_year: null,
  status: 'available', // デフォルトは「貸出可能」
})

// 既存の本のデータを取得する関数
const fetchBooks = async () => {
  try {
    const response = await api.get('/public/books')
    // 書籍データを設定
    books.value = response.data.data || []

    // データが存在する場合、初期選択をnullに設定
    selectedBookId.value = null
  } catch (err) {
    books.value = [] // 空配列を設定
  }
}

// 初期読み込み
onMounted(async () => {
  await fetchBooks()
})

// フォームの検証
const validateForm = () => {
  if (activeTab.value === 'new') {
    return bookForm.value?.validate() ?? true
  }
  return true
}

// バーコードを生成
const generateBarcode = async () => {
  try {
    // 入力チェック
    if (!validateForm()) {
      error.value = '入力内容に問題があります。必須項目を確認してください。'
      return
    }

    isLoading.value = true
    error.value = null

    // 既存書籍モードと新規書籍モードで処理を分ける
    if (activeTab.value === 'existing') {
      await generateForExistingBook()
    } else {
      await generateForNewBook()
    }
  } catch (err) {
    if (err.response && err.response.data && err.response.data.errors) {
      error.value = Object.values(err.response.data.errors).flat().join('\n')
    } else {
      error.value = 'バーコードの生成中にエラーが発生しました: ' + (err.message || '')
    }
  } finally {
    isLoading.value = false
  }
}

// 選択された書籍のデータを取得する補助関数
const getSelectedBook = () => {
  if (!selectedBookId.value || books.value.length === 0) return null
  return books.value.find(book => book.id === selectedBookId.value) || null
}

// 既存書籍用バーコード生成
const generateForExistingBook = async () => {
  try {
    // 選択された書籍が存在するか確認
    const selectedBook = getSelectedBook()
    if (!selectedBook) {
      error.value = '書籍を選択してください。'
      return
    }

    const params = {
      book_id: selectedBook.id,
      format: format.value,
      width: width.value,
      height: height.value,
    }

    console.log('バーコード生成リクエスト:', params)
    const response = await api.post('/barcode/generate', params)
    console.log('バーコード生成レスポンス:', response.data)

    barcodeData.value = response.data
    barcodeData.value.bookInfo = selectedBook
  } catch (err) {
    console.error('バーコード生成エラー:', err)
    error.value = `バーコード生成に失敗しました: ${err.response?.status || ''} ${err.message || ''}`
  }
}

// 新規書籍用バーコード生成
const generateForNewBook = async () => {
  // 新規書籍＋バーコード生成パラメータ
  const params = {
    // 書籍情報
    book: {
      title: newBook.value.title,
      author: newBook.value.author || null,
      isbn: newBook.value.isbn || null,
      publisher: newBook.value.publisher || null,
      publication_year: newBook.value.publication_year || null,
      status: newBook.value.status || 'available',
    },
    // バーコード設定
    format: format.value,
    width: width.value,
    height: height.value,
  }

  try {
    // 新規書籍登録＋バーコード生成APIを呼び出し
    const response = await api.post('/books/create-with-barcode', params)
    barcodeData.value = response.data

    // 書籍リストを再取得（新しく追加された書籍を含めるため）
    await fetchBooks()
  } catch (err) {
    // 通常のバーコード生成APIをフォールバックとして使用
    console.log('通常のバーコード生成APIを使用します')
    const fallbackParams = {
      format: format.value,
      width: width.value,
      height: height.value,
    }

    const fallbackResponse = await api.post('/barcode/generate', fallbackParams)
    barcodeData.value = fallbackResponse.data
    barcodeData.value.bookInfo = {
      title: newBook.value.title,
      author: newBook.value.author || '未登録',
    }

    error.value = '書籍情報の登録に失敗しましたが、バーコードは生成されました。後で書籍情報を登録してください。'
  }
}

// バーコードをダウンロード
const downloadBarcode = () => {
  if (!barcodeData.value) return

  const a = document.createElement('a')
  a.href = barcodeData.value.image_data

  // ファイル名に書籍タイトルを含める（存在する場合）
  let filename = `barcode-${barcodeData.value.barcode}`
  if (barcodeData.value.bookInfo?.title) {
    // ファイル名に使えない文字を削除
    const safeTitle = barcodeData.value.bookInfo.title.replace(/[\\/:*?"<>|]/g, '_')
    filename = `${safeTitle}-${barcodeData.value.barcode}`
  }

  a.download = `${filename}.${format.value}`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
}

// バーコードを印刷
const printBarcode = () => {
  if (!barcodeData.value) return

  // 印刷用ウィンドウを作成
  const printWindow = window.open('', '_blank')
  printWindow.document.write('<html><head><title>バーコード印刷</title>')
  printWindow.document.write(
    '<style>body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }</style>',
  )
  printWindow.document.write('</head><body>')

  // 書籍情報がある場合は表示
  if (barcodeData.value.bookInfo) {
    printWindow.document.write(
      '<div style="font-size: 18px; margin-bottom: 10px;">' + barcodeData.value.bookInfo.title + '</div>',
    )

    if (barcodeData.value.bookInfo.author) {
      printWindow.document.write(
        '<div style="font-size: 14px; margin-bottom: 15px;">' + barcodeData.value.bookInfo.author + '</div>',
      )
    }
  }

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
