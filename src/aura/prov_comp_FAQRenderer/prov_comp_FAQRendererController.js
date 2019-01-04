({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# Other information that needs to be displayed on the page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			9.0			June 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
        //Getting the decoded URL of the page 
        //console.log('inside FAQ Renderer doInit...');
        var string_pageURL = decodeURIComponent(window.location.search.substring(1));
        var list_URLParamArray = string_pageURL.split('&');
        //console.log(list_URLParamArray);
        //iterating through the list of params
        for(var iterating_int = 0; iterating_int < list_URLParamArray.length ; iterating_int++){
            if(list_URLParamArray[iterating_int].split('=')[0] === $A.get("$Label.c.articlename")){
                component.set("v.knwldge_articleTitle", list_URLParamArray[iterating_int].split('=')[1]);
                //console.log(component.get("v.knwldge_articleTitle"));
            }
            else{
                component.set("v.portal_configurationText",list_URLParamArray[iterating_int].split('=')[1]);
                //console.log(component.get("v.portal_configurationText"));
            }
        }
        component.set('v.displayInfo', true);

        helper.redirectIFrameUrl(component,event,helper);
    }
})