var data;

$(document).ready( function () {

	$.getJSON('/js/facebook/feed.js', showPosts);

});

function showPosts(posts) {

	for (var i = 0; i < posts.length; i++) {
	
		var entry = posts[i];
		if (entry.from.name == 'Keith Marran' && entry.caption != 'ping.fm') {
		
			switch (entry.type) {
				case 'status':
					content = '<div class="feed-entry clearfix">';
					content += '<div class="timeago">' + $.timeago(entry.created_time) + '</div>';
					if (entry.message != null) { content += '<div class="message">' + entry.message + '</div>'};
					content += '</div>';
					$('#feed').append($(content));
					break;
				case 'photo':
					content = '<div class="feed-entry clearfix">';
					content += '<div class="timeago">' + $.timeago(entry.created_time) + '</div>';
					if (entry.message != null) { content += '<div class="message">' + entry.message + '</div>'};
					content += '<div class="picture"><a href="' + entry.link + '" target="_blank"><img src="' + entry.picture + '" /></a></div>';
					content += '</div>';
					$('#feed').append($(content));
					break;
				case 'video':
					content = '<div class="feed-entry clearfix">';
					content += '<div class="timeago">' + $.timeago(entry.created_time) + '</div>';
					if (entry.message != null) { content += '<div class="message">' + entry.message + '</div>'};
					content += '<div class="feed-video clearfix">';
					content += '<div class="picture"><a href="' + entry.link + '" target="_blank"><img src="' + entry.picture + '" /></a></div>';
					content += '<div class="name"><a href="' + entry.link + '" target="_blank">' + entry.name + '</a></div>';
					if (entry.description) { content += '<div class="description">' + entry.description + '</div>'; }
					content += '</div>';
					content += '</div>';
					$('#feed').append($(content));
					break;
				case 'link':
					content = '<div class="feed-entry clearfix">';
					content += '<div class="timeago">' + $.timeago(entry.created_time) + '</div>';
					if (entry.message != null) { content += '<div class="message">' + entry.message + '</div>'};
					content += '<div class="feed-video clearfix">';
					if (entry.picture != null) { content += '<div class="picture"><a href="' + entry.link + '" target="_blank"><img src="' + entry.picture + '" /></a></div>'; }
					content += '<div class="name"><a href="' + entry.link + '" target="_blank">' + entry.name + '</a></div>';
					if (entry.description) { content += '<div class="description">' + entry.description + '</div>'; }
					content += '</div>';
					content += '</div>';
					$('#feed').append($(content));
					break;
					

			}
		}

	}

}