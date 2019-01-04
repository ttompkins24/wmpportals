({
	//gets the values for the business picklist.  
	//If loading search criteria, it reloads the location and provider picklist
	doInit : function(component, event, helper) {
		//retrieve business for business picklist
		//helper.retrieveBusiness(component, event, helper);

		//console.log('blp init');
		
        //get the location and provider ids
        var params = component.get('v.params');
    	var locId = params.location;
        var provId = params.provider;
		helper.getServiceLocations(component, event, helper);
		////console.log(component.get('v.currentBusiness'));
		component.set("v.bizAcctRec", component.get('v.currentBusiness'));

        if(locId != null && locId != undefined){
        	component.find("locAccts").set("v.value",locId);
        	helper.getServiceLocationRecord(component, event, helper);

        }

        if(provId != null && provId != undefined){
	        component.find("provAccts").set("v.value",provId);
	        helper.getProviderRecord(component, event, helper);
        }
	 },

	locationChange : function(component, event, helper){
		//console.log('locationChange...'  );
		var locAcctRec = component.get("v.locAcctRec");
		var provAcctRec = component.get("v.provAcctRec");

		var existingId = component.find("locAccts").get("v.value");
		//console.log('existingId: '+existingId);
		if(locAcctRec != null && locAcctRec.Id != existingId){
			//console.log('get providers for::'+JSON.stringify(locAcctRec));
			component.find("locAccts").set("v.value", locAcctRec.Id);
		    helper.getServiceLocationRecord(component, event, helper);
		}
	},	
	providerChange : function(component, event, helper){
		//console.log('locationChange...'  );
		var provAcctRec = component.get("v.provAcctRec");

		var existingId = component.find("provAccts").get("v.value");
		//console.log('existingId: '+existingId);
		if(provAcctRec != null && provAcctRec.Id != existingId){
			//console.log('get providers for::'+JSON.stringify(provAcctRec));
			//console.log('IDpicklisdt  : ' + provAcctRec.Id);
			component.find("provAccts").set("v.value", provAcctRec.Id);
		    helper.getProviderRecord(component, event, helper);
		}
	},

	//retrieves Account record of selected service location
	updateLocSearch: function (component, event, helper) {
		// //console.log('updateLocSearch');
    	helper.getServiceLocationRecord(component, event, helper);
	},

	//retrieves Account record of selected Provider
	updateProvSearch: function (component, event, helper) {
    	helper.getProviderRecord(component, event, helper);
	},

	resetPicklistAction : function(component, event, helper){
		//console.log('resetPicklistAction...');
		var valChange = component.get('v.resetPicklists');
		
		if(valChange){
//			//console.log('1');
			component.set('v.provList', []);
			component.set('v.locList', []);
			component.find("provAccts").set("v.value", '');
			component.set('v.provAcctRec', null);
//			//console.log('2');
			component.set('v.locAcctRec', null);
			component.find("locAccts").set("v.value", '');
			helper.getServiceLocations(component, event, helper);
//			//console.log('3');
			component.set('v.resetPicklists', false);
		}
	},
})