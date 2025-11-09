<?php

declare(strict_types=1);

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class GoogleAuthController extends Controller
{
    /**
     * Google OAuth認証後のユーザー登録/ログイン処理
     */
    public function handleGoogleCallback(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'google_id' => 'required|string',
            'email' => 'required|email',
            'name' => 'required|string',
            'avatar' => 'nullable|url',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Google IDで既存ユーザーを検索
        $user = User::where('google_id', $request->google_id)->first();

        if (!$user) {
            // メールアドレスで既存ユーザーを検索（アカウント統合）
            $user = User::where('email', $request->email)->first();

            if ($user) {
                // 既存ユーザーにGoogle IDを紐付け
                $user->update([
                    'google_id' => $request->google_id,
                    'avatar' => $request->avatar ?? $user->avatar,
                ]);
            } else {
                // 新規ユーザー作成
                $user = User::create([
                    'name' => $request->name,
                    'email' => $request->email,
                    'google_id' => $request->google_id,
                    'avatar' => $request->avatar,
                    'password' => null, // OAuth専用ユーザー
                ]);
            }
        } else {
            // ユーザー情報を更新
            $user->update([
                'name' => $request->name,
                'avatar' => $request->avatar ?? $user->avatar,
            ]);
        }

        // JWTトークン生成
        $token = Auth::guard('api')->login($user);

        if (!is_string($token)) {
            return response()->json(['error' => 'Could not create token'], 500);
        }

        return $this->respondWithToken($token);
    }

    /**
     * トークンレスポンス
     */
    protected function respondWithToken(string $token): JsonResponse
    {
        $guard = Auth::guard('api');
        $ttl = 3600;

        if (method_exists($guard, 'factory') && $guard->factory()) {
            $ttl = $guard->factory()->getTTL() * 60;
        }

        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => $ttl,
            'user' => $guard->user(),
        ]);
    }
}
