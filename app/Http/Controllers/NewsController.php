<?php

namespace App\Http\Controllers;

use App\Models\News;
use App\Models\User;
use App\Models\Topic;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class NewsController extends Controller
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
	
	public function showCreateForm()
    {
		return view('pages.news.create');
			
    }
	
	protected function validator(array $data)
    {
        return Validator::make($data, [
            'title' => 'required|string|max:60|unique:news',
			'content' => 'required|string|max:1500',
			'image' => 'string|max:300'
        ]);
    }
	
	public function create(Request $request)
    {
		$this->validator($request->all())->validate();
		
		$user_id = Auth::user()->id;
		
		$news = News::create([
			'writer' => $user_id,
			'title' => $request->input('title'),
            'content' => $request->input('content'),
			'image' => $request->input('image')
		]);

		$news->topics()->attach($request->input('news_topic'));
		
        return redirect('/news/'.$news->id_news);
    }


    public function show($id)
    {
		$news = News::find($id);
		  
		$user = User::find($news->writer);
		  
		return view('pages.news.index', ['news' => $news, 'writer' => $user]);
    }

	public function list()
    {
		$news = News::with('topics')->orderBy('dates', 'DESC')->get();
	  
		return view('pages.news', ['news' => $news]);
    }

	public function showUpdateForm($id)
    {
		$news = News::find($id);
		
		if (auth()->user()->can('update', $news))
			return view('pages.news.edit', ['news'=>$news]);
		else 
			return redirect()->back();
    }
	
	public function update(Request $request, $id)
    {
		$request->validate([
            'title' => 'required|string|max:60',
			'content' => 'required|string|max:1500',
			'image' => 'string|max:300'
        ]);
		
        $news = News::find($id);
		
		$news->title = $request->input('title');
        $news->content = $request->input('content');
		$news->image = $request->input('image');
		
		$news->save();
		
		if (!$news->topics->contains($request->input('news_topic'))){
			$news->topics()->detach();
			$news->topics()->attach($request->input('news_topic'));
		}
		
		return redirect()->action('NewsController@show', ['id_news' => $id]);
    }
	
	public function delete(Request $request, $id)
    {
		$news = News::find($id);
		
		if (auth()->user()->can('delete', $news)){
			$news->delete();
			return redirect('/news');
		}
		else 
			return redirect()->back();
    }
	
	public function searchText(Request $request)
    {	
		$results = News::search($request->search)->get();

		return view('pages.news.search', ['news'=>$results]);
    }
	
	public function searchExact(Request $request)
    {
        $results = News::search($request->search)->limit(1)->get();
		
		$news = News::find($results[0]->id_news);
		
		$user = User::find($news->writer);

		return view('pages.news.search_exact', ['news'=>$news, 'writer' => $user]);
    }
	
	public function vote(Request $request)
    {
        $news = News::find($request->input('id_news'));
		
		$user = Auth::user();
		
		switch ($request->input('vote')){
			case 'up_vote':
				$news->voteOnNews()->attach($user->id, ['vote' => 1]);
				break;
			case 'down_vote':
				$news->voteOnNews()->attach($user->id, ['vote' => -1]);
				break;
		}
		
		return redirect('/news/'.$request->input('id_news'));
    }
	
	public function deleteVote(Request $request)
    {
        $news = News::find($request->input('id_news'));
		
		$user = Auth::user();
		
		$news->voteOnNews()->detach($user->id);

		return redirect('/news/'.$request->input('id_news'));
    }

	public function userFeed($id_user)
	{
		$user = User::find($id_user);
		
		if (auth()->user()->can('seeFeed', $user)){
			$news = [];
			
			foreach($user->followTopic as $topicInfo){
				$topic = Topic::find($topicInfo->id_topic);
				foreach($topic->news as $item){
					array_push($news, News::find($item->id_news));
				}
			}
			
			foreach($user->followMember as $memberInfo){
				$member = User::find($memberInfo->id);
				foreach($member->newsWriter as $item){
					array_push($news, News::find($item->id_news));
				}
			}
			
			return view('pages.news.user_feed', ['news' => $news]);
		}
		else
			return redirect()->back();
	}
}
