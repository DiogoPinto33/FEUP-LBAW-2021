<div class="topicBar">
	
	@foreach($topics as $topic)
		<div class="topicBarTopic">
			<a href="/news/topic/{{ $topic->id_topic }}">{{ $topic->name }}</a>
		</div>
	@endforeach
	
</div>
