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
        Schema::create('books', function (Blueprint $table) {
            $table->id();
            $table->string('isbn')->nullable()->index(); // ISBN番号（ない本もあるためnullable）
            $table->string('barcode')->unique(); // 独自バーコード（必須）
            $table->string('title'); // 書籍タイトル
            $table->string('author')->nullable(); // 著者
            $table->string('publisher')->nullable(); // 出版社
            $table->year('publication_year')->nullable(); // 出版年
            $table->text('description')->nullable(); // 説明
            $table->string('cover_image')->nullable(); // 表紙画像のパス
            $table->string('location')->nullable(); // 本の保管場所
            $table->enum('status', ['available', 'borrowed', 'lost', 'retired'])->default('available'); // ステータス
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('books');
    }
};
