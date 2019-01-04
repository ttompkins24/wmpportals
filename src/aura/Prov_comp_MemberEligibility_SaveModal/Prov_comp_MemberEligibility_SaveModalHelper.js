({	
	//save search criteria
	saveSearch : function(component, event, helper){

		var title = component.get("v.title");
		if(title == '' || title == null){
			component.set('v.isError', true);
			component.set('v.str_errorMsg', 'Please enter a title');
			} else {

			//calling an action to the server side controller to fetch the current member's related cases
			var action = component.get("c.saveMemberSearch");
			
			//parameters to pass the search page
			var memberList = component.get("v.memberList");
			var businessId = component.get("v.bizAcctRecId");
			var serviceLocationId = component.get("v.locAcctRecId");
			var providerId = component.get("v.provAcctRecId");
	        
	        var tempList = JSON.stringify(memberList);
	        	
	    	action.setParams({
	    		'searchId' : '',
	    		'name':title,
	        	'criteriaStr': tempList,
	            'businessId': businessId,
	            'serviceLocationId': serviceLocationId,
	            'providerId': providerId,
	        });
	    	
			//creating a callback that is executed after the server side action is returned
			action.setCallback(this, function(response){
				//checking if the response is success
				if(response.getState() == 'SUCCESS'){		
				//result should be the criteria search ID.  if there isnt one, it means the search didnt save
					var result = response.getReturnValue();
					
					if(result){
						var title1 = component.get("v.title");

						//set success message
						component.set("v.isSuccess",true);
						component.set("v.str_successMsg",$A.get("$Label.c.Save_Successful"));
						var label = $A.get("$Label.c.Save_Successful");
						//added by mike for bug 183688 
						var successEvent = component.getEvent('searchSavedEvent');
		                successEvent.setParams({
                			"successMsg" : label,
		                	"eventType" : 'submit',
		                	"title": title1
		            	});
						successEvent.fire();
						component.destroy();

						// helper.redirectUrl(component, event, helper,  result);							
					} else {
						//set error message
						component.set("v.isError",true);
						component.set("v.str_errorMsg","Error saving");			
						component.destroy();
							
					}
					//switching off spinner
					$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
				}else{
					//setting the error flag and the message				
					component.set("v.isError",true);
					component.set("v.str_errorMsg","Error saving");
					$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
				}
			});
			$A.enqueueAction(action);
		}
	},

   redirectUrl : function(component, event, helper, searchId){
        var redirectEvent = $A.get('e.c:prov_event_Redirect');

		var pageName = "member-eligibility";
		
		redirectEvent.setParams({
			'pageName' : pageName,
			'searchCriteriaId' : searchId
		});
		redirectEvent.fire();
		component.destroy();
    },
	 
})