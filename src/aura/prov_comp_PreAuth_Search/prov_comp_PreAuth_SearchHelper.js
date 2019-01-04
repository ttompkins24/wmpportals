({
	initializeOptions : function(component) {
        this.initializeAuthStatusOptions(component);
        this.initializeLocationOptions(component);
        this.initializeProviderOptions(component);
    },
    
    createAuthSearchHeader : function(component) {
        var authSearchHeader = component.get('v.authSearchHeader') || {};
        component.set('v.authSearchHeader', authSearchHeader);
    },

    updateAuthSearchHeader : function(component) {
        //console.log('updateAuthSearchHeader start');
        var authSearchHeader = component.get('v.authSearchHeader');
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        var businessid = component.get('v.currentBusinessId');// gets current business id   
        var businessGuid = providercache.businessMap[businessid].windward_guid__c;//gets the guid 
        
        authSearchHeader.BusinessGuid = businessGuid;
        authSearchHeader.ClaimType = 'AUTH';
        authSearchHeader.ReceivedDateStart = component.get('v.startSubmittedDate') || null;
        authSearchHeader.ReceivedDateEnd = component.get('v.endSubmittedDate') || null;
        authSearchHeader.StatusCategory = component.get('v.selectedAuthStatus');
        authSearchHeader.MemberFirstName = component.get('v.memberFirstName') || null;
        authSearchHeader.MemberLastName = component.get('v.memberLastName') || null;
        authSearchHeader.MemBirthDate = component.get('v.memberDOB') || null;
        authSearchHeader.MemberId = component.get('v.memberNumber') || null;
        authSearchHeader.ServiceOfficeGuids = component.get('v.selectedLocation') || null;
        authSearchHeader.TreatingDentistGuids = component.get('v.selectedProvider') || null;
        authSearchHeader.ClaimNumber = component.get('v.authNumber') || null;

        component.set('v.authSearchHeader', authSearchHeader);
        //console.log('authSearchHeader after update: '+JSON.stringify(component.get('v.authSearchHeader')));
        
        //console.log('updateAuthSearchHeader end');
    },

    initializeAuthStatusOptions : function(component) {
        var authStatusOptions = ["Adjudicated","All","Finalized","In Progress","Submitted","Void"];
        component.set('v.authStatusOptions', authStatusOptions);
        component.set('v.selectedAuthStatus', 'All'); 
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
        //console.log('currentBusinessId preAuthSearchHelper: '+currentBusinessId);
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
                //console.log('helper availableDentists: '+JSON.stringify(providerOptions));
            }
        });
        $A.enqueueAction(getAvailable);
    }
})