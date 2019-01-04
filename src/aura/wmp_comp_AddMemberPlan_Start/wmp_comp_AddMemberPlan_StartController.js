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
	
	redirectHome : function(component, event, helper){
		console.log('redirectHome...');
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
						'pageName' : ''
		});
		redirectEvent.fire();
	},

})