<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Validator;

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
    public function register(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt($request->password),
        ]);

        $token = Auth::guard('api')->login($user);

        if ($token) {
            return $this->respondWithToken($token);
        }

        return response()->json(['error' => 'Could not create token'], 500);
    }

    /**
     * Get a JWT via given credentials.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $credentials = $request->only('email', 'password');

        if (!$token = Auth::guard('api')->attempt($credentials)) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        return $this->respondWithToken($token);
    }

    /**
     * Get the authenticated User.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function me(): JsonResponse
    {
        return response()->json(Auth::guard('api')->user());
    }

    /**
     * Log the user out (Invalidate the token).
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(): JsonResponse
    {
        Auth::guard('api')->logout();

        return response()->json(['message' => 'Successfully logged out']);
    }

    /**
     * Refresh a token.
     * トークンをリフレッシュする
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function refresh(): JsonResponse
    {
        return $this->respondWithToken(Auth::guard('api')->refresh());
    }

    /**
     * トークンのレスポンス形式
     *
     * @param string|null $token
     * @return JsonResponse
     */
    protected function respondWithToken(?string $token): JsonResponse
    {
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => Auth::guard('api')->factory()->getTTL() * 60,
            'user' => Auth::guard('api')->user()
        ]);
    }
}
