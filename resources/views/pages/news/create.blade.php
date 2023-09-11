@extends('layouts.app')

@section('title', 'Create News')

@section('content')
	
<form method="POST" action="{{ route('createNews') }}">
    {{ csrf_field() }}

    <label for="title">Title</label>
    <input id="title" type="text" name="title" value="{{ old('title') }}" required autofocus>
    @if ($errors->has('title'))
      <span class="error">
          {{ $errors->first('title') }}
      </span>
    @endif

    <label for="content">Content</label>
    <input id="content" type="text" name="content" value="{{ old('content') }}" required>
    @if ($errors->has('content'))
      <span class="error">
          {{ $errors->first('content') }}
      </span>
    @endif

    <label for="image">Image</label>
    <input id="image" type="text" name="image" value="{{ old('image') }}">
    @if ($errors->has('image'))
      <span class="error">
          {{ $errors->first('image') }}
      </span>
    @endif

	<label for="topic">Topic</label>
	<select size=1 name="news_topic" id="news_topic">
		@foreach($topics as $topic)
			<option value="{{ $topic->id_topic }}">{{ $topic->name }}</option>
		@endforeach
	</select>
	
    <button type="submit">
      Create
    </button>
</form>
	
@endsection
