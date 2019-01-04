({
	/**************************************************************************************************************
     * Method Name							: fetchHelpRequestDetail
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the case url from the controller and fetch for the details
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			13th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	fetchHelpRequestDetail : function(component, event, helper, caseIdForUrl) {
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
				component.set("v.case_inReference",response.getReturnValue());
				
				//calling the method to fetch the case comments
				this.fetchHelpRequestComments(component, event, this, caseIdForUrl);
				
				//calling the method to fetch the attachment
				this.fetchHelpRequestAttachments(component, event, this, caseIdForUrl);
				
				//switching off spinner
				console.log('fetchHelpRequestDetail complete');
				
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: fetchHelpRequestAttachments
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the case url from the controller and fetch for the attachments
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			13th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	fetchHelpRequestAttachments : function(component, event, helper, caseIdForUrl) {
		console.log('caseIdForUrl::'+caseIdForUrl);
		//calling an action to the server side controller to fetch the help request information
		var action = component.get("c.fetch_relatedCaseAttachments");
		//setting the case Id for query
        action.setParams({
        	str_caseId:caseIdForUrl
        });
        //creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() === 'SUCCESS'){
				component.set("v.relatedAttachments",response.getReturnValue());
				//resetting some values
				component.set("v.loadUploadButton",false);
				document.getElementById('fileUpload').value = null;
				document.getElementById('fileUploadAttachment').value = null;
				
				console.log('fetchHelpRequestAttachments complete');
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
				console.log('fetchHelpRequestAttachments error');
			}
		});
		$A.enqueueAction(action);
		console.log('fetchHelpRequestAttachments fired...');
	},
	/**************************************************************************************************************
     * Method Name							: fetchHelpRequestComments
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the case url from the controller and fetch for the case comments
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			14th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	fetchHelpRequestComments : function(component, event, helper, caseIdForUrl) {
		console.log('caseIdForUrl::'+caseIdForUrl);
		//calling an action to the server side controller to fetch the help request information
		var action = component.get("c.fetch_relatedCaseComments");
		//setting the case Id for query
        action.setParams({
        	str_caseId:caseIdForUrl
        });

        console.log('in the case comments function.');

        //creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			console.log('response received...');
			console.log(response.getState());
			//console.log('response string: ' + JSON.stringify(response));

			//checking if the response is success
			if(response.getState() === 'SUCCESS'){
				console.log('success');
				console.log('comments: ' + JSON.stringify(response.getReturnValue()));
				component.set("v.relatedComments",response.getReturnValue());
				
			}else{
				//setting the error flag and the message
				console.log('failed comments');
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
		console.log('action fired...');
	},
	/**************************************************************************************************************
     * Method Name							: fetchRunningUser
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the running of the user of the portal
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			14th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	fetchRunningUser : function(component){
		//calling an action to the server side controller to fetch the help request information
		var action = component.get("c.fetch_RunningUser");
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() === 'SUCCESS'){
				component.set("v.runningUser",response.getReturnValue());
				console.log('fetchRunningUser complete...');
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: uploadAttachment
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To upload the attachment
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			16th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	uploadAttachment : function(component, event,  helper, file){
		console.log('in uploadAttachment 1');
		//getting the case id
		var caseId = component.get("v.case_inReference").Id;
		
		console.log('in uploadAttachment 1' + caseId);
		//file reader - for the file needs to be uploaded
		var fr = new FileReader();
		
		fr.onload = $A.getCallback(function() {
			console.log('in uploadAttachment 2');
			var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
 
            fileContents = fileContents.substring(dataStart);
            var upAttachment = component.get('c.uploadFileAttachment');
            upAttachment.setParams({
        		'caseId' : caseId,
        		'fileName': file.name,
		        'base64Data' : encodeURIComponent(fileContents), 
		        'contentType': file.type
            });
	        upAttachment.setCallback(this, function(response){
	        	if(response.getState() === 'SUCCESS'){
	        		//var result = response.getReturnValue();
	        		console.log('in uploadAttachment 3');
	        		//calling to requery attachments
	        	    helper.fetchHelpRequestAttachments(component, event,  helper, caseId);
	        	}
	        });
	        $A.enqueueAction(upAttachment);
	    });
	
	    fr.readAsDataURL(file);
	    
	},
		
	/**************************************************************************************************************
	 * Method Name							: saveCaseComment
	 * Developed By							: Santosh Kumar Sriram
	 * Purpose								: To save the comment
	 Version#		Build#		Date					by  						Comments
	 1.0			7.0			16th October 2017		Santosh Kumar Sriram		See header - purpose
	
	 ***************************************************************************************************************/
	saveCaseComment : function(component, event, helper, file){
		console.log('in save comment');
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
				//checking for file
		    	if(file !== undefined){
		    		//helper to upload
		    		helper.uploadAttachment(component,event, helper, file);
		    	}
			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
			}
		});
		$A.enqueueAction(action);
	}
})