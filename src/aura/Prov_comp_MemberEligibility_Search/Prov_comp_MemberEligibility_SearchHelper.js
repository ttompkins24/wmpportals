({
	//add 5 rows to the member list
	addFiveRows : function(component, event, helper) {
		var memberList = component.get("v.memberList");
		var date = component.get("v.today");
		for(i=0; i<5; i++){
			if(memberList.length < 30){
				memberList.push({"serviceDate":date, "birthDate":"", "memberNumber":"", "firstName":"", "lastName":"", "index":memberList.length, "errors":""});
			}
		}

		component.set("v.memberList", memberList);
	},

	//load search criteria into member list
	loadSearchCriteria :function(component, event, helper) {
		//console.log('loadSearchCriteria...');
    	var searchCriteriaId = component.get("v.searchCriteriaId");

		var action = component.get("c.loadSearchCriteria");
		
    	action.setParams({
        	'searchCriteriaId': searchCriteriaId
        });
        	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() == 'SUCCESS'){		
				var result = response.getReturnValue();
				
				//set the index of the results
				var ct = 0;
				for(var loc in result.memberList){
					result.memberList[loc].index = ct;
					ct +=1;
				}
					
				//set memberlist, title, and BLP picklist values in wrapper				
				component.set("v.memberList", result.memberList);
				component.set("v.title", result.title);

				component.set("v.locAcctRec", result.serviceLocation);
				component.set("v.provAcctRec", result.provider);
				component.set("v.searchOwner", result.owner);
    
				//switching off spinner
				$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
				
			}else{
				//setting the error flag and the message				
				component.set("v.isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
				$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
			}
		});
		$A.enqueueAction(action);
	},

	//resave an exisiting search
	saveExistingSearch : function(component, event, helper) {

		var action = component.get("c.saveMemberSearch");
		
		//parameters to pass the search page
		var title = component.get("v.title");
		var searchCriteriaId = component.get("v.searchCriteriaId");
		var memberList = component.get("v.memberList");
		var businessId = sessionStorage['businessid'];
		var serviceLocationId = component.get("v.locAcctRec").Id;
		var providerId = component.get("v.provAcctRec").Id;
		var routeId = sessionStorage['portalconfig_lob'];
        
        var tempList = JSON.stringify(memberList);
        	
    	action.setParams({
    		'searchId' : searchCriteriaId,
    		'name':title,
        	'criteriaStr': tempList,
            'businessId': businessId,
            'serviceLocationId': serviceLocationId,
            'providerId': providerId,
            routeId : routeId
            
        });
    	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			//checking if the response is success
			if(response.getState() == 'SUCCESS'){		
				var result = response.getReturnValue();
				
				if(result){
					component.set("v.isSuccess",true);
					component.set("v.str_successMsg",$A.get("$Label.c.Save_Successful"));
								
				} else {
					component.set("v.isError",true);
					component.set("v.str_errorMsg","Error saving");									
				}
				//switching off spinner
				$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
			}else{
				//setting the error flag and the message				
				component.set("v.isError",true);
				component.set("v.str_errorMsg","Error saving");
				$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
			}
		});
		$A.enqueueAction(action);
	},


	//checks to make sure the business, service location, and provider picklists are populated
	checkForErrors : function(component, event, helper) {

		var error = false;
		var serviceLocation = component.get("v.locAcctRec");
		var provider = component.get("v.provAcctRec");

		//get the member list table
		var table = $("#memberTable");

		//check to make sure business, location, and provider are selected
		if(serviceLocation == null || provider == null){
			component.set("v.isError",true);
			component.set("v.str_errorMsg",$A.get("$Label.c.BLP_Error_Message"));
			error = true;
			$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
		} 

		//check to make sure there is at least one member being searched on
		if(!error){		
			//remove empty rows from member list
			var memberList = component.get("v.memberList");
			for(i=0; i < memberList.length; i++){
				var temp = memberList[i];
				if( (temp.firstName === '' || temp.firstName == undefined) && (temp.lastName === '' || temp.lastName == undefined) && (temp.memberNumber === '' || temp.memberNumber == undefined) ){
					memberList.splice(i, 1);
					i--;
				}
			}
//		 //console.log('1');
			if(memberList.length == 0){
				component.set("v.isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.No_Rows_Error_Message"));
				error = true;
				$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
				//helper.addFiveRows(component, event, helper);
				return;
			}
			component.set("v.memberList", memberList);
//		 //console.log('memberList::'+JSON.stringify(memberList));


		//check to make sure service date and birthdate are populated
			//var memberList = component.get("v.memberList");
			if(!error){
				for(i=0; i < memberList.length; i++){
					var temp = memberList[i];
					//check birthdate
				 //console.log('temp.birthDate::'+temp.birthDate);
					if(temp.birthDate === '' || temp.birthDate === null || temp.birthDate == undefined)  {
						error = true;
						//get the field with the error
						var scInputError =  $(table).find('.'+temp.index+'bDayErrorOutput');
	
						//add the error message
						//$(scInputError).text($A.get("$Label.c.No_Future_Birthday")).removeClass('slds-hide');
						//add the error message
						$(scInputError).removeClass('slds-hide').text($A.get("$Label.c.No_Birthdate"));
	
						//add placeholder and CSS to input field 
						$(table).find('.' + temp.index+'memberSearchBirthdate').addClass('errorInputForm');
						//$(table).find('.' + temp.index+'memberSearchBirthdate').attr("placeholder","Please fill out");
					} else {
					 //console.log('temp birthdate is not empty');
						//remove any old styling
						var scInputError = $(table).find('.'+temp.index+'bDayErrorOutput');
						$(scInputError).text('').removeClass('errorInputForm').addClass('slds-hide');
						
					}
	
					//check service date
					if(temp.serviceDate === '' || temp.serviceDate === null) {
						//console.log('serviceDateNull::'+temp.serviceDate);
						error = true;
						//get the field with the error
						var scInputError =  $(table).find('.'+temp.index+'serviceDateErrorOutput');
	
						//add the error message
						$(scInputError).text($A.get("$Label.c.No_Service_Date")).removeClass('slds-hide');
	
						//add placeholder and CSS to input field 
						$(table).find('.' + temp.index+'memberSearchServiceDate').addClass('errorInputForm');
						//$(table).find('.' + temp.index+'memberSearchServiceDate').attr("placeholder","Please fill out");
	
	
					} else {
						//remove any old styling
						var scInputError = $(table).find('.'+temp.index+'serviceDateErrorOutput');
						$(scInputError).text('').removeClass('errorInputForm').addClass('slds-hide');
						
					}
				}
			}

			
		//check if using valid search criteria
			//var memberList = component.get("v.memberList");
			var birthdayError = false;
			var requiredMemNumOrName = false;
			if(!error){
				for(i=0; i < memberList.length; i++){
					var temp = memberList[i];
	
					if(temp.memberNumber === '' && (temp.firstName === '' || temp.lastName === ''))  {
						requiredMemNumOrName = true;
						error = true;
						continue;
					} 
					if( ( ( temp.firstName != '' && temp.firstName != undefined) && ( temp.lastName == '' ||  temp.lastName == undefined ) ) || 
			                   ( ( temp.firstName == '' || temp.firstName == undefined) && ( temp.lastName != '' &&  temp.lastName != undefined ) ) 	){
//			                   //console.log('error tempFirst name and last name');
			            component.set('v.isError', true);
			            component.set('v.str_errorMsg', $A.get('$Label.c.Member_DOB_and_ID_and_First_or_Last'));
			            error = true;
			            $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
			            return;
			        } 
					
					//check that the birthdate is today or in the past
					var difference = new Date() - new Date(temp.birthDate);
					if(difference < 0){
					 //console.log('birthday error');
						error = true;
						
						//get the field with the error
						var scInputError =  $(table).find('.'+temp.index+'bDayErrorOutput');
	
						//add the error message
						$(scInputError).text($A.get("$Label.c.No_Future_Birthday")).removeClass('slds-hide');
	
						//add placeholder and CSS to input field 
						$(table).find('.' + temp.index+'memberSearchBirthdate').addClass('errorInputForm');
					} else {
						//remove any old styling
						var scInputError = $(table).find('.'+temp.index+'bDayErrorOutput');
						$(scInputError).text('').removeClass('errorInputForm').addClass('slds-hide');
						
					}
				}
			}
			
			//service date can only be 1 year in the past or 14 days in the future
			//var memberList = component.get("v.memberList");
			 if( requiredMemNumOrName){
				$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
				component.set("v.isError",true);
				component.set("v.str_errorMsg",$A.get('$Label.c.Incomplete_Rows_Error_Message'));
			} else if(!error){
				for(i=0; i < memberList.length; i++){
					var temp = memberList[i];
					
					var today = new Date();
					var serviceDate = new Date(temp.serviceDate);
					
					//if serviceDate > today its in the future, make sure difference is 14 or less
					if(serviceDate > today){
						var diff = (Math.abs(today.getTime() - serviceDate.getTime()))/ (1000 * 60 * 60 * 24);
						if(diff > 14){
							error = true;
							//get the field with the error
							var scInputError =  $(table).find('.'+temp.index+'serviceDateErrorOutput');
	
							//add the error message
							$(scInputError).text($A.get("$Label.c.Service_Date_Out_Of_Range")).removeClass('slds-hide');
	
							//add placeholder and CSS to input field 
							$(table).find('.' + temp.index+'memberSearchServiceDate').addClass('errorInputForm');
							//$(table).find('.' + temp.index+'memberSearchServiceDate').attr("placeholder","Please fill out");
	
						}else {
							//remove any old styling
							var scInputError = $(table).find('.'+temp.index+'serviceDateErrorOutput');
							$(scInputError).text('').removeClass('errorInputForm').addClass('slds-hide');
							
						}
					} 
					//if service date < today, its in the past.  make sure within 365 days
					else if(serviceDate < today) {
						var diff = (Math.abs(today.getTime() - serviceDate.getTime()))/ (1000 * 60 * 60 * 24);
						//console.log('today::'+today.getTime());
						//console.log('serviceDate::'+serviceDate.getTime());
						//console.log('diff::'+diff);
						if(diff > 365){
							error = true;
							var scInputError =  $(table).find('.'+temp.index+'serviceDateErrorOutput');
	
							//add the error message
							$(scInputError).text($A.get("$Label.c.Service_Date_Out_Of_Range")).removeClass('slds-hide');
	
							//add placeholder and CSS to input field 
							$(table).find('.' + temp.index+'memberSearchServiceDate').addClass('errorInputForm');
							//$(table).find('.' + temp.index+'memberSearchServiceDate').attr("placeholder","Please fill out");
	
						}	else {
							//remove any old styling
							var scInputError = $(table).find('.'+temp.index+'serviceDateErrorOutput');
							$(scInputError).text('').removeClass('errorInputForm').addClass('slds-hide');
							
						}			
					}	
				}
			}
			
			if(error && requiredMemNumOrName == false){
				$A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
				component.set("v.isError",true);
				component.set("v.str_errorMsg", $A.get('$Label.c.Please_correct_errors_before'));
				//Incomplete_Rows_Error_Message
				//Service_Date_Out_Of_Range
			} 
		}

	},

	//search on the inputted criteria
	search : function(component) {
		
		//parameters to pass the search page
		var memberList = component.get("v.memberList");
		var business = sessionStorage['businessid'];
		var serviceLocation = component.get("v.locAcctRec");
		var provider = component.get("v.provAcctRec");
		var routeId = sessionStorage['portalconfig_lob'];

        var temp = new Object();
        temp['business'] = business;
        temp['serviceLocation'] = serviceLocation.Id;
        temp['provider'] = provider.Id;
        temp['routeId'] = routeId;
       	temp['memberList'] = memberList;

        var tempList = JSON.stringify(temp);

        //console.log('tempList ' + tempList);

		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';

    	// var vfOrigin = "https://dev1-greatdentalplans-community.cs13.force.com/Provider/";
		window.scrollTo(0,0);			

    	var vfWindow = component.find("vfFrame").getElement().contentWindow;
    	vfWindow.postMessage(tempList, vfOrigin);
     //console.log('finished post message');
	},

	showToast : function(component, event, type, message) {
		//added by mike for bug 183688 
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


})