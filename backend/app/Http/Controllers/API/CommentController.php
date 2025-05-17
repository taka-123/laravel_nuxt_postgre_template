<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Comment;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class CommentController extends Controller
{
    /**
     * 投稿に対するコメント一覧を取得する
     *
     * @param int $postId
     * @return \Illuminate\Http\JsonResponse
     */
    public function index($postId)
    {
        $post = Post::whereNull('deleted')->findOrFail($postId);
        
        $comments = Comment::with('user')
            ->where('post_id', $postId)
            ->whereNull('deleted')
            ->where('is_approved', true)
            ->orderBy('created', 'desc')
            ->get();
            
        return response()->json($comments);
    }

    /**
     * 新しいコメントを作成する
     *
     * @param Request $request
     * @param int $postId
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request, $postId)
    {
        $post = Post::whereNull('deleted')->findOrFail($postId);
        
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = Auth::user();
        
        $comment = new Comment([
            'post_id' => $postId,
            'user_id' => $user->id,
            'content' => $request->content,
            'is_approved' => true, // デフォルトで承認済み（必要に応じて変更可能）
            'created' => now(),
            'created_user' => $user->email,
            'updated' => now(),
            'updated_user' => $user->email,
        ]);
        
        $comment->save();

        // ユーザー情報を含めて返す
        $comment->load('user');
        
        return response()->json($comment, 201);
    }

    /**
     * コメントを更新する
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $comment = Comment::whereNull('deleted')->findOrFail($id);
        
        // コメント投稿者本人または管理者のみ更新可能
        if (Auth::id() !== $comment->user_id && !Auth::user()->is_admin) {
            return response()->json(['error' => '権限がありません'], 403);
        }

        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $comment->update([
            'content' => $request->content,
            'updated' => now(),
            'updated_user' => Auth::user()->email,
        ]);

        return response()->json($comment);
    }

    /**
     * コメントを削除する（論理削除）
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $comment = Comment::whereNull('deleted')->findOrFail($id);
        
        // コメント投稿者本人または管理者のみ削除可能
        if (Auth::id() !== $comment->user_id && !Auth::user()->is_admin) {
            return response()->json(['error' => '権限がありません'], 403);
        }

        $comment->update([
            'deleted' => now(),
            'deleted_user' => Auth::user()->email,
        ]);

        return response()->json(['message' => 'コメントが削除されました']);
    }
}
