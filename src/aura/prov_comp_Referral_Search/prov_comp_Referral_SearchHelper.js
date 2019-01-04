({initializeOptions : function(component) {
        this.initializeReferralStatusOptions(component);
        this.initializeLocationOptions(component);
        this.initializeProviderOptions(component);
        this.initializeSpecialtyOptions(component);
    },
    
    createReferralSearchHeader : function(component) {
        var referralSearchHeader = component.get('v.referralSearchHeader') || {};
        component.set('v.referralSearchHeader', referralSearchHeader);
    },

    updateReferralSearchHeader : function(component) {
        //console.log('updateReferralSearchHeader start');
        var referralSearchHeader = component.get('v.referralSearchHeader');
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        var businessid = component.get('v.currentBusinessId');// gets current business id   
        var businessGuid = providercache.businessMap[businessid].windward_guid__c;//gets the guid 
        
        referralSearchHeader.BusinessGuid = businessGuid;
        referralSearchHeader.SubmittedDateStart = component.get('v.startReceivedDate') || null;
        referralSearchHeader.SubmittedDateEnd = component.get('v.endReceivedDate') || null;
        referralSearchHeader.RequestStatus = component.get('v.selectedReferralStatus');
        referralSearchHeader.MemberFirstName = component.get('v.memberFirstName') || null;
        referralSearchHeader.MemberLastName = component.get('v.memberLastName') || null;
        referralSearchHeader.MemberDateOfBirth = component.get('v.memberDOB') || null;
        referralSearchHeader.MemberId = component.get('v.memberNumber') || null;
        referralSearchHeader.ServiceOfficeGuids = component.get('v.selectedLocation') || null;
        referralSearchHeader.SubmittingDentistGuids = component.get('v.selectedProvider') || null;
        referralSearchHeader.ReferralNumber = component.get('v.referralNumber') || null;
        referralSearchHeader.RequestedSpecialty = component.get('v.selectedSpecialty') || null;

        component.set('v.referralSearchHeader', referralSearchHeader);
        //console.log('referralSearchHeader after update: '+JSON.stringify(component.get('v.referralSearchHeader')));
        
        //console.log('updateReferralSearchHeader end');
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
				component.set('v.specialtyOptions', specialtyList);
			}
		});
		$A.enqueueAction(action);
    },

    initializeReferralStatusOptions : function(component) {
        var referralStatusOptions = ["All","Finalized","In Progress","Submitted","Void"];
        component.set('v.referralStatusOptions', referralStatusOptions);
        component.set('v.selectedReferralStatus', 'All'); 
    },

    initializeLocationOptions : function(component) {
        var locationOptions = [];
        //gets all available dentists for the business
        var getAvailable = component.get('c.getAllAvailableServiceLocations');
        var currentBusinessId = component.get('v.currentBusinessId');
        getAvailable.setParams({
            'currentBusinessId' : currentBusinessId
        });
        //console.log('currentBusinessId: '+currentBusinessId);
        getAvailable.setCallback(this,function(response){
            var state = response.getState();
            var errors = response.getError();

            var returnedDentists = response.getReturnValue();
            // //console.log(JSON.stringify(returnedDentists));

            if(errors) {
                if (errors[0] && errors[0].message) {
                    //console.log('initializeLocationOptions Error message: ' +
                            // errors[0].message);
                }
            } else {
                //console.log('Unknown error');
            }

            //console.log('initializeLocationOptions state: '+state);
            if(state === 'SUCCESS') {
                for(i = 0; i < returnedDentists.length; i++){
                    locationOptions.push(returnedDentists[i]);
                }
                component.set('v.locationOptions', locationOptions);
                // //console.log('helper availableLocations: '+JSON.stringify(locationOptions));
            }
        });
        $A.enqueueAction(getAvailable);
    },

    initializeProviderOptions : function(component) {
        var providerOptions = [];
        //gets all available dentists for the business
        var getAvailable = component.get('c.getAllAvailableDentists');
        var currentBusinessId = component.get('v.currentBusinessId');
        getAvailable.setParams({
            'currentBusinessId' : currentBusinessId
        });
        //console.log('currentBusinessId referralSearchHelper: '+currentBusinessId);
        getAvailable.setCallback(this,function(response){
            var state = response.getState();
            var errors = response.getError();

            var returnedDentists = response.getReturnValue();
            // //console.log(JSON.stringify(returnedDentists));

            if(errors) {
                if (errors[0] && errors[0].message) {
                    //console.log('initializeProviderOptions Error message: ' +
                            // errors[0].message);
                }
            } else {
                //console.log('Unknown error');
            }

            //console.log('initializeProviderOptions state: '+state);
            if(state === 'SUCCESS') {
                for(i = 0; i < returnedDentists.length; i++){
                    providerOptions.push(returnedDentists[i]);
                }
                component.set('v.providerOptions', providerOptions);
                // //console.log('helper availableDentists: '+JSON.stringify(providerOptions));
            }
        });
        $A.enqueueAction(getAvailable);
    }
})