({
	addBilledAmount_Association : function(component){
		var billed_amount = component.get('v.billed_amount');
		if(billed_amount && !billed_amount.Billed_Amount_Associations__r) {
			billed_amount.Billed_Amount_Associations__r = [];
		}

		var providers = component.get('v.allProviders');
		var provider;
		if(providers && providers.length > 0) {
			provider = providers[0];
		}

		var locations = component.get('v.allLocations');
		var location;
		if(locations && locations.length > 0) {
			location = locations[0];
		}
		// add in dummy billed amount association
		billed_amount.Billed_Amount_Associations__r.push({
			"Billed_Amount__c": billed_amount.Id,
			"Provider__c" : 'ALL',
	        "Provider__r": {
	          "Name": ''
	        },
	        "Service_Location__c" : 'ALL',
	        "Service_Location__r": {
	          "Name": ''
	        },
	        "index" : billed_amount.Billed_Amount_Associations__r.length
	    });
	    ////console.log('### billed_amount: ' + JSON.stringify(billed_amount));

		component.set('v.billed_amount', billed_amount);
	},
	
	addBilledAmount_Detail : function(component){
		var billed_amount = component.get('v.billed_amount');
		if(billed_amount && !billed_amount.Billed_Amount_Details__r) {
			billed_amount.Billed_Amount_Details__r = [];
		}

		// add in dummy billed amounts
		for(var i = 0; i < 5; i++) {
			billed_amount.Billed_Amount_Details__r.push({
				"Billed_Amount__c": billed_amount.Id,
			    "Procedure_Code__c": "",
			    "Billed_Value__c" : '',
			    "Procedure_Code__r": {
			        "Name": "",
			        "Description__c": ""
			    },
			    "index" : billed_amount.Billed_Amount_Details__r.length
			});
		}

		component.set('v.billed_amount', billed_amount);
	},
	
	attachIndexes : function(component, data) {
		if(data) {
			if(data.billed_amount && data.billed_amount.Billed_Amount_Details__r && data.billed_amount.Billed_Amount_Details__r.length > 0) {
				data.billed_amount.Billed_Amount_Details__r.forEach(function(entry, index) {
					entry.index = index;
				});
			} 

			if(data.billed_amount && data.billed_amount.Billed_Amount_Associations__r && data.billed_amount.Billed_Amount_Associations__r.length > 0) {
				data.billed_amount.Billed_Amount_Associations__r.forEach(function(entry, index) {
					entry.index = index;
				});
			} 
		}
		return data;
	},
	deleteAssociation : function(component, associationId) {
        var billed_amount = component.get('v.billed_amount');
        var helper = this;
		var action = component.get("c.deleteAssociationApex");
		var params = {
			billed_amount : billed_amount,
			associationId : associationId
		};		

        action.setParams(params);  
        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();
	            helper.attachIndexes(component, data);
	            component.set('v.billed_amount', data.billed_amount);
	            component.set('v.business', data.business);
	        } else {  
	        	//console.log('error');
	        } 
	    });

	    $A.enqueueAction(action);
	},
	deleteAmount : function(component, amountId) {
		var billed_amount = component.get('v.billed_amount');
		var helper = this;
		var action = component.get("c.deleteAmountApex");
		var params = {
			billed_amount : billed_amount,
			amountId : amountId
		};
				
        action.setParams(params);  
        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();
	            helper.attachIndexes(component, data);
	            component.set('v.billed_amount', data.billed_amount);
	            component.set('v.business', data.business);
	        } else {  
	        	//console.log('error');
	        } 
	    });

	    $A.enqueueAction(action);

	},
	getBilledAmount : function(component, billedAmountId) {
		var helper = this;
		$A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
        //component.set('v.isLoading', true);
        var businessId = component.get('v.currentBusinessId');
        //console.log('businessId::'+businessId);
		var action = component.get("c.getBilledAmountApex");
		var params = { billedAmountId : billedAmountId,
		businessId : businessId };
		
        action.setParams(params);  

        action.setCallback(this, function(response) {
	        var state = response.getState();
            
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();
                ////console.log('data::'+JSON.stringify(data));
                component.set('v.business', data.business);
                
	            if(data.billed_amount == undefined || data.billed_amount == null || data.billed_amount == ''){
	            	if(component.get('v.params.id') != undefined)
	            		helper.generateMessage(component, 'error', $A.get('$Label.c.No_Billed_Amount_Found'));
	            	//component.set('v.isLoading', false);
	            }else{
	            	helper.attachIndexes(component, data);
	            	component.set('v.billed_amount', data.billed_amount);
	            	
	            	if(data.billed_amount && !data.billed_amount.Billed_Amount_Details__r) {
	            		this.addBilledAmount_Detail(component);
	            	}

	            	if(data.billed_amount && !data.billed_amount.Billed_Amount_Associations__r) {
	            		this.addBilledAmount_Association(component);
	            	}
	            	//component.set('v.isLoading', false);
	            }
	        } else {  
	        	//console.log('error');
	        } 
            
	        $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
            
	    });
		
	    $A.enqueueAction(action);
	},

	saveBilledAmount : function(component) {
		$A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
        //component.set('v.isLoading', true);
        var businessId = component.get('v.currentBusinessId');
		var action = component.get("c.saveBilledAmountApex");
		var params = { billedAmountName : component.get('v.billedAmountName'),
						'businessId' : businessId};
		

        action.setParams(params);  
        action.setCallback(this, function(response) {
	        var state = response.getState();
	        //console.log('state::'+state);
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();
	            component.set('v.billed_amount', data.billed_amount);
	            component.set('v.business', data.business);
	        } else {  
	        	//console.log('error');
	        } 
	        $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
	        //component.set('v.isLoading', false);
	    });

	    $A.enqueueAction(action);
	},


	saveBilledAmountDetails : function(component) {
		$A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
        //component.set('v.isLoading', true);
        var billed_amount = component.get('v.billed_amount');

        var helper = this;
        //console.log(JSON.stringify(billed_amount.Billed_Amount_Associations__r));
		var action = component.get("c.saveBilledAmountDetailsApex");
		var params = {
			billed_amount : billed_amount,
			billed_details : JSON.stringify(billed_amount.Billed_Amount_Details__r),
			billed_associations : JSON.stringify(billed_amount.Billed_Amount_Associations__r)
		};
		
        action.setParams(params);  

        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();

	            helper.attachIndexes(component, data);

	            component.set('v.billed_amount', data.billed_amount);
	            component.set('v.business', data.business);
	            helper.generateMessage(component, 'success', 'Billed Amount Saved.');
	            //component.set('v.isLoading', false);
	            window.scrollTo(0,0);
	        } else {  
	        	//component.set('v.isLoading', false);
	        	//console.log(response.getError() 	);
	        	
	        	//console.log('error::'+state);
	        } 
	        $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
	    });

	    $A.enqueueAction(action);
	},
/*
	getServiceLocations : function(component, providerId) {
		// find the selected provider, if it exists
		var action = component.get("c.getServiceLocationsApex");
		var params = { providerId : providerId };
        action.setParams(params);
        var helper = this;  

        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();

	            if(data && data.length > 0) {
	            	helper.getProviders(component, data[0].Id);
	            }
	            component.set('v.availableLocations', data);
	        } else {  
	        	//console.log('error');
	        } 
	    });

	    $A.enqueueAction(action);
	},

	getProviders : function(component, serviceLocationId, associationIndex) {
		// find the selected provider, if it exists
		var action = component.get("c.getProvidersApex");
		var params = { serviceLocationId : serviceLocationId };
        action.setParams(params);  

        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();
	            component.set('v.availableProviders', data);

	            // build a map for the providers available for this service location
	            var serviceLocationToProviderMap = component.get('v.serviceLocationToProviderMap');

	            if(!serviceLocationToProviderMap) {
	            	serviceLocationToProviderMap = {};
	            } 
	            serviceLocationToProviderMap[serviceLocationId] = data;
	            ////console.log('### setting providers: ' + JSON.stringify(serviceLocationToProviderMap));
	            component.set('v.serviceLocationToProviderMap', serviceLocationToProviderMap);
	        } else {  
	        	//console.log('error');
	        } 
	    });

	    $A.enqueueAction(action);
	},*/

	getProvidersAndServiceLocations : function(component) {
		var action = component.get("c.getLocationsAndProvidersApex");
        
        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();
                ////console.log('data::'+JSON.stringify(data));
	            component.set('v.allProviders', data.providers);
	            component.set('v.allLocations', data.locations);
	        } else {  
	        	//console.log('error');
	        }
	    });

	    $A.enqueueAction(action);
	},

	/**
	 * Get procedure code and match to the proper billed amount detail.
	 */
	getProcedureCode : function(component, codeEntered) {

		var action = component.get("c.getProcedureCodeApex");
		var params = { procedureCode : ''+codeEntered };
		////console.log('### running with params: ' + JSON.stringify(params));

        action.setParams(params);  

        action.setCallback(this, function(response) {
	        var state = response.getState();
	        var billed_amount = component.get('v.billed_amount');

	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();

	            if(data && data.length > 0) {
            		var procedure_code = data[0];
            		billed_amount.Billed_Amount_Details__r.forEach(function(entry) {
		            	if(entry.Procedure_Code__r && entry.Procedure_Code__r.Name.toUpperCase() == procedure_code.Name) {
		            		////console.log('entry.Procedure_Code__r.Name::'+entry.Procedure_Code__r.Name);
		            		entry.Procedure_Code__r = procedure_code;
		            		entry.Procedure_Code__c = procedure_code.Id;
		            	}
		            });
	            } else {
	            	//	error
	            	billed_amount.Billed_Amount_Details__r.forEach(function(entry) {
		            	if(entry.Procedure_Code__r && entry.Procedure_Code__r.Name.toUpperCase() == codeEntered.toUpperCase()) {
		            		entry.Procedure_Code__r.Description__c = '';
		            		entry.Procedure_Code__c = ''
		            	}
		            });
	            }
	        } else {  
	        	////console.log('error');
	        	billed_amount.Billed_Amount_Details__r.forEach(function(entry) {
	            	if(entry.Procedure_Code__r && entry.Procedure_Code__r.Name.toUpperCase() == codeEntered.toUpperCase()) {
	            		entry.Procedure_Code__r.Description__c = '';
	            		entry.Procedure_Code__c = '';
	            	}
	            });
	        } 
	        component.set('v.billed_amount', billed_amount);
	    });

	    $A.enqueueAction(action);
	}, 
	 /*
		Generate a message at the top of the screen. Accepts error and success as typeOfMessage and the message will be set based on the passed in info
	 */
	 generateMessage : function(component, typeOfMessage, message){
		 //reinitialize the message notifs
		 component.set('v.isSuccess', false);
		 component.set('v.isError', false);
		 
		 //remove the hide class on the elements (hide gets applied when a user clicks the close on the message
		 $('.errorMessageWrap').removeClass('hide');
		 $('.successMessageWrap').removeClass('hide');
		 
		 //if type is error
		 if(typeOfMessage == 'error'){
			 component.set('v.isError', true);
			 component.set('v.str_errorMsg', message);
		 } else if (typeOfMessage == 'success'){// type is success
			 component.set('v.isSuccess', true);
			 component.set('v.str_successMsg', message);
		 
		 }
	 }
})