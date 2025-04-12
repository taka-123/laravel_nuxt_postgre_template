<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    /**
     * Create a new AuthController instance.
     * 要求されたミドルウェアをコントローラーのメソッドに適用
     *
     * @return void
     */
    public function __construct()
    {
        // 'api' ミドルウェアを 'login', 'register' 以外の全メソッドに適用
        $this->middleware('auth:api', ['except' => ['login', 'register']]);
    }

    /**
     * Register a User.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if($validator->fails()){
            return response()->json($validator->errors()->toJson(), 400);
        }

        $user = User::create([
            'name' => $request->get('name'),
            'email' => $request->get('email'),
            'password' => Hash::make($request->get('password')),
            // 共通監査カラムの初期値設定 (例)
            'created' => now(),
            'updated' => now(),
        ]);

        $token = JWTAuth::fromUser($user);

        return response()->json(compact('user','token'),201);
    }


    /**
     * Get a JWT via given credentials.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $credentials = $request->only('email', 'password');

        if (! $token = auth('api')->attempt($credentials)) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        return $this->respondWithToken($token);
    }

    /**
     * Get the authenticated User.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function me()
    {
        // auth('api')->user() で認証済みユーザー情報を取得
        return response()->json(auth('api')->user());
    }

    /**
     * Log the user out (Invalidate the token).
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout()
    {
        auth('api')->logout(); // 認証済みユーザーをログアウトさせる

        return response()->json(['message' => 'Successfully logged out']);
    }

    /**
     * Refresh a token.
     * トークンをリフレッシュする
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function refresh()
    {
        // auth('api')->refresh() で現在のトークンを無効化し、新しいトークンを生成
        return $this->respondWithToken(auth('api')->refresh());
    }

    /**
     * Get the token array structure.
     * トークン情報を構造化して返すヘルパーメソッド
     *
     * @param  string $token
     *
     * @return \Illuminate\Http\JsonResponse
     */
    protected function respondWithToken($token)
    {
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
             // JWTAuth::factory()->getTTL() でトークンの有効期間（分）を取得し、秒に変換
            'expires_in' => JWTAuth::factory()->getTTL() * 60,
            // 'user' => auth('api')->user() // オプション: ユーザー情報も返す場合
        ]);
    }
}
