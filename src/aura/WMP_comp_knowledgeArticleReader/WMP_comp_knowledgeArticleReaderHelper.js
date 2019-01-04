({
	 /**************************************************************************************************************
     * Method Name							: fetchCurrentMemberPlans
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information from 
     * 											# Current member plans to display in a picklist if there are more than 2
     History
     Version#		Sprint#		Date					by  									Comments
	 1.0			1.0			20th September 2017		Santosh Kumar Sriram					See header - purpose

    ***************************************************************************************************************/
	fetchCurrentMemberPlans : function(component, event, helper) {
		//calling an action to the server side controller to fetch the current member plan
		var action = component.get("c.fetchCurrentMemberPlans");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//set the attribute with the value
				var memberplans = response.getReturnValue();
				component.set("v.currentMemberCovPlans",memberplans);
				component.set('v.chosen_MemberPlan', memberplans[0]);
				//now fetch the plan configuration setting to get the hardcoded values
				helper.fetchPlanConfiguration(component, event, helper, memberplans[0].PlanGUID__c);
			}else{
				//toast to display
				//console.log in case we need to track
				component.set("v.str_errorMsg", $A.get("$Label.c.Error_message"));
				component.set('v.bln_isError', true);
				window.scrollTo(0,0);
			}
		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: fetchPlanNames
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary plan names for the logged in user
     History
     Version#		Sprint#		Date					by  									Comments
	 1.0			1.0			20th September 2017		Santosh Kumar Sriram					See header - purpose

    ***************************************************************************************************************/
	fetchPlanNames :function (component, event, helper){
		//calling an action to the server side controller to fetch the current account plans
		var action = component.get("c.fetchMemberPlansAccounts");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//check for the number of verified plan returned
				if(response.getReturnValue().length > 0){
					//set the attribute with the value and set the error boolean to false
					component.set("v.currentMemberPlans",response.getReturnValue());
				}else{
					//set the error message and the condition
					component.set("v.bln_isError", true);
					component.set("v.str_errorMsg",$A.get("$Label.c.Error_message") + "1");
				}
				
			}else{
				//toast to display
				//console.log in case we need to track
				//set the error message and the condition
				component.set("v.bln_isError", true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Error_message"));
			}
		});
		$A.enqueueAction(action);
	},
	 /**************************************************************************************************************
     * Method Name							: fetchPlanConfiguration
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information from 
     * 											# plan configuration object and get the article name, portal catergory
     *
     History
     Version#		Sprint#		Date					by  									Comments
	 1.0			1.0			20th September 2017		Santosh Kumar Sriram					See header - purpose

    ***************************************************************************************************************/
	fetchPlanConfiguration : function(component, event, helper, chosenMemberPlan) {
		console.log('fetchPlanConfiguration...');
		//calling an action to the server side controller to fetch the current member plan
		var action = component.get("c.fetchCurrentPlanConfiguration");
		//console.log(component.get("v.chosenMemberPlanId") + ' ... '+  chosenMemberPlan);
		if(chosenMemberPlan !== undefined){
			//setting the member plan planGUid as the parameter to the server side action
			action.setParams({ subgroupID : chosenMemberPlan});
			
			
			//creating a callback that is executed after the server side action is returned
			action.setCallback(this, function(response){
				var response_state = response.getState();
				
				//checking if the response is success
				if(response_state === 'SUCCESS'){
					//set the attribute with the value
					component.set("v.runningPlanConfig",response.getReturnValue());
					//component.find("chosenPlanId").set("v.value",component.get("v.chosenMemberPlanId"));
					//calling the redirect for the iframe function
					helper.redirectIFrameUrl(component, event, helper, chosenMemberPlan);
					
				}else{
					//toast to display
					//console.log in case we need to track
					component.set("v.str_errorMsg", $A.get("$Label.c.Error_message"));
					component.set('v.bln_isError', true);
					window.scrollTo(0,0);
				}
			});
			$A.enqueueAction(action);
		}
		else{
			//error handling
			component.set("v.str_errorMsg", $A.get("$Label.c.Error_message"));
			component.set('v.bln_isError', true);
			window.scrollTo(0,0);
		}
	},
	/**************************************************************************************************************
     * Method Name							: redirectIFrameUrl
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To redirect the iframe to display the right ID card
     *
     History
     Version#		Sprint#		Date					by  									Comments
	 1.0			1.0			20th September 2017		Santosh Kumar Sriram					See header - purpose

    ***************************************************************************************************************/
	redirectIFrameUrl : function(component, event, helper,chosenMemberPlan) {
		var sourceString =  $A.get("$Label.c.CommunityURL")+ '/apex/WMP_vf_IDCardPDF?articleType='+component.get("v.knwldge_articleType");
        sourceString += '&queryFields=' + component.get("v.knwldge_queryFields");
//        console.log('comp ' + component.get("v.runningPlanConfig"));
        if((component.get("v.knwldge_articleType") === $A.get("$Label.c.ID_Card_Template"))){
            sourceString += '&portalText=' + 'Member__c';//component.get("v.runningPlanConfig").Data_category_mapping__c;
            sourceString += '&articleTitle=' + component.get("v.runningPlanConfig").ID_card_Knowledge_article_title__c;
            sourceString += '&whatid=' + chosenMemberPlan;
        }else{
            sourceString += '&portalText=' +component.get("v.portal_configurationText");
            //console.log('inside redirectIframeUrl:component.get("v.knwldge_articleTitle")::'+component.get("v.knwldge_articleTitle"));
            sourceString += '&articleTitle=' + component.get("v.knwldge_articleTitle");
        }
		        
        //checking for the boolean case
        if((component.get("v.knwldge_articleType") === $A.get("$Label.c.ID_Card_Template")) && !((component.get("v.bln_displayPDF")))){
        	sourceString += "#zoom=175";
        }
       console.log('sourceString::'+sourceString);
        component.set("v.src_vfPage",sourceString);
	},
	/**************************************************************************************************************
     * Method Name							: getCurrentMember
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current member from cache class
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			30th August 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	getCurrentMember : function(component) {
		//calling an action to the server side controller to fetch the current member
		var action = component.get("c.fetchCurrentMember");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//set the attribute with the value
				component.set("v.currentMember",response.getReturnValue());
			}else{
				//toast to display
				//console.log in case we need to track
			}
		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: changeInPlanId
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current memberplan information
     * 											# current knowledge article related to the member plan
     *										 
     History
     Version#		Sprint#		Date				by  						Comments
	 1.0			1.0			8th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	changeInPlanId : function (component, event, helper){
		//console.log('changeplan');
		planId = event.getSource().get("v.value");
        
		//console.log(planId);
		//calling the function to fetch new id card
		helper.fetchPlanConfiguration(component, event, helper, planId);
		
		var memPlans = component.get('v.currentMemberCovPlans');
		
		for(var memCov in memPlans){
			//console.log('planGuid::'+memPlans[memCov].PlanGUID__c);
			if(planId == memPlans[memCov].PlanGUID__c){
				component.set('v.chosen_MemberPlan', memPlans[memCov]);
				break;
			}
		}
	}
})