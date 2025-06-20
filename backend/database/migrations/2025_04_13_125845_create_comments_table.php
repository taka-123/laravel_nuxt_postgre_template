<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('post_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->text('content'); // コメント内容
            $table->boolean('is_approved')->default(true); // 承認状態
            $table->timestamp('created_at')->nullable(); // レコード作成日時
            $table->string('created_by', 256)->nullable(); // レコード作成ユーザー
            $table->timestamp('updated_at')->nullable(); // レコード最終更新日時
            $table->string('updated_by', 256)->nullable(); // レコード最終更新ユーザー
            $table->timestamp('deleted_at')->nullable(); // 論理削除日時
            $table->string('deleted_by', 256)->nullable(); // レコード削除ユーザー
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('comments');
    }
};
