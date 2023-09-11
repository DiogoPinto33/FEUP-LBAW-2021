<div class="voteNewsButton">
@can('vote', $news)
	<form method="POST" action="/news/{{ $news->id_news }}/vote_on_news">
		{{ csrf_field() }}
		<input value="{{ $news->id_news }}" name="id_news" hidden="hidden">
		<button class="greenButton" type="submit" name="vote" value="up_vote">UpVote</button>
		<button class="redButton" type="submit" name="vote" value="down_vote">DownVote</button>
	</form>
@endcan
@can('deleteVote', $news)
	<form method="POST" action="/news/{{ $news->id_news }}/vote_on_news">
		<input value="{{ $news->id_news }}" name="id_news" hidden="hidden">
		<button class="cancelButton" type="submit">Remove Vote</button>
		@method('delete')
		@csrf
	</form>
@endcan
</div>