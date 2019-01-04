({
	//checks to see if loaded search, if so, load criteria
	//otherwise, load blank member criteria of size 5. 
	doInit : function(component, event, helper) {
	 //console.log('redoInit');

		//holds the origin of the message originating from the Visual Force page
        var origin = $A.get('$Label.c.Member_Eligibility_VF_URL');
        component.set('v.vfHost', origin);

        //check to see if loading a saved search
		var criteriaId = component.get('v.params.criteria');
		if(criteriaId){
			component.set("v.searchCriteriaId", criteriaId);
		}
    	var searchCriteriaId = component.get("v.searchCriteriaId");
    	var today = new Date();
    	
    	var todayMM = today.getMonth()+1;
    	if(todayMM < 10){
    		todayMM = '0' + todayMM;
    	}
    	
    	var todayDD = today.getDate();
    	if(todayDD < 10){
    		todayDD = '0' + todayDD;
    	}
    	component.set('v.today', today.getFullYear() + "-" + todayMM + "-" + todayDD); 	
    	if(searchCriteriaId){
			helper.loadSearchCriteria(component, event, helper);
		} else {
			//build them empty member list to display
			var memberList = component.get("v.memberList");
			if(memberList.length == 0){
				helper.addFiveRows(component, event, helper);
	    	}
		}

		var listener = function(event) {
		var providerId = component.get("v.provAcctRec");
	 //console.log('providerId ' + providerId);
    	 //console.log('return listener');
    	 //console.log('event.origin ' + event.origin);
    	 //console.log('origin' + origin);
			var origin = component.get('v.vfHost');
    		if(event.origin !== origin) {
    			//not the expected origin. reject results
    		 //console.log('origins did not match');
    			return;
    		}

    		//Handle the message
    		var results = event.data;
    		
    		if(results == 'pageLoaded'){
            	component.set('v.checkButtonDisabled', false);
            	return;
            }

    	 //console.log('results ' + results);
    	 //console.log('results ' + JSON.stringify(results));
    	 //console.log('results ' + typeof results);
		 //console.log('time out in search page' + results.hasOwnProperty('timeout'));

			if(results.hasOwnProperty('timeout')){
				component.set("v.isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Server_No_Response_Error"));
				$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");

			} else {

	    		if(providerId == null){
	    			//do nothing
	    		} else if(results != '' && results != null){
	    		 //console.log('good results ');
					//set eligible, not eligible, and not found tables
					component.set("v.eligibleList",  results['eligible']);
					component.set("v.notEligibleList",  results['ineligible']);
					component.set("v.notFoundList",  results['notFound']);
					component.set("v.outOfNetworkList",  results['outOfNetwork']);

					//switching off spinner
					$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");

					//turn on search results
					component.set("v.showResults", true);

					//turn off search table
					component.set("v.showSearch", false);
			
				} else {
	    		 //console.log('bad results ');
					//setting the error flag and the message	
					window.scrollTo(0,0);			
					component.set("v.isError",true);
					component.set("v.str_errorMsg",$A.get("$Label.c.Server_No_Response_Error"));
					$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
				}
			}
		}
	 //console.log('about to hit the if statment');
		if(window.addEventListener !== undefined) {
		 //console.log('adding listener');
			window.addEventListener("message", listener, false);
		} else {
		 //console.log('attaching event');
			attachEvent("onmessage", listener);
		}		
	},

	//calls helper function to add 5 rows to memberlist
	addFiveRows : function(component, event, helper){
		helper.addFiveRows(component, event, helper);
	}, 

	//deletes the selected row
	deleteRow : function(component, event, helper){
		var ctarget = event.currentTarget;
    	var index = ctarget.dataset.value;
		var memberList = component.get("v.memberList");

		memberList.splice(index, 1);

		//reorder index
		for(i=0; i<memberList.length; i++){
			memberList[i].index = i;
		}

		component.set("v.memberList", memberList);
	}, 

	//search for the members based on the provided criteria
	search : function(component, event, helper) {
		//reset error and success messages
		component.set('v.isSuccess', false);
		component.set('v.isError', false);
		$('.errorMessageWrap').removeClass('hide');
		$('.successMessageWrap').removeClass('hide');
		$A.util.removeClass(component.find("searchSpinnerId"), "slds-hide");
        $A.util.addClass(component.find("searchSpinnerId"), "slds-is-fixed");

		//must have business, service location, and provider populated
		//must have at least one row in the table
		//each row must have either member number or first and last name populated
		helper.checkForErrors(component, event, helper);

		var isError = component.get("v.isError");
		if(!isError){
			//turn on spinner
			var spinner = component.find('searchSpinnerId');
			$A.util.removeClass(spinner, 'slds-hide');
	        $A.util.addClass(component.find("searchSpinnerId"), "slds-is-fixed");


			helper.search(component);
		} else {
			window.scrollTo(0,0);
		}

	},

	saveSearch : function(component, event, helper){
		window.scrollTo(0,0);

		//reset error and success messages
		component.set('v.isSuccess', false);
		component.set('v.isError', false);
		$('.errorMessageWrap').removeClass('hide');
		$('.successMessageWrap').removeClass('hide');
		//check to make sure user is owner of search or admin
		var isAdmin = component.get("v.permissions.admin");

		var currentContact = component.get("v.currentContact.Id");
		var searchOwner = component.get("v.searchOwner");

		//check if existing search, if so, save it without popup
		//must have admin permissions or be creator of saved search, otherwise new modal
		var searchCriteriaId = component.get("v.searchCriteriaId");
		if(searchCriteriaId && searchCriteriaId != '' && (isAdmin || currentContact === searchOwner)){
			$A.util.removeClass(component.find("searchSpinnerId"), "slds-hide");
	        $A.util.addClass(component.find("searchSpinnerId"), "slds-is-fixed");

			helper.checkForErrors(component, event, helper);

			var isError = component.get("v.isError");

			//if no errors found save
			if(!isError){
				$A.util.removeClass(component.find("searchSpinnerId"), "slds-hide");
		        $A.util.addClass(component.find("searchSpinnerId"), "slds-is-fixed");

				helper.saveExistingSearch(component, event, helper);
			}

			window.scrollTo(0,0);

		} 
		//else, check to make sure all valid criteria, then launch save modal
		else {

			//reset error and success messages
			component.set('v.isSuccess', false);
			component.set('v.isError', false);
			$('.errorMessageWrap').removeClass('hide');
			$('.successMessageWrap').removeClass('hide');
			
			//must have business, service location, and provider populated
			//must have at least one row in the table
			//each row must have either member number or first and last name populated
			helper.checkForErrors(component, event, helper);

			var isError = component.get("v.isError");

			//if no errors found create save modal
			if(!isError){
				var bizId = component.get("v.bizAcctRec").Id;
				var slId = component.get("v.locAcctRec").Id;
				var providerId = component.get("v.provAcctRec").Id;
				var memberList = component.get("v.memberList");
				var title = component.get("v.title");

				$A.createComponent(
					'c:Prov_comp_MemberEligibility_SaveModal',
					{
						'bizAcctRecId' : bizId,
						'locAcctRecId': slId,
						'provAcctRecId' : providerId,
						'memberList' : memberList,
						'title' : title
					},
					function(newModal, status, errorMessage){
						//Add the new button to the body array
						if (status === "SUCCESS") {
							var body = component.get("v.body");
							body.push(newModal);
							component.set('v.body', body);
						}
					}
				);

			} else {
				window.scrollTo(0,0);
			}
		}
	},
    
    clearSearch : function(component, event, helper) {
		component.set('v.memberList', []);

    	helper.addFiveRows(component, event, helper);
    },

	fixDate : function(component, event, helper) {
       helper.fixDate(component, event);
    },

	//added by mike for bug 183688 
    handleModalSuccess :function(component,event,helper){
		//do something to tell if its success on delete
        //console.log('handlemodal');
        // reset the submit success/error values so that notification will show correctly after being dismissed
        component.set('v.isSubmitSuccess', false);
        component.set('v.isSubmitError', false);
        // retrieve the values from the event
		var successMsg = event.getParam('successMsg');
		var title = event.getParam('title');
		component.set('v.title', title);
        helper.showToast(component, event, 'success', successMsg);
   	},

})

// https://greatdentalplans--dev1.cs13.force.com/Provider
// https://dev1-greatdentalplans-community.cs13.force.com/Provider