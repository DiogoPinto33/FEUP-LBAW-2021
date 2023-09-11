<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Auth\Events\Registered;

class AdminController extends Controller
{
	public function list()
    {
		if (Auth::user()->is_admin){
			$users = DB::table('member')->orderBy('id')->get();
			return view('pages.admin.users', ['users' => $users]);
		}
		else
			return redirect()->back();
    }
	
	public function showCreateForm()
    {
		if (Auth::user()->is_admin){
			return view('pages.admin.users.create');
		}
		else
			return redirect()->back();
    }
	
	protected function validator(array $data)
    {
        return Validator::make($data, [
            'name' => 'required|string|max:100|unique:member',
            'email' => 'required|string|email|max:255|unique:member',
            'password' => 'required|string|min:6',
			'description' => 'string|max:255',
			'image' => 'string|max:300'
        ]);
    }
	
	protected $redirectTo = '/admin/users';
	
    public function create(Request $request)
    {
		if (Auth::user()->is_admin){
			$this->validator($request->all())->validate();
		
			$user = User::create([
			  'name' => $request->input('name'),
			  'email' => $request->input('email'),
			  'password' => bcrypt($request->input('password')),
			  'profile_description' => $request->input('description'),
			  'image' => $request->input('image')
			]);

			return redirect('/admin/users')->with(['message' => 'Successfull creation', 'message-type' => 'Success']);
		}
		else
			return redirect()->back();
    }
	
	public function search(){
		
	}
}
