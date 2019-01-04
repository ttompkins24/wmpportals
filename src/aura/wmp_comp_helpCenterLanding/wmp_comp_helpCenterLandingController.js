({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# Other information that needs to be displayed on the page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
        //getting the portal config information
		helper.getPortalConfig(component, event, helper);
		
		//getting the portal links from the metadata
		//helper.getOtherResourcesLinks(component, event, helper);
	},
	/**************************************************************************************************************
     * Method Name							: redirectToFAQ
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# Will redirec to the common FAQ page with necesary parameters
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	redirectToFAQ :function(component, event, helper){
		var articleName = event.currentTarget.dataset.articlename;
		var dataCategory = event.currentTarget.dataset.datacategory;
		
		 var urlEvent = $A.get("e.force:navigateToURL");
		 urlEvent.setParams({
			 "url":"/faq?articlename="+articleName+"&datacategory="+dataCategory
		 });
		 urlEvent.fire();
	},
	/**************************************************************************************************************
     * Method Name							: redirectContactUs
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# Will redirect to the common Contact us page with neccesary parameters
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	redirectContactUs :function(component, event, helper){
		var articleName = event.currentTarget.dataset.articlename;
		var dataCategory = event.currentTarget.dataset.datacategory;
		
		 var urlEvent = $A.get("e.force:navigateToURL");
		 urlEvent.setParams({
			 "url":"/contact-us"
		 });
		 urlEvent.fire();
	}
})