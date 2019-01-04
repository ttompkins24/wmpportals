({
	/**STATIC VARIABLES**/
	NUM_RESULTS : 20,//number of results per page
	
	/*
		Retrieve the search criteria that the user is able to see under a particular business
	*/
	loadSearchCriteria : function(component, pageNum, sortByField, sortDirection) {
		var business = component.get('v.currentBusinessId');
		var lob = sessionStorage['portalconfig_lob'];
		
		//create the action to the apex method loadSearchCriteriaApex
		var action = component.get('c.loadSearchCriteriaApex');
		
		//Integer pageNum, Integer numResults, String sortByField, String sortDirection
		action.setParams({
				'pageNumS' : ''+pageNum,
				'numResultsS' : ''+this.NUM_RESULTS,
				'sortByField' : sortByField,
				'sortDirection' : sortDirection,
				'businessId': business,
				'routeId' : lob
		});
		//set the params
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var result = response.getReturnValue();
				component.set('v.searchCriteriaList', result);
				
			}
			var spinner = component.find('spinnerIdModal');
			$A.util.toggleClass(spinner, 'slds-hide');
			$A.util.removeClass(spinner, 'slds-is-fixed');
		});
		
		$A.enqueueAction(action);
	},
	
	/*RETRIEVE THE PAGINATION VARIABLES ON LOAD TO GET THE TOTAL NUM RECORDS AND TOTAL NUM PAGES*/
	loadPageVariables : function(component){
		var action = component.get('c.paginationVariables');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var result = response.getReturnValue();
				
				component.set('v.totalPages', result[0]);
				component.set('v.totalResults', result[1]);
			}
		});
		
		$A.enqueueAction(action);
	},
	
	 
})