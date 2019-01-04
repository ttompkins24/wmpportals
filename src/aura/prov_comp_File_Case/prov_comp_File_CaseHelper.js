({	
	retrieveCaseTypes : function(component) {
		component.set('v.showSpinner',true);
		var action = component.get('c.retrieveCaseTypeInfo');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resMap = response.getReturnValue();
				var caseList = [];
				
				for(var key in resMap) {
					if(resMap[key].Value != undefined){
						var obj = {'Value':resMap[key].Value, 'Label':resMap[key].Label, 'Description' : resMap[key].Description};
						
						caseList.push(obj);
					}
				}
				component.set('v.typeDescriptionList', caseList);
			}
			component.set('v.showSpinner',false);
		});
		$A.enqueueAction(action);
	},

	retrieveCaseSettingMap : function(component) {
		component.set('v.showSpinner',true);
		var action = component.get('c.retrieveCaseSettingMap');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				component.set('v.caseSettingMap', response.getReturnValue());
			}
			component.set('v.showSpinner',false);
		});
		$A.enqueueAction(action);
	},

	retrieveCaseFieldValues : function(component) {
		component.set('v.showSpinner',true);
		var action = component.get('c.retrieveCaseFieldValuesApex');

		action.setCallback(this,function(response) {
			var state = response.getState();
			if(state === "SUCCESS"){
				var result = response.getReturnValue();
				var timeList = [];
				var zoneList = [];
				var times = result['times'];
				var zones = result['zones'];

				for(var i=0;i<times.length;i++) {
					timeList.push({"class": "optionClass", label: times[i], value: times[i]});
				}
				for(var i=0;i<zones.length;i++) {
					zoneList.push({"class": "optionClass", label: zones[i], value: zones[i]});
				}
				component.set('v.timeList', timeList);
				component.set('v.zoneList', zoneList);
				//console.log('timeList: '+JSON.stringify(timeList));
				//console.log('zoneList: '+JSON.stringify(zoneList));
			}
			component.set('v.showSpinner',false);
		});
		$A.enqueueAction(action);
	},

	createCase : function(component, paramMap) {
		window.scrollTo(0,0);
		var action = component.get('c.createCaseApex');
		var existingCaseId = component.get('v.caseId') || null;
		
		//console.log('paramMap: '+JSON.stringify(paramMap));

        action.setParams({
			"paramMap" : paramMap,
			"caseSetting" : component.get('v.selectedCaseSetting'),
			"existingCaseId" : existingCaseId
        });

        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
				var result = response.getReturnValue();
				if(result != null) {
					component.set('v.bln_isSuccess', true);
					component.set('v.str_successMsg', $A.get('$Label.c.Case_Submission_Success_Body') + ' ' + result.CaseNumber);
					window.scrollTo(0,0);
					//console.log('success');

					//reset the attributes on the form
					this.resetFields(component,false);
				} else {
					window.scrollTo(0,0);
					component.set('v.str_errorMsg', $A.get("$Label.c.CreateCase_General_Error"));
					component.set('v.bln_isError', true);
				}
			} else {
				window.scrollTo(0,0);
				component.set('v.str_errorMsg', 'Unable to complete your request at this time. Please try again later.');
				component.set('v.bln_isError', true);
				//console.log('state error');
			}
			component.set('v.showSpinner', false);
		});
		
   		$A.enqueueAction(action);
	},

	createDraftCase: function(component, paramMap) {
		// update to save temporary case with correct status
        var action = component.get('c.createDraftCaseApex');  
		
        action.setParams({
			"paramMap" : paramMap,
			"caseSetting" : component.get('v.selectedCaseSetting')
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
				var result = response.getReturnValue();
				if(result != null) {
					component.set('v.caseId', result.Id);
					//console.log('success caseId: '+result.Id);
				} else {
					window.scrollTo(0,0);
					component.set('v.str_errorMsg', $A.get("$Label.c.CreateCase_General_Error"));
					component.set('v.bln_isError', true);
				}
			} else {
				window.scrollTo(0,0);				
				component.set('v.str_errorMsg', 'Unable to complete your request at this time. Please try again later.');
				component.set('v.bln_isError', true);
				//console.log('state error');
			}
			component.set('v.showSpinner', false);
        });

        $A.enqueueAction(action);
    },

	resetFields : function(component,fromChange) {
		// don't reset specific fields when changing request type (common fields)
		//console.log('resetting fields');
		if(!fromChange) {
			component.set('v.typeChosen', null);
			component.set('v.caseId', null);
			component.set('v.requestDesc', null);
			component.set('v.resultDesc', null);
			component.set('v.memberFirstName', null);
			component.set('v.memberLastName', null);
			component.set('v.memberNumber', null);
			component.set('v.resetPicklists', true);
		}
		// specifically reset these fields when request type is changed, as they are specific to certain case types
		component.set('v.claimAuthNumber', null);
		component.set('v.phoneNumber', null);
		component.set('v.contactDate', null);
		component.set('v.timeChosen', null);
		component.set('v.zoneChosen', null);
		//console.log('end resetting fields');
	},

	createParamMap : function(component) {
		var businessId = component.get('v.currentBusinessId');
		var typeChosen = component.get('v.typeChosen');
		var locationChosen = component.get('v.locationChosen');
		var providerChosen = component.get('v.providerChosen');
		var memberFirstName = component.get('v.memberFirstName') || null;
		var memberLastName = component.get('v.memberLastName') || null;
		var memberNumber = component.get('v.memberNumber') || null;
		var claimAuthNumber = component.get('v.claimAuthNumber');
		var requestDesc = component.get('v.requestDesc');
		var resultDesc = component.get('v.resultDesc');
		var phoneNumber = component.get('v.phoneNumber');
		var contactDate = component.get('v.contactDate');
		var timeChosen = component.get('v.timeChosen');
		var zoneChosen = component.get('v.zoneChosen');

		// using BLP picklist component, so we need to send the Id and not the object of the selected location/provider
		var locationId = null;
		var providerId = null;

		if(locationChosen) {
			locationId = locationChosen.Id;
		}
		if(providerChosen) {
			providerId = providerChosen.Id;
		}

		var paramMap = {
			'typeChosen' : typeChosen, 'businessId':businessId, 
			'locationChosen' : locationId, 'providerChosen':providerId, 
			'memberFirstName' : memberFirstName, 'memberLastName':memberLastName, 
			'memberNumber':memberNumber, 'claimAuthNumber':claimAuthNumber, 
			'requestDesc':requestDesc, 'resultDesc':resultDesc, 
			'phoneNumber':phoneNumber, 'contactDate':contactDate,
			'timeChosen':timeChosen,'zoneChosen':zoneChosen};

		//console.log('paramMap: '+JSON.stringify(paramMap));
		
		return paramMap;
	},

	validateEntry : function(component) {
		var businessId = component.get('v.currentBusinessId');
		var typeChosen = component.get('v.typeChosen');
		var locationChosen = component.get('v.locationChosen');
		var providerChosen = component.get('v.providerChosen');
		var memberFirstName = component.get('v.memberFirstName') || null;
		var memberLastName = component.get('v.memberLastName') || null;
		var memberNumber = component.get('v.memberNumber') || null;
		var claimAuthNumber = component.get('v.claimAuthNumber');
		var requestDesc = component.get('v.requestDesc');
		var resultDesc = component.get('v.resultDesc');
		var phoneNumber = component.get('v.phoneNumber');
		var contactDate = component.get('v.contactDate');
		var timeChosen = component.get('v.timeChosen');
		var zoneChosen = component.get('v.zoneChosen');
		
		var isError = false;		

		if(locationChosen == '' || locationChosen == null) {
			component.set('v.locationError', true);
			isError = true;
		}
		if(providerChosen == '' || providerChosen == null) {
			component.set('v.providerError', true);
			isError = true;
		}
		if(requestDesc == '' || requestDesc == null) {
			component.set('v.descriptionError', true);
			isError = true;
		}
		if(resultDesc == '' || resultDesc == null) {
			component.set('v.resultError', true);
			isError = true;
		}
		if((claimAuthNumber == '' || claimAuthNumber == null) && component.get('v.selectedCaseSetting.Show_Claim_Auth_Number__c')) {
			component.set('v.claimNumberError', true);
			isError = true;
		}
		if((phoneNumber == ''  || phoneNumber == null) && component.get('v.selectedCaseSetting.Show_Additional_Meeting_Info__c')) {
			component.set('v.phoneNumberError', true);
			isError = true;
		}
		if((contactDate == ''  || contactDate == null) && component.get('v.selectedCaseSetting.Show_Additional_Meeting_Info__c')) {
			component.set('v.contactDateError', true);
			isError = true;
		}
		if((timeChosen == ''  || timeChosen == null) && component.get('v.selectedCaseSetting.Show_Additional_Meeting_Info__c')) {
			component.set('v.timeChosenError', true);
			isError = true;
		}
		if((zoneChosen == ''  || zoneChosen == null) && component.get('v.selectedCaseSetting.Show_Additional_Meeting_Info__c')) {
			component.set('v.zoneChosenError', true);
			isError = true;
		}

		if(isError){
    		window.scrollTo(0,0);
    		component.set('v.str_errorMsg', $A.get("$Label.c.Case_Required_Fields_Error") );
			component.set('v.bln_isError', true);
			component.set('v.showSpinner', false);
		}
		return isError;
	},

	resetErrors : function(component) {
		component.set('v.locationError', false);
    	component.set('v.providerError', false);
    	component.set('v.claimNumberError', false);
    	component.set('v.phoneNumberError', false);
    	component.set('v.contactDateError', false);
    	component.set('v.timeChosenError', false);
    	component.set('v.zoneChosenError', false);
    	component.set('v.descriptionError', false);
    	component.set('v.resultError', false);
		component.set('v.bln_isError', false);
		component.set('v.bln_isSuccess', false);
	}
})