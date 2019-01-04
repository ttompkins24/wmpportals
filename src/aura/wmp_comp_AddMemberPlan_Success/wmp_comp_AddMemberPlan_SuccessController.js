({
	doInit : function(component, event, helper) {
		helper.retrieveMembers(component);
	},
	
	addDependent : function(component, event, helper){
		component.set('v.step', 'dependent');
	},
	
	selfPlan : function(component, event, helper){
		component.set('v.step', 'self');
	},
	
	/* Redirect to the overview page/ home page. Call the redirect event and fire it passing what page you want to go and refresh of the nav*/
	redirectHome : function(component, event, helper){
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
						'refreshNav' : true,
						'pageName' : ''
		});
		redirectEvent.fire();
	},

})