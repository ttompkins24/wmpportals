({
	doInit : function(component, event, helper) {
        //console.log('doInit');
		//initialize request maps
		component.set('v.preAuthDetailRequest', {});
		component.set('v.claimAttachRequest', {});
		//get parameter passed into page
		var params = component.get('v.params');
		var preAuthClaimId = params.id;
		//console.log(preAuthClaimId);

		var labelName = component.get('v.portalConfig.PreAuthorization_Label__c');
        labelValue = $A.getReference('$Label.c.' + labelName);
        
        ////console.log('pre auth label: ' + labelValue);

        component.set('v.preAuthLabel', labelValue);
		//if the parameter starts with a SFDC id prefix, generate one page
		if(preAuthClaimId.startsWith("a09")){
			////console.log("generating page from draft pre-auth");
			helper.retrieveSFDCPreAuthInfo(component,event,helper, preAuthClaimId);
			
		}
		//else generate the page from the REST call
		else{
			////console.log("generating page from REST call");
			
		}

		var listener = function(event) {
			var origin = component.get('v.vfHost');
			//console.log('in listener');
			//console.log('event.origin ' + event.origin);
    		//console.log('origin' + origin);
			if(event.origin !== origin) {
    			//not the expected origin. reject results
    			//console.log('origins did not match');
    			return;
    		}
    		//Handle the message
    		var results = event.data;
    		
    		if(results == 'pageLoaded'){
    			//console.log('page loaded');
    			if(!params.id.startsWith("a0Y")){
            	helper.retrievePreAuthInfo(component, event, helper, preAuthClaimId);
    			}
            } 

    		//console.log('results ' + results);
    		//console.log('results ' + JSON.stringify(results));
    		//console.log('results ' + typeof results);
			//console.log('time out in search page' + results.hasOwnProperty('timeout'));

			if(results.hasOwnProperty('timeout')){
				component.set("v.isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Server_No_Response_Error"));

			} 
			else if(results.type == "preAuth"){

				if(results.str != '' && results.str != null){
	    			//console.log('good results preAuth');
					component.set("v.preAuthDetail",  results.str);
					//console.log('claim results number' + results.str.Header.ClaimNumber);
					var spinner = component.find('spinnerId');
            		$A.util.addClass(spinner, 'slds-hide');
					helper.getAttachmentsByClaimNum(component,event,helper, results.str.Header.ClaimNumber);
					
			
				} else {
	    			//console.log('bad results preAuth');
					//setting the error flag and the message	
					window.scrollTo(0,0);			
					component.set("v.isError",true);
					component.set("v.str_errorMsg",$A.get("$Label.c.Server_No_Response_Error"));
				}
			}

			else if (results.type == "attachments"){
				if(results.str != '' && results.str != null){
					//console.log('good results ');
					component.set("v.attachDetails", results.str);
				}
				 else {
	    			//console.log('bad results ');
					//setting the error flag and the message	
					window.scrollTo(0,0);			
					component.set("v.isError",true);
					component.set("v.str_errorMsg",$A.get("$Label.c.Server_No_Response_Error"));
				}
	    		
			}
			else if (event.data.type == "attach"){

				if(results.str != '' && results.str != null){
					//console.log('good results from attachment body');
					//console.log('eob returned');
                //Handle the message

                var doc = event.data.str;
                var name = event.data.name;
                var filetype = event.data.filetype;
                //console.log(filetype);

                if(doc != undefined || doc != ''){
                    //console.log('doc not blank');
                    //console.log('doc ' + doc);

                    // IE doesn't allow using a blob object directly as link href
                    // instead it is necessary to use msSaveOrOpenBlob

                    if (window.navigator && window.navigator.msSaveOrOpenBlob) { // IE workaround
                        var byteCharacters = atob(doc);
                        var byteNumbers = new Array(byteCharacters.length);
                        
                        for (var i = 0; i < byteCharacters.length; i++) {
                            byteNumbers[i] = byteCharacters.charCodeAt(i);
                        }
                        
                        var byteArray = new Uint8Array(byteNumbers);
                        var blob = new Blob([byteArray], {type: filetype});
                        window.navigator.msSaveOrOpenBlob(blob, name);
                        component.set('v.showSpinner', false);

                    } else {
                        var element = document.createElement('a');

                        element.setAttribute('href', 'data:make-me-download;base64,' + doc);

                        element.setAttribute('download', name);

                        element.style.display = 'none';
                        document.body.appendChild(element);

                        element.click();

                        document.body.removeChild(element);

                        //console.log('end of download');
                        component.set('v.showSpinner', false);
                    }

                } else {

                    //setting the error flag    and the message
                    component.set('v.showSpinner', false);

                    component.set("v.isError",true);
                    component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
                    //console.log('Error');
                }

					
				}
				 else {
	    			//console.log('bad results ');
					//setting the error flag and the message	
					window.scrollTo(0,0);			
					component.set("v.isError",true);
					component.set("v.str_errorMsg",$A.get("$Label.c.Server_No_Response_Error"));
				}
	    		

			}
		}
		//console.log('about to hit the if statment');
		if(window.addEventListener !== undefined) {
			//console.log('adding listener');
			window.addEventListener("message", listener, false);
		} else {
			//console.log('attaching event');
			attachEvent("onmessage", listener);
		}			
	},

	handleStartClaim :function(component,event,helper){
		//console.log('handling start Claim');
		
		helper.startCreateClaim(component,event,helper);
	},

	printList:function(component, event, helper){
		//console.log("print...");
		window.print();
	},
	handleModalSuccess :function(component,event,helper){

		//check values passed in by component event to check if the parameters should reflect a void or appeal response
		var successValue = event.getParam("isSuccess");
		var successMsg = event.getParam("successMsg");
		var type = event.getParam("eventType");
		if(type == 'appeal'){
			component.set("v.isAppealSuccess", successValue);
			component.set("v.appealSuccessMsg", successMsg);
		}

		
	},

	handlePreAuthAppeal :function (component,event,helper) {
		//console.log('appeal preAuth...');
		var appealClick = event.currentTarget;
		var claimRecClaimNumber = appealClick.dataset.claimnumber;
		var claimRecClaimType = appealClick.dataset.claimtype;
		var claimRecBusiness = appealClick.dataset.business;
		var claimRecOffice = appealClick.dataset.office;
		var claimRecProvider = appealClick.dataset.dentist;
		var claimRecMemberName = appealClick.dataset.membername;
		var claimRecMemberDOB = appealClick.dataset.memberdob;
		var claimRecMemberNumber = appealClick.dataset.membernumber;
		var claimRecBusinessGuid = appealClick.dataset.bizguid;
		var claimRecServiceLocationGuid = appealClick.dataset.locguid;
		var claimRecProviderGuid = appealClick.dataset.provguid;
		//console.log(claimRecMemberDOB);
		$A.createComponent(
			'c:prov_comp_AppealClaim_Modal',
			{
				"claimType" :claimRecClaimType,
				"claimNumber" : claimRecClaimNumber,
				"business" :claimRecBusiness,
				"serviceOffice" : claimRecOffice,
				"provider" : claimRecProvider,
				"businessGuid" :claimRecBusinessGuid,
				"serviceOfficeGuid" : claimRecServiceLocationGuid,
				"providerGuid" :claimRecProviderGuid,
				"memberName" : claimRecMemberName,
				"memberBirth" : claimRecMemberDOB,
				"memberNumber" :claimRecMemberNumber
			},
			function(newModal, status, errorMessage){
				//console.log(status);
				//console.log(newModal);
				if (status === "SUCCESS") {
					var body = component.get("v.body");
					body.push(newModal);
					component.set('v.body', body);
				}
			}
		);
	},

	handleDownloadAttach : function(component,event,helper){
        var tar = event.currentTarget;
        var attachmentLink = tar.dataset.value;
        var name = tar.dataset.name;
        var filetype = tar.dataset.filetype;
		//var attachURL = component.get('v.attachmentUrl');
        
        var fileLink = attachmentLink;//attachURL+'?Id='+attachmentId + '&filename=' + name;


		helper.fetchDocument(component, helper, fileLink, name, filetype);
		// helper.downloadAttach(component,event,helper);
	}


})