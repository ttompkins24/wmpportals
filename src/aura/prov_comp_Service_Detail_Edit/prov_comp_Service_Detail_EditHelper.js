({
    getServiceOfficeInfo : function (component, event, helper){
        component.set('v.showSpinner',true);
        var getServiceOffice = component.get('c.getServiceOfficeInfoDetail');

        getServiceOffice.setParams({
            'recordId' : component.get('v.recordId')
        });
        
        getServiceOffice.setCallback(this,function(response){
            var state = response.getState();
            var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log('Error message: ' +
                         //        errors[0].message);
                    }
                } else {
                    //console.log('Unknown error');
                }

            //console.log('state: '+state);
            if(state === 'SUCCESS'){
                component.set('v.serviceOfficeRecord', response.getReturnValue());
                var serviceOfficeUpdates = component.get('v.serviceOfficeUpdates');
                serviceOfficeUpdates["Service Office Name"] = response.getReturnValue().Name;
                //console.log('serviceOfficeUpdates: '+serviceOfficeUpdates);
                component.set('v.serviceOfficeUpdates', serviceOfficeUpdates);
                //console.log('helper serviceOfficeRecord: '+component.get('v.serviceOfficeRecord.Name'));
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(getServiceOffice);
        //console.log('helper serviceOfficeRecord2: '+component.get('v.serviceOfficeRecord.Id'));
    },    

    setHoursObj : function(component, servLocation) {
        var hoursObj = component.get('v.servOfficeHours');
        //console.log('hoursObj: '+JSON.stringify(hoursObj));
        // //console.log('hoursObj: '+this.fixTime(servLocation.sunday_hours__c.split(" to ")[1]);

        hoursObj['SunOpen'] = this.fixTime(servLocation.sunday_hours__c,0);
        hoursObj['SunClose'] = this.fixTime(servLocation.sunday_hours__c,1);
        hoursObj['MonOpen'] = this.fixTime(servLocation.monday_hours__c,0);
        hoursObj['MonClose'] = this.fixTime(servLocation.monday_hours__c,1);
        hoursObj['TuesOpen'] = this.fixTime(servLocation.tuesday_hours__c,0);
        hoursObj['TuesClose'] = this.fixTime(servLocation.tuesday_hours__c,1);
        hoursObj['WedOpen'] = this.fixTime(servLocation.wednesday_hours__c,0);
        hoursObj['WedClose'] = this.fixTime(servLocation.wednesday_hours__c,1);
        hoursObj['ThursOpen'] = this.fixTime(servLocation.thursday_hours__c,0);
        hoursObj['ThursClose'] = this.fixTime(servLocation.thursday_hours__c,1);
        hoursObj['FriOpen'] = this.fixTime(servLocation.friday_hours__c,0);
        hoursObj['FriClose'] = this.fixTime(servLocation.friday_hours__c,1);
        hoursObj['SatOpen'] = this.fixTime(servLocation.saturday_hours__c,0);
        hoursObj['SatClose'] = this.fixTime(servLocation.saturday_hours__c,1);

        component.set('v.servOfficeHours',hoursObj);
        //console.log('hoursObj: '+JSON.stringify(hoursObj));

    },

    fixTime : function(hourString,split) {
        //console.log('hourString: '+hourString);
        if(hourString == undefined) {
            //console.log('skipped, because hourString is blank');
            return;
        }
        if(hourString.split(" to ")[split] == undefined || hourString.toLowerCase() == 'closed'){
            //console.log('skipped, because hourString is '+ hourString.split(" to ")[split]);
            return;
        }
        var time = hourString.split(" to ")[split];
        var hours = Number(time.match(/^(\d+)/)[1]);
        var minutes = Number(time.match(/:(\d+)/)[1]);
        var AMPM = time.match(/\s(.*)$/)[1];
        if(AMPM == "PM" && hours<12) hours = hours+12;
        if(AMPM == "AM" && hours==12) hours = hours-12;
        var sHours = hours.toString();
        var sMinutes = minutes.toString();
        if(hours<10) sHours = "0" + sHours;
        if(minutes<10) sMinutes = "0" + sMinutes;
        //alert(sHours + ":" + sMinutes);
        
        var fixedTime = sHours + ':' + sMinutes;
        //console.log('fixedTime: '+fixedTime);
        return fixedTime;
    },

    saveUpdatedServiceOfficeRecord : function(component, office_id, updateJSON, notes, businessId){
        component.set('v.showSpinner',true);
        component.set('v.isUpdateSuccess',false);
        component.set('v.isUpdateError',false);
 
        action = component.get('c.saveServiceOfficeUpdateApex');
 
        action.setParams({
            "updateJSON" : updateJSON,
            "notes" : notes,
            "officeId" : office_id,
            "businessId" : businessId
        });
 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                //on SUCCESS status
                //reload new business info
                var result = response.getReturnValue();
                if(result != null) {
					window.scrollTo(0,0);
					component.set('v.caseId', result.Id);
					//console.log('success caseId: '+result.Id);
                    //turn off edit partial
                    component.set('v.editServiceOffice', false);
                    //flashes success message
                    component.set('v.isUpdateSuccess',true);
                    component.set('v.serviceOfficeUpdateSuccessMsg', $A.get("$Label.c.Provider_Case_Saved"));
                    component.set('v.refreshLocation', true);
				} else {
					window.scrollTo(0,0);
					component.set('v.serviceOfficeUpdateErrorMsg', $A.get("$Label.c.CreateCase_General_Error"));
					component.set('v.isUpdateError', true);
				}
            }else{
                //else 
                //flashes error message
				window.scrollTo(0,0);
                component.set('v.serviceOfficeUpdateErrorMsg', $A.get("$Label.c.CreateCase_General_Error"));
				component.set('v.isUpdateError', true);
            }
            component.set('v.showSpinner',false);
        });
 
        $A.enqueueAction(action);
    },

    //gets all available dentists for the business
    getAvailableDentists : function (component, event, helper){
        component.set('v.showSpinner',true);
        var getAvailable = component.get('c.getAllAvailableDentists');
        var businessId = component.get('v.currentBusinessId');
        var locationId = component.get('v.recordId');
        //console.log('businessId', businessId);
        getAvailable.setParams({
            'currentBusinessId' : businessId,
            'currentLocationId' : locationId
    	});
        getAvailable.setCallback(this,function(response){
            var state = response.getState();
            var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log('Error message: ' +
                        //         errors[0].message);
                    }
                } else {
                    //console.log('Unknown error');
                }

            //console.log('state: '+state);
            if(state === 'SUCCESS'){
                component.set('v.availableDentists', response.getReturnValue());
                //console.log('helper availableDentists: '+component.get('v.availableDentists'));
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(getAvailable);
    },

    //add a new dentist to the service location
    addDentist : function(component, event, helper) {
        var dentistList = component.get('v.dentistList');
        var newDentistList = component.get('v.newDentistList');
        var serviceOfficeRecord = component.get('v.serviceOfficeRecord');

        //console.log('newDentistList before add: '+newDentistList.length);
        //if(newDentistList.length)
        newDentistList.push({
            'changeType':'new','selectedProvider':{},'index':newDentistList.length});
        //console.log('newDentistList after add: '+newDentistList.length);

        component.set('v.newDentistList', newDentistList);
    }
})