<?php

namespace App\Providers;

use App\Models\Topic;
use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;

class TopicServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        $topics = Topic::get();
		
        View::composer('layouts.app', function ($view) {
            $view->with('topics', Topic::get());
        });
		
		View::composer('pages.news.create', function ($view) {
            $view->with('topics', Topic::get());
        });
		
		View::composer('pages.news.edit', function ($view) {
            $view->with('topics', Topic::get());
        });
    }
}
