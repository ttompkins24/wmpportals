({
	//get the live chat info 
	retrieveLiveAgent : function(component) {
		var action = component.get('c.retrieveMemberInfoLiveAgent');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resultMap = response.getReturnValue();
				var chatId = resultMap['LiveChatId'];
				component.set('v.chatId', chatId);
			}
		});
		$A.enqueueAction(action);
	},
	
	//retrieve the number of open cases their are that the user is able to see
	retrieveOpenCases : function(component) {
		var action = component.get('c.fetch_countOfOpenCases');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var result = response.getReturnValue();
				component.set('v.openRequests', result);
			}
		});
		$A.enqueueAction(action);
	},
	
	//get the name fo the phone article that should displayed for the phone number article
	retrievePhoneArticle : function(component){
		var action = component.get('c.getPortalConfiguration');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resultMap = response.getReturnValue();
				
				var dataCategory = resultMap.Data_category_mapping__c;
				var phoneTitle = resultMap.Phone_Number_Title__c;
				component.set('v.phoneTitle', phoneTitle);
				component.set('v.dataCategory', dataCategory);
			}
		});
		$A.enqueueAction(action);
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