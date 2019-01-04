/**********************************************************************************************************************
Name                        : 	prov_util_ClaimCallout
Purpose                     : 	utility methods for claims entry and management
Created on                  : 	March 2018
Developed by				: 	West Monroe Partners
History
Version#    Sprint#     Date            by                   Comments
1			4       March 2018		West Monroe Partners	 	

**********************************prov_util_ClaimCallout************************************************************************************/

public without sharing class prov_util_ClaimCallout {
	//get global variables for REST calls
	static final String calloutUsername = Global_Configuration__c.getInstance('PCDRequestUsername').value__c;
	static final String calloutPassword = Global_Configuration__c.getInstance('PCDRequestPassword').value__c;
	static final String claimHeaderCalloutEndpoint = Global_Configuration__c.getInstance('ClaimHeaderRequestEndpoint').value__c;
	static final String referralHeaderCalloutEndpoint = Global_Configuration__c.getInstance('ReferralHeaderRequestEndpoint').value__c;
	static final String claimDetailCalloutEndpoint = Global_Configuration__c.getInstance('ClaimDetailRequestEndpoint').value__c;
	static final String referralDetailCalloutEndpoint = Global_Configuration__c.getInstance('ReferralDetailRequestEndpoint').value__c;
	static final String claimAttachmentsCalloutEndpoint = Global_Configuration__c.getInstance('claimAttachCalloutEndpoint').value__c;	
	static final String attachmentCalloutEndpoint = Global_Configuration__c.getInstance('AttachmentCalloutEndpoint').value__c;

	static final String authorizationHeader = createHTTPHeader();

	public static HTTPRequest requestClaimHeadersRemote(prov_wrap_Claim.ClaimHeaderRequestWrapper incomingClaimHeaderWrapper) {

		// set addtional fields on claimHeaderRequest
		prov_wrap_Claim.ClaimHeaderRequestWrapper claimHeaderRequest = incomingClaimHeaderWrapper;

		// variables hard coded for dev sandbox testing purposes
		//claimHeaderRequest.BusinessGuid = '083149db-9c70-4d09-b21e-87150336cd65';

		system.debug('prov_util_ClaimCallout.requestClaimHeaders: '+claimHeaderRequest);
		system.debug('prov_util_ClaimCallout.requestClaimHeaders json: '+JSON.serialize(claimHeaderRequest));

		HttpRequest request = new HttpRequest();

        request.setEndpoint(claimHeaderCalloutEndpoint);
        //request.setEndpoint('https://connectsso3-test.dentaquest.com/api/testapi/restapi/ClaimSearch');
        request.setMethod('POST');
        request.setTimeout(20000);
        request.setCompressed(false);
	    request.setBody(JSON.serialize(claimHeaderRequest));
	    //request.setBody('{"TreatingDentistGuids":null,"StatusCategory":"All","ServiceOfficeGuids":null,"ReceivedDateStart":null,"ReceivedDateEnd":null,"OrderDirection":null,"OrderBy":null,"MemBirthDate":null,"MemberProfileGuid":null,"MemberLastName":null,"MemberId":null,"MemberFirstName":null,"DateOfServiceStart":null,"DateOfServiceEnd":null,"ClaimType":"CLAIM","ClaimNumber":null,"BusinessGuid":"2771dc80-7615-46bb-a140-c59b4fe8956c"}');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);

		return request;
	}

	public static HTTPRequest requestReferralHeadersRemote(prov_wrap_Claim.ReferralHeaderRequestWrapper incomingReferralHeaderWrapper) {
		// return list of response wrappers
		List<prov_wrap_Claim.ReferralHeaderResponseWrapper> returnedReferrals = new List<prov_wrap_Claim.ReferralHeaderResponseWrapper>();

		// set addtional fields on claimHeaderRequest
		prov_wrap_Claim.ReferralHeaderRequestWrapper referralHeaderRequest = incomingReferralHeaderWrapper;

		// variables hard coded for dev sandbox testing purposes
		//referralHeaderRequest.BusinessGuid = '90729872-D291-4514-81B4-2DD64C43F000';

		system.debug('prov_util_ClaimCallout.requestReferralHeaders: '+referralHeaderRequest);
		system.debug('prov_util_ClaimCallout.requestReferralHeaders json: '+JSON.serialize(referralHeaderRequest));
		HttpRequest request = new HttpRequest();

        request.setEndpoint(referralHeaderCalloutEndpoint);
        request.setMethod('POST');
        request.setTimeout(20000);
        request.setCompressed(false);
	    request.setBody(JSON.serialize(referralHeaderRequest));
	    //request.setBody('{"TreatingDentistGuids":null,"StatusCategory":"All","ServiceOfficeGuids":null,"ReceivedDateStart":null,"ReceivedDateEnd":null,"OrderDirection":null,"OrderBy":null,"MemBirthDate":null,"MemberProfileGuid":null,"MemberLastName":null,"MemberId":null,"MemberFirstName":null,"DateOfServiceStart":null,"DateOfServiceEnd":null,"ClaimType":"CLAIM","ClaimNumber":null,"BusinessGuid":"2771dc80-7615-46bb-a140-c59b4fe8956c"}');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);

		return request;
	}
		@AuraEnabled
        public static List<prov_wrap_Claim.ClaimHeaderResponseWrapper> requestClaimHeaders(prov_wrap_Claim.ClaimHeaderRequestWrapper incomingClaimHeaderWrapper) {
            // return list of response wrappers
            List<prov_wrap_Claim.ClaimHeaderResponseWrapper> returnedClaims = new List<prov_wrap_Claim.ClaimHeaderResponseWrapper>();

            // set addtional fields on claimHeaderRequest
            prov_wrap_Claim.ClaimHeaderRequestWrapper claimHeaderRequest = incomingClaimHeaderWrapper;

            // variables hard coded for dev sandbox testing purposes
            //claimHeaderRequest.BusinessGuid = '083149db-9c70-4d09-b21e-87150336cd65';

            system.debug('prov_util_ClaimCallout.requestClaimHeaders: '+claimHeaderRequest);
            system.debug('prov_util_ClaimCallout.requestClaimHeaders json: '+JSON.serialize(claimHeaderRequest));

            try {
                // call rest service method to perform callout
                HttpResponse claimHeaderHTTPResp = wmp_RestService.callRestService(
                                claimHeaderCalloutEndpoint, authorizationHeader, null, JSON.serialize(claimHeaderRequest), 'POST', 'application/json', 20000);
                                system.debug('claimHeaderHTTPResp: '+claimHeaderHTTPResp);
                // check that the response is good. otherwise, create a fake wrapper record and display that to the user
                if(claimHeaderHTTPResp != null && claimHeaderHTTPResp.getStatusCode() == 200){
                                // Helpful debug messages
                                System.debug(claimHeaderHTTPResp.toString());
                                System.debug('STATUS:'+claimHeaderHTTPResp.getStatus());
                                System.debug('STATUS_CODE:'+claimHeaderHTTPResp.getStatusCode());
                                System.debug('detail body: ' + claimHeaderHTTPResp.getBody());
                                System.debug('Claim header request successful');
                                System.debug('claim header response: '+claimHeaderHTTPResp.getBody());
                                // turn result into overall result wrapper
                                prov_wrap_Claim.ClaimHeaderResultWrapper resultWrapper = (prov_wrap_Claim.ClaimHeaderResultWrapper) System.JSON.deserialize(claimHeaderHTTPResp.getBody(), prov_wrap_Claim.ClaimHeaderResultWrapper.class);
                                system.debug('result wrapper: '+resultWrapper);
                                // extract list of individual results from overall wrapper
                                returnedClaims = (List<prov_wrap_Claim.ClaimHeaderResponseWrapper>) resultWrapper.SearchResult;
                } else {
                                return null;
                }
                return returnedClaims; 
            } catch(System.CalloutException e) {
                            system.debug('Exception while parsing'+e);
                            return null;
            }
        }


	

	private static String createHTTPHeader() {
		Blob headerValue = Blob.valueOf(calloutUsername +':' +calloutPassword);
		String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

		return authHeader;
	}
}