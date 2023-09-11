@extends('layouts.app')

@section('title', 'Admin - Create User')

@section('content')
	
<form method="POST" action="{{ route('createUser') }}">
    {{ csrf_field() }}

    <label for="name">Name</label>
    <input id="name" type="text" name="name" value="{{ old('name') }}" required autofocus>
    @if ($errors->has('name'))
      <span class="error">
          {{ $errors->first('name') }}
      </span>
    @endif

    <label for="email">E-Mail Address</label>
    <input id="email" type="email" name="email" value="{{ old('email') }}" required>
    @if ($errors->has('email'))
      <span class="error">
          {{ $errors->first('email') }}
      </span>
    @endif

    <label for="password">Password</label>
    <input id="password" type="password" name="password" value="{{ old('password') }}" required>
    @if ($errors->has('password'))
      <span class="error">
          {{ $errors->first('password') }}
      </span>
    @endif

	<label for="description">Description</label>
    <input id="description" type="text" name="description" value="{{ old('description') }}">
    @if ($errors->has('description'))
      <span class="error">
          {{ $errors->first('description') }}
      </span>
    @endif
	
	<label for="image">Image</label>
    <input id="image" type="text" name="image" value="{{ old('image') }}">
    @if ($errors->has('image'))
      <span class="error">
          {{ $errors->first('image') }}
      </span>
    @endif
	
    <button type="submit">
      Create
    </button>
</form>
	
@endsection
