@extends('layouts.app')

@section('title', 'Edit user account')

@section('content')
<form method="POST" action="/users/{{ $user->id }}/edit">
    {{ csrf_field() }}

    <label for="name">Name</label>
    <input id="name" type="text" name="name" value="{{ $user->name }}" required autofocus>
    @if ($errors->has('name'))
      <span class="error">
          {{ $errors->first('name') }}
      </span>
    @endif

    <label for="password">Password</label>
    <input id="password" type="password" name="password" required>
    @if ($errors->has('password'))
      <span class="error">
          {{ $errors->first('password') }}
      </span>
    @endif

    <label for="password-confirm">Confirm Password</label>
    <input id="password-confirm" type="password" name="password_confirmation" required>

	<label for="description">Description</label>
    <input id="description" type="text" name="description" value="{{ $user->profile_description }}">
    @if ($errors->has('description'))
      <span class="error">
          {{ $errors->first('description') }}
      </span>
    @endif
	
	<label for="image">Image</label>
    <input id="image" type="text" name="image" value="{{ $user->image }}">
    @if ($errors->has('image'))
      <span class="error">
          {{ $errors->first('image') }}
      </span>
    @endif
	
    <button type="submit">
      Update
    </button>
</form>
@endsection
