<div class="commentSection">
	@if (Auth::check())
		<a class="button" href="{{ $news->id_news }}/create_comment">Comment</a>
	@endif
	@foreach($news->comments as $comment)
		<div class="comments">
			<div class="commentDetails">
				@if($comment->writer != null)
				
					<a href="/users/{{ $comment->writer }}">{{ \App\Models\User::where(['id' => $comment->writer])->pluck('name')->first(); }}</a>
				@else
					Anonymous User
				@endif
				{{ date('d-m-Y, H:i', strtotime($comment->dates)) }}
				Reputation: {{ $comment->reputation }}
			</div>
			<div class="commentContent">
				{{ $comment->content }}
				@can('update', $comment)
				<a class="editComment" href="/edit_comment/{{ $comment->id_comment}}">EDIT</a>
				<form action="{{ url('/delete_comment', ['id_comment' => $comment->id_comment]) }}" method="post">
					<button class="deleteComment" type="submit">Delete</button>
					@method('delete')
					@csrf
				</form>
				@endcan
				
				@include('partials.voteOnComment')
			</div>
		</div>
	@endforeach
</div>
