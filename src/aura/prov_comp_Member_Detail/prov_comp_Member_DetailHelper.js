({
	/**
     * Get the member. the profile id is required - figure out eligibility based on coverages
     */
     
     getMember2 : function(component, memberGuid, providerId, locationId) {
    	var today = new Date();
    	component.set('v.activeDate', today.toISOString());
        if(component.get('v.params.date')) {
        	component.set('v.activeDate', new Date(component.get('v.params.date')).toISOString());
    	} 
    	var currentBusinessId = component.get('v.currentBusinessId');
     	var planDate = new Date(component.get('v.activeDate').split('T')[0]);
     	var planid = component.get('v.params.planid');
		var action = component.get("c.getMemberApex2");
		var params = {
			"memberGuid" : memberGuid,
			"universalId" : component.get('v.params.uid'),
			'businessId' : currentBusinessId,
        	"providerId" : providerId,
        	"locationId" : locationId,
            "serviceDate" : planDate.toISOString().split('T')[0],
            "planGuid" : planid
		}; 
		
        action.setParams(params);

        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();
	            //console.log('memberWrapper::'+JSON.stringify(data));
	            
	            //set the passed in provider and service location if available
		        component.set('v.pcdProvider', data.providerSelected);
	            component.set('v.pcdServiceLocation', data.serviceLocationSelected);
	            //console.log('selected PSL set...');
	            component.set('v.member', data.member);
	            //console.log('member set...'+ JSON.stringify(component.get('v.member')));
		        var allCoverages = [];
	            //console.log('data.planGuid2PlanNetwork::'+JSON.stringify(data.planGuid2PlanNetwork));
	            var plans = [];
	            for (var planKey in data.planGuid2PlanMap) {
	            	var plan = data.planGuid2PlanMap[planKey];
	            	plan.network = data.planGuid2PlanNetwork[planKey];
	            	
	            	var coverage = data.planGuid2MemCovMap[planKey];
	            	console.log( 'coverage::' + JSON.stringify(coverage) );
	            	plan.coverage = coverage;
	            	
	            	allCoverages.push(coverage);
	            	console.log('currentPlanGuid ::'+data.currentPlanGuid );
	            	console.log('coverage.PlanGUID__c.toLowerCase() ::'+coverage.PlanGUID__c.toLowerCase() );
	            	if(data.currentPlanGuid == coverage.PlanGUID__c.toLowerCase()){
	            		component.set('v.activePlan', data.planGuid2PlanMap[planKey]);
	            		plans.unshift(plan);
	            	} else {
	            		plans.push(plan);
                        if(component.get('v.activePlan') == undefined){
                            component.set('v.activePlan', data.planGuid2PlanMap[planKey]);
                        }
	            	}
	            }
                
	            component.set('v.plansAndCoverages', plans);
	            component.set('v.allCoverages', allCoverages);
	            
	            //set the eligibility status
			    component.set('v.eligibleStatus', data.eligibilityStatus);
                    
                    //console.log('end cov callback');
            	component.set('v.selectedTabIndex', 0);
	        } else{
	            //console.log("error");
	            component.set('v.isError', true);
	        }
	        var spinner = component.find('spinnerId');
    		$A.util.addClass(spinner, 'slds-hide');
    		$A.util.removeClass(spinner, 'slds-is-fixed');
	        //$A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            //$A.util.removeClass(component.find("saving-backdrop"), "slds-show");
	        component.set('v.isLoading', false);
	    });
	    
	    $A.enqueueAction(action);
    },
    
    getMemberAdd : function(component, memberGuid) {
        //console.log('get add');
        var action = component.get("c.getMemberAddresses");
        action.setBackground(true);
        var params = {
            "memProfileGuid" : memberGuid
        };
        action.setParams(params);
        action.setCallback(this, function(response){
            var state = response.getState();
            //console.log('addResp: ' + response.state);
	        if(state === "SUCCESS"){   
                var data = response.getReturnValue();
                //console.log('addResp: ' + data);
                component.set('v.address', data[0]);
            }
        });
        $A.enqueueAction(action);
    },
    
    getMemberPhone : function(component, memberGuid) {
        var actionPhones = component.get("c.getMemberPhones");
        actionPhones.setBackground(true);
        var paramsPhones = {
            "memProfileGuid" : memberGuid 
        };
        actionPhones.setParams(paramsPhones);
        actionPhones.setCallback(this, function(response){
            var state = response.getState();
	        if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                //console.log('phoneResp: ' + state);
                //console.log('phoneData ' + JSON.stringify(data));
                // format number helper method
                var formatPhoneNumber = function(s) {
                    var s2 = (""+s).replace(/\D/g, '');
                    var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
                    return (!m) ? null : "(" + m[1] + ") " + m[2] + "-" + m[3];
                }
                
                // Phone
                // Home Phone
                // Cellular Phone
                // Alternate Phone
                
                // convert phones to a list
                component.set('v.phones', data);
                data.forEach(function(entry) {
                    if(entry.Type__c == 'Work Phone') {
                        component.set('v.workPhone', entry);
                    } else if(entry.Type__c == 'Fax Number') {
                        component.set('v.faxPhone', entry);
                    } else {
                        var primaryPhone = component.get('v.primaryPhone');
                        if(!primaryPhone) {
                            component.set('v.primaryPhone', entry);
                        } else if(entry.Type__c == 'Phone') {
                            component.set('v.primaryPhone', entry);
                        } else if(entry.Type__c == 'Home Phone' && primaryPhone.Type__c != 'Phone') {
                            component.set('v.primaryPhone', entry);
                        } else if(entry.Type__c == 'Cellular Phone' && primaryPhone.Type__c != 'Phone' && primaryPhone.Type__c != 'Alternate Phone') {
                            component.set('v.primaryPhone', entry);
                        } else if(entry.Type__c == 'Alternate Phone' && primaryPhone.Type__c != 'Phone' && primaryPhone.Type__c != 'Alternate Phone' && primaryPhone.Type__c != 'Cellular Phone') {
                            component.set('v.primaryPhone', entry);
                        }
                    }
                });
            }
        });
        $A.enqueueAction(actionPhones);
    }
})