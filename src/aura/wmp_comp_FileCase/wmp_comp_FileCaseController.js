({
	doInit : function(component, event, helper) {
		helper.retrieveCaseTypes(component);
		helper.retrieveMembers(component);
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
        var guardianLName = component.find("guardianLastName").get("v.value");
        if(guardianLName != undefined){
            guardianLName = guardianLName.replace(/[^a-zA-Z0-9-. '']/g,'');
        	component.find("guardianLastName").set("v.value",guardianLName);
        }

    },
    
    //change the address that is chosen and update the variable containing the address that is selected
    changeAddressChosen : function(component, event, helper){
    	var selected = event.getSource().get("v.text");
        component.set("v.addressChosen", selected);
        console.log('sel: ' + selected);
    },
    
    //change the current member that is in focus. Possibly load the addresses if the Request ID Card is chosen
    changeCurrentMember : function(component, event, helper){
    	var memberCovGuid = component.get('v.memberChosen');
    	var typeChosen = component.get('v.typeChosen');
        console.log("changedMember: " + memberCovGuid + ' ' + typeChosen);
    	if(memberCovGuid == '' || typeChosen != 'Request ID Card'){
    		var addressList = [];
    		component.set('v.addressList', addressList);
    		component.set('v.addressChosen', '');
    	} else {
            
    		var spinner = component.find('uploadSpinner');
    		$A.util.toggleClass(spinner, 'slds-hide');
	    	var action = component.get('c.retrieveMemberAddress');
	    	action.setParams({'memCovGuid' : memberCovGuid});
	    	action.setCallback(this, function(response){
	    		if(response.getState() == 'SUCCESS'){
	    			var resMap = response.getReturnValue();
                    console.log("addresses: " + JSON.stringify(resMap));
	    			var addressList = [];
	    			var dupDetect = [];
	    			for( var key in resMap){
                        var add2 = '';
                        if(resMap[key].AddressLine2__c!=undefined){add2 = ' ' + resMap[key].AddressLine2__c;}
						var obj = {'Value':key, 'Street':resMap[key].AddressLine1__c + add2, 'City':resMap[key].City__c,
									'State':resMap[key].State__c, 'Country':resMap[key].Country__c, 'Zip':resMap[key].Zip__c,
									'MemberProfileGUID__c' : resMap[key].MemberProfileGUID__c};
                        
                        console.log('dup: ' + dupDetect.includes(resMap[key].AddressLine1__c + resMap[key].State__c));
                        if(!dupDetect.includes(resMap[key].AddressLine1__c + resMap[key].State__c)){
							addressList.push(obj);
                            dupDetect.push(resMap[key].AddressLine1__c + resMap[key].State__c);
                        }
                        
					}
				
					component.set('v.addressList', addressList);
					component.set('v.addressChosen', '');
					var spinner = component.find('uploadSpinner');
					$A.util.toggleClass(spinner, 'slds-hide');
	    		}
	    	});
	    	$A.enqueueAction(action);
	    }
    },
    
    //submut a case for the id card case type
    saveIdCardCase : function(component, event, helper){
    	var spinner = component.find('uploadSpinner');
		$A.util.toggleClass(spinner, 'slds-hide');
    	//reinitialize the values from the case
    	component.set('v.typeError', false);
    	component.set('v.memberError', false);
    	component.set('v.descriptionError', false);
    	//component.set('v.addressError', false);
    	component.set('v.resolvedError', false);
    	component.set('v.bln_isError', false);
    	var isError = false;
    	
    	//get the values from the page
    	var typeChosen = component.get('v.typeChosen');
    	var memberChosen = component.get('v.memberChosen');
    	var addressChosen = component.get('v.addressChosen');
    	
    	if(typeChosen == ''){
    		component.set('v.typeError', true);
    		isError = true;
    	}
    	
    	if(memberChosen == ''){
    		component.set('v.memberError', true);
    		isError = true;
    	}
    	
    	/*if(addressChosen == ''){
    		component.set('v.addressError', true);
    		isError = true;
    	}*/
    	
    	if(isError){
    		window.scrollTo(0,0);
    		component.set('v.str_errorMsg', $A.get("$Label.c.Case_Required_Fields_Error") );
    		component.set('v.bln_isError', true);
    		var spinner = component.find('uploadSpinner');
			$A.util.toggleClass(spinner, 'slds-hide');
    		return;
    	}
    	
    	var paramMap = {'memberchosen' : memberChosen, 'casetype' : typeChosen, 'addressChosen' : addressChosen};
    	
    	helper.createCase(component, paramMap, null);
    },
    
    //save the case if the type is anything other than id card
    saveOtherCase : function(component, event, helper){
    	var spinner = component.find('uploadSpinner');
		$A.util.toggleClass(spinner, 'slds-hide');
    	//reinitialize the values from the case
    	component.set('v.typeError', false);
    	component.set('v.memberError', false);
    	component.set('v.descriptionError', false);
    	component.set('v.addressError', false);
    	component.set('v.resolvedError', false);
    	component.set('v.bln_isError', false);
    	
    	//get the values from the page
    	var typeChosen = component.get('v.typeChosen');
    	var memberChosen = component.get('v.memberChosen');
    	var description = component.find('casedescription').get('v.value');
    	var resolved = component.find('casedesired').get('v.value');
    	var fileInput = component.find("upFiles").getElement();
    	var isError = false;
    	
    	if(typeChosen == ''){
    		component.set('v.typeError', true);
    		isError = true;
    	}
    	
    	if(memberChosen == ''){
    		component.set('v.memberError', true);
    		isError = true;
    	}
    	
    	if(description == '' || description == undefined){
    		component.set('v.descriptionError', true);
    		isError = true;
    	}
    	
    	if(resolved == '' || resolved == undefined){
    		component.set('v.resolvedError', true);
    		isError = true;
    	}
    	if(isError){
    		window.scrollTo(0,0);
    		component.set('v.str_errorMsg', $A.get("$Label.c.Case_Required_Fields_Error") );
    		component.set('v.bln_isError', true);
    		var spinner = component.find('uploadSpinner');
			$A.util.toggleClass(spinner, 'slds-hide');
    		return;
    	}
    	var paramMap = {'memberchosen' : memberChosen, 'casetype' : typeChosen, 'description':description, 'resolved' : resolved};
    	if(fileInput.files.length > 0){
	    	var MAX_FILE_SIZE = 750000; /* 1 000 000 * 3/4 to account for base64 */
	    	var file = fileInput.files[0];
	    	console.log('fileName::'+file.name + ': '+ file.size);
	   
	        if (file.size > MAX_FILE_SIZE) {
	        	component.set('v.str_errorMsg', $A.get("$Label.c.File_Case_File_Size_Error") );
	        	component.set('v.bln_isError', true);
	        	var spinner = component.find('uploadSpinner');
	        	$A.util.toggleClass(spinner, 'slds-hide');
	        	window.scrollTo(0,0);
	    	    return;
	        }
	        //.xlsx,.xls,image/*,.doc, .docx,.ppt, .pptx,.txt,.pdf
	        
	        console.log('fileType::'+file.type);
	        if( !(file.type.includes('.xlsx') || file.type.includes('xls') || file.type.includes('.csv') || file.type.includes('.doc') || 
	        		file.type.includes('pdf') || file.type.includes('msword') || file.type.includes('.ppt') || file.type.includes('.pptx') || 
	        		file.type.includes('text') || file.type.includes('image/')|| file.type.includes('.sheet')|| file.type.includes('excel') ) ){
	        		
	        	component.set('v.str_errorMsg', $A.get("$Label.c.File_Case_Type_Acceptable") );
	        	component.set('v.bln_isError', true);
	        	var spinner = component.find('uploadSpinner');
	        	$A.util.toggleClass(spinner, 'slds-hide');
	        	window.scrollTo(0,0);
	        	return;
	        }
        	helper.createCase(component, paramMap, file);
        }
        else{
        	helper.createCase(component, paramMap, null);
        }
    },
})