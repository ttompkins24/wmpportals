({
	doInit : function(component, event, helper) {
		helper.loadConfig(component);
		helper.loadMember(component);
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