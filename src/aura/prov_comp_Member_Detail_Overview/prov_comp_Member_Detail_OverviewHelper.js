({
	/**
	 * Get member overview information
	 */
	getMemberOverview : function(component, memberGuid, coverageId) {
		var action = component.get("c.getMemberOverviewApex");
		var dateOfService = new Date();
		if(component.get('v.params.date')) {
			dateOfService = new Date(component.get('v.params.date'));
		}
		console.log('memberGuid::'+memberGuid);
		console.log('coverageId::'+coverageId);
		var params = { 
			"coverageId" : coverageId, 
			"memberGuid" : memberGuid,
			"dateOfService" : (dateOfService.getUTCMonth() + 1) + '/' + dateOfService.getUTCDate() + '/' + dateOfService.getUTCFullYear()
		};
		////console.log('### action with params: ' + JSON.stringify(params));

        action.setParams(params);
        
        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();

	            //console.log('### OVERVIEW DATA: ' + JSON.stringify(data));
	            component.set('v.primaryDentist', data.primaryCareDentist);
	            component.set('v.pcdProvider', data.pcdProvider);
	            component.set('v.pcdServiceLocation', data.pcdServiceLocation);
	            component.set('v.otherCoverage', data.otherCoverages);

	            function isLinkExpiryDateWithinRange( dateToCheck, startDate, endDate ) {
	            	if(endDate) return startDate <= dateToCheck && dateToCheck <= endDate;
				    else return startDate <= dateToCheck;
				}

	            var benefits = [];
	            data.benefits.forEach(function(entry) { 
	            	// for each benefit, format the dollar amounts         	
	            	entry.Applied__c = '$' + entry.Applied__c.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
	            	entry.Limit__c = '$' + entry.Limit__c.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
	            	entry.Remaining__c = '$' + entry.Remaining__c.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');

	            	// ensure the benefit is applied for this plan
	            	if(entry.PlanGUID__c == component.get('v.selectedPlan').windward_guid__c) {
	            		// make sure the dates are at or before the current date
	            		if(entry.TerminationDate__c && isLinkExpiryDateWithinRange(dateOfService, new Date(entry.EffectiveDate__c), new Date(entry.TerminationDate__c))) {
	            			benefits.push(entry);
	            		} else if(isLinkExpiryDateWithinRange(dateOfService, new Date(entry.EffectiveDate__c), null)) {
	            			benefits.push(entry);
	            		}
	            	}
	            });

	            component.set('v.benefits', benefits);
	        } else{
	            //console.log("error");
	        }
	        //$A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            //$A.util.removeClass(component.find("saving-backdrop"), "slds-show");
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
	}
})