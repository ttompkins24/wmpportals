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
	getLoggedInUser : function(component, helper) {
		//calling an action to the server side controller to fetch the current member
		var action = component.get("c.fetchLoggedInUser");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//set the attribute with the value
				//component.set("v.loggedInUserRecord",response.getReturnValue());
				var loggedInUserRecord = response.getReturnValue();
				component.set("v.loggedInUserRecord",loggedInUserRecord);
				//console.log(loggedInUserRecord.Displayed_Welcome_message__c);
				//check if the loggedInUserRecord has that checked set to true
				if(loggedInUserRecord.Displayed_Welcome_message__c === false){
					//create the welcome header component
					//now creating the welcome dashboard
					$A.createComponent(
						"c:wmp_comp_welcomeDashboard",
						{},
						function(modalPopUp, status, errorMessage){
							if(status === "SUCCESS"){
								var body = component.get("v.body");
				                body.push(modalPopUp);
				                component.set("v.body", body);
							}
						}
					);
				}
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
     * Method Name							: getOverviewInformation
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# getting the overview wrapper to display in the portal
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	getOverviewInformation :  function (component, helper){
		//calling an action to the server side controller to fetch the current member
		var action = component.get("c.fetch_overviewDetails");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//set the attribute with the value
                console.log('resp: ' + JSON.stringify(response.getReturnValue()));
				component.set("v.overviewInfoWrapper",response.getReturnValue());
				console.log('response.getReturnValue()::'+JSON.stringify(response.getReturnValue() ) );
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
     * Method Name							: helperLoadConfig
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# getting the config value from the custom metadata type
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	helperLoadConfig : function(component){
		var action= component.get('c.loadConfiguration');
//		console.log('in helperLoadConfig');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var pConfig = response.getReturnValue();
				//console.log('pConfig.name::'+pConfig.Label);
				var fadL = pConfig.Main_Dentist_Label__c;
				var findAdentistL = pConfig.Find_a_Dentist_Label__c;
				var whatIsDentist = pConfig.What_is_your_main_dentist_label__c;
				//console.log('fadL::'+fadL);
				
					component.set('v.dentistL', $A.getReference('$Label.c.'+fadL));
					var fadV = $A.getReference('$Label.c.'+ findAdentistL);
					component.set('v.findADentistL', fadV);
					component.set('v.whatIsYourMainDentistL',  $A.getReference('$Label.c.'+whatIsDentist));
					component.set('v.popUpSurroundingTextL',$A.getReference('$Label.c.'+ pConfig.Main_dentist_popup_help_label__c));
					component.set('v.findADentistSupportingTextL',$A.getReference('$Label.c.'+ pConfig.Find_a_Dentist_Support_Overview_Label__c));
				
			}
		});
		$A.enqueueAction(action);
	}
})