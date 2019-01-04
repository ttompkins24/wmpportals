/**********************************************************************************************************************
Name                        : 	prov_util_EOBCallout
Purpose                     : 	utility methods for eob search
Created on                  : 	May 2018
Developed by				: 	West Monroe Partners
History
Version#    Sprint#     Date            by                   Comments
1			8       May 2018		West Monroe Partners	 	

**********************************prov_util_EOBCallout************************************************************************************/
public without sharing class prov_util_EOBCallout {
	//get global variables for REST calls
	static final String calloutUsername = Global_Configuration__c.getInstance('PCDRequestUsername').value__c;
	static final String calloutPassword = Global_Configuration__c.getInstance('PCDRequestPassword').value__c;
	static final String eobHeaderCalloutEndpoint = Global_Configuration__c.getInstance('EOBHeaderRequestEndpoint').value__c;

	static final String authorizationHeader = createHTTPHeader();

	public static HttpRequest requestEOBHeadersRemote(Map<String, Object> paramMap) {

		String endpoint = generateEOBEndpoint(paramMap);
		system.debug('prov_util_EOBCallout.endpoint: '+endpoint);

        HttpRequest request = new HttpRequest();

        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(20000);
        request.setCompressed(false);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);

		return request;
	}

	public static HttpRequest requestEOBRemote(String eobLink) {
        HttpRequest request = new HttpRequest();

        request.setEndpoint(eobLink);
        request.setMethod('GET');
        request.setTimeout(20000);
        request.setCompressed(false);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);

		return request;
	}


	private static String generateEOBEndpoint(Map<String, Object> paramMap) {
		String endpoint = eobHeaderCalloutEndpoint;
		for(String paramKey : paramMap.keySet()) {
			//endpoint can't handle null in any of the attributes
			if(paramMap.get(paramKey) != null) {
				//endpoint can't handle All in PaymentType
				if(paramKey == 'PaymentType' && paramMap.get(paramKey) == 'All') {
					continue;
				}
				endpoint += paramKey + '=' + EncodingUtil.urlEncode((String)paramMap.get(paramKey),'UTF-8') + '&';
			}
		}
		endpoint = endpoint + 'PageSize=10';
		return endpoint;
	}

	private static String createHTTPHeader() {
		Blob headerValue = Blob.valueOf(calloutUsername +':' +calloutPassword);
		String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

		return authHeader;
	}

}