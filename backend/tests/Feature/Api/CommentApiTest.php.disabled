<?php

namespace Tests\Feature\Api;

use App\Models\Comment;
use App\Models\Post;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CommentApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * 投稿に対するコメント一覧を取得できることをテスト
     */
    public function test_can_get_comments_for_post(): void
    {
        // テストユーザーを作成
        $user = User::factory()->create();

        // テスト投稿を作成
        $post = Post::factory()->create([
            'user_id' => $user->id,
            'status' => 'published',
        ]);

        // テストコメントを作成
        Comment::factory()->count(3)->create([
            'post_id' => $post->id,
            'user_id' => $user->id,
        ]);

        // API呼び出し
        $response = $this->getJson("/api/posts/{$post->id}/comments");

        // レスポンスの検証
        $response->assertStatus(200)
            ->assertJsonCount(3)
            ->assertJsonStructure([
                '*' => [
                    'id',
                    'content',
                    'post_id',
                    'user_id',
                    'created',
                    'updated',
                    'user',
                ]
            ]);
    }

    /**
     * 認証済みユーザーがコメントを投稿できることをテスト
     */
    public function test_authenticated_user_can_post_comment(): void
    {
        // テストユーザーを作成
        $user = User::factory()->create();

        // テスト投稿を作成
        $post = Post::factory()->create([
            'user_id' => $user->id,
            'status' => 'published',
        ]);

        // コメントデータ
        $commentData = [
            'content' => 'これはテストコメントです。',
        ];

        // 認証済みユーザーとしてAPI呼び出し
        $response = $this->actingAs($user)
            ->postJson("/api/posts/{$post->id}/comments", $commentData);

        // レスポンスの検証
        $response->assertStatus(201)
            ->assertJson([
                'content' => $commentData['content'],
                'post_id' => $post->id,
                'user_id' => $user->id,
            ]);

        // データベースに保存されていることを確認
        $this->assertDatabaseHas('comments', [
            'content' => $commentData['content'],
            'post_id' => $post->id,
            'user_id' => $user->id,
        ]);
    }

    /**
     * 認証済みユーザーが自分のコメントを更新できることをテスト
     */
    public function test_authenticated_user_can_update_own_comment(): void
    {
        // テストユーザーを作成
        $user = User::factory()->create();

        // テスト投稿を作成
        $post = Post::factory()->create([
            'user_id' => $user->id,
            'status' => 'published',
        ]);

        // テストコメントを作成
        $comment = Comment::factory()->create([
            'post_id' => $post->id,
            'user_id' => $user->id,
            'content' => '元のコメント内容',
        ]);

        // 更新データ
        $updateData = [
            'content' => '更新されたコメント内容',
        ];

        // 認証済みユーザーとしてAPI呼び出し
        $response = $this->actingAs($user)
            ->putJson("/api/comments/{$comment->id}", $updateData);

        // レスポンスの検証
        $response->assertStatus(200)
            ->assertJson([
                'id' => $comment->id,
                'content' => $updateData['content'],
            ]);

        // データベースが更新されていることを確認
        $this->assertDatabaseHas('comments', [
            'id' => $comment->id,
            'content' => $updateData['content'],
        ]);
    }

    /**
     * 認証済みユーザーが自分のコメントを削除できることをテスト
     */
    public function test_authenticated_user_can_delete_own_comment(): void
    {
        // テストユーザーを作成
        $user = User::factory()->create();

        // テスト投稿を作成
        $post = Post::factory()->create([
            'user_id' => $user->id,
            'status' => 'published',
        ]);

        // テストコメントを作成
        $comment = Comment::factory()->create([
            'post_id' => $post->id,
            'user_id' => $user->id,
        ]);

        // 認証済みユーザーとしてAPI呼び出し
        $response = $this->actingAs($user)
            ->deleteJson("/api/comments/{$comment->id}");

        // レスポンスの検証
        $response->assertStatus(200);

        // 論理削除されていることを確認（deleted列がNULLでないこと）
        $this->assertSoftDeleted('comments', [
            'id' => $comment->id,
        ]);
    }

    /**
     * 他のユーザーのコメントは更新できないことをテスト
     */
    public function test_cannot_update_other_users_comment(): void
    {
        // テストユーザーを作成
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        // テスト投稿を作成
        $post = Post::factory()->create([
            'user_id' => $user1->id,
            'status' => 'published',
        ]);

        // user1のコメントを作成
        $comment = Comment::factory()->create([
            'post_id' => $post->id,
            'user_id' => $user1->id,
            'content' => '元のコメント内容',
        ]);

        // 更新データ
        $updateData = [
            'content' => '更新されたコメント内容',
        ];

        // user2としてコメントを更新しようとする
        $response = $this->actingAs($user2)
            ->putJson("/api/comments/{$comment->id}", $updateData);

        // 403 Forbiddenが返されることを確認
        $response->assertStatus(403);

        // データベースが更新されていないことを確認
        $this->assertDatabaseMissing('comments', [
            'id' => $comment->id,
            'content' => $updateData['content'],
        ]);
    }

    /**
     * 投稿者は自分の投稿に対する他のユーザーのコメントを削除できることをテスト
     */
    public function test_post_owner_can_delete_comments_on_their_post(): void
    {
        // テストユーザーを作成
        $postOwner = User::factory()->create();
        $commenter = User::factory()->create();

        // テスト投稿を作成
        $post = Post::factory()->create([
            'user_id' => $postOwner->id,
            'status' => 'published',
        ]);

        // 別のユーザーのコメントを作成
        $comment = Comment::factory()->create([
            'post_id' => $post->id,
            'user_id' => $commenter->id,
        ]);

        // 投稿者としてコメントを削除
        $response = $this->actingAs($postOwner)
            ->deleteJson("/api/comments/{$comment->id}");

        // レスポンスの検証
        $response->assertStatus(200);

        // 論理削除されていることを確認
        $this->assertSoftDeleted('comments', [
            'id' => $comment->id,
        ]);
    }
}
