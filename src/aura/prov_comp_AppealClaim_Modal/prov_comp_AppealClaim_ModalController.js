({
	doInit : function(component, event, helper) {
        var labelName = component.get('v.portalConfig.PreAuthorization_Label__c');
        labelValue = $A.getReference('$Label.c.' + labelName);

        //console.log(component.get('v.memberBirth'));
        
        //console.log('pre auth label: ' + labelValue);

        component.set('v.preAuthLabel', labelValue);
        
        //console.log(component.get('v.memberBirth'));
        
	},
	defaultCloseAppeal : function(component, event, helper){
        component.destroy();
    },

    submitAppealClaim :function(component,event,helper){
        var memberDob = component.get("v.memberBirth");
        var memberNumber = component.get("v.memberNumber");
        //console.log('here is the member Date of Birth' + memberDob);
        component.set("v.isReqFieldError", false);
        component.set("v.isAppealSuccess", false);
     	helper.checkForErrors(component,event,helper);

        var appealReasonError = component.get("v.isReqFieldError");
        //if there isn't an error, submit an appeal case
        if(!appealReasonError){
    	   helper.createAppealClaimCase(component,event,helper);

        }

    },

   

    submitWrapperCase : function(component, event, helper) {
        helper.submitWrapperCase(component);
    },

    


})