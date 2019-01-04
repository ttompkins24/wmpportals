({	
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
	
	getName : function(component){
		var action = component.get('c.getUserName');
		action.setCallback(this, function(response){
			var state = response.getState();
			
			if(state == 'SUCCESS'){
				component.set('v.uFullName', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
        
        var getAccountSettingsUrl = component.get('c.getAccountSettingsUrl');
		getAccountSettingsUrl.setCallback(this, function(response){
			var state = response.getState();
			
			if(state == 'SUCCESS'){
				component.set('v.accountSettingsUrl', response.getReturnValue());
			}
		});
		$A.enqueueAction(getAccountSettingsUrl);
	}
})