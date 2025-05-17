<?php

namespace Database\Seeders;

use App\Models\Comment;
use App\Models\Post;
use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 管理者ユーザーを作成
        $admin = User::factory()->create([
            'name' => '管理者',
            'email' => 'admin@example.com',
        ]);

        // 一般ユーザーを作成
        $user = User::factory()->create([
            'name' => 'テストユーザー',
            'email' => 'user@example.com',
        ]);

        // 追加ユーザーを作成
        $users = User::factory(3)->create();

        // 管理者の投稿を作成
        $adminPosts = $this->createPosts($admin, 3);

        // 一般ユーザーの投稿を作成
        $userPosts = $this->createPosts($user, 2);

        // コメントを作成
        foreach ($adminPosts as $post) {
            $this->createComments($post, $users, 2);
        }

        foreach ($userPosts as $post) {
            $this->createComments($post, $users->concat([$admin]), 2);
        }
    }

    /**
     * 指定されたユーザーの投稿を作成
     */
    private function createPosts(User $user, int $count): array
    {
        $posts = [];

        for ($i = 1; $i <= $count; $i++) {
            $title = "サンプル投稿 {$user->name} #{$i}";
            $post = new Post([
                'user_id' => $user->id,
                'title' => $title,
                'content' => "これは{$user->name}によるサンプル投稿の内容です。\n\nここには記事の本文が入ります。このテンプレートではLaravel、Nuxt、PostgreSQLを使用したWebアプリケーションの基本的な機能を実装しています。",
                'slug' => Str::slug($title),
                'status' => 'published',
                'published_at' => now()->subDays(rand(1, 30)),
                'created' => now(),
                'created_user' => $user->email,
                'updated' => now(),
                'updated_user' => $user->email,
            ]);
            
            $post->save();

            $posts[] = $post;
        }

        return $posts;
    }

    /**
     * 指定された投稿にコメントを作成
     */
    private function createComments(Post $post, $users, int $count): void
    {
        foreach ($users->random($count) as $user) {
            $comment = new Comment([
                'post_id' => $post->id,
                'user_id' => $user->id,
                'content' => "これは{$user->name}によるコメントです。この投稿は非常に参考になりました。",
                'is_approved' => true,
                'created' => now(),
                'created_user' => $user->email,
                'updated' => now(),
                'updated_user' => $user->email,
            ]);
            
            $comment->save();
        }
    }
}
