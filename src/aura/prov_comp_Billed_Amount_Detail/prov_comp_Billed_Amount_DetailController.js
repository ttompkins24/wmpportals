({
	init : function(component, event, helper) {
		
		helper.getBilledAmount(component, component.get('v.params.id'));
		helper.getProvidersAndServiceLocations(component);
		
	},

	saveBilledAmount : function(component, event, helper) {
		var bName = component.get('v.billedAmountName');

		if(bName == undefined || bName == null || bName == ''){
			hasError=true;
			component.find('billedAmountName').set('v.errors', [{message : 'Field is required'}]);
			helper.generateMessage(component, 'error', "Name is a required field.");
			return;
		}
		helper.saveBilledAmount(component);
	},  

	/*getServiceLocations : function(component, event, helper) {
		var ctarget = event.currentTarget;
    	var index = ctarget.dataset.index;
    	var billed_amount = component.get('v.billed_amount');
	},*/

	setLocation : function(component, event, helper) {
		/*//console.log('TODO: Set available providers');
		
		var target = event.getSource();
		var newValue = target.get('v.value');
		//console.log('newValue::'+newValue);
		var td = $(target).parent();
		var index = $(td).attr('data-index');
		
		var billedAmount = component.get('v.billed_amount');
		
		billedAmount.Billed_Amount_Associations__r[index].Service_Location__c = newValue;
		component.set('v.billed_amount', billedAmount);*/
	},

	setProvider : function(component, event, helper) {
		// set provider -> get available locations
		////console.log('TODO: Set available locations');
        /*var target = event.getSource();
		var newValue = target.get('v.value');
		//console.log('newValue::'+newValue);
		var td = $(target).parent();
		var index = $(td).attr('data-index');
		
		var billedAmount = component.get('v.billed_amount');
		
		billedAmount.Billed_Amount_Associations__r[index].Provider__c = newValue;
		component.set('v.billed_amount', billedAmount);*/
	},


	/**
	 * Save billed amount and do validation
	 */ 
	saveBilledAmountDetails : function(component, event, helper) {
		var billed_amount = component.get('v.billed_amount');
		////console.log('TODO: client-side validation');
		var hasError = false; 

		if(billed_amount.Name == ''){
			hasError=true;
			component.find('billedAmountName_id').set('v.errors', [{message : 'Field is required'}]);
			helper.generateMessage(component, 'error', "Name is a required field.");
		}else{
		// Labels
		// {!$Label.c.Invalid_Procedure_Code}
		// {!$Label.c.Duplicate_Procedure_Code}
		// {!$Label.c.No_Billed_Value}


		// // validate billed amount details
		var details = billed_amount.Billed_Amount_Details__r;
		if(details && details.length > 0) {
			var usedProcedureCodeIds = [];
			details.forEach(function(entry) {
				//console.log(entry.Procedure_Code__c );
				entry.hasErrorValue = false;
				entry.errorMessage = undefined;
				if(entry.Procedure_Code__c != '') {
					//console.log('billedValue::'+entry.Billed_Value__c);
					if(entry.Billed_Value__c == 0 || !entry.Billed_Value__c) {
						entry.hasErrorValue = true;
						entry.errorMessage = $A.get('$Label.c.No_Billed_Value');
						hasError = true;
						helper.generateMessage(component, 'error', $A.get('$Label.c.No_Billed_Value'));
						window.scrollTo(0,0);
					} else if(entry.Billed_Value__c < 0){
						//console.log('value if below 0');
						entry.hasErrorValue = true;
						entry.errorMessage = 'Value must be above 0';
						hasError = true;
						helper.generateMessage(component, 'error', 'Value must be above 0');
						window.scrollTo(0,0);
					}
					if(usedProcedureCodeIds.indexOf(entry.Procedure_Code__c) == -1) {
						usedProcedureCodeIds.push(entry.Procedure_Code__c);
					} else {
						entry.hasError = true;
						entry.errorMessage = $A.get('$Label.c.Duplicate_Procedure_Code');
						hasError = true;
						helper.generateMessage(component, 'error', $A.get('$Label.c.Duplicate_Procedure_Code'));
						window.scrollTo(0,0);
					}
				}
			});
		}
		billed_amount.Billed_Amount_Details__r = details;
		

		// validate build amount associations
		/*var associations = billed_amount.Billed_Amount_Associations__r;
		if(associations && associations.length > 0) {
			associations.forEach(function(entry) {

			});
		}*/

		component.set('v.billed_amount', billed_amount);


		if(!hasError) {
			helper.saveBilledAmountDetails(component);
		} else {
			//console.log('### has error!');
		}
		}
	}, 

	/** 
	 * Add a billed amount association
	 */
	addBilledAmountAssociation : function (component, event, helper) {
		helper.addBilledAmount_Association(component);
	},

	/**
	 * delete a billed amount association
	 */
	deleteAssociation : function(component, event, helper) {
		var confirmResponse = confirm('Are you sure you want to delete this Association?');
		if(confirmResponse){
			var ctarget = event.currentTarget;
	    	var index = ctarget.dataset.index;
	    	var value = ctarget.dataset.value;
	
	    	var billed_amount = component.get('v.billed_amount');
	    	billed_amount.Billed_Amount_Associations__r.splice(index, 1);
	
	    	for(i=0; i< billed_amount.Billed_Amount_Associations__r.length; i++){
				billed_amount.Billed_Amount_Associations__r[i].index = i;
			}
			component.set('v.billed_amount', billed_amount);
	
			// delete the record on the server
	    	if(value) {
	    		helper.deleteAssociation(component, value);
	    	}
	    } 
	},


	/**
	 * Add 5 billed amount details
	 */
	addBilledAmountDetail : function (component, event, helper) {
		helper.addBilledAmount_Detail(component);
	},

	/**
	 * Delete a billed amount detail
	 */
	deleteAmount : function(component, event, helper) {
		var confirmResponse = confirm('Are you sure you want to delete this Billed Amount?');
		if(confirmResponse){
			var ctarget = event.currentTarget;
	    	var index = ctarget.dataset.index;
	    	var value = ctarget.dataset.value;
	
	
	    	var billed_amount = component.get('v.billed_amount');
	    	var amount = billed_amount.Billed_Amount_Details__r.splice(index, 1);
	    	for(i=0; i< billed_amount.Billed_Amount_Details__r.length; i++){
				billed_amount.Billed_Amount_Details__r[i].index = i;
			}
			component.set('v.billed_amount', billed_amount);
	
			// Delete the record
	    	if(value) {
	    		helper.deleteAmount(component, value);
	    	} 
	    }
	},

	/**
	 * Query Procedure codes
	 */
	queryProcedureCode : function(component, event, helper) {
		////console.log('queryProcedureCode...');
		
		var billed_amount = component.get('v.billed_amount');
		var codeItem = event.getSource();
		var codeEntered = codeItem.get('v.value');
		var isError = false;
		
		var fullMap = {};
		billed_amount.Billed_Amount_Details__r.forEach(function(entry) {
		   if(entry.Procedure_Code__r && entry.Procedure_Code__r.Name != '' && entry.Procedure_Code__r.Name != undefined) {
			   ////console.log( entry.Procedure_Code__r.Name);
			   var procCode = entry.Procedure_Code__r.Name.toUpperCase();
			   if(fullMap[procCode] == null || fullMap[procCode] == undefined || fullMap[procCode] == ''){
				   fullMap[procCode] = 'entered value';
				   entry.hasError = false;
			   } else {
				   entry.hasError = true;
				   entry.Procedure_Code__r.Description__c = $A.get('$Label.c.Duplicate_Procedure_Code');
				   helper.generateMessage(component, 'error', $A.get('$Label.c.Duplicate_Procedure_Code'));
				   isError = true;
			   }
		   } else {
			   entry.hasError = false;
			   entry.Procedure_Code__r.Description__c = '';
		   }
		});
		component.set('v.billed_amount', billed_amount);
		if(!isError){            	
	        if(codeEntered && codeEntered.length > 0) {
	        	helper.getProcedureCode(component, codeEntered);
	        }
	    }
	},

	printPage : function(component, event, helper) {
		window.print();
	},
	
	backToSearchResults : function(component, event, helper){
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : 'billed-amount'

		});
        redirectEvent.fire();
	},
})