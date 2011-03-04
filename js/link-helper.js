$(document).ready( function () {

	$('body a:not(.popupwindow)').filter(function() {
		var a = this;
		if (a.hostname && a.hostname !== location.hostname) {
			$(a).not(".noAutoIcon").addClass("offSite");
			$(a).not(".noAutoLink").attr('target','_blank').bind('click keypress', function(event) {
				_gat._getTrackerByName()._trackEvent("outbound", this.href);
				return true;
			});
		};
	});
	
});