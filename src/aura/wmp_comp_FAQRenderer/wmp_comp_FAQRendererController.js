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
		//Getting the decoded URL of the page 
		console.log('inside FAQ Renderer doInit...');
		var string_pageURL = decodeURIComponent(window.location.search.substring(1));
		var list_URLParamArray = string_pageURL.split('&');
		//iterating through the list of params
		for(var iterating_int = 0; iterating_int < list_URLParamArray.length ; iterating_int++){
            if(list_URLParamArray[iterating_int].split('=')[0] === $A.get("$Label.c.articlename")){
            	component.set("v.knwldge_articleTitle", list_URLParamArray[iterating_int].split('=')[1]);
            }
            else{
            	component.set("v.portal_configurationText",list_URLParamArray[iterating_int].split('=')[1]);
            }
		}
		component.set('v.displayInfo', true);
	}
})