global without sharing class prov_ctrl_FeeSchedule {
	public String portalURL {get;set;}
	public Boolean useMockData {get;set;}

	public prov_ctrl_FeeSchedule() {
		portalURL = System.Label.Member_Eligibility_VF_URL;
		useMockData = prov_util_MockData.useMockData;
	}
    @AuraEnabled
    public static List<Networks__c> getAllNetworksFeeSchedule(String businessId) {
        Id bizId = Id.valueOf(businessId);
        List<Networks__c> networkList = prov_util_Cache.retrieveNetworks(bizId);
        networkList.sort();
        return networkList;
    }
    
    @RemoteAction
	global static List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper> afterResponseLogic(String str){
		List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper> returnedSchedules = new List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>();
                        
        // turn result into response wrapper
		returnedSchedules = (List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>) System.JSON.deserialize(str, List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>.class);
		system.debug('returnedSchedules: '+returnedSchedules);  
		 
        return returnedSchedules; 
	} 
    @RemoteAction
	global static object getFeeScheduleResults(String str){
		System.debug('Passed in String: ' + str);

		system.debug('getFeeSchedules');
        prov_wrap_FeeSchedule.FeeScheduleRequestWrapper feeScheduleHeader = (prov_wrap_FeeSchedule.FeeScheduleRequestWrapper) System.JSON.deserialize(str,prov_wrap_FeeSchedule.FeeScheduleRequestWrapper.class);
        
        List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper> feeScheduleResponseWrappers = new List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>();

        Map<String,List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>> feeScheduleResponseWrappersMap = new Map<String,List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>>();

        if(prov_util_MockData.useMockData) { 
            feeScheduleResponseWrappers = prov_util_Search_Tests.util_generateFeeScheduleResponses();
	       return feeScheduleResponseWrappers; 
        } else {
            HTTPRequest request = prov_util_FeeSchedule_Callout.requestFeeSchedules_continuation(feeScheduleHeader);
            
			//Create a continuation for HTTPRequest
	        Continuation con = new Continuation(60);
	        con.state = con.addHttpRequest(request);
	        con.continuationMethod = 'callback';
	        return con;
       }
	}
	
	global static object callback(Object state){
        System.debug('in callback');

        HttpResponse res = Continuation.getResponse((String) state);
        System.debug('response ' + res);
        System.debug('response ' + res.getBody());

        if(res.getStatusCode()!=200){
            system.debug('--Fee Schedule  Search Request-------------------------------------------------------------------------');
            system.debug('Response failed.');
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
            system.debug('--Panel Roster Search Request-------------------------------------------------------------------------');
              
            return (Object) '[{"FirstName":"Error","LastName":"timeout"}]';
        } else {
            system.debug('Fee Schedule Body success ');
            return res.getBody();
        }
    }

    @AuraEnabled
    public static Map<String,List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>> getFeeSchedulesApex(String json, String businessId) {
        system.debug(json);
		system.debug('getFeeSchedules');
        prov_wrap_FeeSchedule.FeeScheduleRequestWrapper feeScheduleHeader = (prov_wrap_FeeSchedule.FeeScheduleRequestWrapper) System.JSON.deserialize(json,prov_wrap_FeeSchedule.FeeScheduleRequestWrapper.class);
        
        List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper> feeScheduleResponseWrappers = new List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>();

        Map<String,List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>> feeScheduleResponseWrappersMap = new Map<String,List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>>();

        if(prov_util_MockData.useMockData) { 
            feeScheduleResponseWrappers = prov_util_Search_Tests.util_generateFeeScheduleResponses();
        } else {
            feeScheduleResponseWrappers = prov_util_FeeSchedule_Callout.requestFeeSchedules(feeScheduleHeader);
        }
        System.debug('feeScheduleResponseWrappers: '+ feeScheduleResponseWrappers);

        //create a map so we can tell if the callout failed or just if no results were returned
        if(feeScheduleResponseWrappers != null) {
            feeScheduleResponseWrappersMap.put('calloutSuccess',feeScheduleResponseWrappers);
        } else {
            feeScheduleResponseWrappersMap.put('calloutError', null);
        }

        System.debug('feeScheduleResponseWrappersMap: '+ feeScheduleResponseWrappersMap);
        return feeScheduleResponseWrappersMap;
    }
    
    
}