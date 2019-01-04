({
    //gets available service locations for the selected business
    getServiceLocations: function(component, event, helper) {
        var showActiveOnly = component.get('v.showActiveOnly');

    	var busRecId = component.get('v.currentBusinessId');
        ////console.log('busId::'+busRecId);
        
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        //console.log('### providercache: ' + JSON.stringify(providercache));
        var resultList = [];
        var locationMap = providercache.locationMap;
        var activeLocations = providercache.cActiveLocationIds;

        ////console.log('locationMap::'+JSON.stringify(locationMap));
        var businessId2LocMap = providercache.cBusinessId2LocationIds;
        ////console.log('businessId2LocMap::'+JSON.stringify(businessId2LocMap));
        for(var bId in businessId2LocMap){
        	////console.log('i::'+bId);
        	if(bId.substring(0,15) == busRecId ){
        		for(var sLoc in businessId2LocMap[bId]){
        			var locId = businessId2LocMap[bId][sLoc];
                    if(showActiveOnly == true){
                        if(activeLocations.indexOf(locId)>=0){
                            locId = locId.substring(0,15);
                            ////console.log('some text', locId);
                            var location = locationMap[locId];
                            //console.log('location::'+JSON.stringify(location));
                            resultList.push(location);
                        }

                    } else{
            			locId = locId.substring(0,15);
            			var location = locationMap[locId];
            			resultList.push(location);
                    }


        		}
        		break;
        	}
        }
        
        component.set("v.locList", resultList);
        //console.log('### loclist: ' + JSON.stringify(resultList));
        var serviceLoc = component.get('v.locAcctRec');
        ////console.log('serviceLoc::'+JSON.stringify(serviceLoc));
        if(serviceLoc){
        	////console.log('service loc already set...');
        	component.find("locAccts").set("v.value", serviceLoc.Id);
            helper.getServiceLocationRecord(component, event, helper);
         } else {
             ////console.log('service loc not set...');
            if(resultList.length == 1){
                ////console.log('list size is 1...');
                component.find("locAccts").set("v.value", resultList[0].Id);
                helper.getServiceLocationRecord(component, event, helper); 
                
            } else{
                ////console.log('turn off spinner');
            
            }
        }
        	 //console.log('service loc done...');
        /*var acctRec = sessionStorage['businessid'];
        //console.log('acctRec::'+acctRec);
        var action = component.get("c.getAllLocationsPanelRoster");
        action.setParams({
            "bizAcctID" : acctRec
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var locations = response.getReturnValue();
                component.set("v.locList", locations);

                //add locations to location picklist
                var opts = [{ class: "picklistOption picklistOptionDefault", label: "Select One", value: "" }];
                for(i=0; i<locations.length; i++){
                    opts.push({class:"picklistOption  testScript_blp_location_"+locations[i].Id, label:locations[i].Service_Location_Name__c, value:locations[i].Id });
                }
                component.find("locAccts").set("v.options", opts);

                var locAcctRec = component.get("v.locAcctRec");
                if(locAcctRec){
                     component.find("locAccts").set("v.value", locAcctRec.Id);
                    helper.getServiceLocationRecord(component, event, helper);
                } else {
                    //if there is only one service location, make it the selected service location choice and retrieve that record
                    if(response.getReturnValue().length === 1){
                        component.find("locAccts").set("v.value", response.getReturnValue()[0].Id);
                        helper.getServiceLocationRecord(component, event, helper);
                    } else {
                        //turn off spinner
                        $A.util.addClass(component.find("spinnerIdBLP"), "slds-hide");

                    }
                }
            }
        });
        $A.enqueueAction(action);
         */
	},

    
    //this method runs when a user selects a location from the Service Location picklist.
    //gets the selected location record or removes provider option if the blank SL is selected
    getServiceLocationRecord : function(component, event, helper ) {
        var showActiveOnly = component.get('v.showActiveOnly');

    	////console.log('getLocId::');
        var slLocRecId = component.find("locAccts").get("v.value");
        var bizAcctId = component.get('v.currentBusinessId');
        slLocRecId = slLocRecId.substring(0,15);
        ////console.log(slLocRecId);
        ////console.log(bizAcctId);

        //get the client side cache
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        
        var resultList = [];
        var providerMap = providercache.providerMap;
        var locationMap = providercache.locationMap;

        ////console.log('got location map');
        // if(component.get('v.locAcctRec') == null || component.get('v.locAcctRec').Id.substring(0,15) != slLocRecId){
        	////console.log('loc different then what is stored');
    	component.set("v.locAcctRec", locationMap[slLocRecId]);
        // }
       ////console.log('providerMap::'+JSON.stringify(providerMap));
        var businessId2LocMap = providercache.cBusinessId2Location2ProvidersMap;
        var activeBusinessId2LocMap = providercache.activeBusinessId2Location2ProvidersMap;
        var providerRec = component.get('v.provAcctRec');
        var currentProvRecId = undefined;
        //console.log('prov::'+JSON.stringify(providerRec));
        if(providerRec != undefined && providerRec != null){
            if(providerRec.Id != undefined)
            	currentProvRecId = providerRec.Id.substring(0,15);
        }
        var foundProvider = false;
        ////console.log('businessId2LocMap::'+JSON.stringify(businessId2LocMap));
        //console.log('### how active: ' + showActiveOnly);
        if(showActiveOnly == true){
            for(var bId in activeBusinessId2LocMap){
                ////console.log('i::'+bId);
                ////console.log('slLocRecId::'+slLocRecId);
                if(bId.substring(0,15) == bizAcctId ){
                    for(var sLoc in activeBusinessId2LocMap[bId]){
                        ////console.log('sLoc::'+sLoc);
                        if(sLoc.substring(0, 15) == slLocRecId){
                            for(var provLoc in activeBusinessId2LocMap[bId][sLoc]){
                                ////console.log('provLoc::'+provLoc);
                                var provId = activeBusinessId2LocMap[bId][sLoc][provLoc];
                                provId = provId.substring(0,15);
                                var provider= providerMap[provId];
                                resultList.push(provider);

                                if(provId == currentProvRecId){
                                    foundProvider = true;
                                }
                                ////console.log('provider::'+JSON.stringify(provider));
                            }
                            break;
                        }
                    }
                }
            }
        } else {
            for(var bId in businessId2LocMap){
                ////console.log('i::'+bId);
                ////console.log('slLocRecId::'+slLocRecId);
                if(bId.substring(0,15) == bizAcctId ){
                    for(var sLoc in businessId2LocMap[bId]){
                        ////console.log('sLoc::'+sLoc);
                        if(sLoc.substring(0, 15) == slLocRecId){
                            for(var provLoc in businessId2LocMap[bId][sLoc]){
                                ////console.log('provLoc::'+provLoc);
                                var provId = businessId2LocMap[bId][sLoc][provLoc];
                                provId = provId.substring(0,15);
                                var provider= providerMap[provId];
        					    resultList.push(provider);

                                if(provId == currentProvRecId){
                                    foundProvider = true;
                                }
                                ////console.log('provider::'+JSON.stringify(provider));
            				}
            				break;
            			}
            		}
            	}
            }
        }
        ////console.log('resultList::'+resultList);
        component.set('v.provList', resultList);
        ////console.log('resultList::'+resultList.length);
        if(foundProvider){
            ////console.log('provider already set...');
            component.find("provAccts").set("v.value", providerRec.Id);
        } else {
            if(resultList.length == 1){
               var provId  = resultList[0].Id.substring(0,15);
               ////console.log('provId::'+provId);
               ////console.log(providerMap[provId]);
                component.find("provAccts").set("v.value", provId);
                component.set('v.provAcctRec', providerMap[provId]);
            } else {
            	component.set('v.provAcctRec', null);
            	component.find("provAccts").set("v.value", "");
            	//this.getProviderRecord(component, event, this);
            }
            
            
             
         } 
        //calling an action to the server side controller
       /* var action = component.get("c.getServiceLocationRecord");
        
        var slRecId = component.find("locAccts").get("v.value");

        //if picklist option changed to empty, delete record and provider list
        if(slRecId === ''){
            component.set("v.locAcctRec", "");
            component.set("v.provList", "");
            component.set("v.provAcctRec", "");

        } else {

            action.setParams({
                'serviceLocationId': slRecId
            });
            
            //creating a callback that is executed after the server side action is returned
            action.setCallback(this, function(response){
                //checking if the response is success
                if(response.getState() == 'SUCCESS'){       
                    var result = response.getReturnValue();          
                    component.set("v.locAcctRec", result);

                    //get providers for selected service location
                    helper.getProviders(component, event, helper);

                }else{
                    //setting the error flag and the message                
                    component.set("v.bln_isError",true);
                    component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
                }
            });
            $A.enqueueAction(action);
        }*/
    },

    getProviderRecord : function(component, event, helper ) {
    	var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        
        var providerMap = providercache.providerMap;
        var provId = component.find("provAccts").get("v.value");
        if(provId === ''){
        	component.set("v.provAcctRec", "");
        	
        } else {
        	provId = provId.substring(0,15);
        	component.set("v.provAcctRec", providerMap[provId]);
        	
        }
        //calling an action to the server side controller
        /*var action = component.get("c.getProviderRecord");
        
        var provId = component.find("provAccts").get("v.value");

        //if provider choice changed to empty, reset provider record
        if(provId === ''){
            component.set("v.provAcctRec", "");

        } else {
            
            action.setParams({
                'providerId': provId
            });
                
            //creating a callback that is executed after the server side action is returned
            action.setCallback(this, function(response){
                //checking if the response is success
                if(response.getState() == 'SUCCESS'){       
                    var result = response.getReturnValue();                
                    component.set("v.provAcctRec", result);
                }else{
                    //setting the error flag and the message                
                    component.set("v.bln_isError",true);
                    component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
                }
            });
            $A.enqueueAction(action);
        }*/
    }
})