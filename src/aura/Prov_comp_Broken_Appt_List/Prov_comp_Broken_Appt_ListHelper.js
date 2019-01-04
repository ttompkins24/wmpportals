({
    NUM_RESULTS : 20,//Static variable for number of results per page
	//reteives list of businesses 
    retrieveBizList: function(component, event, helper){
        //get current business on page load
        var action = component.get("c.getAllBusinessesPanelRoster"); 
        action.setCallback(this, function(response){
        var state = response.getState();
        if(state === "SUCCESS"){
            component.set("v.bizAcctRec", response.getReturnValue());
            var bizAcctRec = component.get("v.bizAcctRec");
            var bizAcctRecId = bizAcctRec.Id;
            component.set("v.bizAcctRecId", bizAcctRecId);
            helper.getServiceLocations(component, event, helper);
            }
        });
        $A.enqueueAction(action);
        
    },
    //get list of service locations based on Business
    getServiceLocations : function (component, event, helper){

        var acctRecId = component.get("v.bizAcctRecId");
        var action1 = component.get("c.getAllLocationsPanelRoster");
        action1.setParams({
            "bizAcctId" : acctRecId
        });

        action1.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
                component.set("v.locList", res.getReturnValue());

                if(res.getReturnValue().length === 1){
                component.find("locAccts").set("v.value", res.getReturnValue()[0]);
                        helper.getLocId(component, event, helper);
                    
                }
            }
        });
        $A.enqueueAction(action1);
    },
    //retrieves selected location ID
    getLocId: function(component, event, helper) {
        var selectedLocRec = component.find("locAccts").get("v.value");
        
        var bizAcctId = component.get("v.bizAcctRecId");
        component.set("v.locAcctRecId", selectedLocRec);
        slLocRecId = component.get("v.locAcctRecId");
		////console.log('change location: ' + selectedLocRec + ' : ' + bizAcctId);
        var action2 = component.get("c.getAllProvPanelRoster");
                action2.setParams({
                    "bizAcctId" : bizAcctId,
                    "locAcctId" : selectedLocRec
                });
            	action2.setCallback(this,function(response){
                	var state = response.getState();
                    ////console.log("provCB: " + state + " " + response.getReturnValue());
            		component.set("v.provList", response.getReturnValue());

        		});
        $A.enqueueAction(action2);
    },

    //retrieves selected provider ID
    getProvId: function(component, event, helper) {
        var acctRecId = component.find("provAccts").get("v.value");
        if(acctRecId != 'Any'){
            component.set("v.provAcctRecId", acctRecId);
        } else {
        	component.set("v.provAcctRecId", undefined);
        }
    },

    loadPageVariables : function(component){
        //loads page variables to show after a search (current page, total pages)
        var action = component.get('c.paginationVariables');
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.pages', result[0]);
                component.set('v.total', result[1]);
                component.set('v.page', result[2]);
            }
        });

        $A.enqueueAction(action);

    },

    //gets all broken appointments(cases) based on location, provider, and member name/number search criteria
    getBrokenAppts :function(component,event,helper, pageNum, field, direction){
        component.set("v.searchActive", true);
        var locAcctRecId = component.get("v.locAcctRecId");
        var provAcctRecId = component.get("v.provAcctRecId");
        //console.log('provAcctRecId::'+provAcctRecId);
        //get values from field inputs and set them to attributes
        var firstName = component.find("firstNameInput").get("v.value");
        var lastName = component.find("lastNameInput").get("v.value");
        var memNumber = component.find("memIdInput").get("v.value");
        component.set("v.fNameSearch", firstName);
        component.set("v.lNameSearch", lastName);
        component.set("v.memberNumber", memNumber);

        action = component.get('c.getBrokenAppointments');
        //turn on spinner
        var spinner = component.find('searchSpinnerId');
        $A.util.removeClass(spinner, 'slds-hide');

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
            "servLocId" : locAcctRecId,
            "providerId" : provAcctRecId,
            "fName" : firstName,
            "lName" : lastName,
            "memNum" : memNumber,
            "fieldS" : field,
            "directionS" : direction,
            "numResultsS" : numResult,
            "pageNumS" : page
            
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
            if(state === "SUCCESS"){  
                var totalResults = response.getReturnValue();
            var pageNum = Number(page);
            var numRes = Number(numResult);
            var resultList = [];
            //iterates through total results and adds results to the page based on number of results set
            for(i = ((pageNum-1) * numRes); i < totalResults.length; i++){
                resultList.push(totalResults[i]);
                
                if(resultList.length == numResult) break;
            }
            component.set('v.apptList', resultList);
            
            //show no results element if no results are returned
            if(response.getReturnValue().length < 1){
                component.set('v.noResults', true);
            }
            if(response.getReturnValue().length >= 1){
                component.set('v.noResults', false);
            }
            } else{
            //console.log("error");
            message = errors[0].message;
            //console.log(message);
            }
        });
        $A.enqueueAction(action);
    },

    checkForErrors : function(component,event,helper){
        var locationId = component.get("v.locAcctRecId");
        if(locationId == null || locationId == 'Select One'){
            //console.log("errors found");
            component.set("v.locationError", true);
            component.set("v.locationErrorMsg", "Please choose a location")
        }
    },

    downloadCsv :function(component, data){
    	//console.log('data::'+data);
        //set headers for CSV
        var headers = ["Member First Name", "Member Last Name","Member Number", "Reason Code", "Broken Appointment Date", "Provider"];
        //set attributes for each row in CSV
        var apiNames = ["Provider_Portal_Member_First_Name__c", "Provider_Portal_Member_Last_Name__c", "Subscriber_ID__c", "Reason_Code__c", "Service_Date__c", "Provider"];
        if (data == null || !data.length){
            return null
        }
        
        var csvResult = '';
        csvResult += headers.join(',');
        csvResult += '\n';
        //iterate through data and add to reach row/column
        for(var i=0; i < data.length; i++){ 
            var counter = 0;
            for(var sTempkey in apiNames){
                var skey = apiNames[sTempkey];
                if(counter >0){
                    csvResult += ',';
                }
                //get value by key
                //console.log('data[i].Provider__c::'+data[i].Provider__c);
                if(skey == 'Provider' && data[i].Provider__c != undefined){
                	csvResult += '"'+ data[i].Provider__r.Name+'"';
                }else{
                	if(data[i][skey] == undefined){
                		csvResult += '""';
                	}else{
                		csvResult += '"'+ data[i][skey]+'"';
                	}
                }
                
                counter++;
            }
            csvResult += '\n';
        }
        //console.log('csvResult::'+csvResult);
        return csvResult;
    }
})