@extends('layouts.app')

@section('title', 'Admin - Users')

@section('content')
	<div class="userButton">
		<a class="button" href="{{ url('/admin/users/create') }}">Create User</a>
	</div>
	<div class="userBox">
		<table>
			<tr>
				<th>ID</th>
				<th>Username</th>
				<th>Email</th>
				<th>Reputation</th>
			</tr>
			@foreach($users as $user)
			<tr>
				<td>{{ $user->id }}</td>
				<td><a href="/users/{{ $user->id }}">{{ $user->name }}</a></td>
				<td>{{ $user->email }}</td>
				<td>{{ $user->reputation }}</td>
			</tr>
			@endforeach	
		</table>
	</div>

@endsection
