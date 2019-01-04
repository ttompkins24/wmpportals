({
    doInit : function(component, event, helper) {
        //console.log('init start');
        helper.initializeOptions(component);
        helper.createClaimSearchHeader(component);

        if(component.get('v.isHomepage') == true){
            //console.log('in default tab section');
            var defaultTab = component.get('v.currentContact.Default_Dashboard_Starter_Task__c');
            //console.log('defaultTab ' + defaultTab);
            if(defaultTab == 'claimSearch'){
                //console.log('marking as default tab');
                component.set('v.defaultTab', true);
            }
        }
        
        //console.log('init end');
    },
    
    search : function(component, event, helper){  
        component.set('v.isError', false);
        var showResults = component.get('v.showResults');
        
        helper.updateClaimSearchHeader(component);
        component.set('v.showResults', !showResults);
        
        //console.log('selectedClaimStatus: '+component.get('v.selectedClaimStatus'));
        //console.log('selectedLocation: '+component.get('v.selectedLocation'));
        //console.log('selectedProvider: '+component.get('v.selectedProvider'));
    },

    claimDraftRedirect : function(component, event, helper) {
        var pageName = "claim-drafts";

        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({
            'pageName' : pageName,
            'memberProfileGuid' : null
        });
        redirectEvent.fire();
    },

    clearSearchFields : function(component, event, helper) {
        component.find('memberDOB').set('v.value','');
        component.find('memberNumber').set('v.value','');
        component.find('memberFirstName').set('v.value','');
        component.find('memberLastName').set('v.value','');
        component.find('startServiceDate').set('v.value','');
        component.find('endServiceDate').set('v.value','');
        component.find('claimNumber').set('v.value','');
        component.find('startReceivedDate').set('v.value','');
        component.find('endReceivedDate').set('v.value','');
        component.set('v.locationDisplayedValue','');
        component.set('v.selectedLocation','');
        component.set('v.providerDisplayedValue','');
        component.set('v.selectedProvider','');
        component.set('v.selectedClaimStatus','All');
        window.scrollTo(0,0);
    },

    cleanUpInput: function(component, event) {
        var selectItem = event.getSource();
        var stringEntered = selectItem.get('v.value');
        selectItem.set('v.value',stringEntered.trim());
    },

    fixDate : function(component, event, helper) {
        helper.fixDate(component, event, helper);
    },

    setDefaultTab :function (component, event, helper) {
        //console.log('time to set the default tab');
        var tabName;
        var defaultTab = component.get('v.defaultTab');
        //console.log('defaultTab ' + defaultTab);
        if(defaultTab == true){
            tabName = 'claimSearch';
        } else {
            tabName = '';
        }
        helper.setDefaultTab(component, tabName);
    },

    setDisableClear : function(component, event) {
        component.set('v.disableClear', true);
        if(component.get('v.memberNumber') || component.get('v.memberLastName') ||
            component.get('v.memberFirstName') || component.get('v.claimNumber') ||
            component.get('v.memberDOB') || component.get('v.selectedClaimStatus') != 'All' || 
            component.get('v.startServiceDate') || component.get('v.endServiceDate') ||
            component.get('v.startReceivedDate') || component.get('v.endReceivedDate') ||
            component.get('v.selectedProvider') || component.get('v.selectedLocation')) {
            component.set('v.disableClear',false);
        }
    }
})