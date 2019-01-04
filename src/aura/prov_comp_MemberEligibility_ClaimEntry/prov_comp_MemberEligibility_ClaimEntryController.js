({
	doInit : function(component, event, helper) {
//        //console.log('claim entry eligibility init');
        var useServiceDate = component.get('v.useServiceDate');
//        //console.log('useServiceDate ' + useServiceDate);
		
		if(component.get('v.serviceDate') == undefined || component.get('v.serviceDate') == ''){
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
			component.set('v.serviceDate', today);
		}
        //console.log('claim ' + JSON.stringify(component.get('v.claim')));

        var slID = component.get("v.serviceLocationId");
        var pId = component.get("v.providerId");
//        //console.log('slID ' + slID);
        console.log('pId ' + pId );


        helper.updateBLP(component, event, helper);  
        helper.checkButton(component, event, helper);
        
        if(component.get('v.claimType') == 'REFERRAL')
        	helper.getAvailableReferralPlans(component);

        //holds the origin of the message originating from the Visual Force page for eligibility check
        var origin = $A.get('$Label.c.Member_Eligibility_VF_URL');
        component.set('v.vfHost', origin);


       //listener for callback from VF page on eligibility check
        window.addEventListener("message", function(event) {


            var bizAcctRec = component.get("v.bizAcctRec");
            var locAcctRec = component.get("v.locAcctRec");
            var provAcctRec = component.get("v.provAcctRec");
            var serviceDate = component.get("v.serviceDate");
            var claimType = component.get('v.claimType');
            
//            //console.log('locAcctRec ' + JSON.stringify(locAcctRec));
//            //console.log('provAcctRec ' + JSON.stringify(provAcctRec));

        	var isModalNeeded = false;
        	var title = '';
        	var type = '';

            //console.log('return listener');
            var origin = component.get('v.vfHost');
            if(event.origin !== origin) {
                //not the expected origin. reject results
//                //console.log('origins did not match');
                return;
            }

            //Handle the message
            var results = event.data;
            
            if(results == 'pageLoaded'){
            	component.set('v.checkButtonDisabled', false);
            	return;
            }

            if(results != null){
            	var eligibleList = results['eligible'];
            	var ineligibleList = results['ineligible'];
            	var outOfNetworkList = results['outOfNetwork'];
            	var notFoundList = results['notFound'];

            	//console.log('callout results ' + JSON.stringify(results));
            	//console.log('eligible size ' + eligibleList.length);
            	//console.log('total size ' + (eligibleList.length + ineligibleList.length + outOfNetworkList.length + notFoundList.length));

                var notFoundMember = false;

            	//multiple plans
            	if((eligibleList.length + ineligibleList.length + outOfNetworkList.length + notFoundList.length) > 1){
            		isModalNeeded = true;
            		title = 'Member has Multiple Plan Coverage';
            		type = 'multiplePlans';
            	}

            	//out of network
            	else if(outOfNetworkList.length > 0) {
            		isModalNeeded = true;
            		title = 'Member is Out-of-Network';
            		type='outOfNetwork';

                     if(outOfNetworkList.length == 1){
//                        //console.log('only 1 ineligible');
                        var outOfNetwork = outOfNetworkList[0];
//                        //console.log('outOfNetwork ' + JSON.stringify(outOfNetwork) );
                        var memCov = outOfNetwork.memCov[0];
                        var claim1 = component.get('v.claim');

                        var dateSplit = serviceDate.split("-");
                        var serviceDateStr = dateSplit[1] + '/' + dateSplit[2] + '/' + dateSplit[0];

                        var detailText = bizAcctRec.Name + ' - ' + locAcctRec.Service_Location_Name__c + ' - ' + provAcctRec.Name + ' - ' + serviceDateStr ;
//                        //console.log('detailText ' + detailText );
//                        //console.log('plain ' + outOfNetwork.memCov[0].PlanName__c);
//                        //console.log('unescape ' + unescape(outOfNetwork.memCov[0].PlanName__c));
//                        //console.log('escape ' + escape(outOfNetwork.memCov[0].PlanName__c));
//                        //console.log('decode ' + decodeURI(outOfNetwork.memCov[0].PlanName__c));
//                        //console.log('encode ' + encodeURI(outOfNetwork.memCov[0].PlanName__c));
                        
                        //set claim fields
                        claim1.Last_Eligibility_Check_Information__c = '['+detailText+'] is outside this Member\'s network.'; 
                        claim1.Last_Eligibility_Status__c = 'Out of Network';
                        claim1.Plan_Text__c = unescape(outOfNetwork.planType);
                        claim1.Plan_GUID__c = outOfNetwork.memCov[0].PlanGUID__c;
                        claim1.Subscriber_Last_Name__c = outOfNetwork.memCov[0].LastName__c;
                        claim1.Subscriber_First_Name__c = outOfNetwork.memCov[0].FirstName__c;
                        claim1.Subscriber_Birth_Date__c = outOfNetwork.memCov[0].Birthdate__c;
                        claim1.Subscriber_ID__c = outOfNetwork.memCov[0].SubscriberId__c;
                        claim1.Patient_First_Name__c = outOfNetwork.memCov[0].FirstName__c;
                        claim1.Patient_Last_Name__c = outOfNetwork.memCov[0].LastName__c;
                        claim1.Patient_Birth_Date__c = outOfNetwork.memCov[0].Birthdate__c;
                        claim1.Patient_Member_Profile_GUID__c = outOfNetwork.memberProfileGuid;

                        component.set('v.selectedRecord', outOfNetwork);
                        component.set('v.claim', claim1 );
                        component.set("v.memCovSelected", memCov);
                        //console.log('end out of newtwork');
                    }
            	}
               
                // ineligible
            	else if(ineligibleList.length > 0){
            		isModalNeeded = true;
            		title = 'Member is Not Eligible';
            		type = 'ineligible';

                    if(ineligibleList.length == 1){
//                        //console.log('only 1 ineligible');
                        var ineligible = ineligibleList[0];
//                        //console.log('ineligible ' + JSON.stringify(ineligible) );
                        var memCov = ineligible.memCov[0];
                        var claim1 = component.get('v.claim');

                        var dateSplit = serviceDate.split("-");
                        var serviceDateStr = dateSplit[1] + '/' + dateSplit[2] + '/' + dateSplit[0];

                        var detailText = bizAcctRec.Name + ' - ' + locAcctRec.Service_Location_Name__c + ' - ' + provAcctRec.Name + ' - ' + serviceDateStr ;
                        //console.log('detailText ' + detailText );
                        //console.log('made it this far');
                        claim1.Last_Eligibility_Check_Information__c = 'Member is ineligible: ' + detailText;
                        claim1.Last_Eligibility_Status__c = 'Ineligible';
                        claim1.Plan_Text__c = ineligible.planType;
                        claim1.Plan_GUID__c = ineligible.planGUID;
                        claim1.Subscriber_Last_Name__c = ineligible.lastName;
                        claim1.Subscriber_First_Name__c = ineligible.firstName;
                        claim1.Subscriber_Birth_Date__c = ineligible.birthDate;
                        claim1.Subscriber_ID__c = ineligible.memberNumber;
                        claim1.Patient_First_Name__c = ineligible.firstName;
                        claim1.Patient_Last_Name__c = ineligible.lastName;
                        claim1.Patient_Birth_Date__c = ineligible.birthDate;
                        claim1.Patient_Member_Profile_GUID__c = ineligible.memberProfileGuid;
                        component.set('v.selectedRecord', ineligible);
                        component.set('v.claim', claim1 );
                        component.set("v.memCovSelected", memCov);

//                        //console.log('end ineligibile');
                    }

            	}
               
                //not found
                else if(notFoundList.length > 0){
                    isModalNeeded = true;
                    title = 'The member you entered is not found. Please check the information and try again.';
                    type = 'notFound';
                    component.set('v.hideContinue', true);
                    notFoundMember = true;
                }

				var selectedRecord = component.get('v.selectedRecord');
                
            	if(isModalNeeded){
//            		//console.log('create modal');
                    component.set('v.title', title);
                    $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
                    helper.openModal(component, event, helper, eligibleList, ineligibleList, outOfNetworkList, notFoundList, notFoundMember);
            	} else if(component.get('v.claimType') == 'REFERRAL' && eligibleList != null && !helper.isPlanInList(component.get('v.referralPlans'), eligibleList[0].memCov[0].PlanGUID__c)){
            		//render error
            		 $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
            		component.set('v.str_errorMsg', $A.get('$Label.c.Referral_Error_Not_Required'));
            		component.set('v.isError', true);
            	} else{
                    //only 1 eligibile found
            		//set to appropriate record
//                    //console.log('only 1 eligible');
//                    //console.log('eligibleList ' + JSON.stringify(eligibleList));
            		var locAcctRec = component.get("v.locAcctRec");
            		var provAcctRec = component.get("v.provAcctRec");
            		console.log('provAcctRec::'+JSON.stringify(provAcctRec));
            		component.set("v.serviceLocationId", locAcctRec.Id);
            		component.set("v.providerId", provAcctRec.Id);  
            		   
                    var eligible = eligibleList[0];
                    //console.log('eligible selected ' + JSON.stringify(eligible));
                    var memCov = eligible.memCov[0];
                    var claim = component.get('v.claim');

                    var dateSplit = serviceDate.split("-");
                    var serviceDateStr = dateSplit[1] + '/' + dateSplit[2] + '/' + dateSplit[0];
                    var detailText = bizAcctRec.Name + ' - ' + locAcctRec.Service_Location_Name__c + ' - ' + provAcctRec.Name + ' - ' + serviceDateStr ;

                    memCov.detail = 'Member is eligible: ' + detailText;
                    memCov.status = 'eligible';
                    claim.Last_Eligibility_Check_Information__c = 'Member is eligible: ' + detailText;
                    claim.Last_Eligibility_Status__c = 'Eligible';
                    claim.Plan_Text__c = eligible.planType;
                    claim.Plan_GUID__c = eligible.memCov[0].PlanGUID__c;
                    claim.Subscriber_Last_Name__c = eligible.memCov[0].LastName__c;
                    claim.Subscriber_First_Name__c = eligible.memCov[0].FirstName__c;
                    claim.Subscriber_Birth_Date__c = eligible.memCov[0].Birthdate__c;
                    claim.Subscriber_ID__c = eligible.memCov[0].SubscriberId__c;
                    claim.Patient_First_Name__c = eligible.memCov[0].FirstName__c;
                    claim.Patient_Last_Name__c = eligible.memCov[0].LastName__c;
                    claim.Patient_Birth_Date__c = eligible.memCov[0].Birthdate__c;
                    claim.Patient_Member_Profile_GUID__c = eligible.memberProfileGuid;


                    component.set('v.selectedRecord', eligible);
                    component.set('v.claim', claim );
                    component.set("v.memCovSelected", memCov);
                    //console.log('made it here');
                    // $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
                    component.set('v.callAdditionalInfo', true);
                    // component.additionalInfoMethod();
                    // helper.getAdditionalInformation(component, event, helper);
            	}
            } else {
                //setting the error flag and the message    
                window.scrollTo(0,0);           
                component.set("v.isError",true);            
            }
        }, false);
//        //console.log('claimType::'+component.get('v.claimType'));
        
        	
	},

    updateBLP : function(component, event, helper){
        helper.updateBLP(component, event, helper);  
    },

    //checks to make sure all fields required are entered, then submits the inputs for eligiblity check
	runCheck : function(component, event, helper){
        //reset hide flag
        component.set('v.hideContinue', false);
        helper.runCheck(component, event, helper);

	},

    refreshCheck : function(component, event, helper){
        //console.log('in refreshCheck');
        var checkAgain = component.get('v.runCheckAgain');
        //console.log('running check again: ' + checkAgain);
        if(checkAgain == true){
            checkAgain=false;
            component.set('v.runCheckAgain', false);
            helper.runCheck(component, event, helper);
        }
    },

	fixDate : function(component, event, helper) {
       helper.fixDate(component, event);
       helper.checkButton(component, event, helper);

    },

    checkButton : function(component, event, helper){
    	helper.checkButton(component, event, helper);
    },

    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },

    onRadio : function(component, event, helper){
        component.set('v.isModalError', false);
        component.set('v.str_modalErrorMsg', '');

        var ctarget = event.currentTarget;
        var index = ctarget.dataset.index;
        //console.log('record ' + index);

        var records = component.get("v.records");

        var rec = records[index];

        var claim = component.get('v.claim');

        //console.log('record1 ' + rec.status);
        //console.log('record2 ' + rec.record.memCov[0].PlanName__c);

        rec.record.memCov[0].detail = rec.detailText;
        rec.record.memCov[0].status = rec.status;
        claim.Last_Eligibility_Check_Information__c = rec.detailText;
        claim.Last_Eligibility_Status__c = rec.status;
        claim.Plan_Text__c = rec.record.planType;
        claim.Plan_GUID__c = rec.record.memCov[0].PlanGUID__c;
        claim.Subscriber_Last_Name__c = rec.record.memCov[0].LastName__c;
        claim.Subscriber_First_Name__c = rec.record.memCov[0].FirstName__c;
        claim.Subscriber_ID__c = rec.record.memCov[0].SubscriberId__c;
        claim.Patient_First_Name__c = rec.record.memCov[0].FirstName__c;
        claim.Patient_Last_Name__c = rec.record.memCov[0].LastName__c;
        claim.Patient_Birth_Date__c = rec.record.memCov[0].Birthdate__c;
        claim.Patient_Member_Profile_GUID__c = rec.record.memberProfileGuid;
        component.set('v.claim', claim );
        // component.set('v.firstName', eligible.memCov[0].FirstName__c);
        // component.set('v.lastName', eligible.memCov[0].LastName__c);
        component.set('v.selectedRecord', rec.record);
        component.set("v.memCovSelected", rec.record.memCov[0]);

    },

    onContinue :  function(component, event, helper){
        var selectedRecord = component.get('v.selectedRecord');

        var hasRadio = component.get('v.showRadioButtons');
        //check if modal has radio buttons, if true, check to make sure one is checked
        if (hasRadio == true && !($('input[name=planButtons]:checked').length > 0)) {
            //console.log('zero radio button clicked');
            component.set('v.isModalError', true);
            component.set('v.str_modalErrorMsg', 'Please select a Plan.');
        } 
        //no radio buttons or one is clicked
        else {
        	
        	if(component.get('v.claimType') !='REFERRAL' || helper.isPlanInList(component.get('v.referralPlans'), selectedRecord.memCov[0].PlanGUID__c) ){
	            $A.util.removeClass(component.find("searchSpinnerId"), "slds-hide");
	            $A.util.addClass(component.find("searchSpinnerId"), "slds-is-fixed");
	            //console.log('continue clicked - call helper');  
	            helper.getAdditionalInformation(component, event, helper);
        	} else {
        		component.set('v.isModalError', true);
        		component.set('v.str_modalErrorMsg', $A.get('$Label.c.Referral_Error_Not_Required'));
        	}
        }
    },

    getAdditionalInformation: function(component, event, helper){
        $A.util.removeClass(component.find("searchSpinnerId"), "slds-hide");
        $A.util.addClass(component.find("searchSpinnerId"), "slds-is-fixed");


        //console.log('incontroller getAdditionalInformation');
        helper.getAdditionalInformation(component, event, helper);
    }
 
})