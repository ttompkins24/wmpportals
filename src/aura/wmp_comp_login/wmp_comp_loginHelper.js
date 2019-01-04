({
	loginAction : function(component, uName, pwd) {
		var action = component.get('c.login');
		
		action.setParams({
			'username' : uName,
			'password' : pwd,
			'startUrl' : 'https://wmp-portals.force.com/member'
		}):
		
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				//user should be redirect at this point
			}
		});
		
		$A.enqueueAction(action);
	}
})