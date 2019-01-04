({
	//resaves an existing search 
	saveExistingSearch : function(component, event, helper) {

		//calling an action to the server side controller save search
		var action = component.get("c.saveMemberSearch");
		
		//parameters to pass the search page
		var title = component.get("v.title");
		var searchCriteriaId = component.get("v.searchCriteriaId");
		var memberList = component.get("v.memberList");
		var businessId = component.get("v.bizAcctRec").Id;
		var serviceLocationId = component.get("v.locAcctRec").Id;
		var providerId = component.get("v.provAcctRec").Id;
		var routeId = sessionStorage['portalconfig_lob'];
		
		//stringify the member list        
        var tempList = JSON.stringify(memberList);
        	
    	action.setParams({
    		'searchId' : searchCriteriaId,
    		'name':title,
        	'criteriaStr': tempList,
            'businessId': businessId,
            'serviceLocationId': serviceLocationId,
            'providerId': providerId,
            routeId : routeId
        });
    	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() == 'SUCCESS'){		
				var result = response.getReturnValue();
				//set success toast message				
				if(result){
					component.set("v.isSuccess",true);
					component.set("v.str_successMsg",$A.get("$Label.c.Save_Successful"));
								
				//set error toast message				
				} else {
					component.set("v.isError",true);
					component.set("v.str_errorMsg","Error saving");									
				}
				//switching off spinner
				$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
			}else{
				//setting the error flag and the message				
				component.set("v.isError",true);
				component.set("v.str_errorMsg","Error saving");
				$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
			}
		});
		$A.enqueueAction(action);
	},
})