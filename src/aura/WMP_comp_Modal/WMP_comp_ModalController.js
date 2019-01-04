({
	doInit : function(component, event, helper) {
	},
    
    defaultClose : function(component, event, helper){
        component.destroy();
    },
    
    redirectUrl : function(component, event, helper){
        var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
						'pageName' : ''
		});
		redirectEvent.fire();
		component.destroy();
    },
})