({
	/**************************************************************************************************************
     * Method Name							: redirectHelpRequests
     * Developed By							: West Monroe Partners
     * Purpose								: To take the user back to the help request whole list page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			February 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	redirectHelpRequests : function (component, event, helper){
		//get the member id and plan id
		var pageName = 'help-request'
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		//console.log('pageName: '+pageName);
		redirectEvent.setParams({
		       'pageName' : pageName
		});
		redirectEvent.fire();
	},
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: West Monroe Partners
     * Purpose								: To get the case url from the page url and pass it to helper
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			February 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper){
		//console.log('### doing init...');
		//getting the case id from the url
		var caseIdForUrl = component.get('v.params.id');

		//console.log(caseIdForUrl);
		//caaling the helper method to get the running user
		helper.fetchRunningUser(component);
		//calling helper method to make the server call
		helper.fetchHelpRequestDetail(component, event, helper, caseIdForUrl);
		// component.set('v.showSpinner', false);		
	},
	/**************************************************************************************************************
     * Method Name							: checkSpecialCharacters
     * Developed By							: Todd Tompkins
     * Purpose								: To check for the special characters and replacing with blank
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			13th September 2017		Todd Tompkins(WMP)		See header - purpose

    ***************************************************************************************************************/
    checkSpecialCharacters : function (component, event, helper){
        //For guardian last name
        var casecommentdescription = component.find("casecommentdescription").get("v.value");
        if(casecommentdescription !== undefined){
        	casecommentdescription = casecommentdescription.replace(/[^a-zA-Z0-9-. !%&#@$*()'']/g,'');
        	component.find("casecommentdescription").set("v.value",casecommentdescription);
        }

    },
    uploadComment :  function(component, event, helper){
    	component.set('v.bln_isError', false);
    	//console.log('in case and comment');
    	
		var isError;
		//getting the location
		var location = event.currentTarget.dataset.location;
		
		//helper method to saye the comment
		var description = component.find("casecommentdescription").get("v.value");
		

    	if(description === '' || description === undefined){
    		component.set('v.descriptionError', true);
    		isError = true;
    	}
    	
    	if(isError){
    		window.scrollTo(0,0);
    		component.set('v.str_errorMsg', $A.get("$Label.c.Case_Required_Fields_Error") );
    		component.set('v.bln_isError', true);
    		return;
    	}
    	
    	//helper method to store the case comment
    	helper.saveCaseComment(component,event, helper);
    	
    }
})