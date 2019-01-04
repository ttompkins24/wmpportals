({
	doInit : function(component, event, helper) {
        //console.log('init start');
        helper.initializeOptions(component);
        helper.createAuthSearchHeader(component);

        var labelName = component.get('v.portalConfig.PreAuthorization_Label__c');
 		labelValue = $A.getReference('$Label.c.' + labelName);
 		
 		//console.log('pre auth label: ' + labelValue);

        component.set('v.preAuthLabel', labelValue);
         
        if(component.get('v.isHomepage') == true){
    		//console.log('in default tab section');
    		var defaultTab = component.get('v.currentContact.Default_Dashboard_Starter_Task__c');
    		//console.log('defaultTab ' + defaultTab);
    		if(defaultTab == 'preauthSearch'){
    			//console.log('marking as default tab');
    			component.set('v.defaultTab', true);
    		}
        }
        //console.log('init end');
    },
    
    search : function(component, event, helper){  
        component.set('v.isError', false);
        var showResults = component.get('v.showResults');
        
        helper.updateAuthSearchHeader(component);
        component.set('v.showResults', !showResults);

        //console.log('selectedAuthStatus: '+component.get('v.selectedAuthStatus'));
        //console.log('selectedLocation: '+component.get('v.selectedLocation'));
        //console.log('selectedProvider: '+component.get('v.selectedProvider'));
    },

    authDraftRedirect : function(component, event, helper) {
        var pageName = "pre-auth-drafts";

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
		component.find('startSubmittedDate').set('v.value','');
		component.find('endSubmittedDate').set('v.value','');
		component.find('authNumber').set('v.value','');
        component.set('v.locationDisplayedValue','');
        component.set('v.selectedLocation','');
        component.set('v.providerDisplayedValue','');
        component.set('v.selectedProvider','');
        component.set('v.selectedAuthStatus','All');
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
			tabName = 'preauthSearch';
		} else {
			tabName = '';
		}
		helper.setDefaultTab(component, tabName);
	},

    setDisableClear : function(component, event) {
        component.set('v.disableClear', true);
        if(component.get('v.memberNumber') || component.get('v.memberLastName') ||
            component.get('v.memberFirstName') || component.get('v.authNumber') ||
            component.get('v.memberDOB') || component.get('v.selectedAuthStatus') != 'All' || 
            component.get('v.startSubmittedDate') || component.get('v.endSubmittedDate') ||
            component.get('v.selectedProvider') || component.get('v.selectedLocation')) {
            component.set('v.disableClear',false);
        }
    }
})