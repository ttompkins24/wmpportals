({
    initNewClaim : function(component, helper) {
        var business_id = component.get('v.currentBusinessId');
        var today = new Date();
        var todayStr = today.getFullYear() + "-" + (today.getMonth()+1) + "-" + today.getDate();
        
        // initialize a new claim wrapper           
        var claim = {
            Is_Accident__c : false,
            Place_of_Treatment__c : '',
            Has_ICD__c : false,
            Has_Other_Coverage__c : false,
            Service_Location__c : '',
            Provider__c : '',
            Service_Date__c : todayStr,
            Internal_Care_Transfer__c : true,
            Business__c : business_id,
            Type_of_Referral__c : 'E',
            Subscriber_Birth_Date__c  : '',
            Subscriber_First_Name__c : '',
            Subscriber_Last_Name__c : '',
            Subscriber_ID__c : '',
            Last_Eligibility_Check_Information__c : '',
            Last_Eligibility_Check__c : '', 
            Last_Eligibility_Status__c : '',
            Plan_Text__c : ''
        }

        if(localStorage[component.get('v.params.memid')]) {
            var eligData = JSON.parse(localStorage[component.get('v.params.memid')]);
            component.set('v.eligData', eligData);
            
            if(eligData && eligData.Birthdate__c) {
                var bd = eligData.Birthdate__c.split("/");
                claim.Subscriber_ID__c = eligData.SubscriberID__c;
                claim.Patient_Last_Name__c = eligData.LastName__c;
                claim.Patient_First_Name__c = eligData.FirstName__c;
                claim.Patient_Birth_Date__c = bd[2] + "-" + bd[0] + "-" + bd[1];
            }

            if(eligData && eligData.serviceDate) {
                var sd = eligData.serviceDate.split("/");
                claim.Service_Date__c = sd[2] + "-" + sd[0] + "-" + sd[1];
            }
            
            claim.Provider__c = eligData.providerId;
            claim.Service_Location__c = eligData.serviceLocationId;
            
            component.set('v.serviceLocationId', claim.Service_Location__c);
            component.set('v.providerId', claim.Provider__c);
            localStorage.removeItem(component.get('v.params.memid'));
        }

        //console.log('### init referral: ' + JSON.stringify(claim));
        component.set('v.claim', claim);
        component.set('v.finishedInit', true);        
        component.set('v.isLoading', false);
    },


    initializeSpecialtyOptions : function(component) {
        var action = component.get('c.retrieveSpecialtyOptions');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resMap = response.getReturnValue();
				var specialtyList = [];
				
				for(var key in resMap) {
					if(resMap[key].Value != undefined){
						var obj = {'Value':resMap[key].Value, 'Label':resMap[key].Label, 'Description' : resMap[key].Description};
						
						specialtyList.push(obj);
					}
				}
                //console.log('### specialtyOptions: ' + JSON.stringify(specialtyList));
				component.set('v.specialtyOptions', specialtyList);
			}
		});
		$A.enqueueAction(action);
    },

    validateClaim : function(component, helper, fromEligibilitySearch) {
        //console.log('### do validate1...');
        component.set('v.claimIsSubmitted', false);
        component.set('v.claimSubmitErrorMessage', null);
        component.set('v.hasRequestTypeError', false);
        component.set('v.requestTypeErrorMessage', '');
        component.set('v.hasProviderError', false);

        //console.log('### do validate...');
        var hasErrors = false;
        var claim = component.get('v.claim');

        //console.log('### claim: ' + JSON.stringify(claim));

        // do claim validations
        var validatedClaim = {};
        for (var key in claim) {
            // only add non-related fields
            if(key.indexOf('__r') == -1 && key != 'LastModifiedDate') {
                validatedClaim[key] = claim[key];
            }
        }

        if(!fromEligibilitySearch) {
            if(!claim.Internal_Care_Transfer__c && claim.Reason_for_Referral__c == 'Other') {
                if(!claim.Other_Reason_Description__c || claim.Other_Reason_Description__c == '') {
                    component.set('v.hasRequestTypeError', true);
                    component.set('v.requestTypeErrorMessage', $A.get('$Label.c.Other_Requires_Description'));
                    hasErrors = true;
                }
            }

            if(!claim.Internal_Care_Transfer__c && claim.Type_of_Referral__c == '') {
                component.set('v.hasRequestTypeError', true);
                component.set('v.requestTypeErrorMessage', $A.get('$Label.c.Type_Of_Referral_Null'));
                hasErrors = true;
            }
            if(!claim.Internal_Care_Transfer__c && claim.Requested_Specialty__c == '') {
                component.set('v.hasRequestTypeError', true);
                component.set('v.requestTypeErrorMessage', $A.get('$Label.c.Specialty_Null'));
                hasErrors = true;
            }
            if(!claim.Internal_Care_Transfer__c && claim.Remarks2__c == '') {
                component.set('v.hasRequestTypeError', true);
                component.set('v.requestTypeErrorMessage', $A.get('$Label.c.Reason_for_Referral_Null'));
                hasErrors = true;
            }

            if(claim.Internal_Care_Transfer__c && claim.Reason_for_Interim_Care_Transfer__c == '') {
                component.set('v.hasRequestTypeError', true);
                component.set('v.requestTypeErrorMessage', $A.get('$Label.c.Reason_For_ITC_Null'));
                hasErrors = true;
            }

            if(claim.Referral_Treating_Provider_Name__c == '' || claim.Referral_Treating_Provider_NPI_Number__c == '' ||
                claim.Referral_Service_Location_Address__c == '' || claim.Service_Location_Phone__c == ''  || claim.Referral_Treating_Provider_City__c == '' 
                 || claim.Referral_Treating_Provider_State__c == '' || claim.Referral_Treating_Provider_Zip__c == '') {
                component.set('v.hasProviderError', true);
                component.set('v.providerErrorMessage', $A.get('$Label.c.Enter_All_Provider_Fields'));
                hasErrors = true;
            }
        }
        
    

        if(hasErrors && claim.Claim_Draft_Status__c == 'Submitted') {
            window.scrollTo(0, 0);
            return;
        }
        //console.log('### validate claim: ' + JSON.stringify(claim));

        helper.saveClaim(component, validatedClaim, fromEligibilitySearch);
    },

    saveClaim : function(component, claim, fromEligibilitySearch) {
        var action = component.get("c.saveClaimApex");
        var businessId = component.get('v.currentBusinessId');
        delete claim.Service_Date__c;
        
        var params = { 
            claim           : claim,
            businessId      : businessId
        };

        var helper = this;  

        $A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
            var data = response.getReturnValue();

            //console.log('### got data: ' + JSON.stringify(data));

            if(state === "SUCCESS"){    
                component.set('v.isLoading', false);  

                if(data) {

                    if(data.hasError) {
                        component.set('v.claimIsSubmitted', true);
                        if(data.errors && data.errors.length > 0) {
                            component.set('v.claimSubmitErrorMessage', data.errors[0].error_message);
                        } else {
                            component.set('v.claimSubmitErrorMessage', data.errorMessage);
                        }
                        window.scrollTo(0,0); 
                    } else {
                        //console.log('### CLAIM SUCCESS: ' + JSON.stringify(data));
                        var claim = component.get('v.claim');
                        claim.Id = data.claim.Id;
                        claim.Claim_Number__c = data.claim.Claim_Number__c;
                        claim.LastModifiedDate = new Date();

                        component.set('v.claim', claim);

                        if(claim.Claim_Draft_Status__c == 'Draft') {
                            
                        } else {
                            // Pop success modal
                            $('#claim-submit-modal').attr('aria-hidden', false);
                            $('#claim-submit-modal').addClass('slds-fade-in-open');
                            $('.slds-backdrop').addClass('slds-backdrop--open');
                        }
                    }
                }
            } else {  
                //console.log('error: ' + JSON.stringify(response.getReturnValue()));
            } 
        });

        $A.enqueueAction(action);
    },

    searchServiceHistory : function(component, event, helper) {
        var action = component.get("c.searchServiceHistoryApex");
        var helper = this;  
        var params = component.get('v.historySearchWrapper');

        //console.log('### history: ' + JSON.stringify(component.get('v.historySearchWrapper')));

        function isValidDate(dateString) {
            var regEx = /^\d{4}-\d{2}-\d{2}$/;
            if(!dateString.match(regEx)) return false;  // Invalid format
            var d = new Date(dateString);
            if(!d.getTime() && d.getTime() !== 0) return false; // Invalid date
            return d.toISOString().slice(0,10) === dateString;
        }

        component.set('v.availableHistory', []);
        var claim = component.get('v.claim');
        component.set('v.isLoading', true);

        // only do the query if start we have valid dates or no dates at all
        if((isValidDate(params.endDate) || params.endDate == '') && (isValidDate(params.startDate) || params.startDate == '') && claim) {
            params.memberProfileGuid = claim.Patient_Member_Profile_GUID__c;

            $A.util.addClass(component.find("saving-backdrop"), "slds-show");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");

            //console.log('### doing search: ' + JSON.stringify(params));
            action.setParams(params); 

            action.setCallback(this, function(response) {
                var state = response.getState();    

                if(state === "SUCCESS"){    
                    var data = response.getReturnValue();
                    component.set('v.availableHistory', data);
                    
                } else {  
                    //console.log('error');
                } 
                component.set('v.isLoading', false);

                $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
                $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
            });

            $A.enqueueAction(action);
        }       
    },


})