({
	doInit : function(component, event, helper) {
        //console.log('init start');
        helper.initializeOptions(component);
        helper.createReferralSearchHeader(component);
        //console.log('init end');
    },
    
    search : function(component, event, helper){  
        component.set('v.isError', false);
        var showResults = component.get('v.showResults');
        
        helper.updateReferralSearchHeader(component);
        component.set('v.showResults', !showResults);

        //console.log('selectedReferralStatus: '+component.get('v.selectedReferralStatus'));
        //console.log('selectedLocation: '+component.get('v.selectedLocation'));
        //console.log('selectedProvider: '+component.get('v.selectedProvider'));
	},
	
    clearSearchFields : function(component, event, helper) {
        var pageName = "referral-search";

        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({
            'pageName' : pageName,
            'memberProfileGuid' : null
        });
        redirectEvent.fire();
    },

    cleanUpInput: function(component, event) {
        var selectItem = event.getSource();
        var stringEntered = selectItem.get('v.value');
        selectItem.set('v.value',stringEntered.trim());
    },

    fixDate : function(component, event, helper) {
        helper.fixDate(component, event, helper);
    },

    setDisableClear : function(component, event) {
        component.set('v.disableClear', true);
        if(component.get('v.memberNumber') || component.get('v.memberLastName') ||
            component.get('v.memberFirstName') || component.get('v.referralNumber') ||
            component.get('v.memberDOB') || component.get('v.selectedReferralStatus') != 'All' || 
            component.get('v.selectedSpecialty') ||
            component.get('v.startReceivedDate') || component.get('v.endReceivedDate') ||
            component.get('v.selectedProvider') || component.get('v.selectedLocation')) {
            component.set('v.disableClear',false);
        }
    }
})