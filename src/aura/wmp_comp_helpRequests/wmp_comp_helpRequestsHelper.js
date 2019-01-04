({
	/**************************************************************************************************************
     * Method Name							: fetchRelatedCases
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											#cases from server side controller
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			10th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	fetchRelatedCases:function(component) {
		//calling an action to the server side controller to fetch the current member's related cases
		var action = component.get("c.fetch_relatedCaseDetails");
		
		//getting the limit value
		var limitValue = component.get("v.visibleNumberOfCases");
		
		//getting the offset value
		//formula - offset = (pageNumber - 1) * pageSize
		var offsetValue = (component.get("v.presentPageNumber") - 1) * limitValue;
		console.log(limitValue + ' ***** ' + offsetValue);
		//setting the offset and the number of cases to limit
        action.setParams({
        	limitValue: limitValue,
        	offsetValue: offsetValue
        });
        
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() === 'SUCCESS'){
				component.set("v.list_cases",response.getReturnValue());
				
				//switching off spinner
				$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: fetchTotalCaseCount
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# number of cases from the server side controller
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			11th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	fetchTotalCaseCount : function(component, helper){
		//calling an action to the server side controller to fetch the current member's number of related cases
		var action = component.get("c.fetch_countOfCases");
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() === 'SUCCESS'){
				//getting the number of pages
				var totalNumberOfRecords = response.getReturnValue();
				var totalNumberOfPages = 1;
				//getting the limit value
				var limitValue = component.get("v.visibleNumberOfCases");
				if(totalNumberOfRecords > 0){
					//if there are no reminders, then the additional page is not required
					if(totalNumberOfRecords % limitValue === 0)
						totalNumberOfPages = totalNumberOfRecords/limitValue;
					else//else required
						totalNumberOfPages = Math.floor((totalNumberOfRecords/limitValue)) + 1;
				}
				 
				component.set("v.totalNumberOfPages",totalNumberOfPages);
				//to get the offset number of cases
				helper.fetchRelatedCases(component);
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
	}
})