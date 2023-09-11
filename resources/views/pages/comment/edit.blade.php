@extends('layouts.app')

@section('title', 'Edit Comment')

@section('content')
	
<form method="POST" action="/edit_comment/{{ $comment->id_comment }}">
    {{ csrf_field() }}

    <label for="comment">Comment</label>
    <input id="content" type="text" name="content" value="{{ $comment->content }}" required autofocus>
    @if ($errors->has('content'))
      <span class="error">
          {{ $errors->first('content') }}
      </span>
    @endif

    <button type="submit">
		Update
    </button>
</form>
	
@endsection
