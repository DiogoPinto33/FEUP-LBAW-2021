@extends('layouts.app')

@section('title', 'Collab News - Homepage')

@section('content')

	@include('partials.search')
	
	@if (Auth::check())
	<div class="newsButton">
		<a class="button" href="{{ url('/news/create') }}">Create News</a>
	</div>
	@endif
	
	@foreach($news as $item)
	<div class="newsBox">
		<div class="newsImage">
			<img src="{{ $item->image }}" alt="news_image" width="350" height="250">
		</div>
		<div class="newsInfo">
			<div class="newsTopics">
				@foreach($item->topics as $topic)
					<a href="/news/topic/{{ $topic->id_topic }}">{{ $topic->name }}</a>
				@endforeach
			</div>
			<a href="/news/{{ $item->id_news }}"><div class="newsTitle">{{ $item->title }}</div></a>
			<div class="newsContent">{{ $item->content }}</div>
		</div>
	</div>
	@endforeach	
@endsection
