({
	//checks if the required fields are populated
	checkButton : function(component, event, helper){
		//console.log('checking button');
		var memberNumber = component.get('v.memberNumber');
		var birthdate = component.get('v.birthdate');
		var serviceDate = component.get('v.serviceDate');
		var serviceLocation = component.get('v.locAcctRec');
		var provider = component.get('v.provAcctRec');

        var useServiceDate = component.get('v.useServiceDate');

		//console.log('memberNumber ' + memberNumber);
		//console.log('birthdate ' + birthdate);
		//console.log('serviceDate ' + serviceDate);
	    //console.log('serviceLocation ' + serviceLocation);
        //console.log('provider ' + provider);
        //console.log('useServiceDate ' + useServiceDate);
    
		//check to see if any blank values
        if(useServiceDate == false && (memberNumber == '' || memberNumber == undefined || birthdate == '' || birthdate == null   || serviceLocation == null || serviceLocation == '' || provider == null || provider == '')){
			component.set('v.turnOffCheckButton', true);
        } else if(useServiceDate == true && (memberNumber == '' || memberNumber == undefined || birthdate == '' || birthdate == null || serviceDate == ''  || serviceLocation == null || serviceLocation == '' || provider == null || provider == '')){
            component.set('v.turnOffCheckButton', true);
		} else {
            component.set('v.turnOffCheckButton', false);
        }

	},

    updateBLP : function(component, event, helper){
        //console.log('updateBLP');
        // helper.updateBLP(component, event, helper);   
        var slID = component.get("v.serviceLocationId");
        var pId = component.get("v.providerId");
        //console.log('slID ' + slID);
        //console.log('pId ' + pId );
        var location, provider;
        if(slID != '' && slID != undefined){
            var locationObj = helper.cache_ServiceLocation(component, slID);
            location = {
                Name : locationObj.Name,
                Id : slID,
                Service_Location_Name__c : locationObj.Service_Location_Name__c
            }
            component.set('v.locAcctRec', location);
        } 
		
        ////console.log('locationOBJ::'+ JSON.stringify(locationObj));

        if(pId != '' && pId != undefined){
            var providerObj = helper.cache_Provider(component, pId);
             var provider = {
                Name : providerObj.Name,
                Id : pId
            }
              component.set('v.provAcctRec', provider);   
        }
        
        ////console.log('provOBJ::'+ JSON.stringify(providerObj));
        


       
		////console.log('about to set the loc');
        //component.set('v.locAcctRec', location);   

       
        
    },

	//this function is called when the Check Eligiblity button is clicked
	//creates needed payload and sends to VF page
	runCheck : function(component, event, helper){
        //console.log('run check clicked');
        //turn off old errors
        component.set('v.isError', false);
        component.set('v.str_errorMsg', '');

        //check to make sure all fields are populated
        var memberNumber = component.get('v.memberNumber');
        var birthdate = component.get('v.birthdate');
        var serviceDate = component.get('v.serviceDate');
        var serviceLocation = component.get('v.locAcctRec');
        var provider = component.get('v.provAcctRec');
		var firstName = component.get('v.firstName');
        var lastName = component.get('v.lastName'); 
        console.log('provider ' + JSON.stringify(provider));
        console.log('serviceLocation ' + serviceLocation);
        console.log(' serviceDate ' + serviceDate);
        //console.log('serviceDate ' + serviceDate);

        var serviceFutureDateMax = new Date();
        serviceFutureDateMax.setDate(serviceFutureDateMax.getDate()+14);
        var differenceServiceDateFuture = serviceFutureDateMax - new Date(serviceDate);
        var differenceServiceDate = new Date() - new Date(serviceDate);
        var differenceBirthdate = new Date() - new Date(birthdate);
        console.log('differenceServiceDate ' + differenceServiceDate);
        console.log('differenceServiceDateFuture ' + differenceServiceDateFuture); 

        if(serviceLocation == '' || serviceLocation == null || provider == '' || provider == null){
            component.set('v.isError', true);
            component.set('v.str_errorMsg', $A.get('$Label.c.Select_Provider_and_Service_Location'));
        } /*else if (provider == '' || provider == null){
            component.set('v.isError', true);
            component.set('v.str_errorMsg', $A.get('$Label.c.Incomplete_Rows_Error_Message'));
        } */else if( birthdate == '' || birthdate == null) {
            component.set('v.isError', true);
            component.set('v.str_errorMsg', $A.get('$Label.c.No_Birthdate'));

        } else if (serviceDate == '' || serviceDate == null) {
            component.set('v.isError', true);
            component.set('v.str_errorMsg', $A.get('$Label.c.No_Service_Date'));

        } else if((memberNumber == '' || memberNumber == undefined) && ((firstName == '' || firstName == undefined) && (lastName == '' || lastName == undefined ))){
            component.set('v.isError', true);
            component.set('v.str_errorMsg', $A.get('$Label.c.Claims_Member_Eligibility_Check'));

        } else if( ( ( firstName != '' && firstName != undefined) && (lastName == '' || lastName == undefined ) ) || 
                   ( ( firstName == '' || firstName == undefined) && (lastName != '' && lastName != undefined ) ) 	){
            component.set('v.isError', true);
            component.set('v.str_errorMsg', $A.get('$Label.c.Member_DOB_and_ID_and_First_or_Last'));
        } /*else if (differenceServiceDateFuture < 0 || differenceServiceDate < 0) {
            component.set('v.isError', true);
            component.set('v.str_errorMsg', $A.get('$Label.c.Service_Date_Out_Of_Range'));
        
        }*/ else if (differenceBirthdate < 0) {
            component.set('v.isError', true);
            component.set('v.str_errorMsg', $A.get('$Label.c.No_Future_Birthday'));
        
        } else {

    		//console.log('run check helper');
           
    		//turn on spinner
    		$A.util.removeClass(component.find("searchSpinnerId"), "slds-hide");
            $A.util.addClass(component.find("searchSpinnerId"), "slds-is-fixed");

    		
    		var lastName = component.get('v.lastName');
    		var firstName = component.get('v.firstName');
    		var business = component.get('v.bizAcctRec.Id');
            var claim = component.get('v.claim');
    		var routeId = sessionStorage['portalconfig_lob'];
            //should only be populated when runnin the member eligibility for a member a second time.

            claim.Service_Location__c = serviceLocation.Id;
            claim.Provider__c = provider.Id;

            //console.log('claim: ' + claim);
            component.set('v.claim', claim);

            //holds the origin of the message originating from the Visual Force page
            var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
          	var vfWindow = component.find("vfFrame").getElement().contentWindow;

     		//make a member object to pass to controller
     		//turn service date into YYYY-MM-DD
     		//console.log('making a member');
     		var member = new Object();
     		member.serviceDate = serviceDate;
     		member.birthdate = birthdate;
     		member.memberNumber = memberNumber;
     		if(lastName != null && lastName != ''){
         		member.lastName = lastName;
     		}
     		if(firstName != null && firstName != ''){
         		member.firstName = firstName;
     		}
            member.claim = claim.Id;

    	   	//make an object to hold all parameters
    	   	//console.log('make a temp object');
            var temp = new Object();
            //change businessID to 15 char
            if(business.length == 18){
            	temp['business'] = business.substring(0,15);
            } else {
            	temp['business'] = business;
            }
            temp['serviceLocation'] = serviceLocation.Id;
            temp['provider'] = provider.Id;
            temp['routeId'] = routeId;
            temp['member'] = member;

            //turn object into JSON string
            var tempList = JSON.stringify(temp);
            //console.log('JSON message ' + tempList);
         	
         	//send to vf page
         	vfWindow.postMessage(tempList, vfOrigin);
        }
	}, 

	//this function is called by the listener after records have been returned from the VF page
	openModal : function(component, event, helper, eligibleList, ineligibleList, outOfNetworkList, notFoundList, notfoundMember){

		var bizAcctRec = component.get("v.bizAcctRec");
    	var locAcctRec = component.get("v.locAcctRec");
    	var provAcctRec = component.get("v.provAcctRec");
    	var serviceDate = component.get("v.serviceDate");   //2018-05-03

        var dateSplit = serviceDate.split("-");
        var serviceDateStr = dateSplit[1] + '/' + dateSplit[2] + '/' + dateSplit[0];

        var detailText = bizAcctRec.Name + ' - ' + locAcctRec.Service_Location_Name__c + ' - ' + provAcctRec.Name + ' - ' + serviceDateStr ;

    	//will hold records passed to modal
	   	var records = [];
	   	//counter to track the index of each item in records
    	var counter = 0;

    	//loop through eligible list and create record
    	for(var i=0; i < eligibleList.length; i++){
    		records.push({
	    		status : "Eligible",
	    		index : counter,
	    		detailText : 'Member is eligible: ' + detailText,
	    		record : eligibleList[i]
    		});
    		counter++;

    	}
    	//loop through ineligible list and create record
    	for(i=0; i < ineligibleList.length; i++){
			records.push({
	    		status : "Ineligible",
	    		index : counter,
	    		detailText : 'Member is ineligible: ' + detailText,
	    		record : ineligibleList[i]
    		});
    		counter++;
    	}
    	//loop through out of network list and create record
    	for(i=0; i < outOfNetworkList.length; i++){
			records.push({
	    		status : "Out of Network",
	    		index : counter,
	    		detailText : '['+detailText+'] is outside this Member\'s network.',
	    		record : outOfNetworkList[i]
    		});
    		counter++;
    	}
    	//loop through not found list and create record
    	for(i=0; i < notFoundList.length; i++){
			records.push({
	    		status : "Not Found",
	    		index : counter,
	    		detailText : 'Member is not found.',
	    		record : notFoundList[i]
    		});
    		counter++;
    	}

   		//console.log('Records: ' + JSON.stringify(records));

   		//turn off radio buttons if there is only 1 record to display
   		if(records.length == 1){
   			component.set("v.showRadioButtons", false);
   			//console.log('turn off radio buttons');
   		} else {
   			component.set("v.showRadioButtons", true);
   			//console.log('turn on radio buttons');
   		}

   		//set varibles needed
        if(!notfoundMember){
            //console.log('member found');
            component.set("v.serviceLocationId", locAcctRec.Id);
            component.set("v.providerId", provAcctRec.Id);            
        } else {
            //console.log('member not found');

        }
    	component.set("v.records", records);


    	//console.log('turn on modal');

		//turn on modal
        component.set("v.isOpen", true);

	},

    getAdditionalInformation: function(component, event, helper){
            //need to stamp info on the claim for subscriber and patient
            //if MemberProfileGuid != SubscriberProfileGuid
            // need to get subscriber Member Coverage record
            // then get addresses for member and subscriber coverage
            //address hierarchy is:
                // 1.  Residence
                // 2.  Mail
                // 3.  Alternate
        //console.log('get Additional info');
        var claim = component.get('v.claim');
        var selectedRecord = component.get('v.selectedRecord');
        //console.log('member MemberProfileGuid ' + selectedRecord.memberProfileGuid);
        //console.log('subscriber SubscriberProfileGUID ' + selectedRecord.subscriberProfileGuid);
        

        //calling an action to the server side controller save search
        var action = component.get("c.getAdditionalInfo");
                    
        action.setParams({
            'memberProfileGUID' : selectedRecord.memberProfileGuid,
            'subscriberProfileGUID': selectedRecord.subscriberProfileGuid,
            'planGUID': selectedRecord.planGUID
        });
        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response){
            //console.log('callback');
            //checking if the response is success
            if(response.getState() == 'SUCCESS'){       
                var result = response.getReturnValue();
                //set success toast message             
                if(result){
                    //console.log('result ' + JSON.stringify(result));
                    //set wrapper things

                    if(result.errorMessage == undefined){




                        //console.log('result.Subscriber_Last_Name ' + result.Subscriber_Last_Name);
                        //console.log('result.Subscriber_First_Name__c ' + result.Subscriber_First_Name__c);
                        //console.log('result.Subscriber_Birth_Date__c ' + result.Subscriber_Birth_Date__c);
                        if(result.Subscriber_Last_Name != undefined){
                            claim.Subscriber_Last_Name__c = result.Subscriber_Last_Name;
                        }
                        if(result.Subscriber_First_Name != undefined){
                            claim.Subscriber_First_Name__c = result.Subscriber_First_Name;
                        }
                        if(result.Subscriber_Birth_Date__c != undefined){
                            claim.Subscriber_Birth_Date__c = result.Subscriber_Birth_Date;
                        }
                        claim.Subscriber_Address1__c = result.Subscriber_Address1;
                        claim.Subscriber_Address2__c = result.Subscriber_Address2;
                        claim.Subscriber_City__c = result.Subscriber_City;
                        claim.Subscriber_State__c = result.Subscriber_State;
                        claim.Subscriber_Zip__c = result.Subscriber_Zip;
                        claim.Patient_Address1__c = result.Patient_Address1;
                        claim.Patient_Address2__c = result.Patient_Address2;
                        claim.Patient_City__c = result.Patient_City;
                        claim.Patient_State__c = result.Patient_State;
                        claim.Patient_Zip__c = result.Patient_Zip;

                        //set claim again
                        component.set('v.claim', claim);
                        //close modal
                        component.set("v.isOpen", false);
                        //open step 2
                        component.set("v.showClaimsPage", true);

                    } else {
                        //console.log('error');
                        component.set("v.isError",true);
                        component.set("v.str_errorMsg",result.errorMessage);  
                    }


                } else {
                    component.set("v.isError",true);
                    component.set("v.str_errorMsg","Error retrieving additional information");                                 
                    $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
                }
                //switching off spinner
                    $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
            }else{
                //setting the error flag and the message   
                //console.log('Error');             
                component.set("v.isError",true);
                component.set("v.str_errorMsg","Error retrieving additional information");
                $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
            }
        });
//        //console.log('made it here');
        $A.enqueueAction(action);
//        //console.log('made it here after');
    },
    
    getAvailableReferralPlans : function(component){
    	 var action = component.get("c.availableReferralPlans");
                    
        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response){
        	if(response.getState() == 'SUCCESS'){
        	//console.log('loaded availableReferralPlans');
        		component.set('v.referralPlans', response.getReturnValue());
        	}
        });
        
        $A.enqueueAction(action);
    },

    isPlanInList : function(listObj, planGuid){
        //console.log('isinlist');
        //console.log('is plan in list: ' + JSON.stringify(listObj) + ' ' + planGuid);
    	if(listObj == null || listObj == undefined || listObj.length == 0) return false;
    	planGuid = planGuid.toLowerCase();
    	for(var i in listObj){
    		if(listObj[i] == planGuid){
    			return true;
    		}
    	}
    	
    	return false;
    }
})