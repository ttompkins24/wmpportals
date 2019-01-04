({
	/**STATIC VARIABLES**/
	NUM_RESULTS : 20,//number of results per page
	/**************************************************************************************************************
     * Method Name							: fetchRelatedCases
     * Developed By							: West Monroe Partners
     * Purpose								: To fetch the necessary information  
     * 											#cases from server side controller
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			1			January 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	fetchRelatedCases:function(component, pageNum, sortByField, sortDirection) {
		var businessId = component.get('v.currentBusinessId');
		var portalConfigName = sessionStorage['portalconfig'];
		var filterParams = {};
		
		var caseNum = component.get('v.caseNumber');
		var claimAuthNum = component.get('v.claimAuthNum');
		var subscriberId = component.get('v.subscriberId');
		var startDateParam = component.get('v.startServiceDate');
		var endDateParam = component.get('v.endServiceDate');
		
		filterParams['CaseNumber'] = caseNum;
		filterParams['Claim_Auth__c'] = claimAuthNum;
		filterParams['Member_ID__c'] = subscriberId;
		filterParams['startDate'] = startDateParam;
		filterParams['endDate'] = endDateParam;
		
		filterParams = JSON.stringify(filterParams);
		
		//calling an action to the server side controller to fetch the current member's related cases
		var action = component.get("c.fetch_relatedCaseDetails");
		
		//getting the limit value
		//var limitValue = component.get("v.visibleNumberOfCases");
		
		//getting the offset value
		//formula - offset = (pageNumber - 1) * pageSize
		//var offsetValue = (component.get("v.presentPageNumber") - 1) * limitValue;
		//console.log(limitValue + ' ***** ' + offsetValue);
		//String businessId, String limitValue, String pageNum, String sortByField, String sortDirection
		//setting the offset and the number of cases to limit
//		console.log('numRes::'+this.NUM_RESULTS);
//		console.log('pageNum::'+pageNum);
        action.setParams({
        	businessId : businessId,
        	limitValue: ''+this.NUM_RESULTS,
        	pageNum: ''+pageNum,
        	sortByField : sortByField,
        	sortDirection :sortDirection,
        	configName : portalConfigName,
        	extraFilters : filterParams
        });
        
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() === 'SUCCESS'){
				component.set("v.list_cases",response.getReturnValue());
				
				
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
			//switching off spinner
			$A.util.addClass(component.find("loadingSpinner"), "slds-hide");
		});
		$A.enqueueAction(action);
	},
	/* FETCH THE PAGINATION VARIABLES*/
	loadPageVariables : function(component){
		var action = component.get('c.paginationVariables');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var result = response.getReturnValue();
				//set the page variables
				component.set('v.totalPages', result[0]);
				component.set('v.totalResults', result[1]);
			}
		});
		
		$A.enqueueAction(action);
	},
	
})