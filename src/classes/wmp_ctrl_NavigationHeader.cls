/**********************************************************************************************************************
Name                        : 	WMP_ctrl_NavigationHeader
Purpose                     : 	Controller for the wmp_comp_NotificationHeader. Contains logic to the members that should be in the navigation
Created on                  : 	08/16/2017
Developed by				: 	Todd Tompkins 
History
Version#    Sprint#     Date            by                   Comments
1.0			1.0      	08/16/2017		Todd Tompkins

**********************************************************************************************************************/
public without sharing class wmp_ctrl_NavigationHeader {

	@AuraEnabled
	public static Map<String,Map<String, String>> retrieveMemberPlans(){
		//initialize variables
		Map<String,Map<String, String>> memGuid2MemInfoMap = new Map<String, Map<String, string>>();
		
		for(mock_MemberCoverage__c mc : wmp_util_Cache.MemberPlans.values()){
			//map the fields
			memGuid2MemInfoMap.put(mc.MemberProfileGUID__c, new Map<String, String>());
			
			//map the fields
			memGuid2MemInfoMap.get(mc.MemberProfileGUID__c).put('PlanGuid__c', mc.PlanGuid__c.toLowerCase());
			memGuid2MemInfoMap.get(mc.MemberProfileGUID__c).put('SubscriberId__c', mc.SubscriberId__c.toLowerCase());
			memGuid2MemInfoMap.get(mc.MemberProfileGUID__c).put('MemberProfileGUID__c', mc.MemberProfileGUID__c);
			memGuid2MemInfoMap.get(mc.MemberProfileGUID__c).put('RouteId__c', mc.RouteId__c);
			
			System.debug('SubscriberId__c::'+mc.SubscriberId__c);
			System.debug('PlanGuid__c::'+mc.PlanGuid__c);
			mock_Member__c member = wmp_util_Cache.getMember(mc.SubscriberId__c.toLowerCase(), mc.PlanGuid__c.toLowerCase());
			
			memGuid2MemInfoMap.get(mc.MemberProfileGUID__c).put('FirstName__c', member.FirstName__c);
			memGuid2MemInfoMap.get(mc.MemberProfileGUID__c).put('LastName__c', member.LastName__c);
		}
		
		return memGuid2MemInfoMap;
	}
	 
	@AuraEnabled
    public static Portal_Configuration__mdt loadConfiguration(){
    	System.debug('pconfig::'+wmp_util_Cache.PortalConfiguration);
    	//return the portal configuration
    	return wmp_util_Cache.PortalConfiguration;
    	
    }
}