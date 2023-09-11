<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class News extends Model
{
    use HasFactory;
	
	protected $primaryKey = 'id_news';
	
	public $timestamps = false;
	
	protected $table = 'news';
	
	protected $fillable = [
        'writer', 'title', 'content', 'image', 'dates', 'reputation'
    ];
	
	public function writer() {
      return $this->belongsTo('App\Models\User');
    }
	
	public function topics() {
      return $this->belongsToMany('App\Models\Topic', 'news_topic', 'id_news', 'id_topic');
    }
	
	public function comments() {
      return $this->hasMany('App\Models\Comment', 'news');
    }
	
	public function voteOnNews() {
      return $this->belongsToMany('App\Models\User', 'vote_on_news', 'news', 'member')->withPivot('vote');
    }
	
	public function scopeSearch($query, $search)
    {
        if (!$search) {
            return $query;
        }
        return $query->whereRaw('tsvectors @@ plainto_tsquery(\'english\', ?)', [$search])
            ->orderByRaw('ts_rank(tsvectors, plainto_tsquery(\'english\', ?)) DESC', [$search]);
    }
}
