<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\PostController;
use App\Http\Controllers\API\CommentController;

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

// 公開投稿の取得（認証不要）
Route::get('/posts', [PostController::class, 'index'])->name('posts.index');

// 投稿のコメント取得（認証不要）
Route::get('/posts/{postId}/comments', [CommentController::class, 'index'])->name('comments.index');

// 認証が必要なルート
Route::group(['middleware' => 'auth:api'], function () {
    // 投稿の作成・更新・削除
    Route::post('/posts', [PostController::class, 'store'])->name('posts.store');
    Route::get('/posts/{id}', [PostController::class, 'showById'])->name('posts.showById')->where('id', '[0-9]+');
    Route::put('/posts/{id}', [PostController::class, 'update'])->name('posts.update');
    Route::delete('/posts/{id}', [PostController::class, 'destroy'])->name('posts.destroy');

    // ユーザーのコメント一覧取得
    Route::get('/user/comments', [CommentController::class, 'userComments'])->name('user.comments');

    // コメントの作成・更新・削除
    Route::post('/posts/{postId}/comments', [CommentController::class, 'store'])->name('comments.store');
    Route::put('/comments/{id}', [CommentController::class, 'update'])->name('comments.update');
    Route::delete('/comments/{id}', [CommentController::class, 'destroy'])->name('comments.destroy');
});

// slug による投稿詳細取得（最後に配置）
Route::get('/posts/{slug}', [PostController::class, 'show'])->name('posts.show');
