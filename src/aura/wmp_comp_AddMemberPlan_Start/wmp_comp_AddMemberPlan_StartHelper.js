({
	retrieveMembers : function(component) {
		var action = component.get('c.getMembers');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				component.set('v.members', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
        
        var getSelfCovStatus = component.get('c.disbaleSelfCoverage');
		getSelfCovStatus.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				component.set('v.disableSelfCoverage', response.getReturnValue());
			}
		});
		$A.enqueueAction(getSelfCovStatus);
	}
})