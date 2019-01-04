({
	init : function(component, event, helper) {
        component.set('v.surfacePicklist', helper.getSurfacePicklist());
		var business_id = component.get('v.currentBusinessId');
		component.set('v.statePicklists', helper.getStatePicklists());

		var icdSearchWrapper = { codeType : 'ICD10', code : '', description : '' };
		component.set('v.icdSearchWrapper', icdSearchWrapper);
		var cobSearchWrapper = { payerName : '', policy : '', filterCode : '' };
		component.set('v.cobSearchWrapper', cobSearchWrapper);
        var historySearchWrapper = { currentBusinessId : business_id, procedureCode : '', startDate : '', endDate : '' };  
        component.set('v.historySearchWrapper', historySearchWrapper);

		if(component.get('v.params.id')) {
            component.set('v.loadDraft', true);
			helper.getDraftClaim(component, component.get('v.params.id'));
            if(component.get('v.params.draft') == 1) {
                component.set('v.draftSaved', true);
            }
		} else {
			helper.initNewClaim(component, helper);
            component.set('v.isLoading', false);
		}

	},

    icdSearchTab : function(component, event, helper) { 
        $('#icd-close').focus();
    },

    cobSearchTab : function(component, event, helper) { 
        $('#cob-close').focus();
    },

    checkNextRequired : function(component, event, helper) {
        var classes = event.getSource().get("v.class");
        var claimItemIndex, type; 

        if(classes.indexOf('tooth-') > -1) {
            claimItemIndex = classes.substring(classes.indexOf('tooth-') + 6, classes.length);
            type = 'tooth';
        } else if(classes.indexOf('quad-') > -1) {
            claimItemIndex = classes.substring(classes.indexOf('quad-') + 5, classes.length);
            type = 'quad';
        } else if(classes.indexOf('arch-') > -1) {
            claimItemIndex = classes.substring(classes.indexOf('arch-') + 5, classes.length);
            type = 'arch';
        }

        if(claimItemIndex) {
            var claimItems = component.get('v.claimItems');
            var procedure_code = claimItems[claimItemIndex].Procedure_Code_Lookup__r;

            if(type == 'tooth') {
                if(procedure_code.Is_Quad_Required__c) {
                    $('.quad-' + claimItemIndex).focus();
                } else if(procedure_code.Is_Arch_Required__c) {
                    $('.arch-' + claimItemIndex).focus();
                } else if(procedure_code.Is_Surface_Required__c) {
                    $('.surface-' + claimItemIndex).focus();
                } else {
                    $('.quantity-' + claimItemIndex).focus();
                }


            } else if(type == 'quad') {
                if(procedure_code.Is_Arch_Required__c) {
                    $('.arch-' + claimItemIndex).focus();
                } else if(procedure_code.Is_Surface_Required__c) {
                    $('.surface-' + claimItemIndex).focus();
                } else {
                    $('.quantity-' + claimItemIndex).focus();
                }

            } else if(type == 'arch') {
                if(procedure_code.Is_Surface_Required__c) {
                    $('.surface-' + claimItemIndex).focus();
                } else {
                    $('.quantity-' + claimItemIndex).focus();
                }
            }
        } 
    },

    selectBilledAmount : function(component, event, helper) {        
        event.currentTarget.select();
    },

    handleValueChange : function (component, event, helper) {
        // handle value change
        var claim = component.get('v.claim');
        var memberCoverage = component.get('v.memberCoverage');   


        if(event.getParam("value") && claim.Subscriber_ID__c != '' && !component.get('v.loadDraft')) {
            component.set('v.eligibilityHasRun', true);

            if(!claim.Id) {
                var claimItems = component.get('v.claimItems');
                if(claimItems && claimItems.length == 0) {
                    var item = {
                        Arch__c : "",
                        Diagnosis_Code_A__c : "",
                        Diagnosis_Code_B__c : "",
                        Diagnosis_Code_C__c : "",
                        Diagnosis_Code_D__c : "",
                        Diagnosis_Code_A_Lookup__c : "",
                        Diagnosis_Code_B_Lookup__c : "",
                        Diagnosis_Code_C_Lookup__c : "",
                        Diagnosis_Code_D_Lookup__c : "",
                        has_code_a : false,
                        has_code_b : false,
                        has_code_c : false,
                        has_code_d : false,
                        Line_Number__c : 0,
                        Billed_Amount__c : null,
                        Line_Status__c : "",
                        Quad_Label : "Quad",
                        Arch_Label : "Arch",
                        Surface_Label : 'Surface',
                        Procedure_Code_Lookup__r : {},
                        Message_Description__c : "",
                        Paid_Procedure_Code__c : "",
                        Procedure_Code__c : "",
                        Quad__c : "",
                        Quantity__c : 1,
                        Service_Date__c : claim.Service_Date__c,
                        Surfaces__c : "",
                        Tooth_Number__c : "",
                        addCOB : false,
                        addICD : false,
                        COB_Payer_Details__r : [],
                        index : 0
                    };

                    component.set('v.claimItems', [item]);
                }
                claim.Claim_Draft_Status__c = 'Draft';
                component.set('v.claim', claim);
                helper.validateClaim(component, helper, true); 
            }
        }
        component.set('v.loadDraft', false);
    },

	refreshCheck : function(component,event,helper){
		component.set('v.runCheckAgain', true);
	},


	/* ADD / DELETE LINE ITEMS */
	addIcdCobFromMenu : function(component, event, helper) {
		var selectedMenuItemValue = event.getParam("value");
		var claimItems = component.get('v.claimItems');
		var splitValue = selectedMenuItemValue.split(':');
		var index = splitValue[0];

		var item = claimItems[index];

		if(splitValue[1] == 'ICD') {
			item.addICD = true;
		} else {
			item.addCOB = true;
			var cob_line_item = {
				index : item.COB_Payer_Details__r.length,
				Payment_Date__c : '',
				Paid_Amount__c : null,
				COB_Other_Payer__c : ''
			};
			item.COB_Payer_Details__r.push(cob_line_item);
		}

		component.set('v.claimItems', claimItems);
	},

	deleteCOBLineItemClaim : function(component, event, helper) {
		var eventSource = event.target || event.srcElement;
 		var targetIndex = $(eventSource).closest("div").attr('data-value');
 		var itemIndex = $(eventSource).closest("div").attr('data-item-value');
 		var claimItems = component.get('v.claimItems');
 		claimItems[itemIndex].COB_Payer_Details__r.splice(targetIndex, 1);

 		for(var i = 0; i < claimItems[itemIndex].COB_Payer_Details__r.length; i++) {
 			claimItems[itemIndex].COB_Payer_Details__r[i].index = i;
 		}
 		component.set('v.claimItems', claimItems);
	},

	addServiceLineItem : function(component, event, helper) {
		var items = component.get('v.claimItems');
		var claim = component.get('v.claim');
		var item = {
			Arch__c : "",
			Diagnosis_Code_A__c : "",
			Diagnosis_Code_B__c : "",
			Diagnosis_Code_C__c : "",
			Diagnosis_Code_D__c : "",
            Diagnosis_Code_A_Lookup__c : "",
            Diagnosis_Code_B_Lookup__c : "",
            Diagnosis_Code_C_Lookup__c : "",
            Diagnosis_Code_D_Lookup__c : "",
			has_code_a : false,
			has_code_b : false,
			has_code_c : false,
			has_code_d : false,
			Line_Number__c : 0,
			Billed_Amount__c : null,
			Line_Status__c : "",
			Quad_Label : "Quad",
			Arch_Label : "Arch",
            Surface_Label : 'Surface',
			Procedure_Code_Lookup__r : {},
			Message_Description__c : "",
			Paid_Procedure_Code__c : "",
			Procedure_Code__c : "",
			Quad__c : "",
			Quantity__c : 1,
			Service_Date__c : claim.Service_Date__c,
			Surfaces__c : "",
			Tooth_Number__c	: "",
			addCOB : false,
			addICD : false,
			COB_Payer_Details__r : [],
			index : items.length
		};
		items.push(item);
		component.set('v.claimItems', items);

		//put the focus on the new service line. Put a window timeout to make sure the new components render on the page
		var codeVal = '#code'+item.index;
		window.setTimeout(
	        $A.getCallback(function() {
	            if(component.isValid()){
	                component.set('v.isLoading' , false);
	                $(codeVal).focus();
	            }
	        }), 300
	    );
	},  

	deleteServiceLineItem : function(component, event, helper) {
		var eventSource = event.target || event.srcElement;
 		var targetId = $(eventSource).closest("div").attr('data-target-index');
       // console.log('### target id: ' + targetId);
 		var claimItems = component.get('v.claimItems');

 		var item = claimItems[targetId];
 		if(item && item.Id) {
 			helper.deleteClaimItem(component, item.Id);
 		}
 		claimItems.splice(targetId, 1);

 		for(var i = 0; i < claimItems.length; i++) {
 			claimItems[i].index = i;
 		}
 		component.set('v.claimItems', claimItems);
	},

	addCOBLineItem : function(component, event, helper) {
		var cobPayerClaims = component.get('v.cobPayerClaims');
		var payerClaim = {
			Subscriber_First_Name__c : '',
			Subscriber_Birth_Date__c : '',
			Subscriber_ID__c : '',
			Group_ID__c : '',
			Subscriber_Last_Name__c : '',
			index: cobPayerClaims.length,
			hasError : false
		};

		cobPayerClaims.push(payerClaim);

		console.log('### cobPayerClaims: ' + JSON.stringify(cobPayerClaims));
		component.set('v.cobPayerClaims', cobPayerClaims);
		
		var codeVal = '#cob'+payerClaim.index;
		window.setTimeout(
	        $A.getCallback(function() {
	            if(component.isValid()){
	                $(codeVal).focus();
	            }
	        }), 300
	    );
	},

	deleteCOBLineItem : function(component, event, helper) {
		var eventSource = event.target || event.srcElement;
 		var targetId = $(eventSource).closest("div").attr('data-value');
 		var cobPayerClaims = component.get('v.cobPayerClaims');

 		var cobItem = cobPayerClaims[targetId];
 		var claimItems = component.get('v.claimItems');
 		console.log('### cobItem: ' + JSON.stringify(cobItem));
 		console.log('### claimItems: ' + JSON.stringify(claimItems));

		// loop through items and delete all cob payer details associated with this cob payer
		for(var i = 0; i < claimItems.length; i++) {
			var claimItem = claimItems[i];
			for(var j = 0; j < claimItem.COB_Payer_Details__r.length; j++) {
				var payer = claimItem.COB_Payer_Details__r[j];
				if(payer.COB_Other_Payer__c == cobItem.Payer_Name__c) {
					// delete from server
					if(payer.Id) {
						helper.deleteCobPayerItem(component, payer.Id);
					}
					claimItem.COB_Payer_Details__r.splice(j, 1);
				}
			}
		}	 		
 		if(cobItem && cobItem.Id) {
 			helper.deleteCobPayer(component, cobItem.Id);
 		} 
 		cobPayerClaims.splice(targetId, 1);
  
 		// re-do indexes
 		for(var i = 0; i < cobPayerClaims.length; i++) {
 			cobPayerClaims[i].index = i;
 		}

 		for(var i = 0; i < claimItems.length; i++) {
 			var claimItem = claimItems[i];
 			for(var j = 0; j < claimItem.COB_Payer_Details__r.length; j++) {
				claimItem.COB_Payer_Details__r[j].index = j;
			}
 		}
 		component.set('v.claimItems', claimItems);
 		component.set('v.cobPayerClaims', cobPayerClaims);
	},


	/* ICD ITEMS */
	clearIcd : function(component, event, helper) {
		var icdSearchWrapper = {
			codeType : 'ICD10',
			code : '',
			description : ''
		};
		component.set('v.icdSearchWrapper', icdSearchWrapper);
	},

	searchIcd : function(component, event, helper) {
		component.set('v.icdSearchError', false);
		component.set('v.icdSearchFoundResults', true);
		var icdSearchWrapper = component.get('v.icdSearchWrapper');
		if(icdSearchWrapper.code == '' && icdSearchWrapper.description == '') {
			component.set('v.icdSearchError', true);
			return;
		}
		var claim = component.get('v.claim');
		var icdIds = [];
		
		//get all the already selected icd codes
		if(claim.Diagnosis_Code_A_Lookup__c != undefined && claim.Diagnosis_Code_A_Lookup__c != ''){
			icdIds.push(claim.Diagnosis_Code_A_Lookup__c);
		}
		if(claim.Diagnosis_Code_B_Lookup__c != undefined && claim.Diagnosis_Code_B_Lookup__c != ''){
			icdIds.push(claim.Diagnosis_Code_B_Lookup__c);
		}
		if(claim.Diagnosis_Code_C_Lookup__c != undefined && claim.Diagnosis_Code_C_Lookup__c != ''){
			icdIds.push(claim.Diagnosis_Code_C_Lookup__c);
		}
		if(claim.Diagnosis_Code_D_Lookup__c != undefined && claim.Diagnosis_Code_D_Lookup__c != ''){
			icdIds.push(claim.Diagnosis_Code_D_Lookup__c);
		}
		icdSearchWrapper['existingIds'] = icdIds;
		helper.getIcdCodes(component, icdSearchWrapper);
	},

	selectICD : function(component, event, helper) {
		var eventSource = event.target || event.srcElement;
 		var targetId = $(eventSource).closest("td").attr('data-value');

 		var icdIndex = component.get('v.selected_icd_index');
 		var claim = component.get('v.claim');
 		var availableCodes = component.get('v.availableCodes');
 		var code;
 		availableCodes.forEach(function(entry) {
 			if(entry.Id == targetId) code = entry;
 		});


 		if(icdIndex == 1) {
 			claim.Diagnosis_Code_A_Lookup__r = code;
            claim.Diagnosis_Code_A__c = code.Code__c;
 			claim.Diagnosis_Code_A_Lookup__c = code.Id;
            $('#icdADelete').focus();
 		} else if(icdIndex == 2) {
 			claim.Diagnosis_Code_B_Lookup__r = code;
            claim.Diagnosis_Code_B__c = code.Code__c;
 			claim.Diagnosis_Code_B_Lookup__c = code.Id;
            $('#icdBDelete').focus();
 		} else if(icdIndex == 3) {
 			claim.Diagnosis_Code_C_Lookup__r = code;
            claim.Diagnosis_Code_C__c = code.Code__c;
 			claim.Diagnosis_Code_C_Lookup__c = code.Id;
            $('#icdCDelete').focus();
 		} else if(icdIndex == 4) {
 			claim.Diagnosis_Code_D_Lookup__r = code;
            claim.Diagnosis_Code_D__c = code.Code__c;
 			claim.Diagnosis_Code_D_Lookup__c = code.Id;
            $('#icdDDelete').focus();
 		}
 		component.set('v.claim', claim);
 		//console.log('### claim: ' + JSON.stringify(claim));

 		component.set('v.availableCodes', []);
        $('#icd-modal').attr('aria-hidden', true);
        $('#icd-modal').removeClass('slds-fade-in-open');
        $('.slds-backdrop').removeClass('slds-backdrop--open');
	},


	/* COB ITEMS */
	searchCob : function(component, event, helper) {
		var cobSearchWrapper = component.get('v.cobSearchWrapper');
		var cobPayerClaims = component.get('v.cobPayerClaims');
		
		var cobIds = [];
		for(var i in cobPayerClaims){
			if(cobPayerClaims[i].CodeSets__c != undefined && cobPayerClaims[i].CodeSets__c != ''){
				cobIds.push(cobPayerClaims[i].CodeSets__c);
			}
		}
		
		cobSearchWrapper['existingIds'] = cobIds;
		//console.log('### cob wrapper: ' + JSON.stringify(cobSearchWrapper));
		helper.getCobCodes(component, cobSearchWrapper);
	},

	selectCOB : function(component, event, helper) {
		var availableCobPayers = component.get('v.availableCobPayers');
		var selected_cob;
		var eventSource = event.target || event.srcElement;
 		var targetId = $(eventSource).closest("td").attr('data-value');

		availableCobPayers.forEach(function(entry) {
			if(entry.Id == targetId) { selected_cob = entry; }
		});

		var cobPayerClaims = component.get('v.cobPayerClaims');
		var selected_cob_index = component.get('v.selected_cob_index');
		var payer_claim = cobPayerClaims[selected_cob_index];
		payer_claim.Payer_Name__c = selected_cob.Description__c;
		payer_claim.CodeSets__c = selected_cob.Id;
		cobPayerClaims[selected_cob_index] = payer_claim;
		component.set('v.cobPayerClaims', cobPayerClaims);
		component.set('v.availableCobPayers', []);

        $('.cob-group-' + selected_cob_index).focus();

        $('#cob-modal').attr('aria-hidden', true);
        $('#cob-modal').removeClass('slds-fade-in-open');
        $('.slds-backdrop').removeClass('slds-backdrop--open');
	},

	clearCob : function(component, event, helper) {
		var cobSearchWrapper = {
			payerName : '',
			policy : '',
			filterCode : ''
		};
		component.set('v.cobSearchWrapper', cobSearchWrapper);
	},



	/* CHECKBOX DISPLAY ACTIONS */
	isCOB : function(component, event, helper) {
		var id = event.getSource().getLocalId();
        var claim = component.get('v.claim');

        // clear our icd codes
        if(id == 'cobSelect') {
			var payerClaim = {
				Subscriber_First_Name__c : '',
				Subscriber_Birth_Date__c : '',
				Subscriber_ID__c : '',
				Group_ID__c : '',
				Subscriber_Last_Name__c : '',
				index : 0
			};
			var cobPayerClaims = [payerClaim];
            claim.Has_Other_Coverage__c = true;
			component.set('v.cobPayerClaims', cobPayerClaims);
		} else {
			// clear payer claims and payer claims on claim items
			var claimItems = component.get('v.claimItems');
			for(var i = 0; i < claimItems.length; i++) {
				var claimItem = claimItems[i];
				claimItem.COB_Payer_Details__r = [];
			}
            claim.Has_Other_Coverage__c = false;
			component.set('v.claimItems', claimItems);
			component.set('v.cobPayerClaims', []);
		}
        component.set('v.claim', claim);
	},

	isAccident : function(component, event, helper) {
        var id = event.getSource().getLocalId();
        //console.log('### id: ' + id);
        var claim = component.get('v.claim');
        if(id == 'notAccidentSelect') {
            claim.Is_Accident__c = false;
        } else {
            claim.Is_Accident__c = true;
        }
        component.set('v.claim', claim);
    },

    isICD : function(component, event, helper) {
        var id = event.getSource().getLocalId();
        var claim = component.get('v.claim');

        // clear our icd codes
        if(id == 'notIcdSelect') {
            claim.Diagnosis_Code_A_Lookup__r = {};
            claim.Diagnosis_Code_B_Lookup__r = {};
            claim.Diagnosis_Code_C_Lookup__r = {};
            claim.Diagnosis_Code_D_Lookup__r = {};

            claim.Diagnosis_Code_A_Lookup__c = '';
            claim.Diagnosis_Code_B_Lookup__c = '';
            claim.Diagnosis_Code_C_Lookup__c = '';
            claim.Diagnosis_Code_D_Lookup__c = '';

            claim.Diagnosis_Code_A__c = '';
            claim.Diagnosis_Code_B__c = '';
            claim.Diagnosis_Code_C__c = '';
            claim.Diagnosis_Code_D__c = '';

            var claimItems = component.get('v.claimItems');
            for(var i = 0; i < claimItems.length; i++) {
                claimItem = claimItems[i];
                claimItem.has_code_a = false;
                claimItem.has_code_b = false;
                claimItem.has_code_c = false;
                claimItem.has_code_d = false;
                claimItem.Diagnosis_Code_A__c = '';
                claimItem.Diagnosis_Code_B__c = '';
                claimItem.Diagnosis_Code_C__c = '';
                claimItem.Diagnosis_Code_D__c = '';

                claimItem.Diagnosis_Code_A_Lookup__c = '';
                claimItem.Diagnosis_Code_B_Lookup__c = '';
                claimItem.Diagnosis_Code_C_Lookup__c = '';
                claimItem.Diagnosis_Code_D_Lookup__c = '';

                claimItem.addICD = false;
            }
            claim.Has_ICD__c = false;
            
            component.set('v.claimItems', claimItems);
        } else {
            claim.Has_ICD__c = true;
        }

        component.set('v.claim', claim);
        component.set('v.addICD', checkCmp.get('v.value'));
    },

	hideDisclaimer : function(component, event, helper) {
		component.set('v.hideDisclaimer', true);
	},

	showDisclaimer : function(component, event, helper) {
		component.set('v.hideDisclaimer', false);
	},

	/* MODAL ACTIONS */
    cobLookupOpen: function(component, event, helper) {
        component.set('v.availableCobPayers', null);
    	var eventSource = event.target || event.srcElement;
 		var targetId = $(eventSource).closest("div").attr('data-value');
 		component.set('v.selected_cob_index', targetId);
    	var cobSearchWrapper = { payerName : '', policy : '', filterCode : '' };
		component.set('v.cobSearchWrapper', cobSearchWrapper);

        $('#cob-modal').attr('aria-hidden', false);
        $('#cob-modal').addClass('slds-fade-in-open');
        $('.slds-backdrop').addClass('slds-backdrop--open');

        component.find('id-number').focus();

    },
    cobLookupClose: function(component, event, helper) {
    	component.set('v.availableCobPayers', []);
        $('#cob-modal').attr('aria-hidden', true);
        $('#cob-modal').removeClass('slds-fade-in-open');
        $('.slds-backdrop').removeClass('slds-backdrop--open');
        var cobIndex = component.get('v.selected_cob_index');
         $('.testScript_deleteCOBItem'+cobIndex).focus();
    },   


    deleteIcdA : function(component, event, helper) {
    	var claim = component.get('v.claim');
    	claim.Diagnosis_Code_A_Lookup__r = { 'Description__c' : ''};
    	claim.Diagnosis_Code_A__c = '';
        claim.Diagnosis_Code_A_Lookup__c = '';
    	var claimItems = component.get('v.claimItems');
    	for(var i = 0; i < claimItems.length; i++) {
    		claimItems[i].has_code_a = false;
    		claimItems[i].Diagnosis_Code_A__c = '';
            claimItems[i].Diagnosis_Code_A_Lookup__c = '';
    	}
    	component.set('v.claimItems', claimItems);
    	component.set('v.claim', claim);
    },

    deleteIcdB : function(component, event, helper) {
    	var claim = component.get('v.claim');
    	claim.Diagnosis_Code_B_Lookup__r = { 'Description__c' : ''};
        claim.Diagnosis_Code_B__c = '';
        claim.Diagnosis_Code_B_Lookup__c = '';
    	var claimItems = component.get('v.claimItems');
    	for(var i = 0; i < claimItems.length; i++) {
    		claimItems[i].has_code_b = false;
    		claimItems[i].Diagnosis_Code_B__c = '';
            claimItems[i].Diagnosis_Code_B_Lookup__c = '';
    	}
    	component.set('v.claimItems', claimItems);
    	component.set('v.claim', claim);
    },
    deleteIcdC : function(component, event, helper) {
    	var claim = component.get('v.claim');
    	claim.Diagnosis_Code_C_Lookup__r = { 'Description__c' : ''};
        claim.Diagnosis_Code_C__c = '';
        claim.Diagnosis_Code_C_Lookup__c = '';
    	var claimItems = component.get('v.claimItems');
    	for(var i = 0; i < claimItems.length; i++) {
    		claimItems[i].has_code_c = false;
    		claimItems[i].Diagnosis_Code_C__c = '';
            claimItems[i].Diagnosis_Code_C_Lookup__c = '';
    	}
    	component.set('v.claimItems', claimItems);
    	component.set('v.claim', claim);
    },
    deleteIcdD : function(component, event, helper) {
    	var claim = component.get('v.claim');
    	claim.Diagnosis_Code_D_Lookup__r = { 'Description__c' : ''};
        claim.Diagnosis_Code_D__c = '';
        claim.Diagnosis_Code_D_Lookup__c = '';
    	var claimItems = component.get('v.claimItems');
    	for(var i = 0; i < claimItems.length; i++) {
    		claimItems[i].has_code_d = false;
    		claimItems[i].Diagnosis_Code_D__c = '';
            claimItems[i].Diagnosis_Code_D_Lookup__c = '';
    	}
    	component.set('v.claimItems', claimItems);
    	component.set('v.claim', claim);
    },

    icdLookupOpen1 : function(component, event, helper) {
        //console.log('### lookup open...');
        component.set('v.selected_icd_index', 1);
        component.set('v.icdSearchError', false);
        var icdSearchWrapper = { codeType : 'ICD10', code : '', description : '' };
        component.set('v.icdSearchWrapper', icdSearchWrapper);
        $('#icd-modal').attr('aria-hidden', false);
        $('#icd-modal').addClass('slds-fade-in-open');
        $('.slds-backdrop').addClass('slds-backdrop--open');

        component.find("codeLookup").focus();
    },


    icdLookupOpen2 : function(component, event, helper) {
        //console.log('### focusing...');
    	component.set('v.selected_icd_index', 2);
    	component.set('v.icdSearchError', false);
    	var icdSearchWrapper = { codeType : 'ICD10', code : '', description : '' };
		component.set('v.icdSearchWrapper', icdSearchWrapper);
        $('#icd-modal').attr('aria-hidden', false);
        $('#icd-modal').addClass('slds-fade-in-open');
        $('.slds-backdrop').addClass('slds-backdrop--open');
        component.find("codeLookup").focus();
    },
    icdLookupOpen3 : function(component, event, helper) {
    	component.set('v.selected_icd_index', 3);
    	component.set('v.icdSearchError', false);
    	var icdSearchWrapper = { codeType : 'ICD10', code : '', description : '' };
		component.set('v.icdSearchWrapper', icdSearchWrapper);
        $('#icd-modal').attr('aria-hidden', false);
        $('#icd-modal').addClass('slds-fade-in-open');
        $('.slds-backdrop').addClass('slds-backdrop--open');
        component.find("codeLookup").focus();
    },
    icdLookupOpen4 : function(component, event, helper) {
    	component.set('v.selected_icd_index', 4);
    	component.set('v.icdSearchError', false);
    	var icdSearchWrapper = { codeType : 'ICD10', code : '', description : '' };
		component.set('v.icdSearchWrapper', icdSearchWrapper);
        $('#icd-modal').attr('aria-hidden', false);
        $('#icd-modal').addClass('slds-fade-in-open');
        $('.slds-backdrop').addClass('slds-backdrop--open');
        component.find("codeLookup").focus();
    },
    icdLookupClose: function(component, event, helper) {
    	component.set('v.availableCodes', []);
        $('#icd-modal').attr('aria-hidden', true);
        $('#icd-modal').removeClass('slds-fade-in-open');
        $('.slds-backdrop').removeClass('slds-backdrop--open');

        $('#code0').focus();
    },   

    serviceLookupOpen: function(component, event, helper) {
        var claim = component.get('v.claim');
        if(claim && claim.Subscriber_ID__c) {
            $('#service-modal').attr('aria-hidden', false);
            $('#service-modal').addClass('slds-fade-in-open');
            $('.slds-backdrop').addClass('slds-backdrop--open');

            var business_id = component.get('v.currentBusinessId');
            var historySearchWrapper = { currentBusinessId : business_id, procedureCode : '', startDate : '', endDate : '' };  
            component.set('v.historySearchWrapper', historySearchWrapper);
            helper.searchServiceHistory(component, event, helper);

        }
        component.find("service-from").focus();
    },
    serviceLookupClose: function(component, event, helper) {
        component.set('v.availableHistory', []);
        var business_id = component.get('v.currentBusinessId');
        var historySearchWrapper = {
            currentBusinessId : business_id,
            procedureCode : '',
            startDate : '',
            endDate : ''
        };
        component.set('v.historySearchWrapper', historySearchWrapper);
        $('#service-modal').attr('aria-hidden', true);
        $('#service-modal').removeClass('slds-fade-in-open');
        $('.slds-backdrop').removeClass('slds-backdrop--open');
    }, 

    searchServiceHistory: function(component, event, helper) {
        helper.searchServiceHistory(component, event, helper);
    },

    clearServiceHistory : function(component, event, helper) {
        var business_id = component.get('v.currentBusinessId');
        var historySearchWrapper = { currentBusinessId : business_id, procedureCode : '', startDate : '', endDate : '' };  
        component.set('v.historySearchWrapper', historySearchWrapper);

        helper.searchServiceHistory(component, event, helper);
    },


    /**
	 * Query Procedure codes
	 */
	queryProcedureCode : function(component, event, helper) {	
        var eventSource = event.target || event.srcElement;
        var targetId = $(eventSource).closest("div").attr('data-target-id');
        var claimItemIndex = targetId.split('-')[1];
        var codeEntered = $('#code' + claimItemIndex).val();

        //console.log('### codeEntered: ' + codeEntered);
        
        if(codeEntered && codeEntered.length > 0) {
            helper.getProcedureCode(component, codeEntered, claimItemIndex, targetId);
        }
	},

    fixDate : function(component, event, helper) {
    	helper.fixDate(component, event, helper);

        // find if this is service date
        var classes = event.getSource().get("v.class");

       //console.log('### classes: ' + classes);
        if(classes.indexOf('serv-date-') > -1) {
            var claimItemIndex = classes.substring(classes.indexOf('serv-date-') + 10, classes.length);
            var claimItems = component.get('v.claimItems');
            var procedure_code = claimItems[claimItemIndex].Procedure_Code_Lookup__r;
           // console.log('### index: ' + claimItemIndex);

            if(procedure_code.Is_Tooth_Required__c) {
                $('.tooth-' + claimItemIndex).focus();
            } else if(procedure_code.Is_Quad_Required__c) {
                $('.quad-' + claimItemIndex).focus();
            } else if(procedure_code.Is_Arch_Required__c) {
                $('.arch-' + claimItemIndex).focus();
            } else if(procedure_code.Is_Surface_Required__c) {
                $('.surface-' + claimItemIndex).focus();
            } else {
                // go to quantity
                $('.quantity-' + claimItemIndex).focus();
            }
        }
    },

	/* SERVER ACTIONS */
	submitClaim : function(component, event, helper) {
		var claim = component.get('v.claim');
		claim.Claim_Draft_Status__c = 'Submitted';
		component.set('v.claim', claim);
		helper.validateClaim(component, helper);
	},

	saveDraft : function(component, event, helper) {
		var claim = component.get('v.claim');
		claim.Claim_Draft_Status__c = 'Draft';
		component.set('v.claim', claim);
		helper.validateClaim(component, helper);
	},

    /* CLEAR ACTIONS */
	clearBasicInformation : function(component, event, helper) {
		var claim = component.get('v.claim');
		claim.Service_Date__c = '';
		claim.Provider__c = '';
		claim.Place_of_Treatment__c = '';
		claim.Service_Location__c = '';
		component.set('v.claim', claim);
	},
	

	dismissClaimSuccessModal : function(component, event, helper) {
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : 'claim-search'
		});
        redirectEvent.fire();
	},

	submitAnotherClaim : function(component, event, helper) {

        var claim = component.get('v.claim');

        var servDate = new Date(claim.Service_Date__c);

        var mm = servDate.getUTCMonth()+1; 
        if (mm <= 9) {
            mm = '0' + mm;
        }

        var servDD = servDate.getUTCDate(); 
        if (servDD <= 9) {
            servDD = '0' + servDD;
        }

        var birthDate = new Date(claim.Subscriber_Birth_Date__c);

        var birthMM = birthDate.getUTCMonth()+1; 
        if (birthMM <= 9) {
            birthMM = '0' + birthMM;
        }
        
        var birthDD = birthDate.getUTCDate(); 
        if (birthDD <= 9) {
            birthDD = '0' + birthDD;
        }

        var memCov = {
            // 'FirstName__c' : claim.Subscriber_First_Name__c, 
            // 'LastName__c' : claim.Subscriber_Last_Name__c, 
            // 'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
            // 'SubscriberID__c' : claim.Subscriber_ID__c, 
            'providerId' : claim.Provider__c,
            'serviceLocationId' : claim.Service_Location__c,
            'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
            'planGuid' : claim.Plan_GUID__c
        };
       // console.log('memCov::'+memCov);
        localStorage[claim.Subscriber_ID__c] = JSON.stringify(memCov);
        
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : 'claim-entry?memId=' + claim.Subscriber_ID__c + '&memid=' + claim.Subscriber_ID__c
		});
        redirectEvent.fire();
	},

    checkAlphasOffice : function(component, event, helper) {
        var claim = component.get('v.claim');
        claim.Office_Reference_Number__c = claim.Office_Reference_Number__c.replace(/[^a-z0-9]/gi,'');
        component.set('v.claim', claim);
    },

    checkAlphas : function(component, event, helper) {
        var claim = component.get('v.claim');
        claim.Referral_Number__c = claim.Referral_Number__c.replace(/[^a-z0-9]/gi,'');
        component.set('v.claim', claim);
    },

    //turns off the Claims page components and turns back on the Eligibility Check component
    swapComponents : function(component, event, helper){
    	component.set('v.showClaimsPage', false);
    },

})