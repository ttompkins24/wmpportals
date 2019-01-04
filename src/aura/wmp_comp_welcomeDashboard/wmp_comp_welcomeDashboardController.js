({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current member from cache class
     * 											# Other information that needs to be displayed on the page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
		//fetch the logged in user
		helper.getPortalConfig(component);
		helper.getLoggedInUser(component);
	},
	defaultClose : function(component, event, helper){
		helper.setContactRecordToViewedDashboard(component);
        
    }
})