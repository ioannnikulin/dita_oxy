define(["jquery"], function ($) {
	var $t = $('.tabs');
	if ($t.length)
	{
		if (document.location.protocol == "file:")
		{
			$('.tabs').tabs();
		}
		else
		{
			var cookieName = 'ditaStickyTab';
		
			$('.tabs').tabs({
			  active: (Cookies.get(cookieName) || 0),
			  beforeActivate: function(e, ui){
			   Cookies.set(cookieName, ui.newTab.index(), { expires : 365, sameSite: 'strict', secure: true});
				}
				});
			}
	}
});
