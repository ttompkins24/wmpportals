({
    /**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: WMP - S$
     * Purpose								: To fetch the necessary information from 
     * 											# user settings - language
     * 											# Title of the article - from the portal configuration object
     * 											# fields to query and article type from design attributes
     *										  and query for the knowledge article.
     *										 Once queried the fields will parsed by the custom tokenization logic and 
     *										 then displayed with necessary values
     History
     Version#		Sprint#		Date				by  					Comments
	 1.0			1.0			7th August 2017		WMP-S$					See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
        
        //component.set("v.portal_configurationText",'Colorado_Member_Portal__c');
        //Step 2 - get design attributes
//		console.log('in  controller');
		 //get the current member information
		helper.getCurrentMember(component);
		//get the acccount name related to the plans
		helper.fetchPlanNames(component, event, helper);
		helper.fetchCurrentMemberPlans(component, event, helper);
	},
	/**************************************************************************************************************
     * Method Name							: changeInPlanId
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current memberplan information
     * 											# show current ID card
     *										 
     History
     Version#		Sprint#		Date				by  						Comments
	 1.0			1.0			8th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	changeInPlanId : function (component, event, helper){
		helper.changeInPlanId(component, event, helper);
	},
    /**************************************************************************************************************
     * Method Name							: redirectView
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the member id and the plan id to redirect the user to the respective page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			25th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	redirectContactUs : function (component, event, helper){
		//get the member id and plan id
		var pageName = $A.get("$Label.c.help_center_landing");
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
		       'pageName' : pageName
		});
		redirectEvent.fire();
	}
})