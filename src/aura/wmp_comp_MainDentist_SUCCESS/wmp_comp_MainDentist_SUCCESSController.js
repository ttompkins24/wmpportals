({
	closeWindowClick : function(component, event, helper) {
		component.set('v.closeWindow', true);
		
		//redirect to the home page
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
						'pageName' : ''
		});
		redirectEvent.fire();
	}
})