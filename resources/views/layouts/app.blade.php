<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSRF Token -->
    <meta name="csrf-token" content="{{ csrf_token() }}">

	<title>@yield('title')</title>
	
    <!-- Styles -->
    <link href="{{ asset('css/milligram.min.css') }}" rel="stylesheet">
    <link href="{{ asset('css/app.css') }}" rel="stylesheet">
    <script type="text/javascript">
    </script>
    <script type="text/javascript" src={{ asset('js/app.js') }} defer>
</script>
  </head>
  <body>
	<div id="saltar">
		<a href="#content">Saltar para os conteúdos</a>
	</div>
    <main>
      <header>
        <h1><a href="{{ url('/news') }}">Collaborative News</a></h1>
		<div>
        @if (Auth::check())
		@if (Auth::user()->is_admin)
		<a class="button" href="/admin/users">Admin Features</a>
		@endif
        <a class="button" href="/users/{{ Auth::user()->id }}">{{ Auth::user()->name }}</a>
		<a class="button" href="{{ url('/logout') }}"> Logout </a>
		@else
        <a class="button" href="{{ url('/login') }}"> Login </a>
        @endif
		</div>
		
      </header>
	  
	  @include('partials.topicBar')
      
      <section id="content">
        @yield('content')
      </section>
	  
	  @include('partials.footer')
	  
    </main>
  </body>
</html>
