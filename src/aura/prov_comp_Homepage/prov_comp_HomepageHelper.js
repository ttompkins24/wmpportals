({
	retrieveBanner : function(component) {
        ////console.log('homepage banner');
		var accId = component.get('v.currentBusinessId');
		var action = component.get("c.retrieveBannerApex");

        action.setParams({
            "bizAcctId" : accId
        });

        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
//                //console.log('bannerWrapper::'+JSON.stringify(response.getReturnValue()));
                component.set('v.bannerWrapper', response.getReturnValue());
                
            }
        });
        $A.enqueueAction(action);
	},
	
	recentMessages : function(component){
        ////console.log('homepage messages');
		var accId = component.get('v.currentBusinessId');
		var action = component.get("c.recentMessagesApex");

        action.setParams({
            "currentBusinessId" : accId
        });

        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
//            	//console.log('notifList::'+JSON.stringify(response.getReturnValue()));
                component.set('v.notifList', response.getReturnValue());
                
            }
            component.set('v.notifLoading', false);
        });
        $A.enqueueAction(action);
	},
	
	recentEvents : function(component){
        ////console.log('homepage events');
		var accId = component.get('v.currentBusinessId');
		var action = component.get("c.recentEventsApex");

        action.setParams({
            "currentBusinessId" : accId
        });

        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
            	////console.log('eventList::'+JSON.stringify(response.getReturnValue()));
                component.set('v.eventList', response.getReturnValue());
                
            }
            component.set('v.eventLoading', false);
        });
        $A.enqueueAction(action);
	},
	
	setDefaultTaskStarter : function(component){
		////console.log('taskStarter: ' +component.get('v.taskStarter'));
		////console.log('contact setting: '+JSON.stringify(component.get('v.currentContact')));
		var defaultTaskStarter = component.get('v.currentContact').Default_Dashboard_Starter_Task__c;
		var taskStarter = '';
		var action= component.get('c.returnNothing');
		action.setCallback(this, function(reponse){
			// hit server
			var permissions = component.get('v.permissions');
			//console.log('default taskStarter::'+taskStarter);
            //console.log('permissions::'+JSON.stringify(permissions));
			if(permissions.memberEligibility != 'none' && (defaultTaskStarter == 'Eligibility' || taskStarter == '')){
				taskStarter = 'Eligibility';
			} 
			if(permissions.claims != 'none' &&  (defaultTaskStarter == 'claimSearch' || taskStarter == '')){
				taskStarter = 'claimSearch';
			} 
			if(permissions.preAuth != 'none' &&  (defaultTaskStarter == 'preauthSearch' || taskStarter == '')){
				taskStarter = 'preauthSearch';
			}
            //console.log('taskStarter::'+taskStarter);
			component.set('v.taskStarter', taskStarter);
		});
		$A.enqueueAction(action);
		
		////console.log('taskStarter: ' +component.get('v.taskStarter'));
	},
})