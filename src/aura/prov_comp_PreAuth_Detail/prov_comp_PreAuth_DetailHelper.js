({
	  
    retrievePreAuthInfo: function(component,event,helper, preAuthClaimId){

        var providercache = JSON.parse(localStorage['providercache']);
        var businessId = sessionStorage['businessid'];

        var preAuthDetailRequest = component.get("v.preAuthDetailRequest");
        var businessGuid = providercache.businessMap[businessId].windward_guid__c;

        //preAuthDetailRequest['businessId'] = businessId;
        // preAuthDetailRequest['claimNumber'] = '101429348730100';
        // preAuthDetailRequest['businessGuid'] = '083149db-9c70-4d09-b21e-87150336cd65';

        preAuthDetailRequest['claimNumber'] = preAuthClaimId;
        preAuthDetailRequest['businessGuid'] = businessGuid;

        var jsonStr = JSON.stringify(preAuthDetailRequest);

        //console.log('jsonStr ' + jsonStr);

        var message = {type: "preAuth", str: jsonStr};
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

    retrieveSFDCPreAuthInfo: function(component,event,helper, preAuthClaimId){
        action = component.get("c.getPreAuthRecSFDCDetails");
        //console.log('sfdc pre auth');
        action.setParams({
            "claimId" : preAuthClaimId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
            
                //sets response to wrapper object
                component.set("v.preAuthDetail", response.getReturnValue());
                var claimdetails = response.getReturnValue();

                //console.log(claimdetails.Header.PatientBirthDate);

            }else{
                //console.log("error");
            }
            var spinner = component.find('spinnerId');
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action); 

    },


    startCreateClaim : function(component, event, helper) {
        var preAuth = component.get("v.preAuthDetail");
        //console.log(preAuth);
        //console.log(JSON.stringify(preAuth));
		var action = component.get('c.startClaimFromPreAuth');
		action.setParams({
			"preAuth" : JSON.stringify(preAuth)
		});



		action.setCallback(this, function(response) {
			var state = response.getState();
        	if(state === "SUCCESS"){
        		//get response
        		var claimId = response.getReturnValue();
                //console.log(claimId);
        		//call reroute to claim entry
        		helper.claimEntryRedirect(component,event,helper, claimId);
        	}else{
                //console.log('error');
            }

		});

		$A.enqueueAction(action);
	},

    appealPreAuth :function(component,event,helper){

    },

	claimEntryRedirect : function(component,event,helper, claimId){
        //sets page name to route to
        var pageName = "claim-entry";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "memberProfileGuid" : claimId

            });
            redirectEvent.fire();
    },

    getAttachmentsByClaimNum : function (component,event,helper, claimNum){
        //console.log(claimNum);

        var claimAttachRequest = component.get("v.claimAttachRequest");
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

        //console.log('name ' + name);
        //console.log('fType ' + filetype);

        var attachmentLinkStr = {};

        attachmentLinkStr['eobLink'] = eobLink;
        attachmentLinkStr['filetype'] = filetype;
        attachmentLinkStr['name'] = name;

        var jsonStr = JSON.stringify(attachmentLinkStr);

        //console.log('jsonStr ' + jsonStr);
        var message = {type: "attach", name : name, filetype: filetype, str: jsonStr};
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