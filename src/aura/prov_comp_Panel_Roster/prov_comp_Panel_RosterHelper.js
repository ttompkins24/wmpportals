({

    NUM_RESULTS : 20,//Static variable for number of results per page

    getServiceLocations : function (component, event, helper){ 
        var busRecId = component.get('v.currentBusinessId');
        //console.log('busId::'+busRecId);
        
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        // console.log(providercache);
        var resultList = [];
        var locationMap = providercache.locationMap;
        var activeLocations = providercache.cActiveLocationIds;
//        console.log('locationMap::'+JSON.stringify(activeLocations));
        var businessId2LocMap = providercache.cBusinessId2LocationIds;
        //console.log('businessId2LocMap::'+JSON.stringify(businessId2LocMap));
        for(var bId in businessId2LocMap){
        	//console.log('i::'+bId);
        	if(bId.substring(0,15) == busRecId ){
        		for(var sLoc in businessId2LocMap[bId]){
        			var locId = businessId2LocMap[bId][sLoc];
                    
                    if(activeLocations.indexOf(locId)>=0){
                        locId = locId.substring(0,15);
                        //console.log('some text', locId);
                        var location = locationMap[locId];
//                        console.log('location::'+JSON.stringify(location));
        				resultList.push(location);
                    }
        		}
        		break;
        	}
        }
        
        component.set("v.locList", resultList);

        if(resultList.length == 1){
        	component.find("locAccts").set("v.value", resultList[0].Id);
            helper.getLocId(component, event, helper);
            
        } else{
        	//console.log('turn off spinner');
        	var spinner = component.find('spinnerId');
        	$A.util.addClass(spinner, 'slds-hide');
        
        }

    },

    getProviders :function(component, event, helper) {
        var busRecId = component.get('v.currentBusinessId');
        //console.log('busId::'+busRecId);
        
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        // console.log(providercache);
        var resultList = [];
        var providerMap = providercache.providerMap;
        // console.log('provider Map ' + providerMap);
        var activeLocations = providercache.cActiveLocationIds;
//        console.log('locationMap::'+JSON.stringify(activeLocations));
        var businessId2ProvMap = providercache.cBusinessId2ProviderIds;
        // console.log('businessId2ProvMap::'+JSON.stringify(businessId2ProvMap));
        for(var bId in businessId2ProvMap){
            // console.log('i::'+bId);
            if(bId.substring(0,15) == busRecId ){
                for(var prov in businessId2ProvMap[bId]){
                    // console.log('prov' + prov);
                    var provId = businessId2ProvMap[bId][prov];
                    provId = provId.substring(0,15);
                    var provider = providerMap[provId];
                    // console.log('provider' + provider);
//                        console.log('location::'+JSON.stringify(location));
                    resultList.push(provider);
                    
                }
                break;
            }
        }

        component.set("v.provList", resultList);

        if(resultList.length == 1){
            component.find("provAccts").set("v.value", resultList[0].Id);
            component.set('v.provAcctRecId', resultList[0].Id);
        }
        
    },
    //retrieves selected location ID
    getLocId: function(component, event, helper) {
        component.get("v.locAcctRecId", null);
        var selectedLocRec = component.find("locAccts").get("v.value");
        var bizAcctId = component.get('v.currentBusinessId');
        
        var slLocRecId = component.get("v.locAcctRecId");
        var provAcctId = component.get("v.provAcctRecId");
        // console.log('PROV ACCT ID from getLocId::' + provAcctId);
        slLocRecId = selectedLocRec.substring(0,15);

         if(selectedLocRec != 'Any'){

            component.set("v.locAcctRecId", selectedLocRec);

            var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        
            var resultList = [];
            var providerMap = providercache.providerMap;
            //console.log('providerMap::'+JSON.stringify(providerMap));
            var businessId2Loc2ProvMap = providercache.activeBusinessId2Location2ProvidersMap;


                for(var bId in businessId2Loc2ProvMap){

                if(bId.substring(0,15) == bizAcctId ){
                    for(var sLoc in businessId2Loc2ProvMap[bId]){
                        if(sLoc.substring(0, 15) == slLocRecId){
                            for(var provLoc in businessId2Loc2ProvMap[bId][sLoc]){
                                
                                var provId = businessId2Loc2ProvMap[bId][sLoc][provLoc];
                                provId = provId.substring(0,15);

                                var provider= providerMap[provId];
                                resultList.push(provider);
                            }
                        }
                    }
                    break;
                }
            }
            component.set("v.provList", resultList);
            if(resultList.length == 1){
                component.find("provAccts").set("v.value", resultList[0].Id);
                component.set('v.provAcctRecId', resultList[0].Id);
            } else {
                component.set('v.provAcctRecId', null);
            }

        }
        else {
            component.set("v.locAcctRecId", null);
            // console.log('get all providers');
            helper.getProviders(component,event,helper);
        }


    },

    //retrieves selected provider ID
    getProvId: function(component, event, helper) {
        component.get("v.provAcctRecId", null);
        var acctRecId = component.find("provAccts").get("v.value");
        var bizAcctId = component.get('v.currentBusinessId');
        var slLocRecId = component.get("v.locAcctRecId");
        // console.log('slLocRecId from getProvId' + slLocRecId);
        // console.log(acctRecId);

         if(acctRecId != 'Any'){
            // console.log('there');
            component.set("v.provAcctRecId", acctRecId);
            provAcctId = component.get("v.provAcctRecId");
            provAcctRecId = provAcctId.substring(0,15);

            // console.log('locList: ' + component.get('v.locList').length);


        } else {
            // console.log('everywhere');
        	component.set("v.provAcctRecId", null);
            if(slLocRecId == 'Any'){
                component.set("v.locAcctRecId", null);
            }


            // console.log('get all service locations');
        }
    },

    queryMembers: function(component,event,helper, sortDirection, pageNum, sortField){  
        //use this action to reference controller action that gets member info for panel roster
        
        component.set("v.searchActive", true);
        var locAcctRecId = component.get("v.locAcctRecId");
        var bizAcctRecId = component.get('v.currentBusinessId');
        var provAcctRecId = component.get("v.provAcctRecId");
        var numResult = '';
        
//        console.log('query members ' + numResult);
       

        var fName = component.find("firstNameInput").get("v.value");
        var lName = component.find("lastNameInput").get("v.value");
        component.set('v.fNameSearch', fName);
        component.set('v.lNameSearch', lName);

        var temp = new Object();
        temp['bizAcctId'] = bizAcctRecId;
        temp['locAcctId'] = locAcctRecId;
        temp['provAcctId'] = provAcctRecId;
        temp['firstNameSearch'] = fName;
        temp['lastNameSearch'] = lName;
        temp['sortDirection'] = sortDirection;
        temp['pageNumS'] = ''+pageNum;
        temp['sortField'] = ''+sortField;
        temp['numResultsS'] = ''+this.NUM_RESULTS;
        temp['routeId'] = sessionStorage['portalconfig_lob'];

        var tempList = JSON.stringify(temp);

        console.log('tempList ' + tempList);

		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';

    	// var vfOrigin = "https://dev1-greatdentalplans-community.cs13.force.com/Provider/";
		window.scrollTo(0,0);			

    	var vfWindow = component.find("vfFrame").getElement().contentWindow;
    	vfWindow.postMessage(tempList, vfOrigin);
    	// console.log('finished post message');
    },
    
    downloadMembers: function(component,event,helper, sortDirection, pageNum, sortField){  
        //use this action to reference controller action that gets member info for panel roster
        
        component.set("v.searchActive", true);
        var locAcctRecId = component.get("v.locAcctRecId");
        var bizAcctRecId = component.get('v.currentBusinessId');
        var provAcctId = component.find("provAccts").get("v.value");
        if (provAcctId === 'Any'){
            component.set("v.provAcctRecId", null);
        }
        var provAcctRecId = component.get("v.provAcctRecId");
        var numResult = '';
        
       

        var fName = component.find("firstNameInput").get("v.value");
        var lName = component.find("lastNameInput").get("v.value");
        component.set('v.fNameSearch', fName);
        component.set('v.lNameSearch', lName);
        // console.log('setting params');
        var temp = new Object();
        temp['bizAcctId'] = bizAcctRecId;
        temp['locAcctId'] = locAcctRecId;
        temp['provAcctId'] = provAcctRecId;
        temp['firstNameSearch'] = fName;
        temp['lastNameSearch'] = lName;
        temp['sortDirection'] = sortDirection;
        temp['pageNumS'] = ''+pageNum;
        temp['sortField'] = ''+sortField;
        temp['numResultsS'] = '10000';
        temp['routeId'] = sessionStorage['portalconfig_lob'];
        temp['download'] = 'true';
//        console.log('state::'+state);
       var tempList = JSON.stringify(temp);

        // console.log('tempList ' + tempList);

		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';

    	// var vfOrigin = "https://dev1-greatdentalplans-community.cs13.force.com/Provider/";
		window.scrollTo(0,0);			

    	var vfWindow = component.find("vfFrame").getElement().contentWindow;
    	vfWindow.postMessage(tempList, vfOrigin);
    },

    downloadCsv :function(component, data){
        var headers = ["Member Number", "Birth Date", "First Name", "Last Name","Effective Date", "Phone Number", "Address", "Language", "Plan Type", "Provider", "Service Location Address"];
        var apiNames = ["memberNumber", "birthDate", "firstName", "lastName", "effectiveDate", "phone", "address", "language", "planName", "ProviderName", "ServiceOfficeAddress"];
        if (data == null || !data.length){
            return null
        }

        var csvResult = '';
        csvResult += headers.join(',');
        csvResult += '\n';

        for(var i=0; i < data.length; i++){
            var counter = 0
            for(var sTempkey in apiNames){
                var skey = apiNames[sTempkey];

                if(counter >0){
                    csvResult += ',';
                }
                //get value by key
                if(data[i][skey] != undefined)
                	csvResult += '"'+ data[i][skey]+'"';
                else
                	csvResult += '""';
                counter++;
            }
            csvResult += '\n';
        }
        return csvResult;
    },

    /*
        Generate a message at the top of the screen. Accepts error and success as typeOfMessage and the message will be set based on the passed in info
       */
     generateMessage : function(component, typeOfMessage, message){
         //reinitialize the message notifs
         component.set('v.isSuccess', false);
         component.set('v.isError', false);
         
         //remove the hide class on the elements (hide gets applied when a user clicks the close on the message
         $('.errorMessageWrap').removeClass('hide');
         $('.successMessageWrap').removeClass('hide');
         
         //if type is error
         if(typeOfMessage == 'error'){
             component.set('v.isError', true);
             component.set('v.str_errorMsg', message);
         } else if (typeOfMessage == 'success'){// type is success
             component.set('v.isSuccess', true);
             component.set('v.str_successMsg', message);
         
         }
         window.scrollTo(0,0);
     },
})