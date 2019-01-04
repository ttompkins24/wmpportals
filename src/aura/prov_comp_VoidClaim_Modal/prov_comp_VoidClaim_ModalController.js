({
	doInit : function(component, event, helper) {
	},

	defaultCloseVoid : function(component, event, helper){
        component.destroy();
    },

    submitVoidClaim : function(component,event,helper){
        //set values to attributes on component
    	component.set("v.isReqFieldError", false);
        var amount = component.find("amount").get("v.value");
        var provNPI = component.find("provNPI").get("v.value");
        var reason = component.get("v.claimVoidReason");
        component.set("v.amount", amount);
        component.set("v.provNPI", provNPI);
        //check for errors before submitting
     	helper.checkForErrors(component,event,helper);
     	var reqFieldError = component.get("v.isReqFieldError");
        //if there are no errors, submit the voic claim case
     	if(!reqFieldError){
            console.log("no errors");
    	helper.createVoidClaimCase(component,event,helper);
    	}

    },

    handleRadioButton : function (component,event,helper){
        var opts = document.querySelector('input[name="options"]:checked').id;
        console.log('radio button selection:' + opts);
        
        component.set("v.claimVoidReason", opts);
        if(opts == 'Other'){
            var otherReason = component.find("otherReason").get("v.value");
            component.set("v.otherReason", otherReason);
        }

    },

    submitWrapperCase : function(component, event, helper) {
        helper.submitWrapperCase(component);
    },

    checkNPILength : function (component,event,helper){

        var billingProvNpi = component.get("v.provNPI");

        if(billingProvNpi.toString().length != 10){

            component.set("v.isProvNpiError", true);
            component.set("v.provNpiError", "Billing NPI is not 10 digits");
        }

        if(billingProvNpi.toString().length == 10){

            component.set("v.isProvNpiError", false);
        }
    },

    validate :function (component,event,helper){

        var npi = component.find("provNPI").get("v.value");
        console.log(npi);
        if(npi.toString().length > 10)
        {
            component.set('v.provNPI', npi.toString().substring(0, 10));
        }
    }

})