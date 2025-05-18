<?php

namespace Tests\Feature\Api;

use App\Models\Post;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PostApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * 投稿一覧を取得できることをテスト
     */
    public function test_can_get_posts_list(): void
    {
        // テストユーザーを作成
        $user = User::factory()->create();

        // テスト投稿を作成
        Post::factory()->count(3)->create([
            'user_id' => $user->id,
            'status' => 'published',
        ]);

        // API呼び出し
        $response = $this->getJson('/api/posts');

        // レスポンスの検証
        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'title',
                        'content',
                        'slug',
                        'status',
                        'user_id',
                        'published_at',
                        'created',
                        'updated',
                    ]
                ],
                'meta',
                'links',
            ]);
    }

    /**
     * 特定の投稿を取得できることをテスト
     */
    public function test_can_get_single_post(): void
    {
        // テストユーザーを作成
        $user = User::factory()->create();

        // テスト投稿を作成
        $post = Post::factory()->create([
            'user_id' => $user->id,
            'status' => 'published',
        ]);

        // API呼び出し
        $response = $this->getJson("/api/posts/{$post->slug}");

        // レスポンスの検証
        $response->assertStatus(200)
            ->assertJson([
                'id' => $post->id,
                'title' => $post->title,
                'slug' => $post->slug,
            ]);
    }

    /**
     * 認証済みユーザーが新規投稿を作成できることをテスト
     */
    public function test_authenticated_user_can_create_post(): void
    {
        // テストユーザーを作成
        $user = User::factory()->create();

        // 投稿データ
        $postData = [
            'title' => 'テスト投稿タイトル',
            'content' => 'これはテスト投稿の内容です。',
            'status' => 'draft',
        ];

        // 認証済みユーザーとしてAPI呼び出し
        $response = $this->actingAs($user)
            ->postJson('/api/posts', $postData);

        // レスポンスの検証
        $response->assertStatus(201)
            ->assertJson([
                'title' => $postData['title'],
                'content' => $postData['content'],
                'status' => $postData['status'],
                'user_id' => $user->id,
            ]);

        // データベースに保存されていることを確認
        $this->assertDatabaseHas('posts', [
            'title' => $postData['title'],
            'user_id' => $user->id,
        ]);
    }

    /**
     * 認証済みユーザーが自分の投稿を更新できることをテスト
     */
    public function test_authenticated_user_can_update_own_post(): void
    {
        // テストユーザーを作成
        $user = User::factory()->create();

        // テスト投稿を作成
        $post = Post::factory()->create([
            'user_id' => $user->id,
            'status' => 'draft',
        ]);

        // 更新データ
        $updateData = [
            'title' => '更新されたタイトル',
            'content' => '更新された内容',
            'status' => 'published',
        ];

        // 認証済みユーザーとしてAPI呼び出し
        $response = $this->actingAs($user)
            ->putJson("/api/posts/{$post->id}", $updateData);

        // レスポンスの検証
        $response->assertStatus(200)
            ->assertJson([
                'id' => $post->id,
                'title' => $updateData['title'],
                'content' => $updateData['content'],
                'status' => $updateData['status'],
            ]);

        // データベースが更新されていることを確認
        $this->assertDatabaseHas('posts', [
            'id' => $post->id,
            'title' => $updateData['title'],
        ]);
    }

    /**
     * 認証済みユーザーが自分の投稿を削除できることをテスト
     */
    public function test_authenticated_user_can_delete_own_post(): void
    {
        // テストユーザーを作成
        $user = User::factory()->create();

        // テスト投稿を作成
        $post = Post::factory()->create([
            'user_id' => $user->id,
        ]);

        // 認証済みユーザーとしてAPI呼び出し
        $response = $this->actingAs($user)
            ->deleteJson("/api/posts/{$post->id}");

        // レスポンスの検証
        $response->assertStatus(200);

        // 論理削除されていることを確認（deleted列がNULLでないこと）
        $this->assertSoftDeleted('posts', [
            'id' => $post->id,
        ]);
    }

    /**
     * 他のユーザーの投稿は更新できないことをテスト
     */
    public function test_cannot_update_other_users_post(): void
    {
        // テストユーザーを作成
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        // user1の投稿を作成
        $post = Post::factory()->create([
            'user_id' => $user1->id,
        ]);

        // 更新データ
        $updateData = [
            'title' => '更新されたタイトル',
            'content' => '更新された内容',
        ];

        // user2として投稿を更新しようとする
        $response = $this->actingAs($user2)
            ->putJson("/api/posts/{$post->id}", $updateData);

        // 403 Forbiddenが返されることを確認
        $response->assertStatus(403);

        // データベースが更新されていないことを確認
        $this->assertDatabaseMissing('posts', [
            'id' => $post->id,
            'title' => $updateData['title'],
        ]);
    }
}
