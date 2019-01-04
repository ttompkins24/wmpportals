({
	setSuppressWarning : function(component, helper) {
		var showWarning = localStorage['showDeleteAuthDraftWarning'];
		if(showWarning == undefined){
			//console.log('showWarning undefined');
			localStorage['showDeleteAuthDraftWarning'] = true;
		} else {
			//console.log('showWarning defined: '+showWarning);
			// localStorage['showDeleteAuthDraftWarning'] = false;
			// localStorage['showDeleteAuthDraftWarning'] = true;
		}
	},

	showToast : function(component, event, type, message) {
		var toastEvent = $A.get('e.force:showToast');
		var title;
		if(type == 'success'){
			title = 'Success!';
		} else {
			title = 'Error';
		}
		toastEvent.setParams({
			'title': title,
			'type': type,
			'duration': 2,
			'mode': 'dismissible',
			'message': message			
		});
		toastEvent.fire();
	},

	verifySelectedDrafts : function(component, event, helper) {
        var checkDraft = component.find('checkDraft'); 
        //console.log('checkDraft.length: '+checkDraft.length);
		var atLeastOneSelected = false;
		if(!Array.isArray(checkDraft)) {
			atLeastOneSelected = component.find('checkDraft').get('v.value');
		} else {
			for(var i=0; i<checkDraft.length; i++){
				if(checkDraft[i].get('v.value') == true) {
					atLeastOneSelected = true;
				}
			}
		} 
		//console.log('atLeastOneSelected: '+atLeastOneSelected);
		component.set('v.atLeastOneSelected',atLeastOneSelected);
	},

	deleteSingleDraft :function(component, event, helper){
		//console.log('deleteSingleDraft start');
		var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
		var updatedAuthDrafts = component.get('v.authDrafts');

		if(localStorage['showDeleteAuthDraftWarning'] == 'true') {
			$A.createComponent(
				'c:prov_comp_DeleteClaimDraft_Modal',
				{
					"claimToDelete" : updatedAuthDrafts[index],
					"recordType" : 'auth'
				},
				function(newModal, status, errorMessage){
					//console.log(status);
					//console.log(newModal);
					if (status === "SUCCESS") {
						var body = component.get("v.body");
						body.push(newModal);
						component.set('v.body', body);
					}
				}
			);
		} else { // bypass the modal and immediately delete
			//console.log('skipping confirm modal delete single');
			this.skipConfirmDelete(component, event, helper, updatedAuthDrafts[index], null);
		}
		//console.log('deleteSingleDraft end');
	},

	deleteMultipleDrafts :function(component, event, helper){
		//console.log('deleteMultipleDrafts start');
		var checkDraft = component.find('checkDraft'); 
		var updatedAuthDrafts = component.get('v.authDrafts');
		var draftsToDelete = [];
		
		// loop through and add the checked rows to the update array to be passed to the apex controller
		if(!Array.isArray(checkDraft)) {
			draftsToDelete.push.apply(draftsToDelete,updatedAuthDrafts);
		} else {
			for(var i=0; i<checkDraft.length; i++){
				if(checkDraft[i].get('v.value') == true) {
					draftsToDelete.push(updatedAuthDrafts[i]);
				}
			}
		}
		//console.log('draftsToDelete: '+ JSON.stringify(draftsToDelete));

		if(localStorage['showDeleteAuthDraftWarning'] == 'true') {
			$A.createComponent(
				'c:prov_comp_DeleteClaimDraft_Modal',
				{
					"claimsToDelete" : draftsToDelete,
					"recordType" : 'auth'
				},
				function(newModal, status, errorMessage){
					//console.log(status);
					//console.log(newModal);
					if (status === "SUCCESS") {
						var body = component.get("v.body");
						body.push(newModal);
						component.set('v.body', body);
					}
				}
			);
		} else { // bypass the modal and immediately delete
			//console.log('skipping confirm modal delete multiple');
			this.skipConfirmDelete(component, event, helper, null, draftsToDelete);
		}
		//console.log('deleteMultipleDrafts end');
	},

	skipConfirmDelete : function(component, event, helper, authToDelete, authsToDelete) {
		//console.log('skipConfirmDelete single authToDelete: '+ JSON.stringify(authToDelete));
		//console.log('skipConfirmDelete multiple authsToDelete: '+ JSON.stringify(authsToDelete));

		var action = component.get('c.deleteDraftsApex');
		//console.log('auth to delete: '+ component.get('v.authToDelete'));
		action.setParams({
			"authDraft" : authToDelete,
			"authDrafts" : authsToDelete
		});

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
				var result = JSON.stringify(response.getReturnValue());
				var msgString = component.get('v.portalConfig.PreAuthorization_Label__c') + ' Draft(s) deleted successfully';
				this.showToast(component, event, 'success', msgString);
				this.getAuthDrafts(component);
			}
		});

		$A.enqueueAction(action);
	},

	getAuthDrafts : function(component) {
		component.set('v.noResults', false);
		component.set('v.showSpinner', true);
		var action = component.get('c.getAuthDrafts');	
		var limitNum = 100;

        var businessid = sessionStorage['businessid']; // gets current business id   
		
		action.setParams({ 
			"limitNum" : limitNum,
			"businessId" : businessid 
		}); 

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
				var result = response.getReturnValue();
				if(response.getReturnValue().length == 0) {
					component.set('v.noResults', true);
				}
				// //console.log(JSON.stringify(result));
				for(var i=0; i<result.length; i++){
					if(result[i].Service_Date__c != undefined) {
					result[i].ServiceDate = this.toDate(result[i].Service_Date__c);
					}
				}
				component.set('v.authDrafts',result);
			}
			component.set('v.showSpinner', false);
		});

		$A.enqueueAction(action);
	},

	toDate : function(dateStr) {
		var parts = dateStr.split("-");
		var month = parts[1] + '-';
		var day = parts[2] + '-';
		var year = parts[0];
		var newDate = month.concat(day,year);
    	return new Date(newDate);
	},

	runEligibilityCheck : function(component, drafts) {
		var routeId = sessionStorage['portalconfig_lob'];
        //holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
      	var vfWindow = component.find("vfFrame").getElement().contentWindow;

     	drafts.forEach(function(element) {
     		var member = new Object();
     		var year = element.ServiceDate.getFullYear();
     		var month = element.ServiceDate.getMonth()+1;
     		var date = element.ServiceDate.getDate();
     		member.serviceDate = year + '-' + month + '-' + date;
     		member.birthDate = element.Subscriber_Birth_Date__c;
     		if(element.Subscriber_ID__c != null && element.Subscriber_ID__c != ''){
     			member.memberNumber = element.Subscriber_ID__c;
     		}
     		if(element.Subscriber_First_Name__c != null && element.Subscriber_First_Name__c != ''){
	     		member.firstName = element.Subscriber_First_Name__c;
     		}
     		if(element.Subscriber_Last_Name__c != null && element.Subscriber_Last_Name__c != ''){
	     		member.lastName = element.Subscriber_Last_Name__c;
     		}
     		member.claim = element.Id;

	       	//make an object to hold parameters
	        var temp = new Object();
	        if(element.Business__c.length == 18){
	        	temp['business'] = element.Business__c.substring(0,15);
	        } else {
	        	temp['business'] = element.Business__c;
	        }
	        temp['serviceLocation'] = element.Service_Location__c;
	        temp['provider'] = element.Provider__c;
	        temp['routeId'] = routeId;
	        temp['member'] = member;

	        //turn object into JSON string
	        var tempList = JSON.stringify(temp);
	        //console.log('JSON message ' + tempList);
	     	
	     	//send to vf page
	     	vfWindow.postMessage(tempList, vfOrigin);
     	});
	}
})