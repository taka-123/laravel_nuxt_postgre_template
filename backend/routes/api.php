<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\GoogleAuthController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| シンプルな認証APIのみを提供
|
*/

// 認証関連のルート
Route::group([
    'middleware' => 'api',
    'prefix' => 'auth',
], function ($router) {
    Route::post('register', [AuthController::class, 'register'])->name('register');
    Route::post('login', [AuthController::class, 'login'])->name('login');
    Route::post('logout', [AuthController::class, 'logout'])->name('logout');
    Route::post('refresh', [AuthController::class, 'refresh'])->name('refresh');
    Route::get('me', [AuthController::class, 'me'])->name('me');
    
    // Google OAuth認証
    Route::post('google/callback', [GoogleAuthController::class, 'handleGoogleCallback'])->name('google.callback');
});
