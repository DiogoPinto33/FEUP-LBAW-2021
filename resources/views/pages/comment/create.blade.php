@extends('layouts.app')

@section('title', 'Create Comment')

@section('content')
	
<form method="POST" action="/news/{{ $id_news }}/create_comment">
    {{ csrf_field() }}

    <label for="content">Comment</label>
    <input id="content" type="text" name="content" required autofocus>
    @if ($errors->has('content'))
      <span class="error">
          {{ $errors->first('content') }}
      </span>
    @endif
	
	<input value="{{ $id_news }}" hidden="hidden">

    <button type="submit">
      Create
    </button>
</form>
	
@endsection
