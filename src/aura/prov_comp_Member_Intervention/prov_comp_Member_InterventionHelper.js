({
    NUM_RESULTS : 10,
	 //get list of service locations based on Business
    getServiceLocations : function (component, event, helper){ 
        var busRecId = component.get('v.currentBusinessId');
        ////console.log('busId::'+busRecId);
        
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        
        var resultList = [];
        var locationMap = providercache.locationMap;
        var activeLocations = providercache.cActiveLocationIds;
        //console.log('locationMap::'+JSON.stringify(activeLocations));
        var businessId2LocMap = providercache.cBusinessId2LocationIds;
        ////console.log('businessId2LocMap::'+JSON.stringify(businessId2LocMap));
        for(var bId in businessId2LocMap){
        	////console.log('i::'+bId);
        	if(bId.substring(0,15) == busRecId ){
        		for(var sLoc in businessId2LocMap[bId]){
        			var locId = businessId2LocMap[bId][sLoc];
                    
                    if(activeLocations.indexOf(locId)>=0){
                        locId = locId.substring(0,15);
                        ////console.log('some text', locId);
                        var location = locationMap[locId];
                        //console.log('location::'+JSON.stringify(location));
        				resultList.push(location);
                    }
        		}
        		break;
        	}
        }
        
        component.set("v.locList", resultList);
        ////console.log('checking if size is 1');
        if(resultList.length == 1){
        	component.find("locAccts").set("v.value", resultList[0].Id);
            helper.getLocId(component, event, helper);

            
        } 
        ////console.log('turn off spinner');
        var spinner = component.find('spinnerId');
        $A.util.addClass(spinner, 'slds-hide');
        $A.util.removeClass(spinner, 'slds-is-fixed');
    },

    //retrieves selected location ID
    getLocId: function(component, event, helper) {
    	////console.log('getLocId');
        var selectedLocRec = component.find("locAccts").get("v.value");
        var bizAcctId = component.get('v.currentBusinessId');
        component.set("v.locAcctRecId", selectedLocRec);
        slLocRecId = component.get("v.locAcctRecId");
        slLocRecId = slLocRecId.substring(0,15);
        // //console.log(slLocRecId);
        // //console.log(bizAcctId);

        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        
        var resultList = [];
        var providerMap = providercache.providerMap;
        var activeProviders = providercache.cActiveProviderIds;
        // //console.log('providerMap::'+JSON.stringify(providerMap));
        var businessId2LocMap = providercache.cBusinessId2Location2ProvidersMap;
        // //console.log('businessId2LocMap::'+JSON.stringify(businessId2LocMap));
        for(var bId in businessId2LocMap){
        	// //console.log('i::'+bId);
        	// //console.log('slLocRecId::'+slLocRecId);
        	if(bId.substring(0,15) == bizAcctId ){
        		for(var sLoc in businessId2LocMap[bId]){
        			// //console.log('sLoc::'+sLoc);
        			if(sLoc.substring(0, 15) == slLocRecId){
                        // //console.log(businessId2LocMap[bId][sLoc]);
        				for(var provLoc in businessId2LocMap[bId][sLoc]){
        					// //console.log('provLoc::'+provLoc);
        					var provId = businessId2LocMap[bId][sLoc][provLoc];
                            // //console.log(provId);
                            provId = provId.substring(0,15);
                            var provider = providerMap[provId];
                            resultList.push(provider);
                            // if(activeProviders.indexOf(provId)>=0){
                            //     //console.log('here');
                            //     
                            //     //console.log('some text', locId);
                                
                            //     //console.log('provider::'+JSON.stringify(provider));
                               
                            // }
        				}
        			}
        		}
        		break;
        	}
        }
        component.set("v.provList", resultList);
        component.set("v.provAcctRecId", null);

    },

    //retrieves selected provider ID
    getProvId: function(component, event, helper) {
        var acctRecId = component.find("provAccts").get("v.value");
        if(acctRecId != 'Any'){
            component.set("v.provAcctRecId", acctRecId);
        } else {
        	component.set("v.provAcctRecId", null);
        
        }
    },

    checkForErrors :function(component,event,helper){
        var location = component.get('v.locAcctRecId');
        component.set('v.isReqLocation', false);

        if(location == 'Select One' || location == null || location == ''){
            component.set('v.isReqLocation', true);
            component.set("v.requiredLocationMsg",  $A.get('$Label.c.Required_Location_Member_Int'));
            window.scrollTo(0,0);

            var spinner = component.find('spinnerId');
            $A.util.addClass(spinner, 'slds-hide');
            $A.util.removeClass(spinner, 'slds-is-fixed');
        }

        if(component.get('v.isReqLocation') == false){
            helper.getMemberInterventions(component,event,helper, 1);
            helper.loadPageVariables(component);
        }
    },

    getMemberInterventions: function(component,event,helper, pageNum, sortField, direction){
        var bizAcct = component.get('v.currentBusinessId');
        var locAcct = component.get('v.locAcctRecId');
        var provAcct = component.get('v.provAcctRecId');
        var firstName = component.get('v.fNameSearch');
        var lastName = component.get('v.lNameSearch');
        var memNum = component.get('v.memberNumberSearch');
        var intMes = component.get('v.intMeasure');
        var priorStartDate = component.get('v.startPriorEventDate');
        var priorStopDate = component.get('v.stopPriorEventDate');
        var action = component.get('c.retrieveInterventions');

        var numResult = '';
        var max = component.get("v.maxResults");
        //sets number of results to return page (set to max results if max is not null)
        if(max != null){
            numResult = max;
        } else{
            //otherwise set to 20
            numResult = ''+this.NUM_RESULTS;
        }
        var page = ''+pageNum;

        action.setParams({
            "bizAcctId":bizAcct,
            "locAcctId":locAcct,
            "provAcctId":provAcct,
            "firstNameSearch" :firstName,
            "lastNameSearch" :lastName,
            "memNumSearch" :memNum,
            "priorEventDateStartSearch":priorStartDate,
            "priorEventDateStopSearch" :priorStopDate,
            "intMeasureSearch" : intMes,
            "sortField" :sortField,
            "direction" : direction,
            "pageNumS" : page,
            "numResultsS" :numResult
        });

        action.setCallback(this, function(response){ 
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue().length > 0){
                    component.set('v.noResults', false);
                    component.set('v.searchActive', true);


                    var totalResults = response.getReturnValue();

                    component.set("v.memInts", totalResults);
                    //console.log(totalResults);
                    var pageNum = Number(page);
                    var numRes = Number(numResult);
                    //console.log(pageNum);
                    //console.log(numRes);
                    var resultList = [];
                    //console.log("success");
                    //console.log(totalResults.length);
                    for(i = ((pageNum-1) * numRes); i < totalResults.length; i++){
                        resultList.push(totalResults[i]);
                
                    if(resultList.length == numRes) break;
                    }
                    //console.log(resultList);

                    component.set("v.memInts", resultList);
                    

                }
                //show no results message if there are no results
                else{
                    component.set('v.noResults', true);
                    component.set('v.memInts', null);
                }
            }else{
                //console.log("error");
            }
            var spinner = component.find('spinnerId');
            $A.util.addClass(spinner, 'slds-hide');
            $A.util.removeClass(spinner, 'slds-is-fixed');
        });
        $A.enqueueAction(action);
    },

    verifySelectedInterventions : function(component, event, helper) {
        var checkint = component.find('checkInt'); 

        var atLeastOneSelected = false;
        if(!Array.isArray(checkint)) {
            atLeastOneSelected = component.find('checkInt').get('v.value');
        } else {
            for(var i=0; i<checkint.length; i++){
                if(checkint[i].get('v.value') == true) {
                    atLeastOneSelected = true;
                }
            }
        } 

        component.set('v.atLeastOneSelected',atLeastOneSelected);
    },

    setInterventionAction :function(component,event,helper){
        //set component attribute to the value selected by user
        var intOption = component.find("intOptions").get("v.value");
        if(intOption != 'Select One'){
            component.set('v.selAction', intOption);
            
        }

        if(intOption == 'Select One'){
            component.set('v.selAction', null);
        }

    },


    updateSingleInt : function(component,event,helper){

        //get the value and index of the member intervention row the user selected
        var selectedMenuItem = event.getParam('value');
        var index = event.getSource().get('v.name');
        var updatedMemInts = component.get('v.memInts');

        action = component.get('c.updateSingleInterventionAction');
        //set params with stringified version of the member intervention object
        action.setParams({
            "interventionJSON" : JSON.stringify(updatedMemInts[index]),
            "intAction" : selectedMenuItem
        });

        action.setCallback(this, function(response){ 
            var state = response.getState();
            if(state === "SUCCESS"){
                //populate success message
                component.set('v.isSubmitSuccess', true);
                component.set('v.submitSuccessMsg', $A.get('$Label.c.Member_Intervention_Success_Msg'));
                window.scrollTo(0,0);
                //requery the member interventions with updated action values
                helper.getMemberInterventions(component,event,helper, 1);

            }else{
                //console.log("error");
            }
            var spinner = component.find('spinnerId');
            $A.util.addClass(spinner, 'slds-hide');
            $A.util.removeClass(spinner, 'slds-is-fixed');
        });
        $A.enqueueAction(action);

    },

    updateSelectedInterventions :function(component,event,helper){
        var checkInt = component.find('checkInt'); 
        var updatedMemInts = component.get('v.memInts');
        var intsToUpdate = [];  
        // loop through and add the checked rows to the update array to be passed to the apex controller
        if(!Array.isArray(checkInt)) {
            intsToUpdate.push.apply(intsToUpdate,updatedMemInts);
        } else {
            for(var i=0; i<checkInt.length; i++){
                if(checkInt[i].get('v.value') == true) {
                    intsToUpdate.push(updatedMemInts[i]);
                }
            }
        }
        //console.log('intsToUpdate: '+ JSON.stringify(intsToUpdate));

        action = component.get('c.updateInterventionActions');

        action.setParams({
            "interventionJSON" : JSON.stringify(intsToUpdate)
        });

        action.setCallback(this, function(response){ 
            var state = response.getState();
            if(state === "SUCCESS"){
                //populate success message
                component.set('v.isSubmitSuccess', true);
                component.set('v.submitSuccessMsg', $A.get('$Label.c.Member_Intervention_Success_Msg'));
                window.scrollTo(0,0);
                //requery the member interventions with updated action values
                helper.getMemberInterventions(component,event,helper, 1);
            }else{
                //console.log("error");
            }
            var spinner = component.find('spinnerId');
            $A.util.addClass(spinner, 'slds-hide');
            $A.util.removeClass(spinner, 'slds-is-fixed');
        });
        $A.enqueueAction(action);

    },

    getIntMeasureValues :function(component,event,helper){
            
        var action = component.get("c.getIntMeasures");
        var options = [];     
        //populates picklist values from server query of picklist values
        action.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                options.push(response.getReturnValue()[i]);
            }
            component.set("v.intMeasures", options);
        });

        $A.enqueueAction(action);
    },

    setIntMeasure :function(component,event,helper){
        //set component attribute to the value selected by user
        var intMes = component.find("intMeasures").get("v.value");

        if(intMes != 'Any'){
            component.set('v.intMeasure', intMes);
            
        }

        if(intMes == 'Any'){
            component.set('v.intMeasure', null);
        }

    },

    loadPageVariables : function(component, table){
        //loads page variables to show after a search (current page, total pages)
        var action = component.get('c.paginationVariables');
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                //console.log('loading pagination variables');
                var result = response.getReturnValue();
                //console.log(result);
                component.set('v.intPages', result[0]);
                component.set('v.intTotal', result[1]);
                component.set('v.intPage', result[2]);
                //console.log(component.get('v.intPages'));
                //console.log(component.get('v.intTotal'));
            }
        });

        $A.enqueueAction(action);

    },

}