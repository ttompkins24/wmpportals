({
	/**************************************************************************************************************
     * Method Name							: redirectHelpRequests
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To take the user back to the help request whole list page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			12th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	redirectHelpRequests : function (component, event, helper){
		//get the member id and plan id
		var pageName = $A.get("$Label.c.help_requests_page");
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
		       'pageName' : pageName
		});
		redirectEvent.fire();
	},
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the case url from the page url and pass it to helper
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			12th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper){
		//getting the case id from the url
		var caseIdForUrl = '';
		 var string_pageURL = decodeURIComponent(window.location.search.substring(1));
		 var list_URLParamArray = string_pageURL.split('&');
		 //iterating through the list of params
		 for(var iterating_int = 0; iterating_int < list_URLParamArray.length ; iterating_int++){	
           	if(list_URLParamArray[iterating_int].split('=')[0] === $A.get("$Label.c.caseid"))
           		caseIdForUrl = list_URLParamArray[iterating_int].split('=')[1];
         }
		 
		//new case
		//var caseIdForUrl = '500g000000Gd3C1';
		//closed case
		//var caseIdForUrl = '500g000000Gf1OX';
		
		//caaling the helper method to get the running user
		helper.fetchRunningUser(component);
		//calling helper method to make the server call
		helper.fetchHelpRequestDetail(component, event, helper, caseIdForUrl);
		
	
	},
	/**************************************************************************************************************
     * Method Name							: checkForFileInput
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the file input for case attachments
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			16th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	checkForFileInput : function(component, event, helper){
		component.set('v.bln_isError', false);
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		
		//getting the location
		var location = event.currentTarget.dataset.location;
		var fileInput ;
		//getting the file
		if(location === $A.get("$Label.c.commentSection"))
			fileInput = component.find("upFilesAttachment").getElement();
		else
			fileInput = component.find("upFiles").getElement();
		
		//validations
		if(fileInput.files.length > 0){
			var MAX_FILE_SIZE = 750000; /* 1 000 000 * 3/4 to account for base64 */
	    	var file = fileInput.files[0];
//	    	console.log('fileName::'+file.name + ': '+ file.size);
	   
	        if (file.size > MAX_FILE_SIZE) {
	        	component.set('v.str_errorMsg', $A.get("$Label.c.File_Case_File_Size_Error") );
	        	component.set('v.bln_isError', true);
	        	var spinner = component.find('uploadSpinner');
	        	window.scrollTo(0,0);
	    	    return;
	        }
	        
	        console.log('fileType::'+file.type);
	        if( !(file.type.includes('xlsx') || file.type.includes('xls') || file.type.includes('csv') || file.type.includes('doc') || 
	        		file.type.includes('pdf') || file.type.includes('docx') || file.type.includes('ppt') || file.type.includes('pptx') || 
	        		file.type.includes('txt') || file.type.includes('image/') || file.type.includes('sheet')|| file.type.includes('excel') ) ){
	        		
	        	component.set('v.str_errorMsg', $A.get("$Label.c.File_Case_Type_Acceptable") );
	        	component.set('v.bln_isError', true);
	        	window.scrollTo(0,0);
	        	return;
	      	}
	        
	        //validation successful
	        component.set("v.loadUploadButton", true);
		}
	},
	/**************************************************************************************************************
     * Method Name							: uploadAttachment
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To upload the attachments the file input for case attachments
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			7.0			16th October 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	uploadAttachment: function(component, event, helper){
		
		component.set('v.bln_isError', false);
		//getting the location
		var location = event.currentTarget.dataset.location;
		var fileInput ;
		//getting the file
		if(location === $A.get("$Label.c.commentSection"))
			fileInput = component.find("upFilesAttachment").getElement();
		else
			fileInput = component.find("upFiles").getElement();
		
		
		//getting the file
		//var fileInput = component.find("upFiles").getElement();
		//getting the file
		var file = fileInput.files[0];
		
		//helper to upload
		helper.uploadAttachment(component,event, helper, file);
		
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
    uploadAttachmentAndComment :  function(component, event, helper){
    	component.set('v.bln_isError', false);
    	console.log('in case and attachment');
    	
		var isError;
		//getting the location
		var location = event.currentTarget.dataset.location;
		var fileInput ; 
		
		//getting the file
		if(location === $A.get("$Label.c.commentSection"))
			fileInput = component.find("upFilesAttachment").getElement();
		else
			fileInput = component.find("upFiles").getElement();
		
		//var fileInput = component.find("upFiles").getElement();
		//getting the file
		var file
		if(fileInput.files.length > 0)
			file = fileInput.files[0];
		
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
    	helper.saveCaseComment(component,event, helper, file);
    	
    }
})