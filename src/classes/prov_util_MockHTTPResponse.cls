/**********************************************************************************************************************
Name                        : prov_util_mockHTTPResponse
Purpose                     : Returns a Mock call out response for several prov_util__callout classes
Created on                  : June 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                            By                      Comments
1.0             9          June 2017               	    West Monroe Partners    See header - purpose
 
**********************************************************************************************************************/
@isTest
public class prov_util_MockHTTPResponse implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    // pass in the values you want to be set in the response from the calling test class (see prov_util_EOBCallout_Test for example)
    public prov_util_MockHTTPResponse(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

}