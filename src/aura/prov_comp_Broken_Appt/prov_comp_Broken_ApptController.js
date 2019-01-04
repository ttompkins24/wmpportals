({
	doInit : function(component, event, helper) {

    //get params passed in from a redirect event    
    var params = component.get('v.params');
    var memGuid = params.id;
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
    //get the business/location/provider values 
    //helper.retrieveBizList(component, event, helper, memGuid);
    if(memGuid != null && memGuid != ''){
    	//check to see if guid is in local storage
    	//console.log('memGuid::'+memGuid);
    	var memCovRec = localStorage[memGuid];
    	localStorage.removeItem(memGuid);
    	//console.log('memCovRec ::'+JSON.stringify(memCovRec));
    	if(memCovRec != undefined){
    		memCovRec = JSON.parse(memCovRec);
    		var tempApp = component.get('v.newBrokenAppt');
    		tempApp.memberFirstName = memCovRec.FirstName__c;
            tempApp.memberLastName = memCovRec.LastName__c;
            tempApp.memberNumber = memCovRec.SubscriberID__c;
            tempApp.memBirthDate = memCovRec.Birthdate__c;
            tempApp.portalName = memCovRec.RouteID__c;
            // //console.log('memCovRec.serviceLocationId::'+memCovRec.serviceLocationId);
            // //console.log(helper.cache_ServiceLocation(component, memCovRec.serviceLocationId));
            //get provider and service location map
            ////console.log('servLoc::'+helper.cache_ServiceLocation(component, memCovRec.serviceLocationId));
            component.set('v.locAcctRec', helper.cache_ServiceLocation(component, memCovRec.serviceLocationId));
            component.set('v.provAcctRec', helper.cache_Provider(component, memCovRec.providerId));
            //if(memCovRec.planGuid != undefined)
            	//component.set('v.isSearchSuccess', true);
    	} else {
	    	//console.log('call helper method...');
	    	helper.prepopulateMember(component, event, helper, memGuid);
	    }
    }
    //populates picklist values in form on page load
    helper.getPatTypeValues(component,event,helper);
    helper.getServCatValues(component,event,helper);
    helper.getReasonCodeValues(component,event,helper);

	},
    updateBizSearch: function (component, event, helper) {
        helper.getBizId(component, event, helper);
    },

    updateLocSearch: function (component, event, helper) {
        helper.getLocId(component, event, helper);
    },

    updateProvSearch: function (component, event, helper) {
        helper.getProvId(component, event, helper);
    },

    updatePatType :function(component,event,helper){
        helper.setPatType(component,event,helper);
    },

    updateServiceCategory :function(component,event,helper){
        helper.setServiceCat(component,event,helper);
    },

    updateReasonCode :function(component,event,helper){
        helper.setReasonCode(component,event,helper);
    },

	fixDate : function(component, event, helper) {
        helper.fixDate(component, event);
    },

    handleSearchMember : function(component,event,helper){
        //reset error and success messages
        component.set('v.isSearchSuccess', false);
        component.set('v.isSearchError', false);
        component.set('v.isMemFieldError', false);
        //turn on spinner
        var spinner = component.find('searchSpinnerId');
        $A.util.removeClass(spinner, 'slds-hide');
        //check for errors
        helper.checkForMemberErrors(component);
        var isMemFieldError = component.get("v.isMemFieldError");
        if(!isMemFieldError){
        //calls member search helper
        helper.search(component);
        }

        $A.util.toggleClass(spinner, 'slds-hide');

    },

    handleCancel : function(component,event,helper){
        //redirects to the new broken appointments page while passing in member information
        var selectItem = event.currentTarget;
        //sets page name to route to
        var pageName = "broken-appointment-list";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,

            });
            redirectEvent.fire();

    },

    handleSubmitBrokenAppt : function(component,event,helper){
        //reset error and success messages
        component.set('v.isSubmitSuccess', false);
        component.set('v.isSubmitError', false);
        component.set('v.isDateError', false);
        component.set('v.isProvError', false);
        component.set('v.isReqError', false);

        //checks for errors
        window.scrollTo(0,0);
        helper.checkForErrors(component,event,helper);
            
        var isDateError = component.get("v.isDateError");
        var isProvError = component.get("v.isProvError");
        var isReqError = component.get("v.isReqError");
        var isMemberError = component.get("v.isSearchError");
        var isSearchSuccess = component.get("v.isSearchSuccess");

        //if the search error is true, add error to the top.

        //submits broken appointment case if there are no errors
        if(!isProvError){
            if(!isDateError){
                if(!isReqError){
                    if(isSearchSuccess){
                        var spinner = component.find('searchSpinnerId');
                        $A.util.removeClass(spinner, 'slds-hide');
                        //console.log('hidden spinner');
                        helper.submitBrokenAppt(component,event,helper);
                        //component.find("locAccts").set("v.value", "Select One");
                        //fcomponent.find("provAccts").set("v.value", "Select One");
                    }
                }
            }
        } 
    },
})