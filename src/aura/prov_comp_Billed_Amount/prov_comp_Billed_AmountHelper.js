({
	/**STATIC VARIABLES**/
	NUM_RESULTS : 20,//number of results per page
	
	getBilledAmount : function(component, pageNum, sortByField, sortDirection) {
		$A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
        component.set('v.isLoading', true);
        var businessId = component.get('v.currentBusinessId');

		var action = component.get("c.getBilledAmountApex");
		var params = {
				'businessId' : businessId,
				'pageNumS' : ''+pageNum,
				'numResultsS' : ''+this.NUM_RESULTS,
				'sortByField' : sortByField,
				'sortDirection' : sortDirection
		};
		
        action.setParams(params);  

        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();
	            component.set('v.business', data.business);
	            component.set('v.billed_amounts', data.billed_amounts);
	            
	        } else {  
	        	//console.log('error');
	        } 
	        $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
	        $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
	        component.set('v.isLoading', false);

	    });

	    $A.enqueueAction(action);
	},
	
	
	handleDelete : function(component, billedAmountId){
		var action= component.get('c.handleDeleteApex');
		action.setParams({'billedAmountId' : billedAmountId});
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				if(response.getReturnValue() == ''){
					//display success
					this.generateMessage(component, 'success', $A.get('$Label.c.Successfully_Deleted'));
				} else {
					//display error
					this.generateMessage(component, 'error', $A.get('$Label.c.General_Error_Provider'));
				}
			} else {
				this.generateMessage(component, 'error', $A.get('$Label.c.General_Error_Provider'));
			}
			window.scrollTo(0,0);
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
	 
	 /*
		Helper method to load the page variables that have been set by the loadSearchCriteria method
	 */
	loadPageVariables : function(component){
		var action = component.get('c.paginationVariables');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var result = response.getReturnValue();
				//console.log(result);
				//set the page variables
				component.set('v.totalPages', result[0]);
				component.set('v.totalResults', result[1]);
			}
		});
		
		$A.enqueueAction(action);
	},
})