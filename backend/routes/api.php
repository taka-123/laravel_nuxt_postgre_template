<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;

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

// 書籍関連のルート（今後実装）
Route::group(['middleware' => 'auth:api'], function () {
    // 書籍のCRUD操作のルートをここに追加
});
