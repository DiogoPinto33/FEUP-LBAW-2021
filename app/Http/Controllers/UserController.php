<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class UserController extends Controller
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

    public function show($id)
    {
		$user = User::find($id);
		
		if ($user != null)
			return view('pages.users.index', ['user' => $user]);
		else
			return redirect()->back();
    }
	
	public function showUpdateForm($id)
    {
        $user = User::find($id);
		
		if (auth()->user()->can('update', $user))
			return view('pages.users.edit', ['user'=>$user]);
		else 
			return redirect()->back();
    }

	protected function validator(array $data)
    {
        return Validator::make($data, [
            'name' => 'required|string|max:100',
            'password' => 'required|string|min:6|confirmed',
			'description' => 'string|max:255',
			'image' => 'string|max:300'
        ]);
    }
	
    public function update(Request $request, $id)
    {
        $this->validator($request->all())->validate();
		
		$user = User::find($id);
		
		$user->name = $request->input('name');
		$user->password = $request->input('password');
		$user->profile_description = $request->input('description');
		$user->image = $request->input('image');
		
		$user->save();
		
		return redirect()->action('UserController@show', ['id_user' => $id]);
    }
	
	public function delete(Request $request, $id)
    {
		$user = User::find($id);
		
		if (auth()->user()->can('delete', $user)){
			$user->delete();
			return redirect('/news');
		}
		else 
			return redirect()->back();		
    }
	
	public function follow(Request $request)
    {
        $followed = User::find($request->input('id_user'));
		
		$id_follower = Auth::user()->id;
		
		$followed->followers()->attach($id_follower);
		
		$followed->save();
		
		return redirect('/users/'.$request->input('id_user'));
    }
	
	public function unfollow(Request $request)
    {
        $followed = User::find($request->input('id_user'));
		
		$id_follower = Auth::user()->id;
		
		$followed->followers()->detach($id_follower);
		
		$followed->save();
		
		return redirect('/users/'.$request->input('id_user'));
    }
}
