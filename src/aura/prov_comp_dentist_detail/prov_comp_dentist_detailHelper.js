({

    attachIndex : function(data) {
        data.forEach(function(entry, index) {
            entry.index = index;
        });
    },

    getExistingCase : function(component, providerId) {
        component.set('v.showSpinner',true);
        ////console.log(('providerId: '+providerId);
		var action = component.get('c.getExistingCaseApex');
		action.setParams({
            "currentBusinessId" : component.get('v.currentBusinessId'),
            "providerId" : providerId
		});

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result) {
                    component.set('v.hasExistingCase',true);
                }
			}
            component.set('v.showSpinner',false);
		});

		$A.enqueueAction(action);
    },

    formatDentistData : function(component, helper, data) {
        component.set('v.psl', data.psl);
        component.set('v.caseUpdate', data.caseUpdate);

        // break up specialties
        var specialties = [], specialty_values = [], hospitals = [], hospital_values = [];
        

        if(data.psl.Provider__r.Provider_Affiliation__c) {
            hospitals = data.psl.Provider__r.Provider_Affiliation__c.split(';');
            hospitals.forEach(function(entry, index) {
                var hospital = {
                    Name : entry, 
                    Location : 'Missing Value',
                    id : data.psl.Id,
                    index : index,
                    isDeleted : false, 
                    exists : true,
                    isNew : false
                }
                hospital_values.push(hospital);
            });
        }

        data.psl.treats_ages_to__c = '' + data.psl.treats_ages_to__c;
        data.psl.treats_ages_from__c = '' + data.psl.treats_ages_from__c;

        if(data.psl.is_accepting_new_patients__c) {
            data.psl.is_accepting_new_patients__c = 'Yes';
        } else {
            data.psl.is_accepting_new_patients__c = 'No';
        }

        if(data.psl.is_treating_special_needs_patients__c) {
            data.psl.is_treating_special_needs_patients__c = 'Yes';
        } else {
            data.psl.is_treating_special_needs_patients__c = 'No';
        }

        if(data.psl.Specialties__c) {
            specialties = data.psl.Specialties__c.split(';');
            specialties.forEach(function(entry, index) {
                var specialty = {
                    specialty : entry,
                    certification_status : data.psl.Provider__r.certification_status__c,
                    certification_date : data.psl.Provider__r.board_cert_date__c,
                    board_certified : data.psl.Provider__r.is_board_certified__c,
                    board_name : data.psl.Provider__r.board_cert_name__c,
                    id : data.psl.Id,
                    index : index,
                    isDeleted : false,
                    exists : true,
                    isNew : false
                };
                specialty_values.push(specialty);
            });
        }

        data.psl_networks.forEach(function(entry) {
            entry.net_name = entry.network__r.Name;
            entry.term_date = entry.termination_date__c;
            
            if(!entry.termination_date__c || entry.termination_date__c == '') {
                entry.term_date = '9999-01-01'
                entry.no_date = true;
            }
        });
        // break up hospitals
        helper.attachIndex(data.psl_networks);
        helper.attachIndex(data.provider_licenses);
        component.set('v.psl_networks', data.psl_networks);
        component.set('v.provider_licenses', data.provider_licenses);
        component.set('v.specialties', specialty_values);
        component.set('v.hospitals', hospital_values);
        component.set('v.other_locations', data.other_locations);

        
        // Create deep copies
        component.set('v.psl_updates', $.extend(true, {}, data.psl));
        component.set('v.specialties_updates', JSON.parse(JSON.stringify(specialty_values)));
        component.set('v.hospitals_updates',  JSON.parse(JSON.stringify(hospital_values)));
        component.set('v.psl_networks_updates', JSON.parse(JSON.stringify(data.psl_networks)));
        component.set('v.provider_licenses_updates', JSON.parse(JSON.stringify(data.provider_licenses)));

        // get the checked language options
        data.languagesPicklists.options.forEach(function(entry) {
            if(data.psl.Languages_Spoken__c && data.psl.Languages_Spoken__c.indexOf(entry.value) != -1) {
                entry.isChecked = true;
            }
        });
        component.set('v.languagePicklists', data.languagesPicklists.options);
        helper.getExistingCase(component, component.get('v.psl.Provider__r.Id'));
    },
    /**
     * Retreive dentist information
     */
    getDentist : function(component, psl_id) {
        var businessId = component.get('v.currentBusinessId');
        var action = component.get("c.getDentistApex");
        var params = {
            psl_id : psl_id,
            businessId : businessId
        };      
        var helper = this;
        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.showSpinner', true)
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                ////console.log(('### got dentist data: ' + JSON.stringify(data));
                if(data) {
                    component.set('v.total_psl_networks_page', Math.ceil(data.psl_networks.length / component.get('v.pageSize')));
                    component.set('v.total_psl_networks', data.psl_networks.length);
                    component.set('v.total_psl_networks_edit', data.psl_networks.length);
                    component.set('v.total_other_locations', data.other_locations.length);
                    component.set('v.total_other_locations_page', Math.ceil(data.other_locations.length / component.get('v.pageSize')));
                    helper.formatDentistData(component, helper, data);
                }
                component.set('v.isEdit', false);
                component.set('v.isLoading', false);
            } else {  
                //console.log(('error');
            } 

            
        });

        $A.enqueueAction(action);
    }, 
    
    saveDentistUpdate : function(component, psl_id, updateJSON, notes) {
        var action = component.get("c.saveDentistUpdateApex");
        var wrapperCase = component.get('v.newCaseWrapper');
        var business_id = component.get('v.currentBusinessId');
        var params = {
            psl_id : psl_id,
            updateJSON : updateJSON,
            notes : notes,
            business_id : business_id
        };  

        if(wrapperCase && wrapperCase.Id) {
            params.caseId = wrapperCase.Id;
        }
        var helper = this;  
        //console.log(('### saving dentist: ' + JSON.stringify(params));
        component.set('v.showSpinner', true)

        component.set('v.newCaseSaved', false);
        component.set('v.caseUpdate', null);
        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.showSpinner', false)
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                //console.log(('### case saved: ' + JSON.stringify(data));
                component.set('v.caseUpdate', data);
                helper.getDentist(component, psl_id); 
                component.set('v.isEdit', false);
                component.set('v.newCaseSaved', true);
                component.set('v.isLoading', false);   
                component.set('v.notes', '');   
                component.set('v.newCaseWrapper', null);
                component.set('v.map_psl_updates', {});
                window.scrollTo(0,0);
            } else {  
                //console.log(('error');
            } 
        });

        $A.enqueueAction(action);
    }, 

    submitWrapperCase: function(component) {
        var action = component.get("c.saveDentistWrapperApex");
        var business_id = component.get('v.currentBusinessId');
        var params = { 
            psl_id : component.get('v.params.id'),
            business_id : business_id
        };  
        var helper = this;  

        component.set('v.showSpinner', true)

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.showSpinner', false)
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();

                component.set('v.newCaseWrapper', data);   
            } else {  
                //console.log(('error');
            } 
        });

        $A.enqueueAction(action);
    }
})