({
    init : function(component, event, helper) {
        helper.getDentist(component, component.get('v.params.id'));
        component.set('v.map_psl_updates', {});
        
        var permissions = component.get('v.permissions');

        var ageRanges = [];
        for(var i = 0; i < 100; i++) {
            ageRanges.push(''+i);
        }
        component.set('v.filesList', []);
        component.set('v.ageRanges', ageRanges);
    },

    fieldChange :function (component,event,helper){
        var sourceField = event.getSource();
        var newValue = sourceField.get('v.value');
        var label = sourceField.get('v.label')

        var currentUpdateMap = component.get('v.map_psl_updates');
              
        //console.log(('currentUpdateMap: '+JSON.stringify(currentUpdateMap));

        currentUpdateMap[label] = newValue;
        
        component.set('v.map_psl_updates', currentUpdateMap);
    
        //console.log(('map_psl_updates: '+JSON.stringify(component.get('v.map_psl_updates')));
    },

    printPage : function(component, event, helper) {
        window.print();
    },

    previousNetworkPageClick : function(component, event, helper) {
        var pageNumNetwork = component.get('v.pageNumNetwork');
        pageNumNetwork = pageNumNetwork - 1;
        component.set('v.pageNumNetwork', pageNumNetwork);
    },

    nextNetworkPageClick : function(component, event, helper) {
        var pageNumNetwork = component.get('v.pageNumNetwork');
        pageNumNetwork = pageNumNetwork + 1;
        component.set('v.pageNumNetwork', pageNumNetwork);
    },


    previousOtherPageClick : function(component, event, helper) {
        var pageNumOther = component.get('v.pageNumOther');
        pageNumOther = pageNumOther - 1;
        component.set('v.pageNumOther', pageNumOther);
    },

    nextOtherPageClick : function(component, event, helper) {
        var pageNumOther = component.get('v.pageNumOther');
        pageNumOther = pageNumOther + 1;
        component.set('v.pageNumOther', pageNumOther);
    },

    previousNetworkEditPageClick : function(component, event, helper) {
        var pageNumNetworkEdit = component.get('v.pageNumNetworkEdit');
        pageNumNetworkEdit = pageNumNetworkEdit - 1;
        component.set('v.pageNumNetworkEdit', pageNumNetworkEdit);
    },

    nextNetworkEditPageClick : function(component, event, helper) {        
        var pageNumNetworkEdit = component.get('v.pageNumNetworkEdit');
        pageNumNetworkEdit = pageNumNetworkEdit + 1;
        component.set('v.pageNumNetworkEdit', pageNumNetworkEdit);
    },

    goToLocation : function(component, event, helper) {
        var currentTarget = event.currentTarget;
        var locId = currentTarget.dataset.targetid;
        var pageName = "service-office-detail?id=" + locId;
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({
            "pageName" : pageName,
            "id" : locId
        });
        redirectEvent.fire();
    },

    menuClick : function(component, event, helper){
        var currentTarget = event.currentTarget;
        $(currentTarget).toggleClass('checked');
        var newText = '';
        var psl_updates = component.get('v.psl_updates');
        $('.testClass.checked').each(function(index){
            newText += $(this).data('value') + '; ';
        });

        psl_updates.Languages_Spoken__c = newText;
        component.set('v.psl_updates', psl_updates);

        var currentUpdateMap = component.get('v.map_psl_updates');

        if(newText == ''){
            currentUpdateMap['Languages Spoken'] = 'Removed Languages Spoken';
        } else {
            currentUpdateMap['Languages Spoken'] = newText;
        }
        component.set('v.map_psl_updates', currentUpdateMap);
        //console.log(('map_psl_updates: '+JSON.stringify(component.get('v.map_psl_updates')));

        $('#actionTemp1').val(newText);
    },


    /* DELETE Actions */

    deleteLicense : function(component, event, helper) {
        var provider_licenses_updates = component.get('v.provider_licenses_updates');
        var currentTarget = event.currentTarget;
        var index = currentTarget.dataset.index;
        var provider_license = provider_licenses_updates[index];

        if(provider_license.Id) {
            if(provider_license.isDeleted) {
                provider_license.isDeleted = false;
            } else {
                provider_license.isDeleted = true;
            }
        } else {
            provider_licenses_updates.splice(index, 1);
            helper.attachIndex(provider_licenses_updates);
        }

        component.set('v.provider_licenses_updates', provider_licenses_updates);
    },


    deleteNetwork : function(component, event, helper) {
        var psl_networks_updates = component.get('v.psl_networks_updates');
        var currentTarget = event.currentTarget;
        var index = currentTarget.dataset.index;
        var psl_network = psl_networks_updates[index];

        if(psl_network.Id) {
            if(psl_network.isDeleted) {
                psl_network.isDeleted = false;
            } else {
                psl_network.isDeleted = true;
            }
        } else {
            psl_networks_updates.splice(index, 1);
            component.set('v.total_psl_networks_edit', Math.ceil(psl_networks_updates.length / component.get('v.pageSize')));
            helper.attachIndex(psl_networks_updates);
        }

        component.set('v.psl_networks_updates', psl_networks_updates);
    },

    deleteHospital : function(component, event, helper) {
        var hospitals_updates = component.get('v.hospitals_updates');
        var currentTarget = event.currentTarget;
        var index = currentTarget.dataset.index;
        var hospital = hospitals_updates[index];

        if(hospital.exists) {
            if(hospital.isDeleted) {
                hospital.isDeleted = false;
            } else {
                hospital.isDeleted = true;
            }
        } else {
            hospitals_updates.splice(index, 1);
            helper.attachIndex(hospitals_updates);
        }

        component.set('v.hospitals_updates', hospitals_updates);
    },
    deleteSpecialty : function(component, event, helper) {
        var specialties_updates = component.get('v.specialties_updates');
        var currentTarget = event.currentTarget;
        var index = currentTarget.dataset.index;
        var specialty = specialties_updates[index];
        if(specialty.exists) {
            if(specialty.isDeleted) {
                specialty.isDeleted = false;
            } else {
                specialty.isDeleted = true;
            }
        } else {
            specialties_updates.splice(index, 1);
            helper.attachIndex(specialties_updates);
        }

        component.set('v.specialties_updates', specialties_updates);
    },
    
    /* ADD Actions */
    addHospital : function(component, event, helper) {
        var hospitals = component.get('v.hospitals_updates');
        var hospital = { Name : '', Location : '', isNew : true, index : hospitals.length };
        hospitals.push(hospital);
        component.set('v.hospitals_updates', hospitals);
    },

    addSpecialty : function(component, event, helper) {
        var specialties_updates = component.get('v.specialties_updates');
        var psl = component.get('v.psl');

        var specialty = { 
            specialty : '', 
            certification_status : psl.Provider__r.certification_status__c, 
            certification_date : psl.Provider__r.board_cert_date__c,
            board_certified : psl.Provider__r.is_board_certified__c,
            board_name : psl.Provider__r.Board_Name__c,
            isNew : true,
            index : specialties_updates.length
        };
        specialties_updates.push(specialty);
        component.set('v.specialties_updates', specialties_updates);
    },

    addNetwork : function(component, event, helper) {
        var psl_networks_updates = component.get('v.psl_networks_updates');
        var psln = { 
            "is_accepting_new_patients__c": false,
            "index" : psl_networks_updates.length,
            "termination_date__c": "",
            "effective_date__c": "",
            "participation_status__c": "",
            "isNew" : true
        };
        psl_networks_updates.push(psln);
        component.set('v.total_psl_networks_edit', Math.ceil(psl_networks_updates.length / component.get('v.pageSize')));
        component.set('v.psl_networks_updates', psl_networks_updates);
    },

    addLicense : function(component, event, helper) {
        var provider_licenses_updates = component.get('v.provider_licenses_updates');
        var license = { 
            "index" : provider_licenses_updates.length,
            "license_state__c": "",
            "license_type__c": "",
            "license_id__c": "",
            "isNew" : true
        };

        provider_licenses_updates.push(license);
        component.set('v.provider_licenses_updates', provider_licenses_updates);
    },


    cancelUpdate : function(component, event, helper) {
        component.set('v.isEdit', false);
        helper.getDentist(component, component.get('v.params.id'));
    },

    updateInformation : function(component, event, helper) {
        component.set('v.isEdit', true);
    },

    submitWrapperCase : function(component, event, helper) {
        helper.submitWrapperCase(component);
    },


    saveDentistUpdate : function(component, event, helper) {
        var hospitals_updates = [], specialties_updates = [], psl_networks_updates = [], provider_licenses_updates = [];
        var new_hospitals = [], new_specialties = [], new_psl_networks = [], new_provider_licenses = [];
        var removed_hospitals = [], removed_specialties = [], removed_psl_networks = [], removed_provider_licenses = [];

        component.set('v.invalidCase', false);

        // put all the updated records in
        var psl_updates = component.get('v.psl_updates');

        // first and last name validation
        if(!psl_updates.Provider__r.first_name__c || !psl_updates.Provider__r.last_name__c 
            || psl_updates.Provider__r.first_name__c == '' || psl_updates.Provider__r.last_name__c == '') {
            component.set('v.invalidCase', true);
            component.set('v.invalidMessage', 'First and last name are required.');
            window.scrollTo(0,0);
            return;
        }

        var isValidDate = function(dateString) {
            var regEx = /^\d{4}-\d{2}-\d{2}$/;
            return dateString.match(regEx) != null;
        }

        var specialties = component.get('v.specialties_updates');
        var psl_networks = component.get('v.psl_networks_updates');
        
        for(var i = 0; i < specialties.length; i++) {
            var entry = specialties[i];

            // if dates are null or invalid
            if(entry.certification_date && !isValidDate(entry.certification_date)) {
                //console.log(('INVALID!');
                component.set('v.invalidCase', true);
                component.set('v.invalidMessage', 'Please enter an Certification Date.');
                window.scrollTo(0,0);
                return;
            }
        }

        for(var i = 0; i < psl_networks.length; i++) {
            var entry = psl_networks[i];

            // if dates are null or invalid
            if(!entry.effective_date__c || !isValidDate(entry.effective_date__c) || (entry.termination_date__c && !isValidDate(entry.termination_date__c))) {
                //console.log(('INVALID effective');
                component.set('v.invalidCase', true);
                component.set('v.invalidMessage', 'Please enter an Effective Date.');
                window.scrollTo(0,0);
                return;
            }
        }

        var difference = function(object, base) {
            var changes = function (object, base) {
                return _.transform(object, function(result, value, key) {
                    if (!_.isEqual(value, base[key])) {
                        result[key] = (_.isObject(value) && _.isObject(base[key])) ? changes(value, base[key]) : value;
                    }
                });
            }
            return changes(object, base);
        };

        // Use lodash to find all changes
        // don't include fields that haven't changed.

        var hospitals = component.get('v.hospitals_updates');
        var provider_licenses = component.get('v.provider_licenses_updates');

        var hospitals_original = component.get('v.hospitals');
        var specialties_original = component.get('v.specialties');
        var psl_networks_original = component.get('v.psl_networks');
        var provider_licenses_original = component.get('v.provider_licenses');


        // Get the changes to the old related list records
        hospitals_original.forEach(function(entry, index) {
            if(!entry.isNew) {
                var changes = difference(hospitals[index], entry);
                // only push if there are actually changes
                if(!_.isEmpty(changes)) {
                    if(changes.isDeleted) {
                        var change = {
                            "Name" : entry.Name,
                            "Location" : entry.Location,
                            "Record Id" : entry.id
                        };
                        removed_hospitals.push(change);
                    }
                    else if(!changes.isNew) {
                        var change = {
                            "Name" : (changes.Name ? changes.Name : entry.Name),
                            "Location" : changes.Location,
                            "Record Id" : entry.id
                        };
                        hospitals_updates.push(change);
                    }
                }
            }
        });

        specialties_original.forEach(function(entry, index) {
            if(!entry.isNew) {
                var changes = difference(specialties[index], entry);
                // only push if there are actually changes
                if(!_.isEmpty(changes)) {
                    if(changes.isDeleted) {
                        var change = {
                            "Specialty" : entry.specialty,
                            "Record Id" : entry.id
                        };
                        removed_specialties.push(change);
                    }
                    else if(!changes.isNew) {
                        var change = {
                            "Specialty" : (changes.specialty ? changes.specialty : entry.specialty),
                            "Certification Status" : changes.certification_status,
                            "Certification Date" : changes.certification_date,
                            "Board Certified" : changes.board_certified,
                            "Board Name" : changes.board_name,
                            "Record Id" : entry.id
                        };
                        specialties_updates.push(change);
                    }
                }
            }
        });

        psl_networks_original.forEach(function(entry, index) {
            // Only get non-new records
            if(!entry.isNew) {
                var changes = difference(psl_networks[index], entry);
                // only push if there are actually changes
                if(!_.isEmpty(changes)) {
                    if(changes.isDeleted) {
                        var change = {
                            "Network Name" : entry.net_name,
                            "Record Id" : entry.Id
                        };
                        removed_psl_networks.push(change);
                    }
                    else if(!changes.isNew) {
                        var change = {
                            "Network Name" : (changes.net_name ? changes.net_name : entry.net_name),
                            "Par Code" : changes.participation_status__c,
                            "Effective Date" : changes.effective_date__c,
                            "Termination Date" : changes.termination_date__c,
                            "Record Id" : entry.Id
                        };
                        psl_networks_updates.push(change);
                    }
                }
            }
        });

        provider_licenses_original.forEach(function(entry, index) {
            // Only get non-new records
            if(!entry.isNew) {
                var changes = difference(provider_licenses[index], entry);
                // only push if there are actually changes
                if(!_.isEmpty(changes)) {
                    if(changes.isDeleted) {
                        var change = {
                            "License Type" : entry.license_type__c,
                            "License Number" : entry.license_id__c,
                            "License State" : entry.license_state__c,
                            "Record Id" : entry.Id
                        };
                        removed_provider_licenses.push(change);
                    }
                    else if(!changes.isNew) {
                        var change = {
                            "License Type" : (changes.license_type__c ? changes.license_type__c : entry.license_type__c),
                            "License Number" : changes.license_id__c,
                            "License State" : changes.license_state__c,
                            "Record Id" : entry.Id
                        };
                        provider_licenses_updates.push(change);
                    }
                }
            }
        });

        // Add all the new records
        component.get('v.hospitals_updates').forEach(function(entry) { 
            if(entry.isNew) {
                var change = {
                    "Name" : entry.Name,
                    "Location" : entry.Location,
                }
                new_hospitals.push(change); 
            } 
        });

        component.get('v.specialties_updates').forEach(function(entry) { 
            if(entry.isNew) {
                var change = {
                    "Specialty" : entry.specialty,
                    "Certification Status" : entry.certification_status,
                    "Certification Date" : entry.certification_date,
                    "Board Certified" : entry.board_certified,
                    "Board Name" : entry.board_name
                }
                new_specialties.push(change); 
            } 
        });

        component.get('v.psl_networks_updates').forEach(function(entry) { 
            if(entry.isNew) {
                var change = {
                    "Network Name" : entry.net_name,
                    "Par Code" : entry.participation_status__c,
                    "Effective Date" : entry.effective_date__c,
                    "Termination Date" : entry.termination_date__c
                }
                new_psl_networks.push(change); 
            } 
        });

        component.get('v.provider_licenses_updates').forEach(function(entry) { 
            if(entry.isNew) {
                var change = {
                    "License Type" : entry.license_type__c,
                    "License Number" : entry.license_id__c,
                    "License State" : entry.license_state__c
                }
                new_provider_licenses.push(change); 
            } 
        });

        var provUpdates = component.get('v.map_psl_updates');

        //console.log(('applyToAllDentistOffice: '+component.find('applyToAllDentistOffice').getElement().checked);
        if(component.find('applyToAllDentistOffice').getElement().checked) {
            provUpdates['Apply Service Office changes to Providers at all Locations'] = true;
        }

        if(component.find('applyToAllDentistContact').getElement().checked) {
            provUpdates['Apply Contact changes to Providers at all Locations'] = true;
        }

        var updateJSON = {
            provider_updates : (!_.isNull(provUpdates) ? provUpdates : null),

            hospital_and_group_affiliations_updates : (!_.isEmpty(hospitals_updates) ? hospitals_updates : null),
            new_hospital_and_group_affiliations : (!_.isEmpty(new_hospitals) ? new_hospitals : null),
            removed_hospital_and_group_affiliations : (!_.isEmpty(removed_hospitals) ? removed_hospitals : null),

            provider_licenses_updates : (!_.isEmpty(provider_licenses_updates) ? provider_licenses_updates : null),
            new_provider_licenses : (!_.isEmpty(new_provider_licenses) ? new_provider_licenses : null),
            removed_provider_licenses : (!_.isEmpty(removed_provider_licenses) ? removed_provider_licenses : null),

            specialties_and_certifications_updates : (!_.isEmpty(specialties_updates) ? specialties_updates : null),
            new_specialties_and_certifications : (!_.isEmpty(new_specialties) ? new_specialties : null),
            removed_specialties_and_certifications : (!_.isEmpty(removed_specialties) ? removed_specialties : null),
            
            network_affiliations_updates : (!_.isEmpty(psl_networks_updates) ? psl_networks_updates : null),
            new_network_affiliations : (!_.isEmpty(new_psl_networks) ? new_psl_networks : null),
            removed_network_affiliations : (!_.isEmpty(removed_psl_networks) ? removed_psl_networks : null)
        };

        // stringify all objects on the page.
        helper.saveDentistUpdate(component, component.get('v.params.id'), JSON.stringify(updateJSON), component.get('v.notes'));
    },

    fixDate : function(component, event, helper) {
        helper.fixDate(component, event, helper);
    },

    /**
     * Client side table sort
     */
    sortTableNetwork : function(component, event, helper) {
    	//get the element clicked
    	var tar = event.currentTarget;
    	var col = tar.dataset.col; //get column
    	var fieldName = tar.dataset.fieldname;
    	//console.log(('target and column found');
    	
    	// sort direction for dynamicSort
    	// if null, dynamicSort will sort ascending
    	var sortDirection = '';
    	
    	// resort the table
    	var psl_networks = component.get('v.psl_networks');
    	//console.log(('### networks: ' + JSON.stringify(psl_networks));
    	var isEdit = false;
    	
    	if(tar.dataset.edit && tar.dataset.edit == 1) {
    		isEdit = true;
    		psl_networks = component.get('v.psl_networks_updates');
    	}
    	if($A.util.hasClass(tar, 'notSorted')){
    		//console.log(('not sorted');
    		$A.util.removeClass(tar, 'notSorted');
			sortDirection = 'asc';
			$A.util.addClass(tar, 'sortAscend');
    		$('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');
    		
    	} else if($A.util.hasClass(tar, 'sortAscend')) {
    		//console.log(('asc');
    		//column is currently sorted by ascending order, switch it
    		$A.util.removeClass(tar, 'sortAscend')
    		$A.util.addClass(tar, 'sortDescend');
    		sortDirection = 'desc';
    		//console.log(('end of sort asc');
    	} else {//target has sortDescend
    		//column is currently sorted by descending order, switch it
    		//console.log(('dsc');
    		$A.util.addClass(tar, 'sortAscend');
    		$A.util.removeClass(tar, 'sortDescend');
    	}   
    	component.set('v.pageNumNetwork', 1);
    	psl_networks.sort(dynamicSort(fieldName, sortDirection));
    	
    	if(isEdit) {
    		component.set('v.psl_networks_updates', psl_networks);
    		//needs to update the page number as well back to 1
    	} else {
    		component.set('v.psl_networks', psl_networks);
    		//needs to update the page number as well back to 1
    	}
    	
    	
    	//console.log(('### networks sorted: ' + JSON.stringify(psl_networks));
    },
    
    /**
     * Client side table sort
     */
    sortTableOtherLocation : function(component, event, helper) {
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        var fieldName = tar.dataset.fieldname;
        //console.log(('target and column found:'+fieldName);

        // sort direction for dynamicSort
        // if null, dynamicSort will sort ascending
        var sortDirection = '';

        // resort the table
        var psl_networks = component.get('v.other_locations');
        //console.log(('### networks: ' + JSON.stringify(psl_networks));
        var isEdit = false;
        
        //console.log(('other location field name value::' + psl_networks[0][fieldName]);

//        if(tar.dataset.edit && tar.dataset.edit == 1) {
//            isEdit = true;
//            psl_networks = component.get('v.other_locations_updates');
//        }
        if($A.util.hasClass(tar, 'notSorted')){
//            //console.log(('not sorted');
            $A.util.removeClass(tar, 'notSorted');
        	sortDirection = 'asc';
            $A.util.addClass(tar, 'sortAscend');
            $('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

        } else if($A.util.hasClass(tar, 'sortAscend')) {
            //console.log(('sortDescend');
            //column is currently sorted by ascending order, switch it
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            sortDirection = 'desc';
//            //console.log(('end of sort asc');
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            //console.log(('sortAscend');
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
        }   
        component.set('v.pageNumOther', 1);
        psl_networks.sort(dynamicSort(fieldName, sortDirection));

//        if(isEdit) {
//            component.set('v.psl_networks_updates', psl_networks);
//            //needs to update the page number as well back to 1
//        } else {
            component.set('v.other_locations', psl_networks);
            //needs to update the page number as well back to 1
//        }
        
        
        //console.log(('### networks sorted: ' + JSON.stringify(psl_networks));
    },


    /**
     * Client side table sort
     */
    sortTable : function(component, event, helper) {
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column

        //get table Id
        var tableId = tar.dataset.tableid;

        //get the table 
        var table = $('#'+tableId);     

        //is this column not order
        if($A.util.hasClass(tar, 'notSorted')){
            $A.util.removeClass(tar, 'notSorted');
            if(col == 0){
                //default last updated to descend. newest first
                $A.util.addClass(tar, 'sortDescend');
                sortTable(table, col, 'DESC');
            } else {
                $A.util.addClass(tar, 'sortAscend');
                sortTable(table, col, 'ASC');
            }
            $('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');
        } else if($A.util.hasClass(tar, 'sortAscend')) {
            //console.log(('asc');
            //column is currently sorted by ascending order, switch it
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            sortTable(table, col, 'DESC');
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            //console.log(('dsc');
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
            sortTable(table, col, 'ASC');
        }
    },

    helpRequestRedirect :function(component,event,helper){
        var pageName = "help-request";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName

            });
            redirectEvent.fire();
    }

})