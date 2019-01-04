({
	retrieveReferralInfo: function(component,event,helper, referralClaimId){

        var providercache = JSON.parse(localStorage['providercache']);
        var businessId = component.get("v.currentBusinessId");

        var referralDetailRequest = component.get("v.referralDetailRequest");
        var businessGuid = providercache.businessMap[businessId].windward_guid__c;
        // referralDetailRequest['claimNumber'] = '101212540890500';
        // referralDetailRequest['businessGuid'] = '90729872-d291-4514-81b4-2dd64c43f000';

        referralDetailRequest['claimNumber'] = referralClaimId;
        referralDetailRequest['businessGuid'] = businessGuid;




        //console.log('ref detail req' + referralDetailRequest);
        

        var jsonStr = JSON.stringify(referralDetailRequest);

        //console.log('jsonStr ' + jsonStr);

        var message = {type: "referral", str: jsonStr};
        //console.log('message ' + message);

        //holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
        //console.log(vfOrigin);
        //var vfOrigin = "https://dev1-greatdentalplans-community.cs13.force.com/Provider/";
        window.scrollTo(0,0);           
        //console.log('before');
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        //console.log('after');
        vfWindow.postMessage(message, vfOrigin);
    },

    retrieveSFDCReferralInfo: function(component,event,helper, referralClaimId){
        action = component.get("c.getReferralRecSFDCDetails");
        //console.log(referralClaimId);
        action.setParams({
            "claimId" : referralClaimId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
            
                //sets response to wrapper object
                component.set("v.referralDetail", response.getReturnValue());
                var referralDetail = response.getReturnValue();
                //console.log('referral detail::' + referralDetail.Referral.RequestedProviderName);

            }else{
                //console.log("error");
            }
            var spinner = component.find('spinnerId');
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action); 

    },

     getAttachmentsByClaimNum : function (component,event,helper, claimNum){

        var claimAttachRequest = component.get("v.claimAttachRequest");
        // claimAttachRequest['claimNumber'] = '201704600338500';
        // claimAttachRequest['RouteId'] = 'GOV';

        claimAttachRequest['claimNumber'] = claimNum;
        claimAttachRequest['RouteId'] = sessionStorage['portalconfig_lob'];
        //console.log(claimAttachRequest);

        var jsonStr = JSON.stringify(claimAttachRequest);

        //console.log('jsonStr ' + jsonStr);
        var message = {type: "attachments", str: jsonStr};
        //console.log('message ' + message);

        //holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
        //console.log(vfOrigin);
        //var vfOrigin = "https://dev1-greatdentalplans-community.cs13.force.com/Provider/";
        window.scrollTo(0,0);           
        //console.log('before');
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        //console.log('after');
        vfWindow.postMessage(message, vfOrigin);
    },

    fetchDocument: function(component, helper, eobLink, name, filetype){
        //var action = component.get("c.retreiveAttachmentBody");
        //console.log('name ' + name);
        //console.log('fType ' + filetype);

        var attachmentLinkStr = {};

        attachmentLinkStr['eobLink'] = eobLink;
        attachmentLinkStr['filetype'] = filetype;

        var jsonStr = JSON.stringify(attachmentLinkStr);

        //console.log('jsonStr ' + jsonStr);
        var message = {type: "attach", str: jsonStr};
        //console.log('message ' + message);

        //holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
        //console.log(vfOrigin);
        //var vfOrigin = "https://dev1-greatdentalplans-community.cs13.force.com/Provider/";
        window.scrollTo(0,0);           
        //console.log('before');
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        //console.log('after');
        vfWindow.postMessage(message, vfOrigin);
    },
})