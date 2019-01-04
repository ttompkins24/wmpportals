({

	retrieveCurrentBiz: function(component, event, helper){
        //get current business on page load
        var action = component.get("c.getCurrentBusiness"); 
        action.setCallback(this, function(response){
        var state = response.getState();
        if(state === "SUCCESS"){
            component.set("v.business", response.getReturnValue());
            var bizAcctRec = component.get("v.business");
            var bizAcctRecId = bizAcctRec.Id;
            component.set("v.bizAcctRecId", bizAcctRecId);
            var bizTin = bizAcctRec.tax_id_number__c;
            var bizTinSub = bizTin.substr(bizTin.length - 4)
            var tin = '******' + bizTinSub;
			component.set("v.businessTin", tin);
			component.set("v.businessName", bizAcctRec.Name);

            helper.checkEftStatus(component,event, helper);
            helper.getServiceLocations(component, event, helper);
            }
        });
        $A.enqueueAction(action);
        
    },

    checkEftStatus : function (component, event,helper){

    var bizAcctRec = component.get("v.business");
    var action = component.get("c.checkHasActiveEftPsl");

    action.setParams({
        "bizAcctId" : bizAcctRec.Id
    });

    action.setCallback(this, function(response){
        var state = response.getState();
        if(state === "SUCCESS"){
            ////console.log('eft status' + response.getReturnValue());
            component.set("v.hasEFTMods", response.getReturnValue());
        }
    });
    $A.enqueueAction(action);

    },

	getServiceLocations : function(component,event,helper) {
        ////console.log('getting service locations');
        var acctRecId = component.get("v.bizAcctRecId");
        var action1 = component.get("c.getAllLocations");
        action1.setParams({
            "bizAcctId" : acctRecId
        });

        action1.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
                component.set("v.locList", res.getReturnValue());

                if(res.getReturnValue().length === 1){
                component.find("locAccts").set("v.value", res.getReturnValue()[0]);
                component.set('v.locAcctRecId', res.getReturnValue()[0].Id);
                    component.set('v.showProviderDropdown', true);
                    var modEft = component.get("v.isModEft");
                    if(modEft == true){
                        helper.getEFTProviderServiceLocations(component,event, helper);
                    }else{

                        helper.getNewProviderServiceLocations(component,event, helper);
                    }
                    
                }

            }
        });
        $A.enqueueAction(action1);
	},


    getNewProviderServiceLocations :function (component,event, helper){
        var bizAcctId = component.get("v.bizAcctRecId");
        var slLocRecId = component.get("v.locAcctRecId");

        var action = component.get("c.getNewProviderServiceLocations");
        action.setParams({
            "bizAcctId": bizAcctId,
            "servLocId" : slLocRecId
        });

        action.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){

                component.set("v.pslList", res.getReturnValue());

            }
        });
        $A.enqueueAction(action);

    },

    getEFTProviderServiceLocations :function (component,event, helper){

        var modEft = component.get("v.isModEft");
        var bizAcctId = component.get("v.bizAcctRecId");
        var slLocRecId = component.get("v.locAcctRecId");

        var action = component.get("c.getEFTProviderServiceLocations");
        action.setParams({
            "bizAcctId": bizAcctId,
            "servLocId" : slLocRecId
        });

        action.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
                component.set("v.pslList", res.getReturnValue());
            }
        });
        $A.enqueueAction(action);

    },

    createEftCase :function(component,event,helper, eftjson){
        component.set("v.showSpinner", true);
        component.set("v.isEFTSuccess", false);
        action = component.get("c.createCase");

        var newEftMap = component.get("v.eft_Gid_updates");

        var changes = JSON.stringify(newEftMap, undefined, 4);

        var wrapperCase = component.get('v.newCaseWrapper');
        var caseId ='';
        if(wrapperCase && wrapperCase.Id) {
            caseId = wrapperCase.Id;
        }

        var slLocRecId = component.get("v.locAcctRecId");
        ////console.log('eftJSON ****' + JSON.stringify(eftjson));

        action.setParams({
            "eftJson" : JSON.stringify(eftjson),
            "caseId" : caseId,
            "changesJson" :changes,
            "locAcctId": slLocRecId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                ////console.log("success");
                component.set("v.showSpinner", false);
                //sets response to wrapper object
                component.set("v.caseId", response.getReturnValue());
                var data = response.getReturnValue();
                //set success messages
                component.set("v.isEFTSuccess", true);
                component.set("v.EFTSuccessMsg",  $A.get('$Label.c.EFT_Success_Text') +  data.CaseNumber);
                //clear fields
                component.set("v.bankName", null);
                component.set("v.accountHolderName", null);
                component.set("v.accountNumber", null);
                component.set("v.bankPhone", null);
                component.set("v.desiredStartDate", null);
                component.set("v.routingNumber", null);
                component.set("v.accountType", null);
                component.set("v.contactFirstName", null);
                component.set("v.contactLastName", null);
                component.set("v.contactPhone", null);
                component.set("v.contactEmail", null);
                helper.getServiceLocations(component, event, helper);
                component.set('v.showProviderDropdown', false);
                component.set('v.newCaseWrapper', null);
                component.set('v.anotherContact', false);

                helper.getContactInfo(component, event, helper);

                
                window.scroll(0,0);

            }else{
                ////console.log("error");
            }
                //turn off spinner

        });
        $A.enqueueAction(action); 
    
    },

    checkForErrors :function(component,event,helper, pslToSubmit){
        var anotherContact = component.get('v.anotherContact');
        component.set("v.showSpinner", true);
        component.set('v.isReqFieldError', false);
        hasError = false;
        component.find('bankName').set('v.errors', null);
        component.find('accountHolderName').set('v.errors', null);
        component.find('accountNumber').set('v.errors', null);
        component.find('bankPhone').set('v.errors', null);
        component.find('desiredStartDate').set('v.errors', null);
        component.find('routingNumber').set('v.errors', null);

        component.find('contactFirstName').set('v.errors', null);
        component.find('contactLastName').set('v.errors', null);
        component.find('contactPhone').set('v.errors', null);
        component.find('contactEmail').set('v.errors', null);
        

        var bankName = component.get('v.bankName');
        var acctHolder = component.get('v.accountHolderName');
        var acctNum = component.get('v.accountNumber');
        var bankPhone = component.get('v.bankPhone');
        var startDate = component.get('v.desiredStartDate');
        var routingNumber = component.get('v.routingNumber');
        var contactFirst = component.get('v.contactFirstName');
        var anotherContact = component.get('v.anotherContact');
        var contactLast = component.get('v.contactLastName');
        var phone = component.get('v.contactPhone');
        var email = component.get('v.contactEmail');
        var serviceLocation = component.get("v.locAcctRecId");
        var date_regex =  /^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/  ;
        ////console.log('after')
        if(!(date_regex.test(startDate)) && startDate != null ){
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Date_Format_Validation'));
            window.scrollTo(0,0);
        }

        var emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        
        if(!(emailRegex.test(String(email).toLowerCase()))){
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Email_Format_Validation'));
            window.scrollTo(0,0);
        }

                    
        if(bankName == null || bankName == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('bankName').set('v.errors', [{message : 'Field is required'}]);

            window.scrollTo(0,0);



        }


        if(acctHolder == null || acctHolder == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('accountHolderName').set('v.errors', [{message : 'Field is required'}]);

            window.scrollTo(0,0);

        }

        if(acctNum == null || acctNum == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('accountNumber').set('v.errors', [{message : 'Field is required'}]);
            window.scrollTo(0,0);

        }
        if(bankPhone == null || bankPhone == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('bankPhone').set('v.errors', [{message : 'Field is required'}]);
            window.scrollTo(0,0);

        }

        if(startDate == null || startDate == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('desiredStartDate').set('v.errors', [{message : 'Field is required'}]);
            window.scrollTo(0,0);

        }

        if(routingNumber == null || routingNumber == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('routingNumber').set('v.errors', [{message : 'Field is required'}]);
            window.scrollTo(0,0);

        }

        if(contactFirst == null || contactFirst == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('contactFirstName').set('v.errors', [{message : 'Field is required'}]);

            window.scrollTo(0,0);

        }

        if(contactLast == null || contactLast == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('contactLastName').set('v.errors', [{message : 'Field is required'}]);
            window.scrollTo(0,0);

        }

        if(phone == null || phone == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('contactPhone').set('v.errors', [{message : 'Field is required'}]);
            window.scrollTo(0,0);

        }

        if(email == null || email == ''){
            hasError=true;
            component.set('v.isReqFieldError', true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Required_Fields_Text'));
            component.find('contactEmail').set('v.errors', [{message : 'Field is required'}]);
            window.scrollTo(0,0);

        }
        var num_regex =  /^[0-9]+$/ ;
        ////console.log(routingNumber);

        if(routingNumber != '' && routingNumber != null){
            if(!(num_regex.test(routingNumber)) || routingNumber.length != 9){

            hasError=true;
            component.set("v.isReqFieldError", true);
            component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Routing_Number_Text'));
            component.find('routingNumber').set('v.errors', [{message : 'Field must be 9 digits and a Number'}]);
            window.scrollTo(0,0);
            } 
            
        }
        //console.log(acctNum.length);
        if(acctNum != '' && acctNum != null){
            if(!(num_regex.test(acctNum)) || acctNum.length < 5 || acctNum.length > 20){
                hasError=true;
                component.set("v.isReqFieldError", true);
                component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_Account_Number_Text'));
                component.find('accountNumber').set('v.errors', [{message : 'Field must be a Number'}]);
                window.scrollTo(0,0);
                
            }
        }
        


        if(pslToSubmit.length == 0 && (serviceLocation != 'All' && serviceLocation != null && serviceLocation != '')){
          component.set("v.isReqFieldError", true);
          component.set("v.requiredFieldMsg",  $A.get('$Label.c.EFT_One_Provider_Text'));
          window.scrollTo(0,0);
        }

        var requiredFieldError = component.get('v.isReqFieldError');
        if(requiredFieldError == false){

        
            if(serviceLocation == 'All' || serviceLocation == null){
                helper.eftChangesOnAllServLocations(component,event,helper);    
            }else{
                helper.eftChangesOnServiceLocationsProviders(component,event,helper, pslToSubmit);
            }
        }
////console.log('before spinner');
        component.set('v.showSpinner', false);
////console.log('after spinner');

    },

    getContactInfo : function(component,event,helper){

        action = component.get("c.retrieveCurrentContact");

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){

                var data = response.getReturnValue();
                component.set('v.contact', data);
                helper.setDefaultRadio(component,event,helper);

            }else{
            }

        });
        $A.enqueueAction(action); 


    },

    submitWrapperCase: function(component) {
        var action = component.get("c.saveEFTCaseWrapperApex");
  
        action.setCallback(this, function(response) {
            var state = response.getState();
  
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                ////console.log('### case saved: ' + JSON.stringify(data));
                component.set('v.newCaseWrapper', data);   
            } else {  
                ////console.log('error');
            } 
        });

        $A.enqueueAction(action);
    },

    eftChangesOnAllServLocations : function(component,event, helper){
        component.set('v.showSpinner', true);
        var newEftMap = component.get("v.eft_Gid_updates");

        var bizId =  component.get("v.bizAcctRecId");

        var action = component.get("c.eftAllServLocsMap");

        action.setParams({
            "bizId":bizId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
  
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                component.set('v.eft_Gid_updates', data);   
                var eftCase = component.get("v.eftFieldsForCase");
                helper.createEftCase(component,event,helper, eftCase);
            } else {  
                ////console.log('error');
            } 
        });

        $A.enqueueAction(action);

    },

    eftChangesOnServiceLocationsProviders : function(component,event, helper, pslToSubmit){
        component.set('v.showSpinner', true);
        var newEftMap = component.get("v.eft_Gid_updates");
        var locId =  component.get("v.locAcctRecId");

        var action = component.get("c.eftOneServLocMap");

        action.setParams({
            "locId":locId,
            "pslIdString": pslToSubmit
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
  
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();

                component.set('v.eft_Gid_updates', data);   
                var eftCase = component.get("v.eftFieldsForCase");
                helper.createEftCase(component,event,helper, eftCase);
            } else {  
                ////console.log('error');
            } 
        });

        $A.enqueueAction(action);
    },

    radioHelper : function(component,event,helper){
        component.set('v.anotherContact', false);
        var con = component.get('v.contact');
        var opts = document.querySelector('input[name="options"]:checked').id;

        ////console.log(opts);
        if(opts == 'radio-2'){
            component.set('v.anotherContact', true);
            component.set("v.contactFirstName", null);
            component.set("v.contactLastName", null);
            component.set("v.contactEmail", null);
            component.set("v.contactPhone", null);
        }

        if(opts == 'radio-1'){
            //set the contact information fields to match what is already stored for that contact
            component.set('v.contactFirstName', con.FirstName);
            component.set('v.contactLastName', con.LastName);
            component.set('v.contactPhone', con.Phone);
            component.set('v.contactEmail', con.Email);

        }

        ////console.log(component.get('v.contactFirstName'));
    },

    setDefaultRadio :function(component,event,helper){
        ////console.log('setting default');
        helper.radioHelper(component,event,helper);
    },
})