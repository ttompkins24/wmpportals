({
	logoutAction : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
             "url": '/secur/logout.jsp' 
         });
         urlEvent.fire(); 
	},
	
	redirectHome : function(component, event, helper){
		
		
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			'url' : '/',
			'isredirect' : true
		});
		urlEvent.fire();
		component.set('v.currPage', '');
	},
})