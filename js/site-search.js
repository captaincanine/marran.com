var searchTimer;

$(document).ready( function () {

	$('#search-bar .page-bounds').prepend('<div id="search-results"></div>');

	$('#search-text').keydown( function () {
		if (searchTimer == null)
			searchTimer = setTimeout("siteSearch($('#search-text').val())", 500);
	});

    //siteSearch('meat is delicious in China');

})

siteSearch = function(w) {

    var words;
    var o = this;
    
    o.parseWords = function(w) {
        
        // parse the words out of the query
        words = w.toLowerCase().match(/\w{2,}/gi);
        
        // convert the array to stemmed words
        sWords = new Array();
        for (w2 in words) {
            stem = stemmer(words[w2]);
            if ($.inArray(stem, sWords) == -1) {
                sWords.push(stem);
            }
        }
        
        // return the stemmed version
        return sWords;

    };

    o.getIndexUrls = function(ws) {
    
        // create an array of urls pointing to the first letter of each word
        files = new Object();
        for (word in ws) {
            temp = '/search/terms/' + ws[word].substring(0, 2).toLowerCase() + '.json';
            files[temp] = null;
        }
        
        return files;
        
    };

    o.loadIndexes = function(is) {  
        // make an ajax call to get all the indexes
        for (file in is) {
            $.getJSON(file, o.getPostIds);
        }
    };
    
    o.getPostIds = function(ts) {

        var postData = new Object();
            
        // loop through the terms, then the ids for each term
        for (var term in ts) {
            
					// if the index term matches one of our search terms, add it to the list of posts
					if ($.inArray(term, o.words) != -1) {															
						for (id in ts[term]) {
							if (!postData[ts[term][id]]) {
								postData[ts[term][id]] = 1;
							} else {
								postData[ts[term][id]] ++;
							}
						}
					}
            
        }
        
			var sortable = [];
			for (var postId in postData) {
				sortable.push([postId, postData[postId]])
			}
			
			o.posts = sortable.sort(function(a, b) {return b[1] - a[1]})
							
    };
    
    o.getPosts = function() {
        		
		for (var i=0; i < o.posts.length && i < 20; i++) {
			$.get('/search/posts/' + o.posts[i][0] + '.html', o.loadPostData);
		}

		$(document).unbind();

    };

    o.loadPostData = function(ts) {
        $('#search-results').append(ts);
    }
    
	 // here's the main code of the function
	 clearTimeout(searchTimer);
	 searchTimer = null;
	 $(document).unbind();
    $('#search-results').empty();
    $('#search-results').hide();

    o.posts = new Array();
    o.words = o.parseWords(w);
    o.indexUrls = o.getIndexUrls(o.words);
    
    o.loadIndexes(o.indexUrls);
    
    $(document).ajaxStop(function () { 
    	if (o.posts.length) {
    		o.getPosts();
    		$('#search-results').show()
    	}
    });
    
};