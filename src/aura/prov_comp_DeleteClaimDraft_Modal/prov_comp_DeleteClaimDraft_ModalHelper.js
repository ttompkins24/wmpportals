({
	closeModal : function(component, event, helper) {
		component.destroy();
	},
	
	countDrafts : function(component, event, helper) {
		var draftsToDeleteCount;
		var claimToDelete = component.get('v.claimToDelete');
		var claimsToDelete = component.get('v.claimsToDelete');
		var claimsToSubmit = component.get('v.claimsToSubmit');
		if(claimToDelete != null) {
			component.set('v.draftsToDeleteCount', '1 draft');
		}
		else if(claimsToDelete != null) {
			component.set('v.draftsToDeleteCount', claimsToDelete.length + ' drafts');
		}
		if(claimsToSubmit != null) {
			if(claimsToSubmit.length > 1) {
				component.set('v.draftsToSubmitCount', claimsToSubmit.length + ' drafts');
				
			} else {
				component.set('v.draftsToSubmitCount', '1 draft');
			}
			for( var loc in claimsToSubmit){
				if(claimsToSubmit[loc].Last_Eligibility_Check__c != undefined){
					claimsToSubmit[loc].Last_Eligibility_Check__c = new Date(claimsToSubmit[loc].Last_Eligibility_Check__c); 
				}
			}
			component.set('v.claimsToSubmit', claimsToSubmit);
		}
	},

	submitDrafts : function(component) {
		//console.log(('submitDraftsApex::'+JSON.stringify(component.get('v.claimsToSubmit')));
		var action = component.get('c.submitDraftsApex');
		action.setParams({
			"claimDrafts" : component.get('v.claimsToSubmit')
		});

		action.setCallback(this, function(response){
			//console.log(('submitDrafts....'+response.getState());
			//console.log(('response::'+response);
			//console.log(('response2::'+JSON.stringify(response));
			if(response.getState() === 'SUCCESS'){
				var result = response.getReturnValue();
				//console.log(('submit result: '+JSON.stringify(result));

				var successEvent = component.getEvent('modalSuccessEvent');
                successEvent.setParams({
                	"isSuccess": result['success'] > 0,	
                	"successCount": result['success'],
                	"isError": result['error'] > 0,		
                	"errorCount": result['error'],					
                	"eventType" : 'submit'
            	});
				successEvent.fire();
				component.destroy();
				// this.closeModal(component, event, helper); // not working for some reason
			} else {
				var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log(("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    //console.log(("Unknown error");
                }
			}
		});

		$A.enqueueAction(action);
	},

	deleteDrafts : function(component, event, helper) {
		var action = component.get('c.deleteDraftsApex');
		//console.log(('claim to delete: '+ component.get('v.claimToDelete'));
		action.setParams({
			"claimDraft" : component.get('v.claimToDelete'),
			"claimDrafts" : component.get('v.claimsToDelete')
		});

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
				var result = JSON.stringify(response.getReturnValue());

				var successEvent = component.getEvent('modalSuccessEvent');
                successEvent.setParams({
                	"isSuccess": true,
                	"successMsg" : 'Draft(s) deleted successfully',
                	"eventType" : 'delete'
            	});
				successEvent.fire();
				this.setSuppressWarning(component, event, helper);
				component.destroy();
				// this.closeModal(component, event, helper);
			}
		});

		$A.enqueueAction(action);
	},

	setSuppressWarning : function(component, event, helper) {
		var showWarning = localStorage['showDeleteClaimDraftWarning'];
		var newShowWarning = component.get('v.suppressWarningNewValue');
		var recordType = component.get('v.recordType');
		//console.log(('claim showWarning: '+ showWarning);
		//console.log(('auth showWarning: '+ localStorage['showDeleteAuthDraftWarning']);
		//console.log(('newShowWarning: '+ newShowWarning);
		if(newShowWarning) {
			//console.log(('updated to bypass modal');			
			if(recordType == 'claim') {
				localStorage['showDeleteClaimDraftWarning'] = !newShowWarning;
			}
			if(recordType == 'auth') {
				localStorage['showDeleteAuthDraftWarning'] = !newShowWarning;				
			}
		}
	}
})