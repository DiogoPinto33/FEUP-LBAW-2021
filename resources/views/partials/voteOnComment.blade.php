<div class="voteCommentButton">
@can('vote', $comment)
	<form method="POST" action="/{{ $comment->id_comment }}/vote_on_comment">
		{{ csrf_field() }}
		<input value="{{ $comment->id_comment }}" name="id_comment" hidden="hidden">
		<button class="greenButton" type="submit" name="vote" value="up_vote">UpVote</button>
		<button class="redButton" type="submit" name="vote" value="down_vote">DownVote</button>
	</form>
@endcan
@can('deleteVote', $comment)
	<form method="POST" action="/{{ $comment->id_comment }}/vote_on_comment">
		<input value="{{ $comment->id_comment }}" name="id_comment" hidden="hidden">
		<button class="cancelButton" type="submit">Remove Vote</button>
		@method('delete')
		@csrf
	</form>
@endcan
</div>