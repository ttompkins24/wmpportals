({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information from 
     * 											# footer links and label from the cache class
     *										 To display the links on the footer of the page
     History
     Version#		Sprint#		Date				by  						Comments
	 1.0			1.0			7th August 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	getFooterLinks : function(component,helper) {
		//getting the custom metadata - portal confiugration links from the cache class
		//We will put all the values in part2 and then splice it to create a part 1
		var footer_portalConfigurationLinks_part1;
		
		//calling an action to the server side controller to fetch the list of footer links to display
		var action = component.get("c.getFooterLinks");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//setting the variable with the response list
				footer_portalConfigurationLinks_part1 = response.getReturnValue();
				
				component.set("v.footer_portalConfigurationLinks_part1",footer_portalConfigurationLinks_part1);
			}else{
				console.log('Error >> ' + response);
			}
		});
		$A.enqueueAction(action);
	},

	getGeneralRecordTypeId : function(component, helper){
		//retrieve the General Case
		var recordTypeIdAction = component.get('c.getCaseRTID');
    	recordTypeIdAction.setParams({
        	'recordTypeName': 'General_Case'
        });

        recordTypeIdAction.setCallback(this, function(response){
        	if(response.getState() == 'SUCCESS'){
        		var generalRecordTypeId = response.getReturnValue();
				component.set("v.generalRecordTypeId",generalRecordTypeId);

        	}
		});
		$A.enqueueAction(recordTypeIdAction);
	},

	/**************************************************************************************************************
     * Method Name							: helperLoadConfig
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# getting the config value from the custom metadata type
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			ME			June 2018				West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	getPortalConfig : function(component, event, helper){
		var action= component.get('c.getPortalConfiguration');
		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
				component.set("v.portalConfig",response.getReturnValue());
				console.log('**caaling');
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
	},
})