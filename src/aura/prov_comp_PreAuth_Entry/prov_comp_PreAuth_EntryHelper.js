({
    initNewClaim : function(component, helper) {
        var business_id = component.get('v.currentBusinessId');
        helper.getPicklistWrapper(component);
        var today = new Date();
        var todayStr = today.getFullYear() + "-" + (today.getMonth()+1) + "-" + today.getDate();
        
        // initialize a new claim wrapper           
        var claim = {
            Diagnosis_Code_A_Lookup__r : {},
            Diagnosis_Code_B_Lookup__r : {},
            Diagnosis_Code_C_Lookup__r : {},
            Diagnosis_Code_D_Lookup__r : {},
            Diagnosis_Code_A_Lookup__c : '',
            Diagnosis_Code_B_Lookup__c : '',
            Diagnosis_Code_C_Lookup__c : '',
            Diagnosis_Code_D_Lookup__c : '',
            Diagnosis_Code_A__c : '',
            Diagnosis_Code_B__c : '',
            Diagnosis_Code_C__c : '',
            Diagnosis_Code_D__c : '',

            Is_Accident__c : false,
            Place_of_Treatment__c : '',
            Has_ICD__c : false,
            Has_Other_Coverage__c : false,
            Service_Location__c : '',
            Provider__c : '',
            Service_Date__c : todayStr,
            Business__c : business_id,
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
                claim.Subscriber_Last_Name__c = eligData.LastName__c;
                claim.Subscriber_First_Name__c = eligData.FirstName__c;
                claim.Subscriber_Birth_Date__c = bd[2] + "-" + bd[0] + "-" + bd[1];

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
        //console.log('### claim: ' + JSON.stringify(claim));
        component.set('v.claim', claim);
        component.set('v.claimItems', []);
        component.set('v.finishedInit', true);
        
        component.set('v.isLoading', false);
    },

    deleteClaimItem : function(component, claimItemId) {
        var action = component.get("c.deleteClaimItemApex");
        var params = { claimItemId : claimItemId };  
        var helper = this;  

        $A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
  
        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue(); 
            } else {  
                //console.log('error');
            } 
        });

        $A.enqueueAction(action);
    },

    parseDraftClaim : function(component, claim, claimItems) {
        var business_id = component.get('v.currentBusinessId');
        //console.log('### parsing draft: ' + JSON.stringify(claimItems));
        //console.log('### parsing claim: ' + JSON.stringify(claim));

        // attach indexes
        for(var i = 0; i < claimItems.length; i++) {
            var claimItem = claimItems[i];
            claimItem.index = i;

            // Set defaults
            if(claimItem && claimItem.Procedure_Code_Lookup__r) {
                claimItem.Quad_Label = 'Quad';
                if(claimItem.Procedure_Code_Lookup__r.Is_Quad_Required__c) {
                    claimItem.Quad_Label = 'Quad*';
                }
                claimItem.Arch_Label = 'Arch';
                if(claimItem.Procedure_Code_Lookup__r.Is_Arch_Required__c) {
                    claimItem.Arch_Label = 'Arch*';
                }

            } else {
                claimItem.Quad_Label = 'Quad';
                claimItem.Arch_Label = 'Arch';
            }
            
            if(claimItem.Diagnosis_Code_A__c) {
                claimItem.has_code_a = true;
                claimItem.addICD = true;
            }

            if(claimItem.Diagnosis_Code_B__c) {
                claimItem.has_code_b = true;
                claimItem.addICD = true;
            }
            if(claimItem.Diagnosis_Code_C__c) {
                claimItem.has_code_c = true;
                claimItem.addICD = true;
            }
            if(claimItem.Diagnosis_Code_D__c) {
                claimItem.has_code_d = true;
                claimItem.addICD = true;
            }
        }

        component.set('v.claim', claim);
        component.set('v.claimItems', claimItems);
        component.set('v.showClaimsPage', true);
        component.set('v.finishedInit', true);
    },

    // Parse out draft claim
    getDraftClaim : function(component, claim_id) {
        var action = component.get("c.getDraftClaimApex");
        var businessId = component.get('v.currentBusinessId');
        var params = {
            claim_id : claim_id,
            businessId : businessId
        };  
        var helper = this;  

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();

                // if claim is not a draft, start a new claim
                if(data && data.claim && data.claim.Claim_Draft_Status__c == 'Submitted') {
                    component.set('v.claimNotFound', true);
                    helper.initNewClaim(component, helper);
                    return;
                } else if(!data || !data.claim || !data.claim.Id) {
                    component.set('v.claimNotFound', true);
                    helper.initNewClaim(component, helper);
                    return;
                } else if(data.hasError) {
                    component.set('v.claimNotFound', true);
                    helper.initNewClaim(component, helper);
                    return;
                }

                helper.parseDraftClaim(component, data.claim, data.claimItems);

                if(data.coverage) {
                    component.set('v.memberCoverage', data.coverage);
                }
                
                var claim = component.get('v.claim');
                
                window.setTimeout(
                    $A.getCallback(function() {
                        if(component.isValid()){
                            component.set('v.isLoading' , false);
                            var input = component.find("pos_input");
                            input.focus();
                        }
                    }), 300
                );
                helper.getPicklistWrapper(component);     
                //console.log('### got claim: ' + JSON.stringify(claim));
            } else {  
                component.set('v.claimNotFound', true);
                helper.initNewClaim(component, helper);
                //console.log('error');
            } 
        });

        $A.enqueueAction(action);
    },

    isValidDate : function(dateString) {
        var regEx = /^\d{4}-\d{2}-\d{2}$/;
        if(!dateString.match(regEx)) return false;  // Invalid format
        var d = new Date(dateString);
        if(!d.getTime() && d.getTime() !== 0) return false; // Invalid date
        return d.toISOString().slice(0,10) === dateString;
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

    getIcdCodes : function(component, searchWrapper) {
        var action = component.get("c.getIcdCodesApex");
        var helper = this;  

        action.setParams(searchWrapper); 

        action.setCallback(this, function(response) {
            var state = response.getState();    

            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                component.set('v.availableCodes', data);
                
                if(data.length == 0)
                	component.set('v.icdSearchResultsFound', false);
            } else {  
                //console.log('error');
            } 
        });

        $A.enqueueAction(action);
    },


    validateClaim : function(component, helper, fromEligibilitySearch) {
        component.set('v.claimIsSubmitted', false);
        component.set('v.claimSubmitErrorMessage', null);
        component.set('v.hasClaimItemsError', false);
        var claimItems = component.get('v.claimItems');

        for(var i = 0; i < claimItems.length; i++) {
            var claimItem = claimItems[i];
            claimItem.hasError = false;
            claimItem.errorLabel = '';
        }
        component.set('v.claimItems', claimItems);


        var hasErrors = false;
        var claim = component.get('v.claim');

        if(!claim.Is_Accident__c) {
            claim.Accident_Type__c = '';
            claim.Accident_State__c = '';
            claim.Accident_Date__c = '';
        }

        var placeOfServicePicklist = component.get('v.placeOfServicePicklist');
        for(var i = 0; i < placeOfServicePicklist.length; i++ ) {
            var entry = placeOfServicePicklist[i];
            if(entry.Code__c == claim.Place_of_Treatment__c) {
                //console.log('### found: ' + JSON.stringify(entry));
                claim.Place_of_Treatment_Desc__c = entry.Description__c;
                break;
            }
        }

        // do claim validations
        var validatedClaim = {};
        for (var key in claim) {
            // only add non-related fields
            if(key.indexOf('__r') == -1 && key != 'LastModifiedDate') {
                validatedClaim[key] = claim[key];
            }
        }

        if(claim.Claim_Draft_Status__c == 'Submitted' && claim.Place_of_Treatment__c == '') {
            component.set('v.claimIsSubmitted', true);
            component.set('v.claimSubmitErrorMessage', $A.get('$Label.c.Place_of_Treatment_Not_Entered'));
            hasErrors = true;
        }

        if(!claim.Subscriber_ID__c || claim.Subscriber_ID__c == '') {
            component.set('v.claimIsSubmitted', true);
            component.set('v.claimSubmitErrorMessage', $A.get('$Label.c.Locate_Member_prior_to_Claim_Submission'));
            hasErrors = true;
        }

        // Do claim line item validations
        var validatedClaimItems = [];

        if(fromEligibilitySearch) {
            claimItems = [];
        }        

        if(claimItems.length == 0 && !fromEligibilitySearch  && claim.Claim_Draft_Status__c == 'Submitted') {
            component.set('v.hasClaimItemsError', true);
            component.set('v.claimItemsErrorMessage', $A.get('$Label.c.Claim_Submittal_with_No_Service_Lines_entered'));
            hasErrors = true;
        } else {
            for(var i = 0; i < claimItems.length; i++) {
                var claimItem = claimItems[i];
                var validatedClaimItem = {};
                claimItem.hasError = false;

                if(!claimItem.Procedure_Code_Lookup__c || claimItem.Procedure_Code_Lookup__c == '') {
                    claimItem.hasError = true;
                    claimItem.errorLabel = $A.get('$Label.c.Enter_in_a_valid_Procedure_Code');
                } else if(!claimItem.Quantity__c || claimItem.Quantity__c == 0 || claimItem.Quantity__c > 32) {
                    claimItem.hasError = true;
                    claimItem.errorLabel = $A.get('$Label.c.Enter_a_quantity_0_or_32');
                } else if(claimItem.Procedure_Code_Lookup__r.Is_Surface_Required__c && claimItem.Surfaces__c == '') {
                    claimItem.hasError = true;
                    claimItem.errorLabel = $A.get('$Label.c.Surface_required');
                } else if(claimItem.Procedure_Code_Lookup__r.Is_Tooth_Required__c && claimItem.Tooth_Number__c == '') {
                    claimItem.hasError = true;
                    claimItem.errorLabel = $A.get('$Label.c.Tooth_required');
                } else if(claimItem.Procedure_Code_Lookup__r.Is_Quad_Required__c && claimItem.Quad__c == '') {
                    claimItem.hasError = true;
                    claimItem.errorLabel = $A.get('$Label.c.Quad_required');
                } else if(claimItem.Procedure_Code_Lookup__r.Is_Arch_Required__c && claimItem.Arch__c == '') {
                    claimItem.hasError = true;
                    claimItem.errorLabel = $A.get('$Label.c.Arch_required');
                }

                // attach icd diagnosis codes
                if(claimItem.has_code_a) {
                    claimItem.Diagnosis_Code_A__c = claim.Diagnosis_Code_A__c;
                    claimItem.Diagnosis_Code_A_Lookup__c = claim.Diagnosis_Code_A_Lookup__c;
                } else {
                    claimItem.Diagnosis_Code_A__c = '';
                    claimItem.Diagnosis_Code_A_Lookup__c = '';
                }
                if(claimItem.has_code_b) {
                    claimItem.Diagnosis_Code_B__c = claim.Diagnosis_Code_B__c;
                    claimItem.Diagnosis_Code_B_Lookup__c = claim.Diagnosis_Code_B_Lookup__c;
                } else {
                    claimItem.Diagnosis_Code_B__c = '';
                    claimItem.Diagnosis_Code_B_Lookup__c = '';
                }
                if(claimItem.has_code_c) {
                    claimItem.Diagnosis_Code_C__c = claim.Diagnosis_Code_C__c;
                    claimItem.Diagnosis_Code_C_Lookup__c = claim.Diagnosis_Code_C_Lookup__c;
                } else {
                    claimItem.Diagnosis_Code_C__c = '';
                    claimItem.Diagnosis_Code_C_Lookup__c = '';
                }
                if(claimItem.has_code_d) {
                    claimItem.Diagnosis_Code_D__c = claim.Diagnosis_Code_D__c;
                    claimItem.Diagnosis_Code_D_Lookup__c = claim.Diagnosis_Code_D_Lookup__c;
                } else {
                    claimItem.Diagnosis_Code_D__c = '';
                    claimItem.Diagnosis_Code_C_Lookup__c = '';
                }


                // only set errors if this is a submission
                if(claimItem.hasError && claim.Claim_Draft_Status__c != 'Draft') {
                    component.set('v.claimItems', claimItems);
                    hasErrors = true;
                }

                // Take out all the related fields not on the claim item object
                for (var key in claimItem) {
                    // only add non-related fields
                    if(key.indexOf('__c') > -1 
                        && key != 'index' 
                        && key != 'addICD' 
                        && key != 'addCOB' 
                        && key.indexOf('has_code') == -1 
                        && key.indexOf('Label') == -1) {
                        validatedClaimItem[key] = claimItem[key];
                    }

                    if(key == 'Id') {
                        validatedClaimItem[key] = claimItem[key];
                    }
                }
                validatedClaimItems.push(validatedClaimItem);
            }

        }
        

        if(hasErrors && claim.Claim_Draft_Status__c == 'Submitted') {
            window.scrollTo(0, 0);
            return;
        }

        if(hasErrors && (!claim.Subscriber_ID__c || claim.Subscriber_ID__c == '')) {
            window.scrollTo(0, 0);
            return;
        }

        helper.saveClaim(component, validatedClaim, validatedClaimItems, fromEligibilitySearch);
    },

    saveClaim : function(component, claim, claimItems, fromEligibilitySearch) {
        var action = component.get("c.saveClaimApex");
        var businessId = component.get('v.currentBusinessId');
        delete claim.Service_Date__c;

        var params = { 
            claim           : claim,
            claimItems      : $A.util.json.encode(claimItems),
            businessId      : businessId
        };

        //console.log('### save pre auth: ' + JSON.stringify(params));
        var helper = this;  

        $A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");

        //console.log('### claim params: ' + JSON.stringify(params));

        action.setParams(params);  
        action.setCallback(this, function(response) {
            $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-show");

            var state = response.getState();
            var data = response.getReturnValue();
            //console.log('###  data: ' + JSON.stringify(response.getReturnValue()));
            //console.log('###  state: ' + state);

            if(state === "SUCCESS"){    
                if(data) {
                    component.set('v.claimIsSubmitted', true);

                    if(data.hasError) {
                        

                        if(data.object_type == 'Claim') {
                            window.scrollTo(0,0);
                            component.set('v.claimSubmitErrorMessage', data.errorMessage);
                        } else if(data.object_type == 'Items') {
                            var claimItems = component.get('v.claimItems');
                            document.getElementById('services-header').scrollIntoView();

                            claimItems[data.errorIndex].hasError = true;
                            claimItems[data.errorIndex].errorLabel = data.errorMessage;
                            component.set('v.claimItems', claimItems);
                        } 
                    } else {
                        //console.log('### CLAIM SUCCESS: ' + JSON.stringify(data));
                        var claim = component.get('v.claim');
                        claim.Id = data.claim.Id;
                        claim.Claim_Draft_Status__c = data.claim.Claim_Draft_Status__c;
                        claim.Claim_Number__c = data.claim.Claim_Number__c;
                        claim.LastModifiedDate = new Date();
                        component.set('v.claim', claim);
                        
                        if(claim.Claim_Draft_Status__c == 'Draft') {
                            if(!fromEligibilitySearch) {
                                var redirectEvent = $A.get('e.c:prov_event_Redirect');
                                redirectEvent.setParams({
                                    'pageName' : 'pre-auth-entry?id=' + claim.Id + '&draft=1'
                                });
                                redirectEvent.fire();
                            } else {
                            	var input = component.find("pos_input");
                                input.focus()
                            }
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

    /**
     * Get procedure code and match to the proper billed amount detail.
     */
    getProcedureCode : function(component, codeEntered, claimItemIndex, targetId) {
        var action = component.get("c.getProcedureCodeApex");
        var claim = component.get('v.claim');

        var params = { 
            procedureCode : ''+codeEntered, 
            providerId : claim.Provider__c,  
            locationId: claim.Service_Location__c 
        };

        action.setParams(params);  

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                if(data && data.procedure_code && data.procedure_code.Id) {
                    var claimItems = component.get('v.claimItems');

                    var entry = claimItems[claimItemIndex];

                    $('#code' + claimItemIndex).val(data.procedure_code.Name);
                    entry.Procedure_Code__c = data.procedure_code.Name;
                    entry.Procedure_Code_Lookup__r = data.procedure_code;
                    entry.Procedure_Code_Lookup__c = data.procedure_code.Id;


                    if(data.billed_amount) {
                        entry.Billed_Amount__c = data.billed_amount.Billed_Value__c;
                    }

                    if(entry.Procedure_Code_Lookup__r.QTY__c) {
                        entry.Quantity__c = entry.Procedure_Code_Lookup__r.QTY__c;
                    }
                    
                    entry.hasError = false;

                    if(data.procedure_code.Is_Quad_Required__c) {
                        entry.Quad_Label = 'Quad*';
                    }

                    if(data.procedure_code.Is_Arch_Required__c) {
                        entry.Arch_Label = 'Arch*';
                    }

                    if(data.procedure_code.Is_Tooth_Required__c) {
                        $('.tooth-' + claimItemIndex).focus();
                    } else if(data.procedure_code.Is_Quad_Required__c) {
                        $('.quad-' + claimItemIndex).focus();
                    } else if(data.procedure_code.Is_Arch_Required__c) {
                        $('.arch-' + claimItemIndex).focus();
                    } else if(data.procedure_code.Is_Surface_Required__c) {
                        $('.surface-' + claimItemIndex).focus();
                    } else {
                        $('.quantity-' + claimItemIndex).focus();
                    }


                    component.set('v.claimItems', claimItems);
                } else {
                    var claimItems = component.get('v.claimItems');

                    claimItems[claimItemIndex].Procedure_Code__c = codeEntered;
                    claimItems[claimItemIndex].Procedure_Code_Lookup__r = {};
                    claimItems[claimItemIndex].Procedure_Code_Lookup__c = '';
                    claimItems[claimItemIndex].hasError = true;
                    claimItems[claimItemIndex].errorLabel = 'Procedure Code Not Found.';
                    component.set('v.claimItems', claimItems);
                }

            }
        });

        $A.enqueueAction(action);
    },

    getPicklistWrapper : function(component, event, helper) {
        var action = component.get("c.getPicklistValuesApex");
        var params = {};  
        var helper = this;  

        $A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
  
        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                //console.log('### got picklist...');

                component.set('v.placeOfServicePicklist', data.placeOfServicePicklist);
                component.set('v.isLoading', false);      
            } else {  
                //console.log('error');
            } 
        });
        $A.enqueueAction(action);
    }
})