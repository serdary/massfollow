// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(function() {
	// Check if a user requests paged result directly with a hash
	pageHash = $.getHash('', 'page');
	if (pageHash !== '')
	{
		$.showLoader();
		$.getScript(pageHash[0] + "?page=" + pageHash[1], function() { $.hideLoader(); });
	}
	
	// Shows/Hides notification area
	if ($('.notification .text').text() !== '')
	{
		$('body').attr('style', 'margin-top: 37px');
		$('.notification').show();
		
		setTimeout("$.closeNotification()", 5000);
	}
	
	// Adds click function to all pagination links
	$('.pagination a').live('click', function() {
		$.showLoader();
		$.getScript(this.href, function() { $.hideLoader(); });
		
		pageNr = $.getParam(this.href, 'page');
		window.location.hash = (pageNr !== '') ? "page" + pageNr : '';
		return false;
	});
	
	// Handles search form submission
	$('#search_form').submit(function() {
		$.showLoader();
		$.get(this.action, $(this).serialize(), function() { $.hideLoader(); }, 'script');
		return false;
	});
	
	// Show loader while authenticating user OR getting users list
	$('.tw-login, .form-submit').live('click', function() {
		$.showLoader();
	});
	
	// Selects all/non checkboxes
    $('#select-all').toggle(
        function() {
            $('.checkbox').attr('checked', 'checked');
            $('#select-all').text('unselect all');
        },
        function() {
            $('.checkbox').attr('checked', false);
            $('#select-all').text('select all');
        }
    );
});

// extend jquery
$.extend({
	// gets requested parameter value if exists
	getParam : function(url, key) {
		if(url === "")
			url = window.location.href;

		var value = '', hash;
		var hashes = url.slice(url.indexOf('?') + 1).split('&');
		for(var i = 0; i < hashes.length; i++) {
			hash = hashes[i].split('=');
			if(hash[0] === key) {
				value = hash[1];
				break;
			}
		}
		return value;
	},
	
	// gets requested hash and remaining part of the url
	getHash : function(url, key) {
		if(url === "")
			url = window.location.href;

		if (url.indexOf('#' + key) < 0)	return '';
		
		var hashes = url.split('#');
		hashes[1] = url.slice(url.indexOf('#' + key) + key.length + 1);
		return hashes;
	},
	
	// closes notification area
	closeNotification: function() {
		$('body').attr('style', 'margin-top: 0px');
		$(".notification").hide(500);
	},
	
	// shows the loader
	showLoader: function() {
		$('#loader').show();
	},
	
	// hides the loader
	hideLoader: function() {
		$('#loader').hide();
	}
});