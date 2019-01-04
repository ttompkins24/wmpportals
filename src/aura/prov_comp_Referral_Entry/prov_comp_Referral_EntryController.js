({
	init : function(component, event, helper) {
        //console.log('### doing init...');
		var business_id = component.get('v.currentBusinessId');
        component.set('v.statePicklists', helper.getStatePicklists());
        var historySearchWrapper = { currentBusinessId : business_id, procedureCode : '', startDate : '', endDate : '' };  
        component.set('v.historySearchWrapper', historySearchWrapper);
        helper.initNewClaim(component, helper);
        helper.initializeSpecialtyOptions(component);
	},  

    refreshCheck : function(component,event,helper){
        component.set('v.runCheckAgain', true);
    },

    hideDisclaimer : function(component, event, helper) {
        component.set('v.hideDisclaimer', true);
    },

    showDisclaimer : function(component, event, helper) {
        component.set('v.hideDisclaimer', false);
    },

    hideReferralDisclaimer : function(component, event, helper) {
        component.set('v.hideReferralDisclaimer', true);
    },

    showReferralDisclaimer : function(component, event, helper) {
        component.set('v.hideReferralDisclaimer', false);
    },


    handleValueChange : function (component, event, helper) {
        // handle value change
        var claim = component.get('v.claim');
        var memberCoverage = component.get('v.memberCoverage');   

        //console.log('### value change: ' + JSON.stringify(claim));
        //console.log('### value mem cov: ' + JSON.stringify(memberCoverage));     

        if(event.getParam("value") && claim.Subscriber_ID__c != '' && !component.get('v.loadDraft')) {
            //console.log('### elig has run...');

            if(!claim.Id) {
                claim.Claim_Draft_Status__c = 'Draft';
                component.set('v.claim', claim);
                helper.validateClaim(component, helper, true); 
            }
        }
        component.set('v.loadDraft', false);
    },

	fixDate : function(component, event, helper) {
        helper.fixDate(component, event, helper);  
    },

	submitClaim : function(component, event, helper) {
		var claim = component.get('v.claim');
		claim.Claim_Draft_Status__c = 'Submitted';
		component.set('v.claim', claim);

		helper.validateClaim(component, helper);
	},

	findADentist : function(component, event, helper) {
        $A.createComponent('c:prov_comp_FAD_Modal', {
			"isModal" : "true" 
		}, function(newModal, status, errorMessage){
            if (status === "SUCCESS") {
            	var body = component.get("v.body");
            	body.push(newModal);
            	component.set('v.body', body);
            }
 		});
	},

	handleDentistPopulated : function(component, event, helper) {
		var claim = component.get('v.claim');

  		claim.Referral_Treating_Provider_Name__c = event.getParam('name');
  		claim.Referral_Treating_Provider_NPI_Number__c = event.getParam('npi');
  		claim.Service_Location_Phone__c = event.getParam('phone');
  		claim.Referral_Service_Location_Address__c = event.getParam('address');
  		claim.Referral_Treating_Provider_City__c = event.getParam('city');
  		claim.Referral_Treating_Provider_State__c = event.getParam('state');
  		claim.Referral_Treating_Provider_Zip__c = event.getParam('zip');

		component.set('v.claim', claim);
	},

	changeType : function(component, event, helper) {
		var sourceId = event.getSource().getLocalId();
		if(sourceId == 'referral') {
			component.find('interim').set('v.value', false);
			component.set('v.isReferral', true);
		} else {
			component.find('referral').set('v.value', false);
			component.set('v.isReferral', false);
		}
	},

    serviceLookupOpen: function(component, event, helper) {
        var claim = component.get('v.claim');
        if(claim && claim.Subscriber_ID__c) {
            $('#service-modal').attr('aria-hidden', false);
            $('#service-modal').addClass('slds-fade-in-open');
            $('.slds-backdrop').addClass('slds-backdrop--open');

            var business_id = component.get('v.currentBusinessId');
            var historySearchWrapper = { currentBusinessId : business_id, procedureCode : '', startDate : '', endDate : '' };  
            component.set('v.historySearchWrapper', historySearchWrapper);
            helper.searchServiceHistory(component, event, helper);

        }
    },
    serviceLookupClose: function(component, event, helper) {
        component.set('v.availableHistory', []);
        var business_id = component.get('v.currentBusinessId');
        var historySearchWrapper = {
            currentBusinessId : business_id,
            procedureCode : '',
            startDate : '',
            endDate : ''
        };
        component.set('v.historySearchWrapper', historySearchWrapper);
        $('#service-modal').attr('aria-hidden', true);
        $('#service-modal').removeClass('slds-fade-in-open');
        $('.slds-backdrop').removeClass('slds-backdrop--open');
    }, 



	submitAnotherClaim : function(component, event, helper) {
        var claim = component.get('v.claim');

        var servDate = new Date(claim.Service_Date__c);

        var mm = servDate.getUTCMonth()+1; 
        if (mm <= 9) {
            mm = '0' + mm;
        }

        var servDD = servDate.getUTCDate(); 
        if (servDD <= 9) {
            servDD = '0' + servDD;
        }

        var birthDate = new Date(claim.Subscriber_Birth_Date__c);

        var birthMM = birthDate.getUTCMonth()+1; 
        if (birthMM <= 9) {
            birthMM = '0' + birthMM;
        }
        
        var birthDD = birthDate.getUTCDate(); 
        if (birthDD <= 9) {
            birthDD = '0' + birthDD;
        }

        var memCov = {
            // 'FirstName__c' : claim.Subscriber_First_Name__c, 
            // 'LastName__c' : claim.Subscriber_Last_Name__c, 
            // 'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
            // 'SubscriberID__c' : claim.Subscriber_ID__c, 
            'providerId' : claim.Provider__c,
            'serviceLocationId' : claim.Service_Location__c,
            'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
            'planGuid' : claim.Plan_GUID__c
        };
        //console.log('memCov::'+memCov);
        localStorage[claim.Subscriber_ID__c] = JSON.stringify(memCov);
        
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({
            'pageName' : 'referral-entry?memId=' + claim.Subscriber_ID__c + '&memid=' + claim.Subscriber_ID__c
        });
        redirectEvent.fire();
	}, 

    dismissClaimSuccessModal : function(component, event, helper) {
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({ 'pageName' : 'referral-search' });
        redirectEvent.fire();
    },

	fixPhone : function(component) {
		//console.log('fixPhone start');
		var s = component.get('v.claim.Service_Location_Phone__c');
		//console.log('s: '+s);
		var s2 = (""+s).replace(/\D/g, '');
		//console.log('s2: ' +s2);
		var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
		//console.log('m: '+m);
		var fixedPhone = (!m) ? "" : "(" + m[1] + ") " + m[2] + "-" + m[3];
		component.set('v.claim.Service_Location_Phone__c', fixedPhone);
		//console.log('fixedPhone: '+fixedPhone);
		//console.log('fixPhone end');
	},

	
    //turns off the Claims page components and turns back on the Eligibility Check component
    swapComponents : function(component, event, helper){
    	component.set('v.showClaimsPage', false);
    },

})