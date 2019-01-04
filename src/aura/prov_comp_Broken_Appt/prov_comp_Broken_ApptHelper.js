({

    prepopulateMember :function(component,event, helper, memberGuid){
    	////console.log('prepopulateMember...');
        //if there is a value there, use that to pre populate member fields
        var action = component.get("c.getMembers");
        var businessId = component.get("v.currentBusinessId");
        action.setParams({
            "profileMemberGuid" : memberGuid,
            "businessId" : businessId,
            'routeId' : sessionStorage['portalconfig_lob']
            
        });

        action.setCallback(this, function(response){

            ////console.log(response.getReturnValue());
            if(response.getState() == 'SUCCESS' && response.getReturnValue() != null){
                var tempApp = component.get('v.newBrokenAppt');
                //Get Member Coverage record based on Member Coverage Guid query
                var memCov = response.getReturnValue();
                ////console.log(JSON.stringify(memCov));
                //set values on broken appointment form based on MemberCoverage record
                tempApp.memberFirstName = memCov[0].FirstName__c;
                tempApp.memberLastName = memCov[0].LastName__c;
                tempApp.memberNumber = memCov[0].SubscriberID__c;
                tempApp.memBirthDate = memCov[0].Birthdate__c;
                tempApp.portalName = memCov[0].RouteID__c;

                component.set("v.newBrokenAppt", tempApp);
                component.set('v.isSearchSuccess', true);
                //automatically search for member based on those returned values
                //helper.search(component);
            }

        });

        $A.enqueueAction(action);
    },

    checkForMemberErrors :function (component,event,helper){
        var error = false;
        var memfName = component.get("v.newBrokenAppt.memberFirstName");
        var memlName = component.get("v.newBrokenAppt.memberLastName");
        var memNum = component.get("v.newBrokenAppt.memberNumber");
        var memBirthDate = component.get("v.newBrokenAppt.memBirthDate");
        //if DOB is filled out but no other fields are
        if((memBirthDate != null && memNum == null && (memfName == null && memlName == null))){
            error = true;
        }
        //if DOB is filled out and only first name is also filled out
        else if ((memBirthDate != null && memNum == null && memfName != null && memlName == null)){
            error = true;
        }

        //if DOB is filled out and only last name is also filled out
        else if ((memBirthDate != null && memNum == null && memfName == null && memlName != null)){
            error = true;
        }

        if(error){
            component.set("v.isMemFieldError",true);
            component.set("v.memFieldErrorMsg","You must include Member D.O.B. with Member Number or Member First Name and Last Name in this search");

        }
    },

    checkForErrors : function(component, event, helper) {
        var error = false;
        var business = component.get("v.currentBusinessId");
        var serviceLocation = component.get("v.locAcctRec");
        var provider = component.get("v.provAcctRec");
        var servDate = component.get("v.newBrokenAppt.serviceDate");

        var searchError = component.get("v.isSearchError");
        var searchSuccess =component.get("v.isSearchSuccess");


        var memfName = component.get("v.newBrokenAppt.memberFirstName");
        var memlName = component.get("v.newBrokenAppt.memberLastName");
        var memNum = component.get("v.newBrokenAppt.memberNumber");
        var memBirthDate = component.get("v.newBrokenAppt.memBirthDate");
       
        var tempDate = new Date(servDate);
        //tempDate.setDate(tempDate.getDate() +1);
        var today = new Date();
        //console.log("dates: " + today + ' : ' + tempDate + " : " + servDate);
        //checks if service date is greater than today and throws an error if true
        if(tempDate != null && tempDate > today){
            
                        //console.log("error found");
                        component.set("v.isDateError",true);
                        component.set("v.dateErrorMsg","Service Date cannot be in the Future");
                        window.scrollTo(0,0);
        }

        if(provider == null || provider == 'Select One'){
            ////console.log("error found");
                        component.set("v.isProvError",true);
                        component.set("v.provErrorMsg","Please choose a provider.");
                        window.scrollTo(0,0);
        }

        var patType = component.get('v.newBrokenAppt.patientType');
        var servCat = component.get('v.newBrokenAppt.serviceCat');
        var code = component.get('v.newBrokenAppt.reasonCode');
        

        if(servDate == null || patType == null || servCat == null || code == null){
            ////console.log("required field error");
            component.set("v.isReqError",true);
            component.set("v.reqFieldMsg","Please complete the required fields");
            window.scrollTo(0,0);
        }

        if(!searchSuccess){
            component.set("v.isSubmitError",true);
            component.set("v.submitBAError", "A member must be eligible for services to submit a broken appointment. The selected member does not meet this requirement.");
            // {!$Label.c.Broken_Appt_Submit_Error}
            window.scrollTo(0,0);
        }

       
        



    },

    getPatTypeValues :function(component,event,helper){
        
    var action = component.get("c.getPatTypes");
    var options = [];     
    //populates picklist values
    action.setCallback(this, function(response) {
        for(var i=0;i< response.getReturnValue().length;i++){
            options.push(response.getReturnValue()[i]);
        }
        component.set("v.patientTypes", options);

        var patTypes = component.get("v.patientTypes");
    });

    $A.enqueueAction(action);
    },

    getServCatValues :function(component,event,helper){

    var populatepicklists1 = component.get("c.getServiceCategories2");
    var options = [];     
    //populates picklist values
    populatepicklists1.setCallback(this, function(a) {
        for(var i=0;i< a.getReturnValue().length;i++){
            options.push(a.getReturnValue()[i]);
        }
        component.set("v.serviceCategories", options);

    });

    $A.enqueueAction(populatepicklists1);
    },

    getReasonCodeValues :function(component,event,helper){

    var populatepicklists2 = component.get("c.getReasonCodes2");
    var options = [];     
    //populates picklist values
    populatepicklists2.setCallback(this, function(a) {
        for(var i=0;i< a.getReturnValue().length;i++){
            options.push(a.getReturnValue()[i]);
        }
        //console.log('Reason Code options::'+JSON.stringify(options));
        component.set("v.reasonCodes", options);

    });
    $A.enqueueAction(populatepicklists2);
    },


	//search on the inputted criteria
	search : function(component) {
		var action = component.get("c.searchMembers");
		//parameters to pass the search page
		var business = component.get("v.currentBusinessId");
		var serviceLocation = component.get("v.locAcctRec");
		var provider = component.get("v.provAcctRec");
		//parameters from the member search fields
		var memFName = component.find("memberFName").get("v.value");
        var memLName = component.find("memberLName").get("v.value");
        var memNum = component.find("memberNumber").get("v.value");
		var memBDate = component.find("memberBirthDate").get("v.value");

    	action.setParams({
            "businessId": business,
            "birthDate": memBDate,
            "memberNumber": memNum,
            "firstName": memFName,
            "lastName": memLName,
            'routeId' : sessionStorage['portalconfig_lob']
        });
        	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() == 'SUCCESS' && response.getReturnValue() != null){		
				var result = response.getReturnValue();		
				////console.log('result::'+result);
				//get brokenappointment wrapper record
				var appt = component.get("v.newBrokenAppt");
                //sets Memberprofile Guid from search result on wrapper record
                appt.memProfileGuid = result[0].MemberProfileGUID__c;

                //set values on form based on successful response, in case there are partial searches
                appt.memberFirstName = result[0].FirstName__c;
                appt.memberLastName = result[0].LastName__c;
                appt.portalName = result[0].RouteID__c;
                appt.memberNumber = result[0].SubscriberID__c;

                //console.log(result[0].FirstName__c);
                //console.log(result[0].SubscriberID__c);
                component.set("v.newBrokenAppt", appt);
                component.set('v.memResult', result);
				
				component.set('v.isSearchSuccess', true);
			}else{
				//setting the error flag and the message
				component.set('v.isSearchError', true);	
			}
			
		});
		$A.enqueueAction(action);

		
	},

	


    //retrieves selected provider ID
    getProvId: function(component, event, helper) {
        var acctRecId = component.find("provAccts").get("v.value");
        //console.log(acctRecId);
            component.set("v.provAcctRecId", acctRecId);
    },

    submitBrokenAppt : function(component,event,helper){
    	var appt = component.get("v.newBrokenAppt");
        
        action = component.get("c.createBrokenAppointment");

        var business = component.get("v.currentBusinessId");
		var serviceLocation = component.get("v.locAcctRec");
		var provider = component.get("v.provAcctRec");

        action.setParams({
            "bizId": business,
            "servLocId": serviceLocation.Id,
            "provId": provider.Id,
            "fName" : appt.memberFirstName,
            "lName" : appt.memberLastName,
            "bDate" : appt.memBirthDate,
            "memNum" : appt.memberNumber,
            "servDate" : appt.serviceDate,
            "patType" : appt.patientType,
            "servCat" : appt.serviceCat,
            "reasonCode": appt.reasonCode,
            "dateReported": appt.dateReported,
            "memProGuid": appt.memProfileGuid,
            "notes": appt.notes,
            "portalName" : appt.portalName

        });

        action.setCallback(this, function(response){
            let errors = response.getError();
            if(response.getState() == 'SUCCESS'){   
                component.set('v.isSubmitSuccess', true);
                this.reinitialize(component);
//                var appt2 = component.get("v.newBrokenAppt");
//                //clears search fields on successful submission
//                appt2.memberFirstName = '';
//                appt2.memberLastName = '';
//                appt2.memberNumber = '';
//                appt2.memBirthDate = '';
//                var newList = [];
//                newList.push(appt);
//                component.set("v.newBrokenAppt", newList);
            }
            else{
                component.set('v.isSubmitError', true);
                component.set('v.submitBAError', $A.get("$Label.c.Broken_Appt_Submit_Error"))
            }
            $A.util.addClass(component.find("searchSpinnerId"), 'slds-hide');
            

        });
        $A.enqueueAction(action);
    },

    setPatType :function(component,event,helper){
        var brokenAppt = component.get('v.newBrokenAppt');
        var patientType = component.find("patientType").get("v.value");
        //console.log(patientType);
        brokenAppt.patientType = patientType;
    },

    setServiceCat : function(component,event,helper){
        var brokenAppt = component.get('v.newBrokenAppt');
        var serviceCat = component.find("serviceCat").get("v.value");
        //console.log(serviceCat);
        brokenAppt.serviceCat = serviceCat;

    },

    setReasonCode : function(component,event,helper){
        var brokenAppt = component.get('v.newBrokenAppt');
        var reasonCode = component.find("reasonCode").get("v.value");
        brokenAppt.reasonCode = reasonCode;
    },
    
    reinitialize : function(component){
    	component.set('v.isSearchSuccess', false);
    	var brokenappt = component.get('v.newBrokenAppt');
    	
	    ////console.log('memGuid::'+memGuid);
	    var today = new Date();
	    var dd = today.getDate();
	    var mm = today.getMonth()+1; //January is 0
	
	    var yyyy = today.getFullYear();
	    if(dd<10){
	        dd='0'+dd;
	    } 
	    if(mm<10){
	     mm='0'+mm;
	    } 
	    var today = (yyyy+'-'+mm+'-'+dd);
	    //set default dates
	    brokenappt.dateReported = today;
	    brokenappt.serviceDate = today;
	    brokenappt.patientType = '';
	    brokenappt.serviceCat = '';
	    brokenappt.reasonCode = '';
	    brokenappt.memberFirstName = '';
	    brokenappt.memberLastName = '';
	    brokenappt.memberNumber = '';
	    brokenappt.memBirthDate = '';
	    component.set('v.newBrokenAppt', brokenappt);
    },
})