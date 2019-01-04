({
    isCalled : false,
    notifSize : -1,
    refreshNotifications : function(component, helper){  
		if(!this.isCalled){
            this.isCalled = true;
        	helper.getNotifications(component,helper);
            //execute callApexMethod() again after 30 sec each
            
            /*window.setInterval(
                $A.getCallback(function() { 
                    helper.getNotifications(component,helper);
                }), 30000
            ); */
            
        }
    },
    getNotifications : function(component,helper) {
		//create the action
		var action = component.get("c.getNotifications");
		action.setCallback(this, function(response){
			var state = response.getState();
//			console.log('checking notifications');
			if(state == 'SUCCESS'){
				var notifList = [];
				notifList = response.getReturnValue();
//                console.log('notifs: ' + JSON.stringify(notifList));
				var unread = notifList.length;
                //console.log('Notes:' + JSON.stringify(response.getReturnValue()));
				component.set('v.notifList', notifList);
				component.set('v.numUnread', unread);
                if(this.notifSize!=-1 && this.notifSize!=unread){
                    var refreshAction = component.get("c.refreshCache");
                    refreshAction.setCallback(this, function(response){
                        location.reload();
                    });
                    $A.enqueueAction(refreshAction);
                } else {
//                    console.log('first or same');
                }
                this.notifSize = notifList.length;
			} else {
				component.set('v.notifList', []);
				component.set('v.numUnread', 0);
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