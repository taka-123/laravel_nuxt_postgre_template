<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Services\BarcodeService;
use App\Services\IsbnService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class BookController extends Controller
{
    protected BarcodeService $barcodeService;
    protected IsbnService $isbnService;

    public function __construct(BarcodeService $barcodeService, IsbnService $isbnService)
    {
        $this->barcodeService = $barcodeService;
        $this->isbnService = $isbnService;
    }

    /**
     * 本の一覧を取得する
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $query = Book::query();

        // 検索条件の適用
        if ($request->has('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('author', 'like', "%{$search}%")
                  ->orWhere('isbn', 'like', "%{$search}%")
                  ->orWhere('barcode', 'like', "%{$search}%");
            });
        }

        // ステータスによるフィルタリング
        if ($request->has('status')) {
            $query->where('status', $request->input('status'));
        }

        // ソート順の適用
        $sortBy = $request->input('sort_by', 'created_at');
        $sortOrder = $request->input('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        // ページネーション
        $perPage = $request->input('per_page', 15);
        $books = $query->paginate($perPage);

        return response()->json($books);
    }

    /**
     * 本の詳細を取得する
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $book = Book::findOrFail($id);
        return response()->json($book);
    }

    /**
     * 新しい本を登録する
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'isbn' => 'nullable|string|max:20',
            'title' => 'required|string|max:255',
            'author' => 'nullable|string|max:255',
            'publisher' => 'nullable|string|max:255',
            'publication_year' => 'nullable|integer|min:1000|max:' . (date('Y') + 1),
            'description' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'status' => 'nullable|in:available,borrowed,lost,retired',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // ISBNの検証（指定されている場合）
        if ($request->filled('isbn') && !$this->isbnService->validateIsbn($request->input('isbn'))) {
            return response()->json(['errors' => ['isbn' => ['ISBN形式が正しくありません']]], 422);
        }

        // 独自バーコードの生成
        $barcode = $this->barcodeService->generateUniqueBarcode();

        // 本の登録
        $book = Book::create(array_merge(
            $request->all(),
            ['barcode' => $barcode]
        ));

        return response()->json($book, 201);
    }

    /**
     * 本の情報を更新する
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $book = Book::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'isbn' => 'nullable|string|max:20',
            'title' => 'required|string|max:255',
            'author' => 'nullable|string|max:255',
            'publisher' => 'nullable|string|max:255',
            'publication_year' => 'nullable|integer|min:1000|max:' . (date('Y') + 1),
            'description' => 'nullable|string',
            'cover_image' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'status' => 'nullable|in:available,borrowed,lost,retired',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // ISBNの検証（指定されている場合）
        if ($request->filled('isbn') && !$this->isbnService->validateIsbn($request->input('isbn'))) {
            return response()->json(['errors' => ['isbn' => ['ISBN形式が正しくありません']]], 422);
        }

        $book->update($request->all());

        return response()->json($book);
    }

    /**
     * 本を削除する
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $book = Book::findOrFail($id);
        $book->delete();

        return response()->json(null, 204);
    }

    /**
     * ISBNから書籍情報を取得する
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function fetchBookInfoByIsbn(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'isbn' => 'required|string|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $isbn = $request->input('isbn');

        // ISBNの検証
        if (!$this->isbnService->validateIsbn($isbn)) {
            return response()->json(['errors' => ['isbn' => ['ISBN形式が正しくありません']]], 422);
        }

        // 書籍情報の取得
        $bookInfo = $this->isbnService->getBookInfoByIsbn($isbn);

        if (!$bookInfo) {
            return response()->json(['error' => 'この ISBN に該当する書籍が見つかりませんでした'], 404);
        }

        return response()->json($bookInfo);
    }

    /**
     * バーコードを生成して返す
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function generateBarcode(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'book_id' => 'nullable|exists:books,id',
            'format' => 'nullable|in:png,svg',
            'width' => 'nullable|integer|min:1|max:10',
            'height' => 'nullable|integer|min:10|max:200',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $format = $request->input('format', 'png');
        $width = $request->input('width', 2);
        $height = $request->input('height', 50);

        // 書籍IDが指定されている場合は既存のバーコードを使用
        if ($request->filled('book_id')) {
            $book = Book::findOrFail($request->input('book_id'));
            $barcode = $book->barcode;
        } else {
            // 新しいバーコードを生成
            $barcode = $this->barcodeService->generateUniqueBarcode();
        }

        // バーコード画像の生成
        $barcodeData = $this->barcodeService->generate($barcode, $format, $width, $height);

        // バーコードデータをBase64エンコード
        $base64 = base64_encode($barcodeData);
        $dataUri = 'data:image/' . $format . ';base64,' . $base64;

        return response()->json([
            'barcode' => $barcode,
            'image_data' => $dataUri,
        ]);
    }

    /**
     * 新規書籍登録とバーコード生成を同時に行う
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function createWithBarcode(Request $request)
    {
        // 書籍情報のバリデーション
        $bookData = $request->input('book', []);
        $bookValidator = Validator::make($bookData, [
            'isbn' => 'nullable|string|max:20',
            'title' => 'required|string|max:255',
            'author' => 'nullable|string|max:255',
            'publisher' => 'nullable|string|max:255',
            'publication_year' => 'nullable|integer|min:1000|max:' . (date('Y') + 1),
            'description' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'status' => 'nullable|in:available,borrowed,lost,retired',
        ]);

        if ($bookValidator->fails()) {
            return response()->json(['errors' => $bookValidator->errors()], 422);
        }

        // バーコード設定のバリデーション
        $barcodeValidator = Validator::make($request->all(), [
            'format' => 'nullable|in:png,svg',
            'width' => 'nullable|integer|min:1|max:10',
            'height' => 'nullable|integer|min:10|max:200',
        ]);

        if ($barcodeValidator->fails()) {
            return response()->json(['errors' => $barcodeValidator->errors()], 422);
        }

        // ISBNの検証（指定されている場合）
        if (!empty($bookData['isbn']) && !$this->isbnService->validateIsbn($bookData['isbn'])) {
            return response()->json(['errors' => ['isbn' => ['ISBN形式が正しくありません']]], 422);
        }

        // 独自バーコードの生成
        $barcode = $this->barcodeService->generateUniqueBarcode();

        // 書籍データにバーコードを追加
        $bookData['barcode'] = $barcode;

        // 本の登録
        $book = Book::create($bookData);

        // バーコード画像の生成
        $format = $request->input('format', 'png');
        $width = $request->input('width', 2);
        $height = $request->input('height', 50);
        $barcodeData = $this->barcodeService->generate($barcode, $format, $width, $height);

        // バーコードデータをBase64エンコード
        $base64 = base64_encode($barcodeData);
        $dataUri = 'data:image/' . $format . ';base64,' . $base64;

        // 書籍情報とバーコード情報を含むレスポンス
        return response()->json([
            'book' => $book,
            'barcode' => $barcode,
            'image_data' => $dataUri,
            'bookInfo' => [
                'id' => $book->id,
                'title' => $book->title,
                'author' => $book->author,
                'barcode' => $book->barcode,
            ],
        ], 201);
    }

    /**
     * バーコードから書籍情報を検索する
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function findBookByBarcode(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'barcode' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $barcode = $request->input('barcode');

        // 書籍を検索
        $book = Book::where('barcode', $barcode)->first();

        if (!$book) {
            return response()->json(['error' => 'このバーコードに該当する書籍が見つかりませんでした'], 404);
        }

        // 書籍情報を返す
        return response()->json([
            'id' => $book->id,
            'isbn' => $book->isbn,
            'barcode' => $book->barcode,
            'title' => $book->title,
            'author' => $book->author,
            'publisher' => $book->publisher,
            'publication_year' => $book->publication_year,
            'description' => $book->description,
            'cover_image' => $book->cover_image,
            'location' => $book->location,
            'status' => $book->status,
            'created_at' => $book->created_at,
            'updated_at' => $book->updated_at,
        ]);
    }
}
