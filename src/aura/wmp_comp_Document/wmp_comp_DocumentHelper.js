({
	 /**************************************************************************************************************
     * Name					        		: wmp_comp_DocumentHelper
     * Developed By							: Todd Tompkins
     * Purpose								: To fetch the necessary information  
     * 											# current member from cache class
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			30th August 2017		Todd Tompkins		See header - purpose

    ***************************************************************************************************************/
    getCurrentMember: function(component) {
        //calling an action to the server side controller to fetch the current member
        var action = component.get("c.fetchCurrentMember");

        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response) {
            var response_state = response.getState();

            //checking if the response is success
            if (response_state === 'SUCCESS') {
                //set the attribute with the value
                component.set("v.currentMember", response.getReturnValue());
            } else {
                //toast to display
                //console.log in case we need to track
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    fetchCurrentMemberPlans: function(component, helper) {
        console.log('init');
        //calling an action to the server side controller to fetch the current member plan
        var action = component.get("c.fetchCurrentMemberPlans");

        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response) {
            var response_state = response.getState();

            //checking if the response is success
            if (response_state === 'SUCCESS') {
                //set the attribute with the value
                var memberplans = response.getReturnValue();
                component.set("v.currentMemberPlans", memberplans);
                component.set("v.chosen_MemberPlan", memberplans[0]);
                //component.set("v.chosen_MemberPlan",memberplans[0]);

                //get the related member plan accounts
                helper.getRelatedPlanAccountsFromMemberPlans(component, helper);
                //get the plan name
                helper.getPlanName(component, helper);
            } else {
                //toast to display
                //console.log in case we need to track
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },


    /**************************************************************************************************************
     * Method Name							: getCurrentMemberPlans
     * Developed By							: Todd Tompkins
     * Purpose								: To fetch the necessary information  
     * 											# current member plans from cache class
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			30th August 2017		Todd Tompkins See header - purpose

    ***************************************************************************************************************/
    getCurrentMemberPlans: function(component, helper) {
        //calling an action to the server side controller to fetch the current member plan
        var action = component.get("c.retrieveMemberPlans");

        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response) {
            var response_state = response.getState();

            //checking if the response is success
            if (response_state === 'SUCCESS') {
                //set the attribute with the value
                var memberplanList = response.getReturnValue();
                var resultList = [];
                if(memberplanList.length > 0){
	                for(var loc in memberplanList){
	                	
	               		var obj = {'Label' : memberplanList[loc].Label, 'plan' :memberplanList[loc].plan, 'effDate' : memberplanList[loc].effDate, 'Value' : memberplanList[loc].Value, 'isactive' : memberplanList[loc].isactive};
	               		if(obj.isactive == 'true'){
	               			resultList.unshift(obj);
	               		}else{
	               			resultList.push(obj);
	               		}
	                }
	                component.set("v.chosen_memCov", resultList[0].Value);
	            }
                component.set("v.currentMemberPlans", resultList);
                

            } else {
                //toast to display
                //console.log in case we need to track
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    /**************************************************************************************************************
     * Method Name							: getCurrentMemberPlans
     * Developed By							: Todd Tompkins
     * Purpose								: To fetch the necessary information  
     * 											# current member plans from cache class
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			30th August 2017		Todd Tompkins See header - purpose

     ***************************************************************************************************************/
    getCurrentEobs: function(component, helper) {
    	// var memCov = component.get('v.currentMemberPlan');
    	// if(memCov == undefined || memCov == '') return;
    	//calling an action to the server side controller to fetch the current member plan
    	var action = component.get("c.retrieveEOBs");
        // action.setParams({subscriberId:currentMemberPlan.SubscriberID__c, planId:currentMemberPlan.PlanGUID__c, route:currentMemberPlan.RouteID__c});

    	//creating a callback that is executed after the server side action is returned
    	action.setCallback(this, function(response) {
            console.log('response ' + response.getState());

    		if(response.getState() == 'SUCCESS'){
                $A.util.toggleClass(component.find("documentContainer"), "slds-show");

                var result = response.getReturnValue();
                console.log('result ' + JSON.stringify(result));
                component.set('v.eobList', result);
                $A.util.toggleClass(component.find("spinner"), "slds-hide");
                component.set("v.Spinner", true);   

            } else {
                $A.util.toggleClass(component.find("spinner"), "slds-hide");
                component.set("v.Spinner", true);   
                component.set("v.bln_isError",true);
                component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
                console.log('Error');    		}

    	});
    	
    	$A.enqueueAction(action);
    },
    
    getPortalConfig: function(component) {
		//calling an action to the server side controller to fetch the current member
		var action = component.get("c.loadConfiguration");
	
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//set the attribute with the value
				var pConfig = response.getReturnValue();
				
				var eobL = pConfig.Explanation_of_Benefits__c;
				var eobD = pConfig.Explanation_of_Benefits_Detail__c;
				
				var eobLV = $A.getReference('$Label.c.'+ eobL);
				component.set('v.eobL', eobLV);
				var eobDV = $A.getReference('$Label.c.'+ eobD);
				component.set('v.eobDetailL', eobDV);

			}else{
				//setting the error flag and the message
				component.set("v.bln_isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
	},

    //this function fetches an individual EOB from DocDirect to display to a user
    fetchEOBDocument: function(component, helper, eobLink, name) {

        var action = component.get("c.retrieveEOB");

        action.setParams({
            eobLinkStr:eobLink
        });

        action.setCallback(this, function(response){
            var response_state = response.getState();

            if(response_state === 'SUCCESS'){

                //this should be the binary form of the doc
                var doc = response.getReturnValue();
                
               // commented out is the download solution.   works in chrome and IE
                //It is necessary to create a new blob object with mime-type explicitly set
                // otherwise only Chrome works like it should
                var newBlob = new Blob([doc], {type: "application/pdf"});

                // IE doesn't allow using a blob object directly as link href
                // instead it is necessary to use msSaveOrOpenBlob
                if (window.navigator && window.navigator.msSaveOrOpenBlob) {
                    window.navigator.msSaveOrOpenBlob(newBlob);
                    return;
                } 

                // For other browsers: 
                // Create a link pointing to the ObjectURL containing the blob.
                // const data = window.URL.createObjectURL(newBlob);
                // var link = document.createElement('a');
                // link.href = data;
                // link.download=name+".pdf";
                // link.target = "_blank";
                // link.click(); 


                var element = document.createElement('a');
                element.setAttribute('href', 'data:application/pdf;charset=utf-8,' + encodeURIComponent(doc));
                element.setAttribute('download', name+".pdf");

                element.style.display = 'none';
                document.body.appendChild(element);

                element.click();

                document.body.removeChild(element);



                console.log('end of download');
          
            } else {
                //setting the error flag    and the message
                component.set("v.bln_isError",true);
                component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
                console.log('Error');
            }

        });
        $A.enqueueAction(action);
    }, 
})