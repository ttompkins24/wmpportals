({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current member from cache class
     * 											# current member plan from cache class
     * 											# preselect the tab to display
     *										  and query for the knowledge article.
     *										 
     History
     Version#		Sprint#		Date				by  						Comments
	 1.0			1.0			30th August 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
		console.log('doInit...');
		//get the current member information
		helper.getCurrentMember(component);
		//get the current member plans information
		helper.getCurrentMemberPlans(component, helper);
		
		
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
		helper.changeInPlanId(component, event, helper);
		
	},
	changeInPlanIdMob : function (component, event, helper){
		helper.changeInPlanIdMob(component, event, helper);
		
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