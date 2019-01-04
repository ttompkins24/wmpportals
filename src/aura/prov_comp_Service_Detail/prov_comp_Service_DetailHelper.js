({
	NUM_RESULTS : 20,
	//get current Service locaiton based on params
	getCurrentServiceLocation :function(component,event,helper, servLocId){
        component.set('v.showSpinner',true);
		var action = component.get('c.getServiceLocationbyId');
		//console.log(servLocId);
		action.setParams({
            "servLocId" : servLocId
		});

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
				var result = response.getReturnValue();
				//console.log(result);
				component.set('v.locAcctRec', result);
                component.set('v.locAcctRecId', result.Id);
                component.set('v.locAcctRecName', result.BillingCity.toUpperCase());
				helper.getDentists(component,event, helper, 1, 'Provider__r.Name', 'ASC')
			}
		});

		$A.enqueueAction(action);
    },

    getExistingCase : function(component, servLocId) {
        component.set('v.showSpinner',true);
		var action = component.get('c.getExistingCaseApex');
		//console.log(servLocId);
		action.setParams({
            "servLocId" : servLocId,
            "currentBusinessId" : component.get('v.currentBusinessId')
		});

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result) {
                    component.set('v.hasExistingCase',true);
                }
			}
            component.set('v.showSpinner',false);
		});

		$A.enqueueAction(action);
    },

    getDentists : function (component,event, helper, pageNum, field, direction){

    	var locAcctId = component.get('v.locAcctRecId');
        //console.log(locAcctId);
        
        var businessId = component.get('v.currentBusinessId');

        var action = component.get('c.getDentistPSLs');

    	var numResult = '';
        var max = component.get('v.maxResults');
        //sets number of results to return page (set to max results if max is not null)
        if(max != null){
            numResult = max;
        } else{
            //otherwise set to 20
            numResult = ''+this.NUM_RESULTS;
        }
        var page = ''+pageNum;

        var returnedDentists;

    	action.setParams({
    		'locAcctId' : locAcctId,
            'fieldS' : field,
            'directionS' : direction,
            'currentBusinessId' : businessId
    	});
        //console.log('currentBusinessId: '+component.get('v.currentBusinessId'));
    	action.setCallback(this, function(response) {
    		var state = response.getState();
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    //console.log('Error message: ' +
                    //         errors[0].message);
                }
            } else {
                //console.log('Unknown error');
            }

    		if(state === 'SUCCESS'){
    			if(response.getReturnValue().length > 0){
    				//console.log(response.getReturnValue().length);

    				component.set('v.noResults', false);

                    var returnedDentists = response.getReturnValue();                    
            		var pageNum = Number(page);
           	 		var numRes = Number(numResult);
            		var resultList = [];
    				
                    for(i = ((pageNum-1) * numRes); i < returnedDentists.length; i++){
                        returnedDentists[i].index = i;
                        returnedDentists[i].changeType = 'existing';
                        if(returnedDentists[i].treats_ages_from__c == undefined) {
                            returnedDentists[i].treats_ages_from__c = 0;
                        }
                        if(returnedDentists[i].treats_ages_to__c == undefined) {
                            returnedDentists[i].treats_ages_to__c = 0;
                        }
                        if(returnedDentists.length == numResult) break;
                    }
                    //console.log(returnedDentists);

                    component.set('v.dentistList', returnedDentists);
                    component.set('v.showSpinner',false);
                    //set dentists list
    			}else{
    				//show no results table
                    component.set('v.showSpinner',false);
                    component.set('v.noResults', true);
    			}
            }
            component.set('v.showSpinner',false);
       	});
    	$A.enqueueAction(action);

    }
})