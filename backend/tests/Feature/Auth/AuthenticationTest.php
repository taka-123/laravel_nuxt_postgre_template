<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * ユーザー登録のテスト
     */
    public function test_user_can_register(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password',
            'password_confirmation' => 'password',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'access_token',
                'token_type',
                'expires_in',
                'user' => [
                    'id',
                    'name',
                    'email',
                    'created',
                    'updated',
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);
    }

    /**
     * ユーザー登録のバリデーションエラーテスト
     */
    public function test_user_cannot_register_with_invalid_data(): void
    {
        // メールアドレスが無効
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Test User',
            'email' => 'invalid-email',
            'password' => 'password',
            'password_confirmation' => 'password',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);

        // パスワードが短すぎる
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'pass',
            'password_confirmation' => 'pass',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['password']);

        // パスワード確認が一致しない
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password',
            'password_confirmation' => 'different',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['password']);
    }

    /**
     * ログインのテスト
     */
    public function test_user_can_login(): void
    {
        // ユーザーを作成
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'access_token',
                'token_type',
                'expires_in',
                'user' => [
                    'id',
                    'name',
                    'email',
                    'created',
                    'updated',
                ],
            ]);
    }

    /**
     * 無効な認証情報でログインできないことを確認
     */
    public function test_user_cannot_login_with_invalid_credentials(): void
    {
        // ユーザーを作成
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
        ]);

        // 間違ったパスワード
        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'wrong-password',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'error' => 'Unauthorized',
            ]);

        // 存在しないメールアドレス
        $response = $this->postJson('/api/auth/login', [
            'email' => 'nonexistent@example.com',
            'password' => 'password',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'error' => 'Unauthorized',
            ]);
    }

    /**
     * 認証済みユーザーが自分の情報を取得できることを確認
     */
    public function test_user_can_get_their_profile(): void
    {
        // ユーザーを作成してログイン
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'api')
            ->getJson('/api/auth/me');

        $response->assertStatus(200)
            ->assertJson([
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ]);
    }

    /**
     * 未認証ユーザーがプロフィールにアクセスできないことを確認
     */
    public function test_unauthenticated_user_cannot_access_profile(): void
    {
        $response = $this->getJson('/api/auth/me');

        $response->assertStatus(401);
    }

    /**
     * トークンのリフレッシュをテスト
     */
    public function test_user_can_refresh_token(): void
    {
        // ユーザーを作成してログイン
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'api')
            ->postJson('/api/auth/refresh');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'access_token',
                'token_type',
                'expires_in',
                'user',
            ]);
    }

    /**
     * ログアウトのテスト
     */
    public function test_user_can_logout(): void
    {
        // ユーザーを作成してログイン
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'api')
            ->postJson('/api/auth/logout');

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Successfully logged out',
            ]);

        // ログアウト後にプロフィールにアクセスできないことを確認
        $response = $this->getJson('/api/auth/me');
        $response->assertStatus(401);
    }
}
