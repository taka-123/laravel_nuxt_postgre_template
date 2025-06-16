<?php

namespace Tests\Feature\Api;

use App\Models\Book;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BookApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * 認証なしで公開書籍一覧を取得できることをテスト
     */
    public function test_can_get_public_books_without_auth(): void
    {
        // 書籍データを作成
        Book::factory()->count(3)->create();

        $response = $this->getJson('/api/public/books');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'current_page',
                'data' => [
                    '*' => [
                        'id',
                        'title',
                        'author',
                        'isbn',
                        'barcode',
                    ]
                ],
                'total'
            ])
            ->assertJsonCount(3, 'data');
    }

    /**
     * 認証済みユーザーが書籍一覧を取得できることをテスト
     */
    public function test_authenticated_user_can_get_books(): void
    {
        // ユーザーを作成
        $user = User::factory()->create();

        // 書籍データを作成
        Book::factory()->count(5)->create();

        $response = $this->actingAs($user, 'api')
            ->getJson('/api/books');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'current_page',
                'data' => [
                    '*' => [
                        'id',
                        'title',
                        'author',
                        'isbn',
                        'barcode',
                    ]
                ],
                'total'
            ])
            ->assertJsonCount(5, 'data');
    }

    /**
     * 認証済みユーザーが書籍を登録できることをテスト
     */
    public function test_authenticated_user_can_create_book(): void
    {
        // ユーザーを作成
        $user = User::factory()->create();

        $bookData = [
            'title' => 'テスト書籍',
            'author' => 'テスト著者',
            'publisher' => 'テスト出版社',
            'publication_year' => 2022,
            'isbn' => '9784167158057',
        ];

        $response = $this->actingAs($user, 'api')
            ->postJson('/api/books', $bookData);

        $response->assertStatus(201)
            ->assertJson([
                'title' => 'テスト書籍',
                'author' => 'テスト著者',
                'publisher' => 'テスト出版社',
                'publication_year' => 2022,
                'isbn' => '9784167158057',
            ]);

        $this->assertDatabaseHas('books', [
            'title' => 'テスト書籍',
            'author' => 'テスト著者',
        ]);
    }

    /**
     * 認証済みユーザーが書籍を更新できることをテスト
     */
    public function test_authenticated_user_can_update_book(): void
    {
        // ユーザーを作成
        $user = User::factory()->create();

        // 書籍を作成
        $book = Book::factory()->create([
            'title' => '元のタイトル',
            'author' => '元の著者',
        ]);

        $updateData = [
            'title' => '更新後のタイトル',
            'author' => '更新後の著者',
        ];

        $response = $this->actingAs($user, 'api')
            ->putJson("/api/books/{$book->id}", $updateData);

        $response->assertStatus(200)
            ->assertJson([
                'id' => $book->id,
                'title' => '更新後のタイトル',
                'author' => '更新後の著者',
            ]);

        $this->assertDatabaseHas('books', [
            'id' => $book->id,
            'title' => '更新後のタイトル',
            'author' => '更新後の著者',
        ]);
    }

    /**
     * 認証済みユーザーが書籍を削除できることをテスト
     */
    public function test_authenticated_user_can_delete_book(): void
    {
        // ユーザーを作成
        $user = User::factory()->create();

        // 書籍を作成
        $book = Book::factory()->create();

        $response = $this->actingAs($user, 'api')
            ->deleteJson("/api/books/{$book->id}");

        $response->assertStatus(204);

        $this->assertDatabaseMissing('books', [
            'id' => $book->id,
        ]);
    }

    /**
     * 認証がないユーザーが認証必須のAPIにアクセスできないことをテスト
     */
    public function test_unauthenticated_user_cannot_access_protected_routes(): void
    {
        // 書籍一覧（認証必須）
        $this->getJson('/api/books')
            ->assertStatus(401);

        // 書籍登録（認証必須）
        $this->postJson('/api/books', [
                'title' => 'テスト書籍',
                'author' => 'テスト著者',
            ])
            ->assertStatus(401);

        // 書籍作成+バーコード生成（認証不要）は401を返さない
        $this->postJson('/api/books/create-with-barcode', [
                'book' => [
                    'title' => 'テスト書籍',
                    'author' => 'テスト著者',
                ]
            ])
            ->assertStatus(422); // バリデーションエラーは返すが401ではない
    }

    /**
     * ISBNから書籍情報を取得するAPIをテスト
     */
    public function test_can_fetch_book_info_by_isbn(): void
    {
        // モックデータを作成するには実際のISBNサービスをモックする必要がある
        // このテストは単に接続性のみを確認

        $response = $this->postJson('/api/isbn/fetch', [
            'isbn' => '9784167158057', // 実在するISBN
        ]);

        // サービスが利用できない場合は404または500が返される可能性があるため
        // ステータスコードは検証しない
        $response->assertStatus(200);
    }

    /**
     * バーコードを生成するAPIをテスト
     */
    public function test_can_generate_barcode(): void
    {
        $response = $this->postJson('/api/barcode/generate', [
            'format' => 'png',
            'width' => 2,
            'height' => 50,
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'barcode',
                'image_data',
            ]);
    }

    /**
     * バーコードから書籍を検索するAPIをテスト
     */
    public function test_can_find_book_by_barcode(): void
    {
        // バーコード付きの書籍を作成
        $book = Book::factory()->create([
            'barcode' => 'TEST12345',
        ]);

        $response = $this->postJson('/api/barcode/search', [
            'barcode' => 'TEST12345',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'id' => $book->id,
                'title' => $book->title,
                'barcode' => 'TEST12345',
            ]);
    }
}
