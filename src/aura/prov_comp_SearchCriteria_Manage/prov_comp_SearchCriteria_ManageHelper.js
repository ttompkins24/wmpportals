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
			var spinner = component.find('spinnerId');
			$A.util.toggleClass(spinner, 'slds-hide');
			$A.util.removeClass(spinner, 'slds-is-fixed');
		});
		
		$A.enqueueAction(action);
	},
	
	/*
		Helper method to load the page variables that have been set by the loadSearchCriteria method
	 */
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
	
	/* DELETE SEARCH CRITERIA HELPER METHOD*/
	deleteSearchCriteria : function(component, scId){
		var action = component.get('c.deleteSearchCriteriaApex');
		action.setParams({'searchCriteriaId' : scId});
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resultStatus = response.getReturnValue(); //returns true if success, false if failed
				
				if(resultStatus){
					//dont need to reload since we just remove it from the table
					//this.loadSearchCriteria(component);
					this.generateMessage(component, 'success', $A.get('$Label.c.Record_Delete_Success'));
				}else {
					//display error message and hide spinner
					$A.util.toggleClass(spinner, 'slds-hide');
					$A.util.removeClass(spinner, 'slds-is-fixed');
					this.generateMessage(component, 'success', $A.get('$Label.c.Save_Error_Message'));
				} 
			} else {
				//display error message and hide spinner
				$A.util.toggleClass(spinner, 'slds-hide');
				$A.util.removeClass(spinner, 'slds-is-fixed');
				this.generateMessage(component, 'success', $A.get('$Label.c.Save_Error_Message'));
			}
		});
		$A.enqueueAction(action);
	},
	
	/*
		Update the search criteria record
	 */
	 updateSearchCriteria : function(component, scId, scName){
		 var action = component.get('c.updateSearchCriteriaApex')
		 action.setParams({'searchCriteriaId' : scId,
		 					'newName' : scName}
		 				);
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var result = response.getReturnValue();
				if(result){
					//generate success message
					this.generateMessage(component, 'success', $A.get('$Label.c.Record_Update_Success'));

				}else {
					//show error message
					this.generateMessage(component, 'success', $A.get('$Label.c.Save_Error_Message'));
				} 
			} else {
				//show error message
				this.generateMessage(component, 'success', $A.get('$Label.c.Save_Error_Message'));
			}
		});
		
		$A.enqueueAction(action);
	 },
	  /*
		Generate a message at the top of the screen. Accepts error and success as typeOfMessage and the message will be set based on the passed in info
	   */
	 generateMessage : function(component, typeOfMessage, message){
		 //reinitialize the message notifs
		 component.set('v.isSuccess', false);
		 component.set('v.isError', false);
		 
		 //remove the hide class on the elements (hide gets applied when a user clicks the close on the message
		 $('.errorMessageWrap').removeClass('hide');
		 $('.successMessageWrap').removeClass('hide');
		 
		 //if type is error
		 if(typeOfMessage == 'error'){
			 component.set('v.isError', true);
			 component.set('v.str_errorMsg', message);
		 } else if (typeOfMessage == 'success'){// type is success
			 component.set('v.isSuccess', true);
			 component.set('v.str_successMsg', message);
		 
		 }
	 },
	 
    redirectUrl : function(component, event, helper, searchId){
        var redirectEvent = $A.get('e.c:prov_event_Redirect');

		var pageName = "member-eligibility";
		
		redirectEvent.setParams({
			'pageName' : pageName,
			'searchCriteriaId' : searchId
		});
		redirectEvent.fire();
    },
	
})