({
	/* GET THE MEMBERS that the person is able to view/ manage*/
	retrieveMembers : function(component) {
		var action = component.get('c.getMembers');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				component.set('v.members', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	}
})