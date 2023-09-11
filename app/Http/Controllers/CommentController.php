<?php

namespace App\Http\Controllers;

use App\Models\News;
use App\Models\User;
use App\Models\Comment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class CommentController extends Controller
{

	public function showCreateForm($id_news)
    {
		return view('pages.comment.create', ['id_news' => $id_news]);	
    }
	
	protected function validator(array $data)
    {
        return Validator::make($data, [
			'content' => 'required|string|max:1500'
        ]);
    }

    public function create(Request $request, $id_news)
    {
        $this->validator($request->all())->validate();
		
		$id_user = Auth::user()->id;
		
		Comment::create([
			'writer' => $id_user,
			'news' => $id_news,
			'content' => $request->input('content')
		]);

        return redirect('/news/'.$id_news);
    }


    public function showUpdateForm($id_comment)
    {
		$comment = Comment::find($id_comment);
		
		if (auth()->user()->can('update', $comment)){
			return view('pages.comment.edit', ['comment' => $comment]);
		}
		else 
			return redirect()->back();
    }

    public function update(Request $request, $id_comment)
    {
        $request->validate([
			'content' => 'required|string|max:1500'
		]);
		
		$comment = Comment::find($id_comment);
		
		$comment->content = $request->input('content');
		
		$comment->save();
		
		return redirect('/news/'.$comment->news);
    }
	
	public function delete(Request $request, $id_comment)
    {
		$comment = Comment::find($id_comment);		
		
		if (auth()->user()->can('delete', $comment)){
			$id_news = $comment->news;
			$comment->delete();
			return redirect('/news/'.$id_news);
		}
		else 
			return redirect()->back();
    }
	
	public function vote(Request $request)
    {
        $comment = comment::find($request->input('id_comment'));
		
		$user = Auth::user();
		
		switch ($request->input('vote')){
			case 'up_vote':
				$comment->voteOnComment()->attach($user->id, ['vote' => 1]);
				break;
			case 'down_vote':
				$comment->voteOnComment()->attach($user->id, ['vote' => -1]);
				break;
		}
		
		return redirect('/news/'.$comment->news);
    }
	
	public function deleteVote(Request $request)
    {
        $comment = comment::find($request->input('id_comment'));
		
		$user = Auth::user();
		
		$comment->voteOnComment()->detach($user->id);

		return redirect('/news/'.$comment->news);
    }
}
