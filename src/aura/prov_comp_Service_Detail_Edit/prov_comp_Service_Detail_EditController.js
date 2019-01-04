({
    //page utility methods
    doInit : function(component, event, helper) {
        //console.log('init Start::'+component.get('v.currentBusinessId'));

        var serviceOfficeUpdates = {};
        // var serviceOffice = component.get('v.serviceOfficeRecord');
        // serviceOfficeUpdates["Service Office Name"] = serviceOffice.Name;
        // //console.log('serviceOfficeUpdates: '+serviceOfficeUpdates);
        
        component.set('v.serviceOfficeUpdates', {});
        component.set('v.servOfficeHours',{});

        //console.log('init recordId: '+component.get('v.recordId'));

        //console.log('serviceOffice init: '+component.get('v.serviceOfficeRecord'));

        //console.log('dentistList init: '+component.get('v.dentistList'));
        
        //get list of available denists for adding to location
        helper.getAvailableDentists(component, event, helper);
        helper.setHoursObj(component, component.get('v.serviceOfficeRecord'));
       
        //turn on for easier testing of dentist roster
        //helper.addDentist(component, event, helper);
    },

    edit : function(component, event, helper) {
        var isEdit = component.get('v.editServiceOffice');
        //console.log('isEdit before: '+isEdit);
        component.set('v.editServiceOffice', !isEdit);
    },

    submit : function(component, event, helper) {
        component.set('v.isSubmitError', false);
        component.set('v.isProviderError', false);
        if(!component.get('v.serviceOfficeRecord.Name')) {
            window.scrollTo(0,0);
            component.set('v.serviceOfficeSubmitErrorMsg', "Service Office Name is required.");
            component.set('v.isSubmitError', true);
            return;
        }
        var serviceOfficeUpdates = component.get('v.serviceOfficeUpdates');
        var existingProviders = component.get('v.dentistList');
        var newProviders = component.get('v.newDentistList');
        var removedProviders = [];
		var businessId = component.get('v.currentBusinessId');        
        
        // make sure the user confirms all new providers
        for(var field in newProviders) {
            if(newProviders[field].changeType == 'new') {
                //console.log('newProviders: '+newProviders[field].changeType);
                component.set('v.providerErrorMsg', "Please confirm provider changes before submitting.");
                component.set('v.isProviderError', true);
                return;
            }
        }

        for(var field in existingProviders) {
            if(existingProviders[field].changeType == 'deleted') {
                var removedProvider = {
                    'Name' : existingProviders[field].Provider_Name__c,
                    'Windward GUID' : existingProviders[field].ProviderGUID__c};
                removedProviders.push(removedProvider);
                //console.log('this provider should be removed');
            }
        }

        var new_providers = [];
        newProviders.forEach(function(entry) {
            var change = {
                "Name" : entry.Name,
                "NPI" : entry.NPI
            }
            new_providers.push(change);
        });

        //console.log('newProviders: '+ JSON.stringify(new_providers)); 
        //console.log('removedProviders: '+ JSON.stringify(removedProviders)); 
        //console.log('serviceOfficeUpdates: '+ JSON.stringify(serviceOfficeUpdates));
        
        var updateJSON = {
            service_office_updates : serviceOfficeUpdates,
            new_providers: new_providers,
            removed_providers : removedProviders
        };
        //console.log('updateJSON: '+ JSON.stringify(updateJSON));  

        helper.saveUpdatedServiceOfficeRecord(component, component.get('v.params.id'), JSON.stringify(updateJSON, undefined, 4), component.get('v.notes'), businessId);

        // //console.log('newList: '+ JSON.stringify(component.get('v.newDentistList')));
        // //console.log('existingList: '+ JSON.stringify(component.get('v.dentistList')));
    },

    fieldChange :function (component,event,helper){
        //console.log('fieldChange');
        var serviceOfficeChanges = component.get('v.serviceOfficeUpdates');

        //console.log('serviceOfficeChanges before: '+serviceOfficeChanges); 
 
        var sourceField = event.getSource();
        var newValue = sourceField.get('v.value');
        //console.log(newValue);
        var label = sourceField.get('v.label');
        //console.log(label); 
 
        if(label.indexOf('Open') > -1 || label.indexOf('Close') > -1) {
            if(newValue == null || newValue == '') {
                serviceOfficeChanges[label] = 'Removed hours';
            } else {
                serviceOfficeChanges[label] = newValue;
            }
        } else {
            serviceOfficeChanges[label] = newValue;            
        }
        //console.log('got here'); 
        for (var key in serviceOfficeChanges) {
            //console.log("key " + key + " has value " + serviceOfficeChanges[key]);
        }
        component.set('v.serviceOfficeUpdates', serviceOfficeChanges);
    },

    getAvailableDentists : function(component, event, helper) {
        helper.getAvailableDentists(component, event, helper);
    },

    addDentist : function(component, event, helper) {
        //console.log('addDentist Start');
        helper.addDentist(component, event, helper);
        //console.log('newDentistList addDentist: '+JSON.stringify(component.get('v.newDentistList')));
    },

    setProviderId : function(component, event, helper) {
        
        var providerId = event.getSource().get('v.value');
        //console.log('providerId: '+providerId);
        var index = event.getSource().get('v.label');
        //console.log('index: '+index);

        var availableDentists = component.get('v.availableDentists');

        var serviceOffice = component.get('v.serviceOfficeRecord');

        //convert the list of available dentists to a map for use in setting provider attributes
        var availableDentistMap = availableDentists.reduce(function(map, obj) {
            map[obj.Id] = obj;
            return map;
        }, {});
        //console.log('availableDentistMap: '+JSON.stringify(availableDentistMap));

        var newDentistList = component.get('v.newDentistList');
        if(providerId == 'Select') {
            newDentistList[index].selectedProvider = 'Select';
            newDentistList[index].Name = '';
            newDentistList[index].NPI = '';
            newDentistList[index].WindwardGUI = '';
        } else {
            newDentistList[index].selectedProvider = providerId;
            newDentistList[index].Name = availableDentistMap[providerId].Name;
            newDentistList[index].NPI = availableDentistMap[providerId].npi__c;
            newDentistList[index].WindwardGUI = availableDentistMap[providerId].windward_guid__c;
        }
        component.set('v.newDentistList', newDentistList);

        //console.log('setProviderId end');
    },

    //deletes the selected existing row
    deleteExistingRow : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        var dentistList = component.get('v.dentistList');
        //console.log('index ctarget: '+index);
        //console.log('index deleteExistingRow: '+index);

        dentistList[index].changeType = 'deleted';
        
        component.set('v.dentistList', dentistList);
    }, 

    //undeletes the selected new row
    undeleteExistingRow : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        //console.log('index: '+index);

        var dentistList = component.get('v.dentistList');
        dentistList[index].changeType = 'existing';
        component.set('v.dentistList', dentistList);
    }, 

    //deletes the selected new row
    deleteNewRow : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        //console.log('index: '+index);
        var newDentistList = component.get('v.newDentistList');

        //console.log('newDentistList before deleteNewRow: '+newDentistList.length);
        //newDentistList[index].changeType = 'deleted';
        newDentistList.splice(index, 1);

        //reorder index
        for(i=0; i<newDentistList.length; i++){
            newDentistList[i].index = i;
        }
        //console.log('newDentistList after deleteNewRow: '+newDentistList.length);

        component.set('v.newDentistList', newDentistList);
    }, 

    //confirms the selected new row
    confirmNewRow : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        //console.log('ctarget: '+ctarget);
        //console.log('index: '+index);
        $A.util.addClass(ctarget,'selectedRow');

        var newDentistList = component.get('v.newDentistList'); 
        newDentistList[index].changeType = 'confirmed';
        component.set('v.newDentistList', newDentistList);
    }, 

    //undoes the selected new row
    editNewRow : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        //console.log('ctarget: '+ctarget);
        //console.log('index: '+index);

        var newDentistList = component.get('v.newDentistList');
        newDentistList[index].changeType = 'new';
        component.set('v.newDentistList', newDentistList);

        var selectedProv = newDentistList[index].selectedProvider;

        var testField = [];
        testField = component.find('selectedProvider');
        //console.log('testField: '+testField);
        for(var field in component.find('selectedProvider')) {
            testField[field].set('v.selectedProvider',selectedProv);
        }        
    }, 
    //end page utility methods
    

    //column sort methods
    //sorts the column selected
    
    updateColumnSorting: function(component, event, helper){
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        //console.log('got here 0');

        //console.log('tar: '+tar);
        //console.log('col: '+col);

        //get table Id
        var tableId = tar.dataset.tableid;
        //console.log('tableId: '+tableId);
        //get the table 
        var table = $('#'+tableId);     

        //console.log('got here 1');
        //is this column not order
        if($A.util.hasClass(tar, 'notSorted')){
            //console.log('not sorted');
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
            //console.log('asc');
            //column is currently sorted by ascending order, switch it
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            sortTable(table, col, 'DESC');
        //console.log('got here 3');
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            //console.log('dsc');
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
            sortTable(table, col, 'ASC');
        }
        //console.log('got here 2');
    }
    //end column sort methods
})