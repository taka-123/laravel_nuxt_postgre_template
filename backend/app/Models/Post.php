<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Post extends Model
{
    use HasFactory;
    
    /**
     * Laravelのタイムスタンプを無効化
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'title',
        'content',
        'slug',
        'featured_image',
        'status',
        'published_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'published_at' => 'datetime',
        'created' => 'datetime',
        'updated' => 'datetime',
        'deleted' => 'datetime',
    ];

    /**
     * 投稿の作成者を取得
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * 投稿に対するコメントを取得
     */
    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class)->whereNull('deleted');
    }

    /**
     * 公開済みの投稿のみを取得するスコープ
     */
    public function scopePublished($query)
    {
        return $query->where('status', 'published')
            ->whereNotNull('published_at')
            ->whereNull('deleted')
            ->where('published_at', '<=', now());
    }
}
