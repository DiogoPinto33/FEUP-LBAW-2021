<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/
// Home
Route::get('/', 'Auth\LoginController@home');

// Authentication
Route::get('login', 'Auth\LoginController@showLoginForm')->name('login');
Route::post('login', 'Auth\LoginController@login');
Route::get('logout', 'Auth\LoginController@logout')->name('logout');
Route::get('register', 'Auth\RegisterController@showRegistrationForm')->name('register');
Route::post('register', 'Auth\RegisterController@register');

// Users
Route::get('users/{id_user}', ['middleware' => 'auth', 'uses' => 'UserController@show']);
Route::delete('users/{id_user}', 'UserController@delete');
Route::get('users/{id_user}/edit', 'UserController@showUpdateForm')->name('editUser');
Route::post('users/{id_user}/edit', 'UserController@update');
Route::post('users/{id_user}/follow', 'UserController@follow');
Route::delete('users/{id_user}/follow', 'UserController@unfollow');

// Search
Route::get('news/search', 'NewsController@searchText');
Route::get('news/search_exact', 'NewsController@searchExact');

// Topic
Route::get('news/topic/{id_topic}', 'TopicController@list');
Route::post('news/topic/{id_topic}/follow', 'TopicController@follow');
Route::delete('news/topic/{id_topic}/follow', 'TopicController@unfollow');

// News
Route::get('news', 'NewsController@list');
Route::get('news/create', ['middleware' => 'auth', 'uses' =>'NewsController@showCreateForm'])->name('createNews');
Route::post('news/create', 'NewsController@create');
Route::get('news/{id_news}', 'NewsController@show');
Route::delete('news/{id_news}', 'NewsController@delete');
Route::get('news/{id_news}/edit', 'NewsController@showUpdateForm');
Route::post('news/{id_news}/edit', 'NewsController@update');
Route::get('news/user_feed/{id_user}', 'NewsController@userFeed');

// Comments
Route::get('news/{id_news}/create_comment', ['middleware' => 'auth', 'uses' => 'CommentController@showCreateForm']);
Route::post('news/{id_news}/create_comment', 'CommentController@create');
Route::get('edit_comment/{id_comment}', 'CommentController@showUpdateForm');
Route::post('edit_comment/{id_comment}', 'CommentController@update');
Route::delete('delete_comment/{id_comment}', 'CommentController@delete');

// Votes
Route::post('news/{id_news}/vote_on_news', 'NewsController@vote');
Route::delete('news/{id_news}/vote_on_news', 'NewsController@deleteVote');
Route::post('{id_comment}/vote_on_comment', 'CommentController@vote');
Route::delete('{id_comment}/vote_on_comment', 'CommentController@deleteVote');

// Admin
Route::get('admin/users', 'AdminController@list');
Route::get('admin/users/create', 'AdminController@showCreateForm')->name('createUser');
Route::post('admin/users/create', 'AdminController@create');

// Static
Route::get('help', 'StaticController@showHelp');
Route::get('about', 'StaticController@showAbout');

