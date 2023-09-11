@extends('layouts.app')

@section('title', 'Help')

@section('content')

<div class="infoPage">
    <div class="centeredText">
        <h1 class="subtitle">Help</h1>
        <div class="textBox">
            <h1>FAQ</h1>
            <h2 class="subtile">Why should I become a member?</h2>
            <p>Members can create news and edit them. They can also comment on news and vote news or comments.</p>
            <h2 class="subtile">How is my reputation calculated?</h2>
            <p>The reputation of a member is calculated according to the votes in their news and comments. Each positive vote adds one point and each negative vote subtracts one point.</p>
            <h2 class="subtile">How can I follow other users?</h2>
            <p>Other users can be followed through a button in their profile.</p>
            <h2 class="subtile">Why can't I delete the news/comment I wrote?</h2>
            <p>If your news/comment has votes or comments you cannot delete it.</p>
			<h2 class="subtile">How can I see articles recommended to me?</h2>
			<p>First you have to follow topics you might find relevant or other members of your interest. Then, just go to your profile and hit the button "Suggestions for me".</p>
        </div>
        <h2 class="subtitle">For technical support email tickets@cl.org</h2>
    </div>

@endsection
