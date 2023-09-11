<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\News;
use App\Models\Topic;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class TopicController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
    }

	public function list($id)
    {
		$topic = Topic::find($id);
		
		return view('pages.news.topic', ['topic' => $topic]);
    }
	
	public function follow(Request $request)
    {
        $topic = Topic::find($request->input('id_topic'));
		
		$id_user = Auth::user()->id;
		
		$topic->followers()->attach($id_user);
		
		$topic->save();
		
		return redirect('/news/topic/'.$request->input('id_topic'));
    }
	
	public function unfollow(Request $request)
    {
        $topic = Topic::find($request->input('id_topic'));
		
		$id_user = Auth::user()->id;
		
		$topic->followers()->detach($id_user);
		
		$topic->save();
		
		return redirect('/news/topic/'.$request->input('id_topic'));
    }
}
