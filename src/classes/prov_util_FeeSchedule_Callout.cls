/**********************************************************************************************************************
Name                        : 	prov_util_FeeSchedule_Callout
Purpose                     : 	utility methods for feeschedule callout
Created on                  : 	April 2018
Developed by				: 	West Monroe Partners
History
Version#    Sprint#     Date            by                   Comments
1			6       April 2018		West Monroe Partners	 	

**********************************prov_util_FeeSchedule_Callout************************************************************************************/

public without sharing class prov_util_FeeSchedule_Callout {
	//get global variables for REST calls
	static final String calloutUsername = Global_Configuration__c.getInstance('PCDRequestUsername').value__c;
	static final String calloutPassword = Global_Configuration__c.getInstance('PCDRequestPassword').value__c;
	static final String feeScheduleRequestEndpoint = Global_Configuration__c.getInstance('FeeScheduleRequestEndpoint').value__c;
	static final String feeScheduleSpecialRequestEndpoint = Global_Configuration__c.getInstance('FeeScheduleSpecialRequestEndpoint').value__c;

	static final String authorizationHeader = createHTTPHeader();

	@AuraEnabled
	public static List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper> requestFeeSchedules(prov_wrap_FeeSchedule.FeeScheduleRequestWrapper incomingFeeScheduleWrapper) {
		// return list of response wrappers 
		List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper> returnedSchedules = new List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>();

		// set addtional fields on feeScheduleRequest
		prov_wrap_FeeSchedule.FeeScheduleRequestWrapper feeScheduleRequest = incomingFeeScheduleWrapper;

		system.debug('prov_util_FeeSchedule_Callout.feeScheduleRequest: '+feeScheduleRequest);
		system.debug('prov_util_FeeSchedule_Callout.feeScheduleRequest json: '+JSON.serialize(feeScheduleRequest));

		try {
			// call rest service method to perform callout
			String endpoint = feeScheduleRequestEndpoint;
			/*if(feeScheduleRequest.IsSpecialDeal) {
				endpoint = feeScheduleSpecialRequestEndpoint;
				// variables hard coded for dev sandbox testing purposes
				feeScheduleRequest.BusinessGuid = 'B6315CE0-84A8-4D6C-A15A-EC35C038A8BC';
				feeScheduleRequest.ProviderGuid = '7C38294B-95D1-4AED-A03B-FB7CDDB23F3B';
				feeScheduleRequest.ServiceOfficeGuid = '8F4C81DC-3BF5-4366-8663-9BC8BBF762A0';
				feeScheduleRequest.NetworkGuid = 'FB334554-6E80-48DD-ACED-7EDBCCC491EE';
				feeScheduleRequest.RouteId = 'GOV';
			} else {
				// variables hard coded for dev sandbox testing purposes
				feeScheduleRequest.BusinessGuid = null;
				feeScheduleRequest.ProviderGuid = null;
				feeScheduleRequest.ServiceOfficeGuid = null;
				feeScheduleRequest.NetworkGuid = 'FB7207D1-1416-4561-8ACB-4B8C19A8E728';
				feeScheduleRequest.RouteId = 'GOV';
			}*/
			HttpResponse feeScheduleHTTPResp = wmp_RestService.callRestService(
				endpoint, authorizationHeader, null, JSON.serialize(feeScheduleRequest), 'POST', 'application/json', 20000);
				System.debug('feeScheduleHTTPResp: '+feeScheduleHTTPResp);
			// check that the response is good. otherwise, create a fake wrapper record and display that to the user
			if(feeScheduleHTTPResp != null && feeScheduleHTTPResp.getStatusCode() == 200){
				// Helpful debug messages
				System.debug(feeScheduleHTTPResp.toString());
				System.debug('STATUS:'+feeScheduleHTTPResp.getStatus());
				System.debug('STATUS_CODE:'+feeScheduleHTTPResp.getStatusCode());
				System.debug('fee schedule request successful');
				System.debug('fee schedule response: '+feeScheduleHTTPResp.getBody());
				// turn result into response wrapper
				returnedSchedules = (List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>) System.JSON.deserialize(feeScheduleHTTPResp.getBody(), List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>.class);
				system.debug('returnedSchedules: '+returnedSchedules);
			} else {
				return null;
			}
			return returnedSchedules; 
		} catch(System.CalloutException e) {
			system.debug('Exception while parsing'+e);
			return null;
		}
	}
	
	public static HttpRequest requestFeeSchedules_continuation(prov_wrap_FeeSchedule.FeeScheduleRequestWrapper incomingFeeScheduleWrapper) {
		// return list of response wrappers
		List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper> returnedSchedules = new List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>();

		// set addtional fields on feeScheduleRequest
		prov_wrap_FeeSchedule.FeeScheduleRequestWrapper feeScheduleRequest = incomingFeeScheduleWrapper;

		system.debug('prov_util_FeeSchedule_Callout.feeScheduleRequest: '+feeScheduleRequest);
		system.debug('prov_util_FeeSchedule_Callout.feeScheduleRequest json: '+JSON.serialize(feeScheduleRequest));

		try {
			// call rest service method to perform callout
			String endpoint = feeScheduleRequestEndpoint;
			if(feeScheduleRequest.IsSpecialDeal) {
				endpoint = feeScheduleSpecialRequestEndpoint;
				// variables hard coded for dev sandbox testing purposes
				feeScheduleRequest.BusinessGuid = 'B6315CE0-84A8-4D6C-A15A-EC35C038A8BC';
				feeScheduleRequest.ProviderGuid = '7C38294B-95D1-4AED-A03B-FB7CDDB23F3B';
				feeScheduleRequest.ServiceOfficeGuid = '8F4C81DC-3BF5-4366-8663-9BC8BBF762A0';
				feeScheduleRequest.NetworkGuid = 'FB334554-6E80-48DD-ACED-7EDBCCC491EE';
				feeScheduleRequest.RouteId = 'GOV';
			} else {
				// variables hard coded for dev sandbox testing purposes
				feeScheduleRequest.BusinessGuid = null;
				feeScheduleRequest.ProviderGuid = null;
				feeScheduleRequest.ServiceOfficeGuid = null;
				feeScheduleRequest.NetworkGuid = 'FB7207D1-1416-4561-8ACB-4B8C19A8E728';
				feeScheduleRequest.RouteId = 'GOV';
			}
				
			Blob headerValue = Blob.valueOf(calloutUsername +':' +calloutPassword);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            //make a callout to WW to submit the request
            System.debug('headerValue::'+calloutUsername +':' +calloutPassword);
            System.debug('calloutEndpoint::'+endpoint);
            HTTP h = new HTTP();
            HTTPRequest req = new HTTPRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setTimeout(60000);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', authorizationHeader);
            String payload = JSON.serialize(feeScheduleRequest);
            system.debug('Payload: ');
            system.debug(payload);
            req.setBody(payload);
            return req;
			
			
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