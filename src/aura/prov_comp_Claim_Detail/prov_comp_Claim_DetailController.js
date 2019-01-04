({
	doInit : function(component, event, helper) {
		//initialize request maps
		component.set('v.claimDetailRequest', {});
		component.set('v.claimAttachRequest', {});

		//get parameter passed into page
		var params = component.get('v.params');
		var claimId = params.id;
		//console.log(claimId);
		//if the parameter starts with a SFDC id prefix, generate one page
		if(params.id.startsWith("a09")){
			//console.log("generating page from draft claim");
			helper.retrieveSFDCClaimInfo(component,event,helper, claimId);
			
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
            	helper.retrieveClaimInfo(component, event, helper, claimId);

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
			else if(results.type == "claim"){
				if(results.str != '' && results.str != null){
	    			//console.log('good results ');
					component.set("v.claimDetail",  results.str);
					//console.log('claim results number' + results.str.Header.ClaimNumber);
					var spinner = component.find('spinnerId');
            		$A.util.addClass(spinner, 'slds-hide');
					helper.getAttachmentsByClaimNum(component,event,helper, results.str.Header.ClaimNumber);

			
				} else {
	    			//console.log('bad results ');
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

	printList:function(component, event, helper){
		//console.log("print...");
		window.print();
	},

	voidClaim :function(component,event,helper){
		//console.log('void Claim...');
		var voidClick = event.currentTarget;
		var claimRecClaimNumber = voidClick.dataset.claimnumber;
		var claimRecClaimType = voidClick.dataset.claimtype;
		var claimRecBusiness = voidClick.dataset.business;
		var claimRecOffice = voidClick.dataset.office;
		var claimRecProvider = voidClick.dataset.dentist;
		var claimRecBusinessGuid = voidClick.dataset.bizguid;
		var claimRecServiceLocationGuid = voidClick.dataset.locguid;
		var claimRecProviderGuid = voidClick.dataset.provguid;
		var claimRecMemberFirst = voidClick.dataset.memFirstName;
		var claimRecMemberLast = voidClick.dataset.memLastName;
		$A.createComponent(
			'c:prov_comp_VoidClaim_Modal',
			{
				"claimNumber" : claimRecClaimNumber,
				"business" :claimRecBusiness,
				"serviceOffice" : claimRecOffice,
				"provider" : claimRecProvider,
				"businessGuid" :claimRecBusinessGuid,
				"serviceOfficeGuid" : claimRecServiceLocationGuid,
				"providerGuid" :claimRecProviderGuid,
				"memFirstName" : claimRecMemberFirst,
				"memLastName" : claimRecMemberLast
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

	appealClaim :function (component,event,helper) {
		//console.log('appeal Claim...');
		var appealClick = event.currentTarget;
		var claimRecClaimNumber = appealClick.dataset.claimnumber;
		var claimRecClaimType = appealClick.dataset.claimtype;
		var claimRecBusiness = appealClick.dataset.business;
		var claimRecOffice = appealClick.dataset.office;
		var claimRecProvider = appealClick.dataset.dentist;
		var claimRecMemberName = appealClick.dataset.membername;
		var claimRecMemberDOB = appealClick.dataset.memberdob;
		var claimRecMemberNumber = appealClick.dataset.membernumber;
		var claimRecMemberFirst = appealClick.dataset.memFirstName;
		var claimRecMemberLast = appealClick.dataset.memLastName;

		var claimRecBusinessGuid = appealClick.dataset.bizguid;
		var claimRecServiceLocationGuid = appealClick.dataset.locguid;
		var claimRecProviderGuid = appealClick.dataset.provguid;
		//console.log('claim dob' + claimRecMemberDOB);
		$A.createComponent(
			'c:prov_comp_AppealClaim_Modal',
			{
				"claimNumber" : claimRecClaimNumber,
				"business" :claimRecBusiness,
				"serviceOffice" : claimRecOffice,
				"provider" : claimRecProvider,
				"businessGuid" :claimRecBusinessGuid,
				"serviceOfficeGuid" : claimRecServiceLocationGuid,
				"providerGuid" :claimRecProviderGuid,
				"memberName" : claimRecMemberName,
				"memberBirth" : claimRecMemberDOB,
				"memberNumber" :claimRecMemberNumber,
				"claimType" : claimRecClaimType,
				"memFirstName" : claimRecMemberFirst,
				"memLastName" : claimRecMemberLast
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

	handleModalSuccess :function(component,event,helper){

		//check values passed in by component event to check if the parameters should reflect a void or appeal response
		var successValue = event.getParam("isSuccess");
		var successMsg = event.getParam("successMsg");
		var type = event.getParam("eventType");
		if(type == 'void'){
			component.set("v.isVoidSuccess", successValue);
			component.set("v.voidSuccessMsg", successMsg);
		}

		if(type == 'appeal'){
			component.set("v.isAppealSuccess", successValue);
			component.set("v.appealSuccessMsg", successMsg);
		}

		
	},

	handleDownloadAttach : function(component,event,helper){
        var tar = event.currentTarget;
        var attachmentLink = tar.dataset.value;
        var name = tar.dataset.name;
        var filetype = tar.dataset.filetype;
		//var attachURL = component.get('v.attachmentUrl');
        
        var fileLink = attachmentLink;//attachURL+'?Id='+attachmentId + '&filename=' + name;
        helper.fetchDocument(component, helper, fileLink, name, filetype);
				
		
	},

})