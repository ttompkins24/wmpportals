({
	doInit : function(component, event, helper) {
        //console.log('init start');

       //holds the origin of the message originating from the Visual Force page
        var origin = $A.get('$Label.c.Member_Eligibility_VF_URL');
        component.set('v.vfHost', origin);

        var labelName = component.get('v.portalConfig.PreAuthorization_Label__c');
 		labelValue = $A.getReference('$Label.c.' + labelName);
 		
 		//console.log('pre auth label: ' + labelValue);

 		component.set('v.preAuthLabel', labelValue);

        helper.getAuthDrafts(component);
        helper.setSuppressWarning(component, helper); 
        //console.log('init end');

        //listener for callback from VF page
        window.addEventListener("message", function(event) {
            //console.log('return listener');
            //console.log('event.origin ' + event.origin);
            var origin = component.get('v.vfHost');
            if(event.origin !== origin) {
                //not the expected origin. reject results
                //console.log('origins did not match');
                return;
            }

            //Handle the message
            var results = event.data;

            if(results != null){
                var auths = component.get("v.authDrafts");
                 if(results.hasOwnProperty('timeout')){
                    component.set("v.isError",true);
                    component.set("v.str_errorMsg",$A.get("$Label.c.Server_No_Response_Error"));
                    
                    if(results.hasOwnProperty('claimId')){
                        var dataMap = JSON.parse(results);
                        var failedClaim = dataMap.claimId;
                        //console.log('failedClaim::'+failedClaim);
                        for(var i=0; i<auths.length; i++){
                            if(auths[i].Id === failedClaim){
                                //console.log('claim found ineligible');
                                auths[i].eligible = 'Error - Please retry'; 
                                auths[i].isSearching = false;
                                //auths[i].Last_Eligibility_Check__c = now;
                            }
                        }
                    }
                    $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
                    window.scrollTo(0,0);           

                } else {
                    
                    
                    //check to see if member is in eligible or ineligible list
                    var eligible = results['eligible'];
                    var ineligible = results['ineligible'];
                    var notFound = results['notFound'];
                    var outOfNetwork = results['outOfNetwork'];
    
                    
    
                    //todays date for last checked field                
                    var now = Date.now()
                    //console.log('now');
                    var alreadyFound = false;
                    if(eligible.length > 0){
                        //console.log('claim found eligible');
                        alreadyFound = true;
                        //member eligible
                        //get the claim ID.   only one should be returned in list
                        var claimId = eligible[0].claim;
                        //loop through claims, find it and update it 
                        for(var i=0; i<auths.length; i++){
                            if(auths[i].Id === claimId){
                                //console.log('claim found eligible');
                                auths[i].eligible = 'Eligible';
                                auths[i].isSearching = false;
                                auths[i].Last_Eligibility_Check__c = now;
                                ////console.log('claim after return changes' + JSON.stringify(claims[i]));
                            }
                        }
                    } 
                    else if(ineligible.length > 0){
                        //console.log('claim found ineligible');
                        alreadyFound = true;
                        //member ineligible
                        //get the claim ID.   only one should be returned in list
                        var claimId = ineligible[0].claim;
                        //console.log('claimId ' + claimId);
                        //loop through auths, find it and update it 
                        for(var i=0; i<auths.length; i++){
                            if(auths[i].Id === claimId){
                                //console.log('claim found ineligible');
                                auths[i].eligible = 'Ineligible';
                                auths[i].isSearching = false;
                                auths[i].Last_Eligibility_Check__c = now;
                            }
                        }
                    }
                    else if (outOfNetwork.length > 0){
                    	 alreadyFound = true;
                        //member ut of network
                        //get the claim ID.   only one should be returned in list
                        var claimId = outOfNetwork[0].claim;
                        //console.log('claimId ' + claimId);
                        //loop through claims, find it and update it 
                        for(var i=0; i<auths.length; i++){
                            if(auths[i].Id === claimId){
                                //console.log('claim found out of network');
                                auths[i].eligible = 'Out of Network';
                                auths[i].isSearching = false;
                                auths[i].Last_Eligibility_Check__c = now;
                            }
                        }
                    } 
                     if(!alreadyFound){
    
    
                        //member not found
                        //get the claim ID.   only one should be returned in list
                        var claimId = notFound[0].claim;
                        //loop through claims, find it and update it 
                        for(var i=0; i<auths.length; i++){
                            if(auths[i].Id === claimId){
                                //console.log('claim found Not Found');
                                auths[i].eligible = 'Not Found';
                                auths[i].isSearching = false;
                                auths[i].Last_Eligibility_Check__c = now;
                            }
                        }
                    }
    
                    component.set("v.authDrafts", auths);
                }

                


        
            } else {
                //setting the error flag and the message    
                window.scrollTo(0,0);           
                component.set("v.isError",true);            
            }
        }, false);


    },

    handleSingleRowUpdate: function(component, event, helper) {
        helper.deleteSingleDraft(component, event, helper);
    },

    handleMultipleRowUpdate : function(component, event, helper) {
        //console.log('handleMultipleRowUpdate start');

        helper.deleteMultipleDrafts(component, event, helper);
       
        //console.log('handleMultipleRowUpdate end');
    },
    
    submitSelectedDrafts : function(component, event, helper) {
        //console.log('submitSelectedDrafts start');

        var checkDraft = component.find('checkDraft'); 
		var updatedAuthDrafts = component.get('v.authDrafts');
        var draftsToSubmit = [];
        
        // loop through and add the checked rows to the update array to be passed to the apex controller
        if(!Array.isArray(checkDraft)) {
            draftsToSubmit.push.apply(draftsToSubmit,updatedAuthDrafts);
        } else {
            for(var i=0; i<checkDraft.length; i++){
                if(checkDraft[i].get('v.value') == true) {
                    draftsToSubmit.push(updatedAuthDrafts[i]);
                }
            }
        }
		// //console.log('draftsToSubmit: '+ JSON.stringify(draftsToSubmit));

		$A.createComponent(
			'c:prov_comp_DeleteClaimDraft_Modal',
			{
                 "submitInProgress" : true,
                 "claimsToSubmit" : draftsToSubmit,
                 "recordType" : 'auth'
			},
			function(newModal, status, errorMessage){
				//console.log(status);
				//console.log(newModal);
				if (status === "SUCCESS") {
					var body = component.get('v.body');
					body.push(newModal);
					component.set('v.body', body);
				}
			}
		);
        //console.log('submitSelectedDrafts end');
    },
    
    runCheck :function(component, event, helper) {

        //console.log('runCheck start');

        var checkDraft = component.find('checkDraft'); 
        var updatedAuthDrafts = component.get('v.authDrafts');
        var draftsToSubmit = [];
        
        // loop through and add the checked rows to the update array to be passed to the apex controller
        if(!Array.isArray(checkDraft)) {
            draftsToSubmit.push.apply(draftsToSubmit,updatedAuthDrafts);
        } else {
            for(var i=0; i<checkDraft.length; i++){
                if(checkDraft[i].get('v.value') == true) {
                    draftsToSubmit.push(updatedAuthDrafts[i]);
                    updatedAuthDrafts[i].isSearching = true;
                }
            }
        }

        component.set("v.authDrafts", updatedAuthDrafts);

        //console.log('list of draftsToSubmit: ' + JSON.stringify(draftsToSubmit));

        helper.runEligibilityCheck(component, draftsToSubmit);

    },

    draftDetail : function(component,event,helper){
        //calls redirect event to go to the draft detail

        //gets Auth SF Id
        var authId = event.currentTarget.dataset.authid;
        //sets page name to route to
        var pageName = "pre-auth-entry";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "memberProfileGuid" : authId

            });
            redirectEvent.fire();
    },
    
    // CONTROLLER UTILITY METHODS
    handleSelectAllDrafts : function(component, event, helper) {
        var checkValue = component.find('selectAll').get('v.value');        
        var checkDraft = component.find('checkDraft'); 
        //console.log('checkDraft.length: '+checkDraft.length);
        //console.log('checkValue: '+checkValue);
        if(checkValue == true){
            if(!Array.isArray(checkDraft)) {
                component.find('checkDraft').set('v.value',true);
            } else {
                for(var i=0; i<checkDraft.length; i++){
                    checkDraft[i].set('v.value',true);
                }
            } 
        }
        else{ 
            if(!Array.isArray(checkDraft)) {
                component.find('checkDraft').set('v.value',false);
            } else {
                for(var i=0; i<checkDraft.length; i++){
                    checkDraft[i].set('v.value',false);
                }
            }             
        }
        helper.verifySelectedDrafts(component, event, helper);
    },

    handleSelectSingleRow : function(component, event, helper) {
        helper.verifySelectedDrafts(component, event, helper);
    },

    handleModalSuccess :function(component,event,helper){
		//do something to tell if its success on delete
        //console.log('handlemodal');
        // reset the submit success/error values so that notification will show correctly after being dismissed
        component.set('v.isSubmitSuccess', false);
        component.set('v.isSubmitError', false);
        // retrieve the values from the event
		var successValue = event.getParam('isSuccess');
		var successMsg = event.getParam('successMsg');
		var successCount = event.getParam('successCount');
		var errorValue = event.getParam('isError');
		var errorCount = event.getParam('errorCount');
        var type = event.getParam('eventType');
        //console.log('modal type: '+type);
		if(type == 'delete'){
            // component.set('v.isDeleteSuccess', true);
            // component.set('v.deleteSuccessMsg', successMsg);
            helper.showToast(component, event, 'success', successMsg);
        }
        if(type == 'submit'){
            if(successValue) {
                component.set('v.isSubmitSuccess', true);
                if(successCount > 1) {
                    component.set('v.submitSuccessMsg', successCount + ' drafts were submitted successfully.');
                } else {
                    component.set('v.submitSuccessMsg', '1 draft was submitted successfully.');                    
                }
            }
            if(errorValue) {
                component.set('v.isSubmitError', true);
                if(errorCount > 1) {
                    component.set('v.submitErrorMsg', errorCount + ' drafts were not submitted due to errors.');
                } else {
                    component.set('v.submitErrorMsg', '1 draft was not submitted due to errors.');                    
                }
            }
            window.scroll(0,0);
        }
        helper.getAuthDrafts(component);
        component.find('selectAll').set('v.value',false);
        component.set('v.atLeastOneSelected',false);
	},

    //column sort methods
    //sorts the column selected
    updateColumnSorting: function(component, event, helper){
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        //console.log('target and column found');

        //console.log('tar: '+tar);
        //console.log('col: '+col);

        //get table Id
        var tableId = tar.dataset.tableid;
        //console.log('tableId: '+tableId);
        //get the table 
        var table = $('#'+tableId);     

        //console.log('table id found');
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
            //console.log('end of sort asc');
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            //console.log('dsc');
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
            sortTable(table, col, 'ASC');
        }
        //console.log('end of sort method');
    }
    //end column sort methods
})