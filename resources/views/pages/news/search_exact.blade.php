@extends('layouts.app')

@section('title', 'Exact Match')

@section('content')

	<div class="newsDetail">
		<div class="newsDetailLeft">
		<header>
			<div class="newsDetailTopic">
				@foreach($news->topics as $topic)
					{{ $topic->name }}
				@endforeach
			</div>
			<h1 class="newsDetailTitle">{{ $news->title }}</h1>
		</header>
			<p class="newsDetailContent">{{ $news->content }}</p>
			<img class="newsDetailImg" src="{{ $news->image }}" alt="news_image" width="450" height="200">
		</div>
		<div class="newsDetailRight">
			<p class="newsDetailWriter">Published by</p>
			<p class="newsDetailWriter">
				@if($writer != null)
					<a href="/users/{{ $news->writer }}">{{ $writer->name }}</a>
				@else
					Anonymous User
				@endif
			</p>
			<p class="newsDetailData">{{ date('d-m-Y, H:i', strtotime($news->dates)) }}</p>
			<p class="newsDetailData">Reputation: {{ $news->reputation }}
			
			@include('partials.voteOnNews')
		</div>
		
		@can('update', $news)
		<div class="newsButton">
			<a class="button" href="{{ $news->id_news }}/edit">Edit</a>
			<form action="{{ url('/news', ['id_news' => $news->id_news]) }}" method="post">
				<input type="submit" value="Delete" />
				@method('delete')
				@csrf
			</form>
		</div>
		@endcan
	</div>
	@include('partials.comments')
	
@endsection
