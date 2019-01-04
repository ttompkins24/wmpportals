({
	/**************************************************************************************************************
     * Method Name							: redirectView
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the member id and the plan id to redirect the user to the respective page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			10th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	redirectContactUs : function (component, event, helper){
		//get the member id and plan id
		var pageName = 'contact-us';
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
		       'pageName' : pageName
		});
		redirectEvent.fire();
	},
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# Other information that needs to be displayed on the page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			10th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
		
		//starting spinner
		//started automatically
		//to get the total number
		helper.fetchTotalCaseCount(component, helper);
		//to get the offset number of cases
		//helper.fetchRelatedCases(component);
	},
	/**************************************************************************************************************
     * Method Name							: clickNext
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To increase the page number by 1 and also call the server side call
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			11th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	clickNext : function (component, event, helper){
		//Switching on the spinner
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		//setting the present page number
		var presentPageNumber = component.get("v.presentPageNumber");
		presentPageNumber = presentPageNumber + 1;
		//added the present page number as 1 more
		component.set("v.presentPageNumber", presentPageNumber);
		//now calling the helper method to get related cases
		helper.fetchRelatedCases(component);
		window.scrollTo(0,0);
	},
	/**************************************************************************************************************
	 * Method Name							: clickPrevious
	 * Developed By							: Santosh Kumar Sriram
	 * Purpose								: To decrease the page number by 1 and also call the server side call
	 History
	 Version#		Build#		Date					by  						Comments
	 1.0			7.0			11th October 2017		Santosh Kumar Sriram		See header - purpose
	
	***************************************************************************************************************/
	clickPrevious : function (component, event, helper){
		//Switching on the spinner
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		//setting the present page number
		var presentPageNumber = component.get("v.presentPageNumber");
		presentPageNumber = presentPageNumber - 1;
		//added the present page number as 1 more
		component.set("v.presentPageNumber", presentPageNumber);
		//now calling the helper method to get related cases
		helper.fetchRelatedCases(component);
		window.scrollTo(0,0);
	},
	/**************************************************************************************************************
	 * Method Name							: clickFirst
	 * Developed By							: Santosh Kumar Sriram
	 * Purpose								: To set the page number to 1 and also call the server side call
	 History
	 Version#		Build#		Date					by  						Comments
	 1.0			7.0			12th October 2017		Santosh Kumar Sriram		See header - purpose
	
	***************************************************************************************************************/
	clickFirst : function (component, event, helper){
		//Switching on the spinner
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		//setting the present page number
		var presentPageNumber = component.get("v.presentPageNumber");
		presentPageNumber = 1;
		//added the present page number as 1 more
		component.set("v.presentPageNumber", presentPageNumber);
		//now calling the helper method to get related cases
		helper.fetchRelatedCases(component);
		window.scrollTo(0,0);
	},
	/**************************************************************************************************************
	 * Method Name							: redirectToCreateNewHelpRequest
	 * Developed By							: Santosh Kumar Sriram
	 * Purpose								: To redirect to create new help request page
	 History
	 Version#		Build#		Date					by  						Comments
	 1.0			7.0			12th October 2017		Santosh Kumar Sriram		See header - purpose
	
	***************************************************************************************************************/
	redirectToCreateNewHelpRequest : function(component, event, helper) {
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.loc;
		//calling the redirectEvent
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
						'pageName' : pageName
		});
		redirectEvent.fire();
	},
	/**************************************************************************************************************
	 * Method Name							: redirectToDetailPage
	 * Developed By							: Santosh Kumar Sriram
	 * Purpose								: To redirect to create help request detail page
	 History
	 Version#		Build#		Date					by  						Comments
	 1.0			7.0			16th October 2017		Santosh Kumar Sriram		See header - purpose
	
	***************************************************************************************************************/
	redirectToDetailPage : function(component, event, helper){
		var caseid = event.currentTarget.dataset.caseid;
		
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url":"/help-request-detail?caseid="+caseid
		});
		urlEvent.fire();
	}
})