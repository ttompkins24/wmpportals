/**********************************************************************************************************************
Purpose						: The controller for displaying the EOB for a certain member
Created on					: 9th Oct 2017
Developed by				: Todd Tompkins
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th Oct 2017					Todd Tompkins					See header - purpose
  

**********************************************************************************************************************/
public without sharing class wmp_ctrl_Document {
    
    /***********************************************************************
	Method name: 	getCurrentMember
	Return type:	mock_Member__c from cache class
	***********************************************************************/
	@AuraEnabled
	public static mock_Member__c fetchCurrentMember(){ 
		System.debug('Current member: ' +  wmp_util_cache.getCurrentMember());
		return wmp_util_cache.getCurrentMember();
	} 

	@AuraEnabled
	public static mock_MemberCoverage__c fetchCurrentMemberPlan(){
		return 	wmp_util_cache.getCurrentMemberPlan();
	}
	
	/***********************************************************************
	Method name: 	getCurrentMemberPlans
	Return type:	mock_Member__c from cache class
	***********************************************************************/
	@AuraEnabled 
	public static list<mock_MemberCoverage__c> fetchCurrentMemberPlans(){ 
		//iterate and push the in-context first
		list<mock_MemberCoverage__c> listOfMemberPlans = new list<mock_MemberCoverage__c>();
		for(mock_MemberCoverage__c iterating_coverage : wmp_util_cache.getCurrentMemberPlans()){
			//check if the plan in context
			if(wmp_util_cache.getPlanGUID() == iterating_coverage.PlanGUID__c && !listOfMemberPlans.isEmpty())
				listOfMemberPlans.add(0,iterating_coverage);
			else
				listOfMemberPlans.add(iterating_coverage);
		}
		return listOfMemberPlans; 
	}

    /***********************************************************************
	Method name: 	retrieveMemberPlans
	Return type:	list of accounts
					There are 2 steps:
					# 1 fetch all the related member plan GUIDs from the cache class
					# 2 fetch the related account Id via a query and display as dropdown
	***********************************************************************/
    @AuraEnabled
	public static List<Map<String,String>> retrieveMemberPlans(){
		System.debug('starting retrieveMemberPlans...');
		//initialize variables
		List<Map<String,String>> resultList = new List<Map<String,String>>();
		Map<String, String> memCovMap = new Map<String, String>();
		//Map<String, String> memberGuidToMemberAndPlan = wmp_util_Cache.MemberGuidToMemberAndPlan;
		Map<String, String> planGuid2PlanNameMap = new Map<String, String>();
		
		for(mock_MemberCoverage__c mc : wmp_util_Cache.getCurrentMemberPlans()){
			planGuid2PlanNameMap.put(mc.PlanGuid__c, null);
		}
		System.debug('planGuid2PlanNameMap::'+planGuid2PlanNameMap.keyset());
		
		//query for the plan names
		for(Account acc : [SELECT id, Name, guid__c FROM Account WHERE guid__c IN:planGuid2PlanNameMap.keyset()]){
			planGuid2PlanNameMap.put(acc.guid__c, acc.Name);
		}
		System.debug('planGuid2PlanNameMap::'+planGuid2PlanNameMap);
		
		Date todaysDate = Date.today();
		//loop through the member coverage and map the mem coverage guid to the member name and plan name
		for(mock_MemberCoverage__c mc : wmp_util_Cache.getCurrentMemberPlans()){
			//initialize the fields
			String labelName = '';//label for the picklist
			memCovMap = new Map<String, String>();
			String effDate = mc.EffectiveDate__c.format();
			//get the member
			mock_Member__c member = wmp_util_Cache.getMember(mc.SubscriberId__c.toLowerCase(), mc.PlanGuid__c.toLowerCase());
			System.debug('member::'+member);
			//construct the label
			labelName =  planGuid2PlanNameMap.get(mc.PlanGuid__c) + ' - ' + effDate;
			memCovMap.put('Label', labelName);
			memCovMap.put('plan', planGuid2PlanNameMap.get(mc.PlanGuid__c));
			memCovMap.put('effDate', effDate);
			memCovMap.put('Value', mc.MemberCoverageGuid__c);
			
			if(todaysDate <= mc.EffectiveDate__c){
				memCovMap.put('isactive', 'false');
			} else {
				memCovMap.put('isactive', 'true');
				
			}
			System.debug('memCovMap::'+memCovMap);
			//map the mem coverage guid to the generated label
			resultList.add(memCovMap);
		}
		System.debug('resultList::'+resultList);
		return resultList;
	}

	//this method gets the memberprofileGUID and Subscriber ID ready to call for the EOBs.  When a plan is overriden, two calls are made
	@AuraEnabled
	public static List<wmp_EOBRequestDetail> retrieveEOBs(){

		List<wmp_EOBRequestDetail> detail = new List<wmp_EOBRequestDetail>();


		//if current active plan is an override plan, get overriden plan and pass MemberProfileGUID of that one to get the EOBs
		System.debug('member coverages ' + wmp_util_Cache.cobj.MemberPlans);
		System.debug('profile guids ' + wmp_util_Cache.cobj.MemberAndPlanToProfileGuid);
		System.debug('plan overide ids ' + wmp_util_Cache.cobj.planOverridesIds);
		System.debug('plan guids ' + wmp_util_Cache.cobj.PlanGUID);
		System.debug('plans ' + wmp_util_Cache.cobj.Plans);

		//get current plan details
		mock_MemberCoverage__c memCov = wmp_util_cache.getCurrentMemberPlan();
		String subscriberId = memCov.SubscriberID__c;
		String memberProfile = memCov.MemberProfileGUID__c;
		String route = memCov.RouteID__c;
		System.debug('subID: ' + subscriberId + ' memberProfile: ' + memberProfile + ' route: ' + route);


		System.debug('first EOB call');
		List<wmp_EOBRequestDetail> firstCallEOBs = retrieveEOBList(subscriberId, memberProfile, route);
			
		if(firstCallEOBs != null){
			detail.addAll(firstCallEOBs);
		}
		System.debug('end first EOB call');

		//check to see if plan is overridden, if so, get details for overridden plan
    	Set<string> planIds = new Set<String>();
    	Map<String,Set<String>> overriddenPlansMap = wmp_util_Cache.getPlanOverrides();
		//if true, it is an overriding plan
		if(overriddenPlansMap.containsKey(wmp_util_Cache.getPlanGUID())){
			planIds = overriddenPlansMap.get(wmp_util_Cache.getPlanGUID());
		}
    	System.debug('planIds ' + planIds);

    	//make map of plan id to plan guid from accounts
		Map<String, String> planIdToGuidMap = new Map<String, String>();
		for(Account plan: wmp_util_Cache.getPlans().values()){
			planIdToGuidMap.put(String.valueOf(plan.id).left(15),plan.guid__c.toLowercase());
		}
    	System.debug('planIdToGuidMap ' + planIdToGuidMap);
    	
    	//loop through plans and get the plan guid that matches the planId
    	Set<String> planGuidSet = new Set<String>();
    	for(String s : planIds){
			planGuidSet.add(planIdToGuidMap.get(s));	    		
    	}
    	System.debug('planGuidSet ' + planGuidSet);
    	//get memberprofileguids for each plan
    	for(String s : planGuidSet){
    		System.debug('s1 ' + wmp_util_Cache.getSubscriberId()+s);
    		System.debug('s2 ' + wmp_util_Cache.cobj.MemberAndPlanToProfileGuid.get(wmp_util_Cache.getSubscriberId()+s));
    		String memberProfileGUID = wmp_util_Cache.cobj.MemberAndPlanToProfileGuid.get(wmp_util_Cache.getSubscriberId()+s);

    		//call out for EOBs
			System.debug('next EOB call');
			List<wmp_EOBRequestDetail> eobCall = retrieveEOBList(subscriberId, memberProfileGUID, route);
			if(eobCall != null){
				//add eob to complete list
				detail.addAll(eobCall);
			}
			System.debug('next first EOB call');
    	}
    	System.debug('All EOBs ' + detail.size() + ' ' + detail);
		return detail;
	}

   
   	//updated 12/13/2017 to pass Member Profile GUID instead of Member Plan GUID
   	//updated 3/6/2018 to be able to call more than once when a member has two active plans
	@AuraEnabled
	public static List<wmp_EOBRequestDetail> retrieveEOBList(String subscriberId, String memberProfile, String route){
		HttpResponse httpResp;
		List<wmp_EOBRequestDetail> detail = new List<wmp_EOBRequestDetail>();

		//only for dev4 testing
		if(subscriberId == 'SUB 16' && memberProfile == 'Profile 8'){
			subscriberId = '522978997';
			memberProfile = '1ad5eff1-1c14-475a-98df-82aa8bc08a63';
		} else if(subscriberId == 'SUB 16' && memberProfile == 'Profile 10'){
			subscriberId = 'U664107';
			memberProfile = '7A2DC9F9-83CD-4EE5-AB90-1A1763068C8E';
		}

		System.debug('subId ' + subscriberId);
		System.debug('memProfileGUID ' + memberProfile);

	    try {

	    	Global_Configuration__c pcdUsername = Global_Configuration__c.getInstance('PCDRequestUsername');
			Global_Configuration__c pcdPassword = Global_Configuration__c.getInstance('PCDRequestPassword');

			Blob headerValue = Blob.valueOf(pcdUsername.value__c +':' +pcdPassword.value__c);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

	        httpResp = wmp_RestService.callRestService(System.Label.EOB_Call_URL+''+subscriberId + '/'+memberProfile + '/'+route, authorizationHeader, null, null, 'GET', 'application/json', 20000);
	        
	        //Helpful debug messages
	        System.debug(httpResp.toString());
	        System.debug('STATUS:'+httpResp.getStatus());
	        System.debug('STATUS_CODE:'+httpResp.getStatusCode());
			System.debug('detail body: ' + httpResp.getBody());
			if(httpResp.getBody() != ''){
				System.debug('detail body not empty');
		        detail = wmp_EOBRequestDetail.parse(httpResp.getBody());
			}
	        System.debug('detail list: ' + detail);
	        return detail;

	     } catch(System.CalloutException e) {
	        System.debug('Exception while parsing'+e);
	        throw new ConnectwareException('The transaction timed out. ' + e);
	        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The transaction timed out.'));
	        return null;
	     }       
	}

	//retrieves the document from Doc Direct
	@AuraEnabled
	public static String retrieveEOB(String eobLinkStr){
		HttpResponse httpResp;

	    try {

	    	Global_Configuration__c pcdUsername = Global_Configuration__c.getInstance('PCDRequestUsername');
			Global_Configuration__c pcdPassword = Global_Configuration__c.getInstance('PCDRequestPassword');

			Blob headerValue = Blob.valueOf(pcdUsername.value__c +':' +pcdPassword.value__c);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

	        httpResp = wmp_RestService.callRestService(eobLinkStr, authorizationHeader, null, null, 'GET', 'application/pdf', 20000);
	        
	        //Helpful debug messages
	        System.debug(httpResp.toString());
	        System.debug('STATUS:'+httpResp.getStatus());
	        System.debug('STATUS_CODE:'+httpResp.getStatusCode());
			System.debug('detail body: ' + httpResp.getBody());
			if(httpResp.getBody() != ''){
				System.debug('detail body not empty');
		        //detail = wmp_EOBRequestDetail.parse(httpResp.getBody());
			}
	        //System.debug('detail: ' + detail);
	        //return detail;
	        return httpResp.getBody();
	     } catch(System.CalloutException e) {
	        System.debug('Exception while parsing'+e);
	        throw new ConnectwareException('The transaction timed out. ' + e);
	        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The transaction timed out.'));
	        return null;
	     }       
	}

	/**************************************************************
	Method Name : loadConfiguration
	Return type : portal config metadata type
	&**********************************************************************/
	@AuraEnabled
	public static Portal_Configuration__mdt loadConfiguration(){
    	//return the portal configuration
    	return wmp_util_Cache.PortalConfiguration;
    }

    public class ConnectwareException extends exception{}

}