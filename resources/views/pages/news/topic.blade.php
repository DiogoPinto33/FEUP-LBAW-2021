@extends('layouts.app')

@section('title', 'Topic')

@section('content')

	@include('partials.search')
	
	@if (Auth::check())
	@can('follow', $topic)
	<div class="newsButton">
		<form method="POST" action="/news/topic/{{ $topic->id_topic }}/follow">
			{{ csrf_field() }}
			<input value="{{ $topic->id_topic }}" name="id_topic" hidden="hidden">
			<button type="submit">Follow topic</button>
		</form>
	</div>
	@endcan
	@can('unfollow', $topic)
	<div class="newsButton">
		<form method="POST" action="/news/topic/{{ $topic->id_topic }}/follow">
			<input value="{{ $topic->id_topic }}" name="id_topic" hidden="hidden">
			<input type="submit" value="Unfollow topic" />
			@method('delete')
			@csrf
		</form>
	</div>
	@endcan
	@endif
	
	@foreach($topic->news as $item)
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
