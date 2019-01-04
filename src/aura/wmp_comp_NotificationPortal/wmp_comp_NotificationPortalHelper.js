({
	getNotifications : function(component) {
		//create the action
		var action = component.get("c.getPortalNotifications");
		action.setCallback(this, function(response){
			var state = response.getState();
			
			if(state == 'SUCCESS'){
				var notifList = [];
				notifList = response.getReturnValue();
				
				component.set('v.notifList', notifList);
			}
		});
		$A.enqueueAction(action);
	},
	initLanguage : function(component){
		var action = component.get('c.initLanguage');
		action.setCallback(this, function(response){
			var state = response.getState();
			
			if(state == 'SUCCESS'){
				component.set('v.lang', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},
})