({
	/**************************************************************************************************************
     * Method Name							: getLoggedInUser
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current member from cache class
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	getLoggedInUser : function(component) {
		//calling an action to the server side controller to fetch the current member
		var action = component.get("c.fetchLoggedInUser");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//set the attribute with the value
				component.set("v.loggedInUserRecord",response.getReturnValue());
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
	},
	
	getPortalConfig: function(component) {
		//calling an action to the server side controller to fetch the current member
		var action = component.get("c.loadConfiguration");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//set the attribute with the value
				var pConfig = response.getReturnValue();
				
				var welcomeH = pConfig.Welcome_FAD_Header_Label__c;
				var welcomeD = pConfig.Welcome_FAD_Description_Label__c;
				
				var welcomeHV = $A.getReference('$Label.c.'+ welcomeH);
				component.set('v.manageDependentHeaderL', welcomeHV);
				var welcomeDV = $A.getReference('$Label.c.'+ welcomeD);
				component.set('v.manageDependentDescriptionL', welcomeDV);
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: setContactRecordToViewedDashboard
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To set the checkbox back to false
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			26th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	setContactRecordToViewedDashboard : function (component){
		console.log('setting contact before destroy!');
		//calling an action to the server side controller to fetch the current member
		var action = component.get("c.updateWelcomeDashboard");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			console.log(response_state);
			if(response_state === "SUCCESS"){
				//destroy the component
				component.destroy();
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
	}
})