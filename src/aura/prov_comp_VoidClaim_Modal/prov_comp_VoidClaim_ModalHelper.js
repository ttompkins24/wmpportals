({

    MAX_FILE_SIZE: 4500000,    //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,        //Chunk Max size 750Kb 
    
	createVoidClaimCase : function(component,event, helper) {
        //get parameters that are set on the modal
		var action = component.get("c.createVoidClaimCase");
        var fileList = component.get("v.fileNames");
		var claimNum = component.get("v.claimNumber");
        var servLocguid = component.get("v.serviceOfficeGuid");
        var bizguid = component.get("v.businessGuid");
        var provguid = component.get("v.providerGuid");
        var amount = component.get("v.amount");
        var provNPI = component.get("v.provNPI");
        var claimReason = component.get("v.claimVoidReason");
        var memFirst = component.get("v.memFirstName");
        var memLast = component.get("v.memLastName");

        
       
        
        var otherReason = component.get("v.otherReason");
        //pass parameters to the case creation method
		var params = {
            claimNum : claimNum,
            servLocguid : servLocguid,
            bizguid : bizguid,
            provguid : provguid,
            amount : amount,
            provNPI : provNPI,
            claimReason : claimReason,
            otherReason : otherReason,
            memFirst :memFirst,
            memLast :memLast

		};

        var wrapperCase = component.get('v.newCaseWrapper');
         
        //console.log(wrapperCase);
        if(wrapperCase && wrapperCase.Id) {
            params.caseId = wrapperCase.Id;
        }

        action.setParams(params); 

		action.setCallback(this,function(res){
			var state = res.getState();
            if(state === "SUCCESS"){
                var data = res.getReturnValue();
                //console.log("success");
                //populate success message parameters
				component.set("v.isVoidSuccess", true);
				component.set("v.voidSuccessMsg", $A.get('$Label.c.Claim_Void_Toast_Message') + ' # ' + data.CaseNumber );
				var successMsg = component.get("v.voidSuccessMsg");

                //attach files
                if (fileList.length > 0) {
                    component.set('v.caseId', data.Id);

                } else{
                    helper.successHelper(component,event, helper);
                }
            }else{
                //console.log('errors');
            }
		});

		$A.enqueueAction(action);
	},

	checkForErrors : function(component,event,helper){
		//check for required fields
		var amount = component.get("v.amount");
		var billingProvNpi = component.get("v.provNPI");
        var claimVoidReason = component.get("v.claimVoidReason");
        var otherReason = component.get("v.otherReason");
        //if required fields aren't filled out, throw an error
		if(amount == null || billingProvNpi == null){
			//console.log("here");
			component.set("v.isReqFieldError", true);
			component.set("v.requiredFieldMsg", "Please fill out the required fields before submitting");
		}

        if(amount < 0){
            component.set("v.isReqFieldError", true);
            component.set("v.requiredFieldMsg", "Amount cannot be a negative value");
        }

        if(billingProvNpi.toString().length != 10){
            component.set("v.isReqFieldError", true);
            component.set("v.requiredFieldMsg", "Billing NPI is not 10 digits");
        }

        if(isNaN(billingProvNpi)){
            component.set("v.isReqFieldError", true);
            component.set("v.requiredFieldMsg", "Billing NPI is not a number or not 10 digits");
        }

        if(claimVoidReason == null){
            component.set("v.isReqFieldError", true);
            component.set("v.requiredFieldMsg", "Please fill out the required fields before submitting");
        }
        //if claim void reason is other, the other reason field must be filled out
		if(claimVoidReason == 'Other' && otherReason == null){
            component.set("v.isReqFieldError", true);
            component.set("v.requiredFieldMsg", "Please fill out the required fields before submitting");
        }


	},

    successHelper : function (component, event, helper){
        //console.log('in success helper');
        var successMsg = component.get("v.voidSuccessMsg");
        //pass success parameters back to claim detail component
        var successEvent = component.getEvent("modalSuccessEvent");
            successEvent.setParams({
                    "isSuccess": true,
                    "successMsg" : successMsg,
                    "eventType" : "void"
            });
            successEvent.fire();

        component.destroy();
    },

    deleteAttachment : function(component, attachment, index) {
        component.set('v.fileNames', null);

    },

    submitWrapperCase: function(component) {
        //console.log("submitting wrapper case");
        var action = component.get("c.saveVoidWrapperApex"); 
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