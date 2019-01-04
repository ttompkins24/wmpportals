/**********************************************************************************************************************
Purpose						: The controller for the history page which shows the member plan service history for a particular member
Created on					: 9th Oct 2017
Developed by				: Todd Tompkins
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th Oct 2017					Todd Tompkins					See header - purpose
1.1				ME  		22 Feb 2018						WMP 					Updated retrieve history to check to see if there is a plan override.  if true, get history for override plan and overridden plan

**********************************************************************************************************************/
public without sharing class wmp_ctrl_History {
   
   	public static final Integer RESULTS_PER_PAGE = 5;
	
    @AuraEnabled
    //return the pagination variables for the service history
    public static List<Integer> paginationVariables(){
    	//intitalize variables
    	List<Integer> paginationVars = new List<Integer>();
    	
    	//add the results to the list to return
    	paginationVars.add(RESULTS_PER_PAGE);
    	
    	//return the list
    	return paginationVars;
    }
    
    @AuraEnabled
    //retrieve the service history for the current member in focus
    public static Map<Date, List<wmp_wrap_History>> retrieveHistory(){
    	System.debug('START retrieveHistory...................');
		//initialize the variables
    	Map<String, Account> planGuid2PlanMap = new Map<String, Account>();
    	wmp_wrap_History wrapper;
    	Map<Date, List<wmp_wrap_History>> returnMap = new Map<Date, List<wmp_wrap_History>>();

    	try{
	    	//get the current member
	    	mock_Member__c member = wmp_util_Cache.CurrentMember;
	    	
	    	Set<String> planGuids = new Set<String>();
	    	Set<String> memProfileGuids = new Set<String>();
	    	
	    	System.debug('member plans ' + wmp_util_Cache.getCurrentMemberPlans());
	    	System.debug('plan overrides ' + wmp_util_Cache.getPlanOverrides());
	    	System.debug('PlanConfigurations ' + wmp_util_Cache.getPlanConfigurations());
	    	System.debug('memCov ' + wmp_util_Cache.getCurrentMemberPlans().size() + ' ' + wmp_util_Cache.getCurrentMemberPlans());
	    	System.debug('subscriber ID ' + wmp_util_Cache.getSubscriberId());
	    	System.debug('Plans ' + wmp_util_Cache.getPlans());

	    	//get all the current member plans relevant info in order to retrieve the member service history
	    	for(mock_MemberCoverage__c memCov : wmp_util_Cache.getCurrentMemberPlans()){
	    		planGuids.add(memCov.PLanGuid__c);
	    		memProfileGuids.add(memCov.MemberProfileGuid__c);
	    	}
			System.debug('wmp_util_Cache.cobj.MemberAndPlanToProfileGuid:: ' + wmp_util_Cache.cobj.MemberAndPlanToProfileGuid);
			
	    	//check to see if plan is overriding plan, if so, get the overridden plan id
	    	Set<string> planIds = new Set<String>();
	    	Map<String,Set<String>> overriddenPlansMap = wmp_util_Cache.getPlanOverrides();
	    	for(String s : planGuids){
	    		//if true, it is an overriding plan
	    		if(overriddenPlansMap.containsKey(s.toLowerCase())){

	    			List<String> overriddenPlanList = New List<String>(overriddenPlansMap.get(s.toLowerCase()));
	    			System.debug('overriddenPlanList:: ' + overriddenPlanList);
	    			planIds.addAll(overriddenPlanList);
	    		}
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
	    		memProfileGuids.add(wmp_util_Cache.cobj.MemberAndPlanToProfileGuid.get(wmp_util_Cache.getSubscriberId()+s));
	    		planGuids.add(s);
	    	}

	    	system.debug('planGuids::'+planGuids);
	    	system.debug('memProfileGuids::'+memProfileGuids);
	    	
	    	//retrieve the member profile guid
	    	for(mock_MembersServiceHistory__c history : wmp_util_DAL.getMemberServiceHistory( new List<String>(memProfileGuids), //send all member profile guids for that member
	    																				 new List<String>(planGuids)//send all the plan guids that the user has verified for that member 
	    																				 ) ){
	    		System.debug('history::'+history);
	    		
	    		//set the attributes for the wrapper class
	    		wrapper = new wmp_wrap_History(history);
	    		System.debug('wrapper::'+wrapper);
	    		
	    		//map the plan guid to get the plan name
	    		planGuid2PlanMap.put(history.PlanGuid__c, null);
	    		
	    		//add the wrapper to the map
	    		if(returnMap.containsKey(history.ProcedureDate__c)){
	    			returnMap.get(history.ProcedureDate__c).add(wrapper);
	    		} else {
	    			returnMap.put(history.ProcedureDate__c, new List<wmp_wrap_History>{wrapper});
	    		}
	    	}
	    	System.debug('returnMap.keyset::'+returnMap.keyset());
	    	
	    	//get all plans
	    	for(Account plan : [SELECT id, guid__c, name FROM Account WHERE guid__c IN:planGuid2PlanMap.keyset()]){
	    		planGuid2PlanMap.put(plan.guid__c.toLowerCase(), plan);
	    	}
	    	
	    	//loop through the results and set the additional fields
	    	for(Date newDate : returnMap.keyset()){
	    		for(wmp_wrap_History history : returnMap.get(newDate)){
	    			if(planGuid2PlanMap.containsKey(history.planGuid.toLowercase() ) ){
	    				history.planName = planGuid2PlanMap.get(history.planGuid.toLowerCase() ).Name;
	    			}
	    		}
	    	}
    	}catch(Exception ex){
    		System.debug('*****************ERROR');
    		System.debug('*****************');
    		System.debug('message::'+ex.getMessage());
    		System.debug('ln::'+ex.getLineNumber());
    		System.debug('stackTrace::'+ex.getStackTraceString());
    		System.debug('*****************');
    		System.debug('ERROR*****************');
    	}
    	System.debug('returnMap::'+returnMap);
    	return returnMap;
    }
    
    @AuraEnabled
    public static mock_Member__c getCurrentMember(){
    	System.debug('current member ' + wmp_util_Cache.CurrentMember);
    	return wmp_util_Cache.CurrentMember;
    }
}