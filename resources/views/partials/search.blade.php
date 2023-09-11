<div>
	<form action="/news/search" method="GET">
		@csrf
		<input name="search" type="text" placeholder="Search...">
		<button type="submit">Search</button>
		<button type="submit" formaction="/news/search_exact">Exact match</button>
	</form>
</div>
