({
	doInit : function(component, event, helper) {
		helper.loadMemberInfo(component);
	},
	
	processPCD : function(component, event, helper){

		var dentistId = component.get('v.dentistId');
		var officeId = component.get('v.officeId');
		var memCovList = component.get('v.successMemCovIds');
		var reason = component.get('v.chosen_reason');
		var setPCD = component.get('c.setPCDForMember');
		setPCD.setParams({
				'memCovGuids' : memCovList ,
				'dentistId' : dentistId ,
				'locationId' : officeId,
				'reason' : reason
		});
		setPCD.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				component.set('v.stageName', 'SUCCESS');
			}
		});
		$A.enqueueAction(setPCD);
	},
	
	cancelClick : function(component, event, helper){
		component.set('v.closeWindow', true);
	},
})