@extends('layouts.app')

@section('title', 'User profile')

@section('content')

	<div class="profile">
		<div>
			<h1 class="username">{{ $user->name }}</h1>
        	<img src="{{ $user->image }}" alt="profile_image" width="150" height="200">
      		</div>
      	<div class="bio">
      		<p>{{ $user->profile_description }}</p>
      	</div>
		<div class="info">
			<div>
          	<p>Reputation: {{ $user->reputation }}</p>
          	<p>Joined on: {{ date('d-m-Y', strtotime($user->dates)) }}</p>
        	</div>
		</div>
		@can('update', $user)
		<div class="newsButton">
			<a class="button" href="{{ $user->id }}/edit">Edit</a>
			<form action="{{ url('/users', ['id_user' => $user->id]) }}" method="post">
				<input type="submit" value="Delete Account" />
				@method('delete')
				@csrf
			</form>
		</div>
		@endcan
		@can('follow', $user)
		<div class="newsButton">
			<form method="POST" action="/users/{{ $user->id }}/follow">
				{{ csrf_field() }}
				<input value="{{ $user->id }}" name="id_user" hidden="hidden">
				<button type="submit">Follow user</button>
			</form>
		</div>
		@endcan
		@can('unfollow', $user)
		<div class="newsButton">
			<form method="POST" action="/users/{{ $user->id }}/follow">
				<input value="{{ $user->id }}" name="id_user" hidden="hidden">
				<input type="submit" value="Unfollow user" />
				@method('delete')
				@csrf
			</form>
		</div>
		@endcan
	</div>
	@can('seeFeed', $user)
		<div class="suggestButton">
			<a class="button"  href="/news/user_feed/{{ $user->id }}">Suggestions for me</a>
		</div>
	@endcan	
	<div class="userPosts">
		<div class="userNewsBox">
			<h1>News</h1>
			<div class="userNews">
				@foreach($user->newsWriter as $item)
				<div class="userNewsTitle">
					<a href="/news/{{ $item->id_news }}">{{ $item->title }}</a>
				</div>
				@endforeach
			</div>
		</div>
		<div class="userCommentsBox">
			<h1>Comments</h1>
			<div class="userComments">
				@foreach($user->commentWriter as $comment)
				<div class="userCommentsTitle">
					<a href="/news/{{ $comment->news }}">{{ $comment->content }}</a>
				</div>
				@endforeach
			</div>
		</div>
	</div>
	
@endsection
