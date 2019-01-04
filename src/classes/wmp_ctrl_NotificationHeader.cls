/**********************************************************************************************************************
Name                        : 	WMP_ctrl_NotificationHeader
Purpose                     : 	Controller for the wmp_comp_NotificationHeader.Contains logic to retrieve the portal notifications and notifications that the user can see,
								based on the plans that they manage or the people that they manage
Created on                  : 	08/16/2017
Developed by				: 	Todd Tompkins
History
Version#    Sprint#     Date            by                    Comments
1.0			1.0      	08/16/2017		Todd Tompkins

**********************************************************************************************************************/
public without sharing class wmp_ctrl_NotificationHeader {
    
    /*
		Return all notifications that the user can see that is not defined by the portal
	*/
    @AuraEnabled
	public static boolean refreshCache(){
        wmp_util_Cache.GetCacheData();
        return true;
    }
    
	@AuraEnabled
	public static List<Notification__c> getNotifications(){
		//intialize variables
		if(wmp_util_Cache.Plans != null){
			Set<String> planIds = wmp_util_Cache.Plans.keyset();
			List<String> memCoverageGuids = wmp_util_Cache.MemberAndPlanToGuid.values();
            Set<String> memAndPlans = wmp_util_Cache.MemberAndPlanToGuid.keyset();
            String portalName = wmp_util_Cache.PortalConfiguration.Label;
			Date todaysDate = Date.today();
			System.debug('memCoverageGuids::'+memCoverageGuids);
			System.debug('planIds::'+planIds);
			//query for the notifications and return them
			List<Notification__c> notifs = new List<Notification__c>();
			notifs = [SELECT id, Plan_ID__c, Member_Id__c, Body_US__c, Body_ES__c, Read__c 
                        FROM Notification__c 	
                        WHERE (Plan_Id__c IN:planIds OR Member_ID__c in:memCoverageGuids OR Member_ID__c in:memAndPlans OR Portal__c = :portalName) 
                        AND ( (Start__c = null OR Start__c <=:todaysDate) AND (End__c = null OR End__c >=:todaysDate)) ];
            //Pcd Assignment Successfully completed
            return notifs;
		} else{
			return new List<Notification__c>();
		}
		
		
	}
	
	 /*
		Return all notifications that the user can see that is defined by the portal
	*/
	@AuraEnabled
	public static List<Notification__c> getPortalNotifications(){
		//intialize variables
		Set<String> planIds = wmp_util_Cache.Plans.keyset();
		String portalName = wmp_util_Cache.PortalConfiguration.Label;
		Set<String> memProfileGuids = wmp_util_Cache.MemberAndPlanToGuid.keyset();
		Date todaysDate = Date.today();
		System.debug('memProfileGuids::'+memProfileGuids);
		System.debug('planIds::'+planIds);
		//query for the notifications and return them
		return [SELECT id, Plan_ID__c, Member_Id__c, Body_US__c, Body_ES__c, Portal__c 
				FROM Notification__c 	
				WHERE Portal__c = :portalName AND  ( (Start__c = null OR Start__c <=:todaysDate) AND (End__c = null OR End__c >=:todaysDate))];//
			
		
	}
	/*
		Return the language the user has selected
	*/
	@AuraEnabled
    public static String initLanguage(){
    	//initialize the variables
    	Map<String, String> lang2langCodeMap = new Map<String, String>{'en_US'=>'English', 'es' =>'Espanol'};
    	String locKey = UserInfo.getLanguage();
    	
    	System.debug('langSelected::'+locKey);
    	
    	if(lang2langCodeMap.containsKey(locKey)){
    		return lang2langCodeMap.get(locKey);
    	}
    	
    	return 'English';
    } 
    
    @AuraEnabled
    public static Boolean isOpenPCDRequest(mock_MemberCoverage__c memCov){
    	String pcdRequest = null;
    System.debug('keyset:pcdRequest::'+wmp_util_Cache.PCDRequests.keyset());
    System.debug('valules:pcdRequest::'+wmp_util_Cache.PCDRequests.values());
    	if(memCov != null )
    		pcdRequest = wmp_util_Cache.getPCDRequest(memCov.MemberCoverageGuid__c.toLowerCase());
    		
    	return pcdRequest != null && pcdRequest != '';
    }
}