({
    NUM_RESULTS : 10,
	//reteives list of businesses 
    retrieveBizList: function(component, event, helper){
        component.set('v.showSpinner', true);

        var action = component.get("c.getAllBusinessesBusinessDetail"); 
        action.setCallback(this, function(response){
        var state = response.getState();
            if(state === "SUCCESS"){
                //sets business attribute for comparison on edit
                component.set('v.business', response.getReturnValue());
                component.set("v.bizAcctRec", response.getReturnValue());
                var bizAcctRec = component.get("v.bizAcctRec");
                var bizAcctRecId = bizAcctRec.Id;
                component.set("v.bizAcctRecId", bizAcctRecId);
                helper.getServiceLocations(component, event, helper, 1);
                helper.loadPageVariables(component,event,helper);
                helper.getExistingCase(component);
                component.set('v.business_updates', {});
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },

    getExistingCase : function(component) {
        component.set('v.showSpinner',true);
		var action = component.get('c.getExistingCaseApex');
		action.setParams({
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

    //get list of service locations based on B
    getServiceLocations : function (component, event, helper, pageNum, field, direction){
        component.set('v.showSpinner', true);
        var acctRecId = component.get("v.bizAcctRecId");
        var action1 = component.get("c.getAllLocationsBusinessDetail");

        var numResult = '';
        var max = component.get("v.maxResults");
        //sets number of results to return page (set to max results if max is not null)
        if(max != null){
            numResult = max;
        } else{
            //otherwise set to 20
            numResult = ''+this.NUM_RESULTS;
        }
        var page = ''+pageNum;
        action1.setParams({
            "bizAcctId" : acctRecId,
            "pageNumS" : page,
            "numResultsS" : numResult,
            "fieldS" : field,
            "directionS" : direction
        });

        action1.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){

                //add pagination here
                var totalResults = res.getReturnValue();
                var pageNum = Number(page);
                var numRes = Number(numResult);
                var resultList = [];

                for(i = ((pageNum-1) * numRes); i < totalResults.length; i++){
                    resultList.push(totalResults[i]);
                if(resultList.length == numResult) break;
                }
            
                component.set("v.locList", resultList);
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action1);
    },


    loadPageVariables : function(component){
        //loads page variables to show after a search (current page, total pages)
        component.set('v.showSpinner', true);
        var action = component.get('c.paginationVariables');
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.pages', result[0]);
                component.set('v.total', result[1]);
                component.set('v.page', result[2]);
            }
            component.set('v.showSpinner', false);
        });

        $A.enqueueAction(action);

    },

    saveUpdatedBusinessRecord : function(component,event, helper, json){
        component.set('v.showSpinner', true);
        component.set("v.isUpdateSuccess",false);
        component.set("v.isUpdateError",false);
        var bizAcctId = component.get('v.bizAcctRecId');
        var notes = component.get('v.notes');

        action = component.get("c.saveBusinessUpdateApex");

        action.setParams({
            "updateJSON" : json,
            "bizAcctId" : bizAcctId,
            "notes": notes,
            "visibleLOB": sessionStorage['portalconfig']
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                //on SUCCESS status
                //reload new business info
                var res = response.getReturnValue();
                //console.log(res);
                component.set('v.caseUpdateNumber', res);

                //turn off edit partial
                component.set('v.editBusiness', false);
                //flashes success message
                component.set("v.isUpdateSuccess",true);
                component.set("v.bizUpdateSuccessMsg", $A.get("$Label.c.Provider_Case_Saved"));
                helper.retrieveBizList(component,event,helper);
                window.scrollTo(0,0);
                component.set('v.showSpinner', false);
            }else{
                //else
                //flashes error message
                window.scrollTo(0,0);
                component.set("v.isUpdateError",true);
                component.set("v.bizUpdateErrorMsg", $A.get("$Label.c.CreateCase_General_Error"));
                component.set('v.showSpinner', false);
            }
            component.set('v.showSpinner', false);
        });

        $A.enqueueAction(action);
    },

    getProvTypeValues :function(component,event,helper){
        component.set('v.showSpinner', true);
            
        var action = component.get("c.getProvTypes");
        var options = [];     
        //populates picklist values
        action.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                options.push(response.getReturnValue()[i]);
            }
            component.set("v.providerTypes", options);

            var patTypes = component.get("v.providerTypes");
            component.set('v.showSpinner', false);
        });

        $A.enqueueAction(action);
    }
})