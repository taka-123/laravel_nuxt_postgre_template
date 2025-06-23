<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // テスト用ユーザーを作成
        User::factory()->create([
            'name' => '管理者',
            'email' => 'admin@example.com',
        ]);

        User::factory()->create([
            'name' => 'テストユーザー',
            'email' => 'user@example.com',
        ]);
    }
}