<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Topic extends Model
{
    use HasFactory;
	
	protected $primaryKey = 'id_topic';
	
	protected $table = 'topic';
	
	protected $fillable = [
        'name'
    ];
	
	public function news() {
      return $this->belongsToMany('App\Models\News', 'news_topic', 'id_topic', 'id_news');
    }
	
	public function followers() {
      return $this->belongsToMany('App\Models\User', 'follow_topic', 'id_topic', 'id_member');
    }
}
