public class wmp_RestService {
    public static HttpResponse callRestService(String serviceEndPoint, 
                                        String header,
                                        String certificateName,
                                        String inputJson, 
                                        String httpMethod, 
                                        String contentType, 
                                        Integer timeout){
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        System.debug('ServiceEndPoint: ' + serviceEndPoint);
        Http http = new Http();
        request.setEndpoint(serviceEndPoint);
        request.setMethod(httpMethod);
        request.setTimeout(timeout);
        request.setCompressed(false);
        request.setHeader('Content-Type', contentType);
        request.setHeader('Authorization', header);

        if(httpMethod != 'GET' && inputJson != null){
            request.setBody(inputJson);
            system.debug('addedBody');
        }

        try{ 
            system.debug('request: '+request);
            response = http.send(request);
            System.debug('response: ' + response);
        } catch(System.CalloutException cex) { 
            System.debug('Http Callout error: '+ cex);
            return null;
        } catch(Exception ex) { 
            System.debug('Generic exception'+ ex);
            return null;
        }
        //if(response.getStatusCode() == '404'){
        //    throw new 
        //}
        return response;
    }
}