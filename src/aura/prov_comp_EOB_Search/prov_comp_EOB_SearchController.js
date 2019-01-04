({
	doInit : function(component, event, helper) {
        console.log('init start');
        helper.initializePaymentStatusOptions(component);
        helper.createEOBSearchHeader(component);
        console.log('init end');
    },
    
    search : function(component, event, helper){  
        var showResults = component.get('v.showResults');
        
        helper.updateEOBSearchHeader(component);
        component.set('v.showResults', !showResults);
    },

    clearSearchFields : function(component, event, helper) {
        var pageName = "eob-search";

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
        if(component.get('v.checkNumber') || component.get('v.payerName') ||
            component.get('v.payeeName') || component.get('v.startReleasedDate') ||
            component.get('v.endReleasedDate') || component.get('v.selectedPaymentMethod') != 'All') {
            component.set('v.disableClear',false);
        }
    }
})