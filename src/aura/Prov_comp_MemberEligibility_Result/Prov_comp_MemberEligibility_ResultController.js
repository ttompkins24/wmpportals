({

	//sets the time for the Search Run field
	doInit : function(component, event, helper){
		//console.log('result do init start');
		var d = new Date();
	    minutes = d.getMinutes().toString().length == 1 ? '0'+d.getMinutes() : d.getMinutes();
	    if(d.getHours().toString().length == 1)
	    	hours = '0'+d.getHours();
	    else{
	    	if(d.getHours() > 12){
	    		hours = d.getHours()-12;
	    		hours = hours.length > 1 ? hours : '0'+hours;
	    	}else{
	    		hours = d.getHours();
	    	}
	    }
	    	
	    ampm = d.getHours() >= 12 ? 'pm' : 'am';
	    months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
	    days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];

	    var timeSearchRan = days[d.getDay()]+' '+months[d.getMonth()]+' '+d.getDate()+' '+d.getFullYear()+' at '+hours+':'+minutes+ampm;
		component.set("v.searchRun", timeSearchRan);

		window.scrollTo(0,0);



	},
	//resets the error messages, then opens the search criteria modal to save a new search, or just resaves existing search
	saveSearch : function(component, event, helper){

		//reset error and success messages
		component.set('v.isSuccess', false);
		component.set('v.isError', false);
		$('.errorMessageWrap').removeClass('hide');
		$('.successMessageWrap').removeClass('hide');


		//check to make sure user is owner of search or admin
		var isAdmin = component.get("v.permissions.admin");
		var currentContact = component.get("v.currentContact.Id");
		var searchOwner = component.get("v.searchOwner");

		//check to see if already in a saved search criteria.  if so, resave
		var searchCriteriaId = component.get("v.searchCriteriaId");
		if(searchCriteriaId && searchCriteriaId != '' && (isAdmin || currentContact === searchOwner)){
			helper.saveExistingSearch(component, event, helper);
			window.scrollTo(0,0);

		}
		//launch save modal
		else {

			var bizId = component.get("v.bizAcctRec").Id;
			var slId = component.get("v.locAcctRec").Id;
			var providerId = component.get("v.provAcctRec").Id;
			var memberList = component.get("v.memberList");

			$A.createComponent(
				'c:Prov_comp_MemberEligibility_SaveModal',
				{
					'bizAcctRecId' : bizId,
					'locAcctRecId': slId,
					'provAcctRecId' : providerId,
					'memberList' : memberList
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
		}
	},

	//turn off the results section and turn on the search section
	backToSearch : function(component, event, helper){

		component.set("v.showSearch", true);
		component.set("v.showResults", false);

	}

})