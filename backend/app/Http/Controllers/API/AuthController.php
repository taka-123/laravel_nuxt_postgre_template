<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
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
     */
    public function register(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt($request->password),
        ]);

        $token = Auth::guard('api')->login($user);

        if (!is_string($token)) {
            return $this->errorResponse('Could not create token', 500);
        }

        return $this->respondWithToken($token);
    }

    /**
     * Get a JWT via given credentials.
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $credentials = $request->only('email', 'password');

        $token = Auth::guard('api')->attempt($credentials);
        if (! $token) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        if (!is_string($token)) {
            return $this->errorResponse('Authentication failed', 401);
        }

        return $this->respondWithToken($token);
    }

    /**
     * Get the authenticated User.
     */
    public function me(): JsonResponse
    {
        return response()->json(Auth::guard('api')->user());
    }

    /**
     * Log the user out (Invalidate the token).
     */
    public function logout(): JsonResponse
    {
        Auth::guard('api')->logout();

        return response()->json(['message' => 'Successfully logged out']);
    }

    /**
     * Refresh a token.
     * トークンをリフレッシュする
     */
    public function refresh(): JsonResponse
    {
        $guard = Auth::guard('api');
        if (method_exists($guard, 'refresh')) {
            $token = $guard->refresh();
            if (is_string($token)) {
                return $this->respondWithToken($token);
            }
        }

        return $this->errorResponse('Could not refresh token', 401);
    }

    /**
     * トークンのレスポンス形式
     */
    protected function respondWithToken(?string $token): JsonResponse
    {
        if ($token === null) {
            return $this->errorResponse('Token generation failed', 500);
        }

        $guard = Auth::guard('api');
        $ttl = 3600; // Default 1 hour

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

    /**
     * 統一的なエラーレスポンス
     */
    private function errorResponse(string $message, int $code = 500): JsonResponse
    {
        return response()->json(['error' => $message], $code);
    }
}
