<?php

namespace App\Models;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use Notifiable;

    // Don't add create and update timestamps in database.
    public $timestamps  = false;
	
	protected $table = 'member';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name', 'email', 'password', 'profile_description', 'image', 'dates'
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password'
    ];
	 
    public function newsWriter() {
      return $this->hasMany('App\Models\News', 'writer');
    }
	
	public function commentWriter() {
      return $this->hasMany('App\Models\Comment', 'writer');
    }
	
	public function followTopic() {
      return $this->belongsToMany('App\Models\Topic', 'follow_topic', 'id_member', 'id_topic');
    }
	
	public function followMember() {
		return $this->belongsToMany('App\Models\User', 'follow_member', 'follower', 'followed');
	}
	
	public function followers() {
		return $this->belongsToMany('App\Models\User', 'follow_member', 'followed', 'follower');
	}
	
	public function voteOnNews() {
      return $this->belongsToMany('App\Models\News', 'vote_on_news', 'member', 'news')->withPivot('vote');
    }
	
	public function voteOnComment() {
      return $this->belongsToMany('App\Models\Comment', 'vote_on_comment', 'member', 'comments')->withPivot('vote');
    }
}
