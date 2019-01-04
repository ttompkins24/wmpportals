({
	doInit : function(component, event, helper) {
		helper.picklistYears(component);
	},
	
	/**************************************************************************************************************
     * Method Name							: verifyMember
     * Developed By							: Todd Tompkins
     * Purpose								: gather the fields needed to verify, check they are all populated then check the object to see if
												that member plan exists, if so create the member verification record and continue to the success message
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Todd Tompkins(WMP)		See header - purpose

    ***************************************************************************************************************/
	verifyMember : function(component, event, helper){
		var hasError = false;
		component.set('v.bln_isError', false);
		component.set('v.memFirstNameError', false);
		component.set('v.memLastNameError', false);
		component.set('v.memIdError', false);
		component.set('v.memDOBError', false);
		component.set('v.guardianFirstNameError', false);
		component.set('v.guardianLastNameError', false);
		
		//get first name of member and check if blank, if so shoot error out
		var memFName = component.find('memberFirstName').get("v.value");
		if(memFName === undefined || memFName == ''){
			hasError = true;
			component.set('v.memFirstNameError', true);
		}
		
		//get mem last name and check if blank, if so shoot error out
		var memLName = component.find('memberLastName').get("v.value");
		if(memLName === undefined || memLName == ''){
			hasError = true;
			component.set('v.memLastNameError', true);
		}
		
		//get date of month 
		var dobMonth = component.find('memberDOBMonth').get("v.value");
		//get dob of day 
		var dobDay = component.find('memberDOBDay').get("v.value");
		//get dob of year
		var dobYear = component.find('memberDOBYear').get("v.value");
		//check if any of the dob fields are blank
		if(dobMonth === undefined || dobMonth == '0' || dobDay === undefined || dobDay == '0' || dobYear === undefined || dobYear == '0' ){
			hasError = true;
			component.set('v.memDOBError', true);
		}
		
		//get member Id and check if blank, if so shoot error out
		var memId = component.find('memberId').get("v.value");
		if(memId === undefined || memId == ''){
			hasError = true;
			component.set('v.memIdError', true);
		}
		
		//get guardian first name and check if blank, if so shoot error out
		var guardianFName = component.find('guardianFirstName').get("v.value");
		if(guardianFName === undefined || guardianFName == ''){
			hasError = true;
			component.set('v.guardianFirstNameError', true);
		}
		
		//get guardian last name and check if blank, if so shoot error out
		var guardianLName = component.find('guardianLastName').get("v.value");
		if(guardianLName === undefined || guardianLName == ''){
			hasError = true;
			component.set('v.guardianLastNameError', true);
		}
		if(!hasError){
			var paramMap = {'memberId' : memId, 'dobDay' : dobDay, 'dobMonth' : dobMonth, 'dobYear' : dobYear, 
							'firstName' : memFName, 'lastName' : memLName, 'guardianFirstName' : guardianFName, 'guardianLastName' : guardianLName};
			var action = component.get('c.verifyGuardianMemberPlan');
			action.setParams({ 'paramMap' : paramMap});
			action.setCallback(this, function(response){
				if(response.getState() == 'SUCCESS'){
					var result = response.getReturnValue();
					
					if(result == 'Exists'){//user plan verification already exists
//						console.log('result::'+result);
						component.set('v.bln_isError', true);
						component.set('v.str_errorMsg', $A.get("$Label.c.Member_Add_Plan_Already_Exists") );
						window.scrollTo(0,0);
					} else if( result == 'Error'){
						component.set('v.bln_isError', true);
						component.set('v.str_errorMsg', $A.get("$Label.c.Member_Plan_Error_Message") );
						window.scrollTo(0,0);
					} else {//successful add
						var refreshCache = component.get('c.reloadCacheData');
						refreshCache.setCallback(this, function(response){
							if(response.getState() == 'SUCCESS'){
							}
						});
						$A.enqueueAction(refreshCache);
						component.set('v.nameAdded', result);
						component.set('v.successfulStep', 'self');
						
						//redirect to success message
						component.set('v.step', 'success');
					}
				}
			});
			$A.enqueueAction(action);
		} else {//there is an error display the error message
			component.set('v.bln_isError', true);
			component.set('v.str_errorMsg', $A.get("$Label.c.Error_message"));
			
			window.scrollTo(0,0);
		}
	},
	
	
	goBack : function(component, event, helper){
		component.set('v.step', 'selection');
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
        //For member first name 
        var memFName = component.find("memberFirstName").get("v.value");
        if(memFName != undefined){
            memFName = memFName.replace(/[^a-zA-Z0-9-. '']/g,"");
        	component.find("memberFirstName").set("v.value",memFName);
        }
        
        //For member last name
        var memLName = component.find("memberLastName").get("v.value");
         if(memLName != undefined){
            memLName = memLName.replace(/[^a-zA-Z0-9-. '']/g,"");
        	component.find("memberLastName").set("v.value",memLName);
         }
        
        //For member id
        var memberId = component.find("memberId").get("v.value");
        if(memberId != undefined){
            memberId = memberId.replace(/[^a-zA-Z0-9-. '']/g,'');
        	component.find("memberId").set("v.value",memberId);
        }

        
        //For guardian first name
        var guardianFName = component.find("guardianFirstName").get("v.value");
        if(guardianFName != undefined){
        	guardianFName = guardianFName.replace(/[^a-zA-Z0-9-. '']/g,'');
        	component.find("guardianFirst").set("v.value",guardianFName);
        }
        
        //For guardian last name
        var guardianLName = component.find("guardianLastName").get("v.value");
        if(guardianLName != undefined){
            guardianLName = guardianLName.replace(/[^a-zA-Z0-9-. '']/g,'');
        	component.find("guardianLastName").set("v.value",guardianLName);
        }

    },
})