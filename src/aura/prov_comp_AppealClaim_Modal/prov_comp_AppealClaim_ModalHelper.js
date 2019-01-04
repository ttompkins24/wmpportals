({
	MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 

	createAppealClaimCase : function(component, event, helper) {
		
        var claimType = component.get("v.claimType");
		var claimNum = component.get("v.claimNumber");
        var servLocguid = component.get("v.serviceOfficeGuid");
        var bizguid = component.get("v.businessGuid");
        var provguid = component.get("v.providerGuid");
        var fileList = component.get("v.fileNames");
        var appealReason = component.get("v.appealReason");
        var desiredResolution = component.get("v.outcomeDesired");
        var memberName = component.get("v.memberName");
        var memberDOB = component.get("v.memberBirth");
        var memberNumber = component.get("v.memberNumber"); 
        var memFirst = component.get("v.memFirstName");
        var memLast = component.get("v.memLastName");
        

        var action = component.get("c.createAppealClaimCase");
        var params = {
            claimNum : claimNum,
            servLocguid : servLocguid,
            bizguid : bizguid,
            provguid : provguid,
            claimType : claimType,
            appealReason : appealReason,
            desiredResolution : desiredResolution,
            memberName : memberName,
            memberDOB : memberDOB,
            memberNumber : memberNumber,
            memFirst :memFirst,
            memLast :memLast

        };

        var wrapperCase = component.get('v.newCaseWrapper');
         

        if(wrapperCase && wrapperCase.Id) {
            params.caseId = wrapperCase.Id;
        }

        action.setParams(params);

        action.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
                var data = res.getReturnValue();
                //console.log(data);
                '$Label.c.Successfully_Deleted'
                //set success messages
                component.set("v.isAppealSuccess", true);
                component.set("v.appealSuccessMsg", $A.get('$Label.c.Claim_Appeal_Toast_Message') + ' # ' +  data.CaseNumber);
                var successMsg = component.get("v.appealSuccessMsg");
                //attach files if there are files
                //console.log('here');
                if (fileList.length > 0) {
                    component.set('v.caseId', data.Id);
                    helper.uploadHelper(component, event, helper, data.Id);


                } else{
                    helper.successHelper(component,event, helper);
                }
            }
        });

        $A.enqueueAction(action);
        
    },



	checkForErrors : function(component,event,helper){
		//check for required fields
		var appealReason = component.get("v.appealReason");
		if(appealReason == null){
			//console.log("here");
			component.set("v.isReqFieldError", true);
			component.set("v.requiredFieldMsg", "Please specify a reason for this Appeal");
		}
	},

    successHelper : function (component, event, helper){

         var successMsg = component.get("v.appealSuccessMsg");
        //pass success parameters back to claim detail component
        var successEvent = component.getEvent("modalSuccessEvent");
            successEvent.setParams({
                    "isSuccess": true,
                    "successMsg" : successMsg,
                    "eventType" : "appeal"
            });
            successEvent.fire();

        component.destroy();
    },

    deleteAttachment : function(component, attachment, index) {
        component.set('v.fileNames', null);

    },

    submitWrapperCase: function(component) {
        var action = component.get("c.saveAppealWrapperApex"); 
        var helper = this;  

        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                //console.log('### case saved: ' + JSON.stringify(data));
                component.set('v.newCaseWrapper', data);   
            } else {  
                //console.log('error');
            } 
        });

        $A.enqueueAction(action);
    }


})