({
	/**************************************************************************************************************
     * Method Name							: fetchHelpRequestDetail
     * Developed By							: West Monroe Partners
     * Purpose								: To get the case url from the controller and fetch for the details
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			February 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	fetchHelpRequestDetail : function(component, event, helper, caseIdForUrl) {
		component.set('v.showSpinner', true);		
		//calling an action to the server side controller to fetch the help request information
		var action = component.get("c.fetch_relatedCaseInfo");
		
		//setting the case Id for query
        action.setParams({
        	str_caseId:caseIdForUrl
        });
        
      //creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() === 'SUCCESS'){

				var my_case = response.getReturnValue();
				if(my_case.Description) {
					my_case.Description = my_case.Description.substring(0, my_case.Description.indexOf('****'));
				}
				if(my_case.Subject) {
					if(my_case.Subject.indexOf('Claim Void') > -1) {
						component.set('v.showVoidInfo', true);
					} else if((my_case.Subject.indexOf('Claim Appeal') > -1 || my_case.Subject.indexOf('Authorization & Estimate Appeal') > -1)) {
						component.set('v.showAppealInfo', true);
						component.set('v.showMemberInfo', true);
					} else if(my_case.Subject == 'EFT Enrollment/Update/Cancellation') {
						component.set('v.showEFTInfo', true);
					} else if(my_case.Subject.indexOf('Detail Update') > -1) {
						component.set('v.showPMInfo', true);
					} else {
						component.set('v.showStandardInfo', true);
					}
				}
				component.set("v.case_inReference", my_case);
				
				//console.log('### got case: ' + JSON.stringify(response.getReturnValue()));
				//calling the method to fetch the case comments
				this.fetchHelpRequestComments(component, event, this, caseIdForUrl);
			
				//switching off spinner
				//console.log('fetchHelpRequestDetail complete');
				
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: fetchHelpRequestComments
     * Developed By							: West Monroe Partners
     * Purpose								: To get the case url from the controller and fetch for the case comments
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			February 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	fetchHelpRequestComments : function(component, event, helper, caseIdForUrl) {
		//console.log('caseIdForUrl::'+caseIdForUrl);
		component.set('v.showSpinner', true);		
		//calling an action to the server side controller to fetch the help request information
		var action = component.get("c.fetch_relatedCaseComments");
		//setting the case Id for query
        action.setParams({
        	str_caseId:caseIdForUrl
        });

        //console.log('in the case comments function.');

        //creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//console.log('response received...');
			//console.log(response.getState());
			////console.log('response string: ' + JSON.stringify(response));

			//checking if the response is success
			if(response.getState() === 'SUCCESS'){
				//console.log('success');
				//console.log('comments: ' + JSON.stringify(response.getReturnValue()));
				component.set("v.relatedComments",response.getReturnValue());		
				
			}else{
				//setting the error flag and the message
				//console.log('failed comments');
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);
		//console.log('action fired...');
	},
	/**************************************************************************************************************
     * Method Name							: fetchRunningUser
     * Developed By							: West Monroe Partners
     * Purpose								: To get the running of the user of the portal
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			February 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	fetchRunningUser : function(component){
		//calling an action to the server side controller to fetch the help request information
		var action = component.get("c.fetch_RunningUser");
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() === 'SUCCESS'){
				component.set("v.runningUser",response.getReturnValue());
				//console.log('fetchRunningUser complete...');
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
	},

	/**************************************************************************************************************
	 * Method Name							: saveCaseComment
	 * Developed By							: West Monroe Partners
	 * Purpose								: To save the comment
	 Version#		Build#		Date					by  						Comments
	 1.0			7.0			February 2018		West Monroe Partners		See header - purpose
	
	 ***************************************************************************************************************/
	saveCaseComment : function(component, event, helper){
		//console.log('in save comment');
		component.set('v.showSpinner', true);		
		var caseCommentDescription = component.find("casecommentdescription").get("v.value");
		//getting the case id
		var caseId = component.get("v.case_inReference").Id;
		
		//calling an action to the server side controller to save the case comment
		var action = component.get("c.saveCaseComment");
		//setting the offset and the number of cases to limit
        action.setParams({
        	caseCommentDescription: caseCommentDescription,
        	caseId: caseId
        });
      	
      	//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() === 'SUCCESS'){
				//calling the method to fetch the case comments
				helper.fetchHelpRequestComments(component, event, helper, caseId);
				component.find("casecommentdescription").set("v.value","");
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);
	}
})