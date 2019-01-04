({
	doInit : function(component, event, helper) {
		component.set('v.eftFieldsForCase', {});
        component.set('v.eft_Gid_updates', {});

        //check if the business is enrolled yet
        helper.retrieveCurrentBiz(component,event,helper);

        helper.getContactInfo(component,event,helper);

        
	},

	submitNewEft :function(component,event,helper){
	   
		var eftCase = component.get("v.eftFieldsForCase");

        eftCase['BankName'] = component.get('v.bankName');
        eftCase['AccountHolderName'] = component.get('v.accountHolderName');
        eftCase['AccountNumber'] = component.get('v.accountNumber');
        eftCase['BankPhone'] = component.get('v.bankPhone');
        eftCase['DesiredStartDate'] = component.get('v.desiredStartDate');
        eftCase['RoutingNumber'] = component.get('v.routingNumber');
        eftCase['ContactFirstName'] = component.get('v.contactFirstName');
        eftCase['ContactLastName'] = component.get('v.contactLastName');
        eftCase['ContactPhone'] = component.get('v.contactPhone');
        eftCase['ContactEmail'] = component.get('v.contactEmail');
        eftCase['BankAccountType'] = component.get('v.accountType');

        eftCase['EftMod'] = component.get('v.eFTModificationType');
        //get the list of PSLs that are checked
        //console.log(eftCase);
 	      
		var updatedPSL = component.get('v.pslList');
     	var pslToSubmit = [];
     	var checkPSL = component.find('checkPSL');
        if(updatedPSL.length > 0){


        if(!Array.isArray(checkPSL)) {
                pslToSubmit.push(updatedPSL[0].windward_guid__c)
            } else {
                for(var i=0; i<checkPSL.length; i++){
                    if(checkPSL[i].get('v.value') == true)
                    pslToSubmit.push(updatedPSL[i].windward_guid__c);

                }
            } 
        }
        
        
		helper.checkForErrors(component,event,helper, pslToSubmit);
       

	},

	//retrieves selected location ID
    updateLocSearch: function(component, event, helper) {
        component.set('v.showProviderDropdown', true);
        var selectedLocRec = component.find("locAccts").get("v.value");

        component.set("v.locAcctRecId", selectedLocRec);

        if(component.get("v.locAcctRecId") == 'All'){

            component.set('v.showProviderDropdown', false);
        }

        var modEft = component.get("v.isModEft");

        if(modEft == true){
            helper.getEFTProviderServiceLocations(component,event, helper);
        }else{

            helper.getNewProviderServiceLocations(component,event, helper);
        }

    },

    handleSelectAllPSLs :function (component,event,helper){

		var checkValue = component.find('selectAll').get('v.value');        
        var checkPSL = component.find('checkPSL'); 
        if(checkValue == true){
            if(!Array.isArray(checkPSL)) {
                component.find('checkPSL').set('v.value',true);
            } else {
                for(var i=0; i<checkPSL.length; i++){
                    checkPSL[i].set('v.value',true);
                }
            } 
        }
        else{ 
            if(!Array.isArray(checkPSL)) {
                component.find('checkPSL').set('v.value',false);
            } else {
                for(var i=0; i<checkPSL.length; i++){
                    checkPSL[i].set('v.value',false);
                }
            }             
        }
    },

	newEftTab :function(component,event,helper){

        $('.slds-tabs_default').find('.mod-eft-tab').removeClass('slds-active');
        $('.slds-tabs_default').find('.new-eft-tab').addClass('slds-active');
        component.set("v.isNewEft", true);
        component.set("v.isModEft", false);
        component.set("v.eFTModificationType", null);
        
        helper.getNewProviderServiceLocations(component,event, helper);
 

    },

    modEftTab :function(component,event,helper){

        $('.slds-tabs_default').find('.new-eft-tab').removeClass('slds-active');
        $('.slds-tabs_default').find('.mod-eft-tab').addClass('slds-active');

        component.set("v.isModEft", true);
        
        var modEft = component.get("v.isModEft");
            helper.getEFTProviderServiceLocations(component,event, helper);

    },

    redirectToFAQ :function(component, event, helper){
        var articleName = event.currentTarget.dataset.articlename;
        var dataCategory = event.currentTarget.dataset.datacategory;
        
         var urlEvent = $A.get("e.c:prov_event_Redirect");
         urlEvent.setParams({
             "pageName" :"faq?articlename="+articleName+"&datacategory="+dataCategory
         });
         urlEvent.fire();
    },

    setModType :function (component,event,helper){
        var type = component.get("v.eFTModificationType");
        ////console.log(type);
        if(type == "Cancel"){
            component.set("v.isCancelEft", true);
        }else{
            component.set("v.isCancelEft", false);
        }
    },

	handleRadioButton : function (component,event,helper){
		helper.radioHelper(component,event,helper);

    },

    submitWrapperCase : function(component, event, helper) {
        helper.submitWrapperCase(component);
    },

    fixConPhone :function(component,event,helper){

        var s = component.get('v.contactPhone');

        var s2 = (""+s).replace(/\D/g, '');

        var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
        var fixedPhone = (!m) ? "" : "(" + m[1] + ") " + m[2] + "-" + m[3];
        component.set('v.contactPhone', fixedPhone);

    },

    fixBankPhone :function(component,event,helper){

        var s = component.get('v.bankPhone');

        var s2 = (""+s).replace(/\D/g, '');

        var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
        var fixedPhone = (!m) ? "" : "(" + m[1] + ") " + m[2] + "-" + m[3];
        component.set('v.bankPhone', fixedPhone);

    },

    fixAcctNum :function(component,event,helper){
        component.set('v.isReqFieldError', false);
        
        var acctNum =  component.get('v.accountNumber');

        var num_regex =  /^[0-9]+$/  ;
        if(acctNum != null && acctNum != '' && acctNum != undefined && !(num_regex.test(acctNum))){
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Number_Validation'));
            window.scrollTo(0,0);
        }

    },


    fixRoutingNum :function(component,event,helper){
        component.set('v.isReqFieldError', false);
        
        var routingNum = component.get('v.routingNumber');

        var num_regex =  /^[0-9]+$/  ;

        if(routingNum != null && routingNum != '' && routingNum != undefined && !(num_regex.test(routingNum))){

            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Number_Validation'));
            window.scrollTo(0,0);
        }

    },


})