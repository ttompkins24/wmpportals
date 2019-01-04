({
	doInit : function(component, event, helper) {
		// var reasons = ['I want to', 'He isnt nice', 'too old'];
		// component.set('v.reasonList', reasons);
		helper.fetchReasonPicklist(component);

	},

	applyOneMember : function(component, event, helper) {
		console.log('apply one member clicked');
				//validate that the member has selected a reason
		var reason = component.get('v.chosen_reason');
		if(reason == undefined || reason == ''){
			console.log('no reason is selected');
			component.set('v.reasonError', true); 
		} else {
			console.log('reason is selected');

			console.log('Reason picked: ' + component.get('v.chosen_reason'));
			component.set('v.isError', false);
			var memCov = component.get('v.memCovIds')[0];
			var dentistId = component.get('v.dentistId');
			var officeId = component.get('v.officeId');
			var setPCD = component.get('c.setPCDForOneMember');
			setPCD.setParams({
					'memCovGuids' : memCov ,
					'dentistId' : dentistId ,
					'locationId' : officeId,
					'reason': reason
			});
			setPCD.setCallback(this, function(response){
				if(response.getState() == 'SUCCESS'){
					var result = response.getReturnValue();
					if(result == 'success'){
						component.set('v.stageName', 'SUCCESS');
					} else if(result == 'open'){
						var resultMap ={};
						resultMap[component.get('v.memCovIds')[0]]= 'open';
						component.set('v.memSuccessMap', resultMap);
						component.set('v.stageName', 'VAL');
					} else {
						component.set('v.isError', true);
					
					}
				} else {
					component.set('v.isError', true);
				}
			});
			$A.enqueueAction(setPCD);
		} 
	},
	
	applyAllMember : function(component, event, helper){
		console.log('apply all member clicked');

		console.log('Reason picked: ' + component.get('v.chosen_reason'));

		//validate that the member has selected a reason
		var reason = component.get('v.chosen_reason');
		//if no reason, show error message
		if(reason == undefined || reason == ''){
			console.log('no reason is selected');
			component.set('v.reasonError', true);
		//reason code selected 
		} else {
			console.log('reason is selected');

			component.set('v.isError', false);
			//get the variables needed for the params
			var dentistId = component.get('v.dentistId');
			var officeId = component.get('v.officeId');
			
			//create the action
			var action = component.get('c.setPCDForAllMember');
			action.setParams({//set the params
							'dentistId' : dentistId ,
							'locationId' : officeId
			});
			action.setCallback(this, function(response){//set the callback
				if(response.getState() == 'SUCCESS'){
					var result = response.getReturnValue();
					var isOneError = false;
					var memCovList = [];
					if(result['all'] == undefined){
						for(var memCov in result){
							memCovList.push(memCov);
							if(result[memCov] == 'error' || result[memCov] == 'open'){
								isOneError = true;
							} 
							
						}
						if(isOneError){//redirect to the validation page
							component.set('v.memCovIds', memCovList);
							component.set('v.memSuccessMap', result);
							component.set('v.stageName', 'VAL');
						
						} else {//redirect to success page/ initialize it for all members
							var setPCD = component.get('c.setPCDForMember');
							setPCD.setParams({
									'memCovGuids' : memCovList ,
									'dentistId' : dentistId ,
									'locationId' : officeId,
									'reason': reason
							});
							setPCD.setCallback(this, function(response){
								if(response.getState() == 'SUCCESS'){
									var result2 = response.getReturnValue();
									if(result2 == 'success'){
										component.set('v.stageName', 'SUCCESS');
									} else {
										component.set('v.isError', true);
									}
								} else {
									component.set('v.isError', true);
								}
							});
							$A.enqueueAction(setPCD);
						}
					} else {
						component.set('v.isError', true);
					}
				}
			});
			//queue up the action
			$A.enqueueAction(action);
		}
	},
})