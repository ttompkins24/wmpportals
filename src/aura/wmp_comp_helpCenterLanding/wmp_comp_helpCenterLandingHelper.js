({
	/**************************************************************************************************************
     * Method Name							: helperLoadConfig
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# getting the config value from the custom metadata type
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	getPortalConfig : function(component, event, helper){
		var action= component.get('c.loadConfiguration');
		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
				component.set("v.portalConfig",response.getReturnValue());
				console.log('**caaling');
				helper.getOtherResourcesLinks(component, event, helper)
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: getOtherResourcesLinks
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# getting the config links to display in the portal links object
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	getOtherResourcesLinks : function(component, event, helper){
		//getting the files to query from 
		var knowledgeArticleTitles = component.get("v.portalConfig").Other_Resources_KA_Titles_comma_Sep__c;
		var listOfTitles = knowledgeArticleTitles.split($A.get("$Label.c.comma"));
		console.log('**'+knowledgeArticleTitles + '%%'+listOfTitles);
		//setting thelist of kA titles as the parameter to the server side action
		var action= component.get('c.getOtherResourcesPortalLinks');
		action.setParams({
            list_KATitles: listOfTitles
        });
		
		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
				component.set("v.portalConfigLinks",response.getReturnValue());
				console.log('response ' + JSON.stringify(response.getReturnValue()));

			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
	}
})