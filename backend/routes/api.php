<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\BookController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// 認証関連のルートをグループ化
Route::group([
    'middleware' => 'api',
    'prefix' => 'auth'

], function ($router) {

    Route::post('register', [AuthController::class, 'register'])->name('register');
    Route::post('login', [AuthController::class, 'login'])->name('login');
    Route::post('logout', [AuthController::class, 'logout'])->name('logout');
    Route::post('refresh', [AuthController::class, 'refresh'])->name('refresh');
    Route::get('me', [AuthController::class, 'me'])->name('me');

});

// バーコードとISBN関連のルート（認証不要）
Route::group(['prefix' => 'barcode'], function () {
    Route::post('generate', [BookController::class, 'generateBarcode'])->name('barcode.generate');
    Route::post('search', [BookController::class, 'findBookByBarcode'])->name('barcode.search');
});

Route::group(['prefix' => 'isbn'], function () {
    Route::post('fetch', [BookController::class, 'fetchBookInfoByIsbn'])->name('isbn.fetch');
});

// テスト用：認証不要の書籍一覧エンドポイント
Route::get('/public/books', [BookController::class, 'index'])->name('books.public.index');

// 新規書籍＋バーコード生成エンドポイント（認証不要）
Route::post('/books/create-with-barcode', [BookController::class, 'createWithBarcode'])->name('books.create-with-barcode');

// 書籍関連のルート（認証必要）
Route::group(['middleware' => 'auth:api', 'prefix' => 'books'], function () {
    Route::get('/', [BookController::class, 'index'])->name('books.index');
    Route::post('/', [BookController::class, 'store'])->name('books.store');
    Route::get('/{id}', [BookController::class, 'show'])->name('books.show');
    Route::put('/{id}', [BookController::class, 'update'])->name('books.update');
    Route::delete('/{id}', [BookController::class, 'destroy'])->name('books.destroy');
});
