({
	retrieveClaimInfo : function(component, event, helper, claimRecNum) {
        //get session variables to pass into REST request
		var providercache = JSON.parse(localStorage['providercache']);
		var businessId = sessionStorage['businessid'];
		var claimDetailRequest = component.get("v.claimDetailRequest");
		var businessGuid = providercache.businessMap[businessId].windward_guid__c;
		//claimDetailRequest['businessId'] = businessId;
		claimDetailRequest['claimNumber'] = claimRecNum;
		// claimDetailRequest['businessGuid'] = '083149db-9c70-4d09-b21e-87150336cd65';
        //turn this on when needed
        claimDetailRequest['businessGuid'] = businessGuid;


        var jsonStr = JSON.stringify(claimDetailRequest);

        //console.log('jsonStr ' + jsonStr);

        var message = {type: "claim", str: jsonStr};
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

	retrieveSFDCClaimInfo : function(component,event,helper,claimId){

		action = component.get("c.getClaimRecSFDCDetails");

		action.setParams({
			"claimId" : claimId
		});

		action.setCallback(this, function(response){
        	var state = response.getState();
        	if(state === "SUCCESS"){
        		//sets response to wrapper object
                // console.log('response wrapper ' + JSON.stringify(response.getReturnValue()));
        		component.set("v.claimDetail", response.getReturnValue());
        		var claimdetails = response.getReturnValue();
        		//console.log('claim detail' + claimdetails.Header.PatientBirthDate);
                component.set("v.claimNum", claimdetails.Header.ClaimNumber);
        		

        	}else{
        		//console.log("error");
        	}
			var spinner = component.find('spinnerId');
       	    $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action); 

	},

    getAttachmentsByClaimNum : function (component,event,helper, claimNum){
        //console.log(claimNum);
        //get attachments based on claim num retrieved from initial page load
        var claimAttachRequest = component.get("v.claimAttachRequest");
        // claimAttachRequest['claimNumber'] = '201704600338500';
        // claimAttachRequest['RouteId'] = 'GOV';

        claimAttachRequest['claimNumber'] = claimNum;
        claimAttachRequest['RouteId'] = sessionStorage['portalconfig_lob'];


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