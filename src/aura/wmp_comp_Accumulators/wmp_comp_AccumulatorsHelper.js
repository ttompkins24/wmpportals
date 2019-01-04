({
	/**************************************************************************************************************
     * Name									: wmp_comp_AccumulatorsHelper
     * Developed By							: West Monroe Partners
     * Purpose								: To fetch the necessary information  
     * 											accumulators from server side controller
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			8.0			19th October 2017		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	fetchAccumulators:function(component, helper) {
		//calling an action to the server side controller to fetch the current member's related cases
		var action = component.get("c.getMemberAccumulatorsByGUIDs");
		
	
		var memCoverageNum = component.get("v.memCovRec.MemberCoverageGUID__c");
        var memProfileNum = component.get("v.memCovRec.MemberProfileGUID__c");
        
        console.log('mg: ' + JSON.stringify(component.get("v.memCovRec")));
        if(memCoverageNum != undefined){
        	
        	action.setParams({
	        	'memberProfileGUID': memProfileNum,
                'memberCoverageGUID': memCoverageNum
	        });
        	
			//creating a callback that is executed after the server side action is returned
			action.setCallback(this, function(response){
				//checking if the response is success
				if(response.getState() == 'SUCCESS'){		
					component.set("v.list_accumulators",response.getReturnValue());
					var result = response.getReturnValue();
                    console.log('result: ' + JSON.stringify(result));
					//switching off spinner
					$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
				}else{
					//setting the error flag and the message				
					component.set("v.bln_isError",true);
					component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
					$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
				}
			});
			$A.enqueueAction(action);
		}
	},
})