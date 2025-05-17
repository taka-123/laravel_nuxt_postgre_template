<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class PostController extends Controller
{
    /**
     * 投稿の一覧を取得する
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $query = Post::with('user')->whereNull('deleted');

        // 検索条件の適用
        if ($request->has('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('content', 'like', "%{$search}%");
            });
        }

        // ステータスによるフィルタリング
        if ($request->has('status')) {
            $query->where('status', $request->input('status'));
        } else {
            // デフォルトでは公開済みの投稿のみを表示
            $query->published();
        }

        // ソート順の適用
        $sortBy = $request->input('sort_by', 'published_at');
        $sortOrder = $request->input('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        // ページネーション
        $perPage = $request->input('per_page', 10);
        $posts = $query->paginate($perPage);

        return response()->json($posts);
    }

    /**
     * 投稿の詳細を取得する
     *
     * @param string $slug
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($slug)
    {
        $post = Post::with(['user', 'comments.user'])
            ->whereNull('deleted')
            ->where('slug', $slug)
            ->firstOrFail();

        return response()->json($post);
    }

    /**
     * 新しい投稿を作成する
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'status' => 'required|in:draft,published,archived',
            'featured_image' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = Auth::user();
        $slug = Str::slug($request->title);

        // スラッグが既に存在する場合は、ユニークになるように数字を追加
        $count = 1;
        $originalSlug = $slug;
        while (Post::where('slug', $slug)->exists()) {
            $slug = $originalSlug . '-' . $count++;
        }

        $post = new Post([
            'user_id' => Auth::id(),
            'title' => $request->title,
            'content' => $request->content,
            'slug' => $slug,
            'featured_image' => $request->featured_image,
            'status' => $request->status,
            'published_at' => $request->status === 'published' ? now() : null,
            'created' => now(),
            'created_user' => Auth::user()->email,
            'updated' => now(),
            'updated_user' => Auth::user()->email,
        ]);

        $post->save();

        return response()->json($post, 201);
    }

    /**
     * 投稿を更新する
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $post = Post::whereNull('deleted')->findOrFail($id);

        // 投稿者本人または管理者のみ更新可能
        if (Auth::id() !== $post->user_id && !Auth::user()->is_admin) {
            return response()->json(['error' => '権限がありません'], 403);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'status' => 'required|in:draft,published,archived',
            'featured_image' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // 公開ステータスが変更された場合の処理
        if ($request->status === 'published' && $post->status !== 'published') {
            $post->published_at = now();
        }

        $post->update([
            'title' => $request->title,
            'content' => $request->content,
            'featured_image' => $request->featured_image,
            'status' => $request->status,
            'updated' => now(),
            'updated_user' => Auth::user()->email,
        ]);

        return response()->json($post);
    }

    /**
     * 投稿を削除する（論理削除）
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $post = Post::whereNull('deleted')->findOrFail($id);

        // 投稿者本人または管理者のみ削除可能
        if (Auth::id() !== $post->user_id && !Auth::user()->is_admin) {
            return response()->json(['error' => '権限がありません'], 403);
        }

        $post->update([
            'deleted' => now(),
            'deleted_user' => Auth::user()->email,
        ]);

        return response()->json(['message' => '投稿が削除されました']);
    }
}
