({
    initializeOptions : function(component) {
        this.initializeClaimStatusOptions(component);
        this.initializeLocationOptions(component);
        this.initializeProviderOptions(component);
    },
    
    createClaimSearchHeader : function(component) {
        var claimSearchHeader = component.get('v.claimSearchHeader') || {};
        component.set('v.claimSearchHeader', claimSearchHeader);
    },

    updateClaimSearchHeader : function(component) {
        ////console.log('updateClaimSearchHeader start');
        var claimSearchHeader = component.get('v.claimSearchHeader');
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        var businessid = component.get('v.currentBusinessId');// gets current business id   
        var businessGuid = providercache.businessMap[businessid].windward_guid__c;//gets the guid 
        
        claimSearchHeader.BusinessGuid = businessGuid;
        claimSearchHeader.ClaimType = 'CLAIM';
        claimSearchHeader.DateOfServiceStart = component.get('v.startServiceDate') || null;
        claimSearchHeader.DateOfServiceEnd = component.get('v.endServiceDate') || null;
        claimSearchHeader.StatusCategory = component.get('v.selectedClaimStatus');
        claimSearchHeader.MemberFirstName = component.get('v.memberFirstName') || null;
        claimSearchHeader.MemberLastName = component.get('v.memberLastName') || null;
        claimSearchHeader.MemBirthDate = component.get('v.memberDOB') || null;
        claimSearchHeader.MemberId = component.get('v.memberNumber') || null;
        claimSearchHeader.ServiceOfficeGuids = component.get('v.selectedLocation') || null;
        claimSearchHeader.TreatingDentistGuids = component.get('v.selectedProvider') || null;
        claimSearchHeader.ClaimNumber = component.get('v.claimNumber') || null;
        claimSearchHeader.ReceivedDateStart = component.get('v.startReceivedDate') || null;
        claimSearchHeader.ReceivedDateEnd = component.get('v.endReceivedDate') || null;

        component.set('v.claimSearchHeader', claimSearchHeader);
        ////console.log('claimSearchHeader after update: '+JSON.stringify(component.get('v.claimSearchHeader')));
        
        ////console.log('updateClaimSearchHeader end');
    },

    initializeClaimStatusOptions : function(component) {
        var claimStatusOptions = ["Adjudicated","All","Finalized","In Progress","Submitted","Void"];
        component.set('v.claimStatusOptions', claimStatusOptions);
        component.set('v.selectedClaimStatus', 'All'); 
    },

    initializeLocationOptions : function(component) {
        var locationOptions = [];
        //gets all available dentists for the business
        var getAvailable = component.get('c.getAllAvailableServiceLocations');
        var currentBusinessId = component.get('v.currentBusinessId');
        getAvailable.setParams({
            'currentBusinessId' : currentBusinessId
        });
        ////console.log('currentBusinessId: '+currentBusinessId);
        getAvailable.setCallback(this,function(response){
            var state = response.getState();
            var errors = response.getError();

            var returnedDentists = response.getReturnValue();
            // ////console.log(JSON.stringify(returnedDentists));

            if(errors) {
                if (errors[0] && errors[0].message) {
                    //console.log('initializeLocationOptions Error message: ' +
                            // errors[0].message);
                }
            } else {
                ////console.log('Unknown error');
            }

            ////console.log('initializeLocationOptions state: '+state);
            if(state === 'SUCCESS') {
                for(i = 0; i < returnedDentists.length; i++){
                    locationOptions.push(returnedDentists[i]);
                }
                component.set('v.locationOptions', locationOptions);
                // ////console.log('helper availableLocations: '+JSON.stringify(locationOptions));
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
        ////console.log('currentBusinessId claimSearchHelper: '+currentBusinessId);
        getAvailable.setCallback(this,function(response){
            var state = response.getState();
            var errors = response.getError();

            var returnedDentists = response.getReturnValue();
            // ////console.log(JSON.stringify(returnedDentists));

            if(errors) {
                if (errors[0] && errors[0].message) {
                    ////console.log('initializeProviderOptions Error message: ' +
                            // errors[0].message);
                }
            } else {
                ////console.log('Unknown error');
            }

            ////console.log('initializeProviderOptions state: '+state);
            if(state === 'SUCCESS') {
                for(i = 0; i < returnedDentists.length; i++){
                    providerOptions.push(returnedDentists[i]);
                }
                component.set('v.providerOptions', providerOptions);
                // ////console.log('helper availableDentists: '+JSON.stringify(providerOptions));
            }
        });
        $A.enqueueAction(getAvailable);
    }
})