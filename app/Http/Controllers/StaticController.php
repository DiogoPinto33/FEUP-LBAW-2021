<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class StaticController extends Controller
{
	public function showHelp()
    {
		return view('pages.help');
    }	
	public function showAbout()
    {
		return view('pages.about');
    }	
}
