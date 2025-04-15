<?php

namespace App\Http\Middleware;

use Closure;
use Exception;
use Illuminate\Http\Request;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
use PHPOpenSourceSaver\JWTAuth\Exceptions\TokenExpiredException;
use PHPOpenSourceSaver\JWTAuth\Exceptions\TokenInvalidException;
use PHPOpenSourceSaver\JWTAuth\Exceptions\JWTException;

class JwtMiddleware
{
    /**
     * JWTトークンを検証し、ユーザーが認証されていることを確認します。
     *
     * @param \Illuminate\Http\Request $request
     * @param \Closure $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        try {
            // トークンを検証してユーザーを取得
            $user = JWTAuth::parseToken()->authenticate();

            // ユーザーが見つからない場合
            if (!$user) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'User not found'
                ], 404);
            }

        } catch (TokenExpiredException $e) {
            // トークンの有効期限切れ
            return response()->json([
                'status' => 'error',
                'message' => 'Token has expired',
                'error' => 'token_expired'
            ], 401);

        } catch (TokenInvalidException $e) {
            // 無効なトークン
            return response()->json([
                'status' => 'error',
                'message' => 'Token is invalid',
                'error' => 'token_invalid'
            ], 401);

        } catch (JWTException $e) {
            // トークンがない場合
            return response()->json([
                'status' => 'error',
                'message' => 'Authorization token not found',
                'error' => 'token_absent'
            ], 401);

        } catch (Exception $e) {
            // その他のエラー
            return response()->json([
                'status' => 'error',
                'message' => 'Authorization error',
                'error' => $e->getMessage()
            ], 500);
        }

        // 次の処理に進む
        return $next($request);
    }
}
