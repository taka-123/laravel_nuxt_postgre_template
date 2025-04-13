<?php

namespace App\Services;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;
use Illuminate\Support\Facades\Log;

class IsbnService
{
    protected Client $client;
    protected string $apiUrl = 'https://www.googleapis.com/books/v1/volumes';
    protected ?string $apiKey;

    public function __construct()
    {
        $this->client = new Client();
        $this->apiKey = env('GOOGLE_BOOKS_API_KEY'); // APIキーは任意
    }

    /**
     * ISBNから書籍情報を取得する
     *
     * @param string $isbn ISBN番号
     * @return array|null 書籍情報
     */
    public function getBookInfoByIsbn(string $isbn): ?array
    {
        try {
            // ISBNをクリーニング
            $cleanIsbn = $this->cleanIsbn($isbn);

            // クエリパラメータ
            $query = [
                'q' => 'isbn:' . $cleanIsbn,
                'maxResults' => 1
            ];

            // APIキーがあれば追加
            if ($this->apiKey) {
                $query['key'] = $this->apiKey;
            }

            Log::info('Google Books APIリクエスト', ['isbn' => $cleanIsbn]);

            // Google Books APIにリクエスト
            $response = $this->client->get($this->apiUrl, [
                'query' => $query,
                'timeout' => 10, // タイムアウト設定を追加
                'http_errors' => false // エラーを例外として扱わない
            ]);

            $statusCode = $response->getStatusCode();
            $contents = $response->getBody()->getContents();
            $data = json_decode($contents, true);

            Log::info('Google Books APIレスポンス', [
                'status' => $statusCode,
                'totalItems' => $data['totalItems'] ?? 0,
                'hasItems' => isset($data['items'])
            ]);

            // エラーレスポンスの場合
            if ($statusCode !== 200) {
                Log::error('Google Books APIエラー', [
                    'status' => $statusCode,
                    'response' => $contents
                ]);
                return null;
            }

            // 該当する書籍が見つからない場合
            if (!isset($data['items']) || empty($data['items'])) {
                // 代替検索を試みる - ISBNから部分一致検索
                return $this->fallbackSearch($cleanIsbn);
            }

            // 最初の結果を取得
            $bookInfo = $data['items'][0]['volumeInfo'] ?? null;

            if (!$bookInfo) {
                return null;
            }

            // 著者配列の処理
            $author = null;
            if (isset($bookInfo['authors']) && is_array($bookInfo['authors'])) {
                $author = implode(', ', $bookInfo['authors']);
            }

            // 表紙画像の取得（高解像度があれば使用）
            $coverImage = null;
            if (isset($bookInfo['imageLinks'])) {
                $coverImage = $bookInfo['imageLinks']['thumbnail'] ?? null;
                // より高解像度の画像があれば使用
                $coverImage = $bookInfo['imageLinks']['smallThumbnail'] ?? $coverImage;
                $coverImage = $bookInfo['imageLinks']['small'] ?? $coverImage;
                $coverImage = $bookInfo['imageLinks']['medium'] ?? $coverImage;
                $coverImage = $bookInfo['imageLinks']['large'] ?? $coverImage;
                $coverImage = $bookInfo['imageLinks']['extraLarge'] ?? $coverImage;

                // HTTPSに変換
                if ($coverImage && strpos($coverImage, 'http:') === 0) {
                    $coverImage = 'https:' . substr($coverImage, 5);
                }
            }

            // 必要な情報を抽出
            return [
                'isbn' => $cleanIsbn,
                'title' => $bookInfo['title'] ?? '不明なタイトル',
                'author' => $author,
                'publisher' => $bookInfo['publisher'] ?? null,
                'publication_year' => isset($bookInfo['publishedDate']) ? substr($bookInfo['publishedDate'], 0, 4) : null,
                'description' => $bookInfo['description'] ?? null,
                'cover_image' => $coverImage,
                'page_count' => $bookInfo['pageCount'] ?? null,
                'categories' => $bookInfo['categories'] ?? null,
            ];
        } catch (GuzzleException $e) {
            Log::error('ISBN検索中にエラーが発生しました', [
                'isbn' => $isbn,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return null;
        } catch (\Exception $e) {
            Log::error('予期せぬエラーが発生しました', [
                'isbn' => $isbn,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return null;
        }
    }

    /**
     * ISBNが見つからない場合の代替検索
     */
    private function fallbackSearch(string $isbn): ?array
    {
        try {
            Log::info('代替検索を実行', ['isbn' => $isbn]);

            // ISBNの一部を使用して検索
            $partialIsbn = substr($isbn, 0, 6);

            $query = [
                'q' => $partialIsbn,
                'maxResults' => 5
            ];

            if ($this->apiKey) {
                $query['key'] = $this->apiKey;
            }

            $response = $this->client->get($this->apiUrl, [
                'query' => $query,
                'timeout' => 10,
                'http_errors' => false
            ]);

            if ($response->getStatusCode() !== 200) {
                return null;
            }

            $data = json_decode($response->getBody()->getContents(), true);

            if (!isset($data['items']) || empty($data['items'])) {
                return null;
            }

            // 最も関連性の高い結果を選択
            foreach ($data['items'] as $item) {
                $bookInfo = $item['volumeInfo'] ?? null;

                if (!$bookInfo) {
                    continue;
                }

                // 著者配列の処理
                $author = null;
                if (isset($bookInfo['authors']) && is_array($bookInfo['authors'])) {
                    $author = implode(', ', $bookInfo['authors']);
                }

                // 表紙画像
                $coverImage = null;
                if (isset($bookInfo['imageLinks'])) {
                    $coverImage = $bookInfo['imageLinks']['thumbnail'] ?? null;
                    if ($coverImage && strpos($coverImage, 'http:') === 0) {
                        $coverImage = 'https:' . substr($coverImage, 5);
                    }
                }

                return [
                    'isbn' => $isbn, // 元のISBNを使用
                    'title' => $bookInfo['title'] ?? '不明なタイトル',
                    'author' => $author,
                    'publisher' => $bookInfo['publisher'] ?? null,
                    'publication_year' => isset($bookInfo['publishedDate']) ? substr($bookInfo['publishedDate'], 0, 4) : null,
                    'description' => $bookInfo['description'] ?? null,
                    'cover_image' => $coverImage,
                    'page_count' => $bookInfo['pageCount'] ?? null,
                    'categories' => $bookInfo['categories'] ?? null,
                ];
            }

            return null;
        } catch (\Exception $e) {
            Log::error('代替検索中にエラーが発生しました', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * ISBNをクリーニングする
     */
    private function cleanIsbn(string $isbn): string
    {
        // 数字とハイフン以外の文字を削除
        $isbn = preg_replace('/[^0-9X-]/', '', $isbn);

        // ハイフンを削除
        return str_replace('-', '', $isbn);
    }

    /**
     * ISBNが有効かどうかを検証する
     *
     * @param string $isbn ISBN番号
     * @return bool 有効かどうか
     */
    public function validateIsbn(string $isbn): bool
    {
        // ISBNをクリーニング
        $isbn = $this->cleanIsbn($isbn);

        // ISBN-10またはISBN-13の長さチェック
        $length = strlen($isbn);
        if ($length !== 10 && $length !== 13) {
            return false;
        }

        // ISBN-10のチェックディジット検証
        if ($length === 10) {
            $sum = 0;
            for ($i = 0; $i < 9; $i++) {
                $sum += (int)$isbn[$i] * (10 - $i);
            }
            $checkDigit = ($isbn[9] === 'X') ? 10 : (int)$isbn[9];
            $sum += $checkDigit;

            return ($sum % 11 === 0);
        }

        // ISBN-13のチェックディジット検証
        if ($length === 13) {
            $sum = 0;
            for ($i = 0; $i < 12; $i++) {
                $sum += (int)$isbn[$i] * ($i % 2 === 0 ? 1 : 3);
            }
            $checkDigit = (10 - ($sum % 10)) % 10;

            return ($checkDigit === (int)$isbn[12]);
        }

        return false;
    }
}
