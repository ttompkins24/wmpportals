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
		var businessId = component.get('v.currentBusinessId');
		var portalConfigName = sessionStorage['portalconfig'];
		var action = component.get('c.fetch_countOfOpenCases');
		action.setParams({
			'businessId' : businessId,
			configName : portalConfigName
		});
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
		console.log('get phone article');
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
})