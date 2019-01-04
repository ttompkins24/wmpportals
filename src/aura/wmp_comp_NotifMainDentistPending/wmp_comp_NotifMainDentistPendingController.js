({
	isPCDPending : function(component,event, helper) {
		var memCov = component.get('v.memCovRec');
		console.log('memCov::'+JSON.stringify(memCov));
		var timer = component.get('v.timer');
		var self = this;
		window.clearInterval(timer);
		
		if(memCov != null && memCov != undefined){
			//create the action
			var action = component.get("c.isOpenPCDRequest");
			action.setParams({
						'memCov' : memCov
				});
			
			action.setCallback(this, function(response){
				var state = response.getState();
				
				if(state == 'SUCCESS'){
					var result = response.getReturnValue();
					console.log('result::'+result);
					if(result){
						component.set('v.pendingRequest', true);
						
						timer = window.setInterval( 
								$A.getCallback(function(){
									component.runPCDRequest();
								}),
						 10000);
						component.set('v.timer', timer);
					} else{
						component.set('v.pendingRequest', false);
						component.set('v.timer', null);
					}
				}else{
					component.set('v.pendingRequest', false);
					component.set('v.timer', null);
				}
			});
			$A.enqueueAction(action);
		}
	},
	
})