<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    use HasFactory;
	
	protected $primaryKey = 'id_comment';
	
	public $timestamps = false;
	
	protected $table = 'comments';
	
	protected $fillable = [
        'writer', 'news', 'content', 'dates', 'reputation'
    ];
	
	public function writer() {
      return $this->belongsTo('App\Models\User');
    }
	
	public function news() {
      return $this->belongsTo('App\Models\News');
    }
	
	public function voteOnComment() {
      return $this->belongsToMany('App\Models\User', 'vote_on_comment', 'comments', 'member')->withPivot('vote');
    }
}
