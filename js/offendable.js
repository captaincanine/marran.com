$(document).ready(function () { 

	$('.post .box-header-left .tag-link').each( function() {
		if ($(this).text() == '#offendable') {
		
			console.log(document.cookie);

			if ($.cookie("offendable") != 'no') {
		
				setTimeout(function () {
					Shadowbox.open({
						content:    '<div id="dialog"><p>There is content on this page that may offend some people.</p><p>If you think you may be offended by adult subject matter or you are related to me, I suggest you not read this page.</p><p>This means you, grandma.</p><ul><li><a href="javascript:offendable_goback();">Ick. I\'d rather not read this sort of thing.</a></li><li><a href="javascript:offendable_safe();">I can handle it and stop asking me.</a></li><li><a href="javascript:offendable_dismiss();">I\'ll read just this one, but warn me again in the future.</a></li></div>',
						player:     "html",
						title:      "Fair warning",
						height:     350,
						width:      450
					});
				}, 100);

			}

		}
	});

});

function offendable_dismiss() {
	Shadowbox.close();
}

function offendable_safe() {
	$.cookie('offendable', 'no', 1000)
	Shadowbox.close();
}

function offendable_goback() {
	Shadowbox.close();
	history.go(-1);
}

