({
	doInit : function(component, event, helper) {
		helper.picklistYears(component);
		helper.getUserFirstName(component);
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
		component.set('v.memIdError', false);
		component.set('v.memDOBError', false);

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
		
		
		if(!hasError){
			var paramMap = {'memberId' : memId, 'dobDay' : dobDay, 'dobMonth' : dobMonth, 'dobYear' : dobYear};
			var action = component.get('c.verifyMemberPlan');
			action.setParams({ 'paramMap' : paramMap});
			action.setCallback(this, function(response){
				if(response.getState() == 'SUCCESS'){
					var result = response.getReturnValue();
					
					if(result == 'Exists'){//user plan verification already exists
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
			component.set('v.str_errorMsg', $A.get("$Label.c.Member_Plan_Error_Message") );
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
        
        
        //For member id
        var memberId = component.find("memberId").get("v.value");
        if(memberId != undefined){
            memberId = memberId.replace(/[^a-zA-Z0-9-. '']/g,'');
        	component.find("memberId").set("v.value",memberId);
        }

       

    },
})