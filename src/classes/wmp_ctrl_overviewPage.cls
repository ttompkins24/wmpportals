/**********************************************************************************************************************
Name 						: wmp_ctrl_overviewPage
Purpose						: The controller for the component that displays the overview page
Created on					: 19th September 2017
Developed by				: Santosh Kumar Sriram
History
Version#		Sprint#		Date							By  						Comments
1.0				1.0			19th September 2017				Santosh Kumar Sriram		See header - purpose
2.0				ME			22nd March 2018					WMP							Added check in fetch_overviewDetails to ensure that only one overview card gets added for a user on the DIDD plans

**********************************************************************************************************************/
public without sharing class wmp_ctrl_overviewPage {
	
	//Creating a wrapper class
	/********************************************************************************************************************
	Wrapper class 							: wrapper_overviewPage
	Part of the wrapper						: mock_Member__c
											  mock_MemberCoverage__c
											  Account__c
	Purpose									: So, here are the details. The overview page displays the member name (from mock_Member__c)
											  The plan name and the subscriber id (mock_MemberCoverage__c)
											  and also the primary dentist information and the view information 
	********************************************************************************************************************/
	public class wrapper_overviewPage{
		@AuraEnabled
		mock_Member__c inst_memberExternal {get;set;}
		@AuraEnabled
		mock_MemberCoverage__c inst_memberCoverageExternal {get;set;}
		@AuraEnabled
		String planName{get; set;}
		@AuraEnabled
		wmp_class_PrimaryDentistInfo inst_primaryProviderInfo {get;set;}
		@AuraEnabled
		Plan_Configuration__mdt related_planConfig{get;set;}
		//Constructor
		public wrapper_overviewPage(){ 
			inst_memberExternal = new mock_Member__c();
			inst_memberCoverageExternal = new mock_MemberCoverage__c();
			planName = '';
			//related_planConfig = new Plan_Configuration__mdt();
			//inst_primaryProviderInfo = new wmp_class_PrimaryDentistInfo();
		}
	}
    
    //populating the wrapper class from the cache class
    /********************************************************************************************************************
	Method name 							: fetch_overviewDetails
	Purpose									: There are 4 steps
											  1. Get the verified member plan for the logged in user
											  2. Get the user verfication to determine who the guardian is 
											  3. Fetch all the related primary dentist info
											  4. Populate the wrapper list and send it back to the lightning component 
	********************************************************************************************************************/
	@AuraEnabled
    public static list<wrapper_overviewPage> fetch_overviewDetails(){
    	//The data collection that will be returned back to the lightinng component
    	list<wrapper_overviewPage> list_AllOverviewRecords = new list<wrapper_overviewPage>();
    	//Step 1 - Get the verified member plans for the logged in user
        map<Id,User_Plan_Verification__c> map_AllVerifiedRecords = wmp_util_cache.VerifiedPlans;
        System.debug('Plans - ' + map_AllVerifiedRecords.size() + ' - ' + map_AllVerifiedRecords);
        //Getting data from the cache class to ensure that we create the wrapper class
        map<string,mock_Member__c> map_AllMembers = wmp_util_cache.getmembers();
        System.debug('members - ' + map_AllMembers.size() + ' - ' + map_AllMembers);

        map<string,mock_MemberCoverage__c> map_AllMemberCoverageRecords = wmp_util_cache.getVerifiedMembersPlans();
        System.debug('member coverage - ' + map_AllMemberCoverageRecords.size() + ' - ' + map_AllMemberCoverageRecords);

        //getting the plan config map from the cache class
        map<String, Plan_Configuration__mdt> map_allPlanConfigurations = wmp_util_cache.getPlanConfigurations();
        System.debug('Plan Configs - ' + map_allPlanConfigurations.size() + ' - ' + map_allPlanConfigurations);

        //Iterate through the map and add the guardian first
        if(map_AllVerifiedRecords==null)
            map_AllVerifiedRecords = new map<Id,User_Plan_Verification__c>();
        System.debug('map_AllMemberCoverageRecords::'+map_AllMemberCoverageRecords.keyset());
        System.debug('map_AllMembers::'+map_AllMembers.keyset());
        Set<String> usedMemPlans = new Set<String>();
        for(User_Plan_Verification__c iterating_userPlanVerfication : map_AllVerifiedRecords.values()){
            String memplan = iterating_userPlanVerfication.Subscriber_ID__c.toLowerCase() + iterating_userPlanVerfication.Plan_ID__c.toLowerCase();
            if(!usedMemPlans.contains(memplan)){
                usedMemplans.add(memplan);
        	//Checking if the guardian contact is null - relates to the fact that the person manages his/her own plans
                System.debug('iterating_userPlanVerfication::'+iterating_userPlanVerfication);
                if( iterating_userPlanVerfication.Guardian_Contact__c == null){ 
                    //Adding the guardian to the list of records that will return
                    //we check if all the records exists to ensure that the record is added to the list
                    System.debug('>>> ' + map_AllMemberCoverageRecords);
                    System.debug('>>> ' + iterating_userPlanVerfication);
                    if(map_AllMemberCoverageRecords==null)
                        map_AllMemberCoverageRecords = new map<string,mock_MemberCoverage__c>();
                    if( map_AllMemberCoverageRecords.containsKey(iterating_userPlanVerfication.MemberCoverageGuid__c.toLowerCase())
                        &&
                        map_AllMembers.containsKey(map_AllMemberCoverageRecords.get(iterating_userPlanVerfication.MemberCoverageGuid__c.toLowerCase()).MemberProfileGUID__c.toLowerCase())
                        ){
                        //Adding the guardian to the list
                        wrapper_overviewPage iterating_Wrapper = new wrapper_overviewPage();
                        iterating_Wrapper.inst_memberExternal 		= map_AllMembers.get(map_AllMemberCoverageRecords.get(iterating_userPlanVerfication.MemberCoverageGuid__c.toLowerCase()).MemberProfileGUID__c.toLowerCase());
                        iterating_Wrapper.inst_memberCoverageExternal = map_AllMemberCoverageRecords.get(iterating_userPlanVerfication.MemberCoverageGuid__c.toLowerCase());
                        iterating_Wrapper.inst_primaryProviderInfo	= wmp_util_cache.getPrimaryDentist(iterating_Wrapper.inst_memberCoverageExternal.SubscriberID__c.toLowerCase(),iterating_Wrapper.inst_memberCoverageExternal.PlanGUID__c.toLowerCase());
                        iterating_Wrapper.planName					= wmp_util_cache.getPlanName(iterating_Wrapper.inst_memberCoverageExternal.PlanGUID__c.toLowerCase());
                        //checking if the planid is present in the map to fetch pllan configurations
                        if(map_allPlanConfigurations.containsKey(iterating_Wrapper.inst_memberCoverageExternal.PlanGUID__c.toLowerCase())){
                            iterating_Wrapper.related_planConfig = map_allPlanConfigurations.get(iterating_Wrapper.inst_memberCoverageExternal.PlanGUID__c.toLowerCase());
                        }
                        //Adding this as the first element to the list that will return
                        if(list_AllOverviewRecords.size() > 0)
                            list_AllOverviewRecords.add(0,iterating_Wrapper);
                        else
                            list_AllOverviewRecords.add(iterating_Wrapper);
                    }
                }else{ //rest of the data - includes the list of wards/dependents
                    if( map_AllMemberCoverageRecords.containsKey(iterating_userPlanVerfication.MemberCoverageGuid__c.toLowerCase())
                        &&
                        map_AllMembers.containsKey(map_AllMemberCoverageRecords.get(iterating_userPlanVerfication.MemberCoverageGuid__c.toLowerCase()).MemberProfileGUID__c.toLowerCase())
                        ){
                        //Adding the guardian to the list
                        wrapper_overviewPage iterating_Wrapper = new wrapper_overviewPage();
                        iterating_Wrapper.inst_memberExternal 		= map_AllMembers.get(map_AllMemberCoverageRecords.get(iterating_userPlanVerfication.MemberCoverageGuid__c.toLowerCase()).MemberProfileGUID__c.toLowerCase());
                        iterating_Wrapper.inst_memberCoverageExternal = map_AllMemberCoverageRecords.get(iterating_userPlanVerfication.MemberCoverageGuid__c.toLowerCase());
                        iterating_Wrapper.inst_primaryProviderInfo	= wmp_util_cache.getPrimaryDentist(iterating_Wrapper.inst_memberCoverageExternal.SubscriberID__c,iterating_Wrapper.inst_memberCoverageExternal.PlanGUID__c.toLowerCase());//Adding this as the first element to the list that will return
                        iterating_Wrapper.planName					= wmp_util_cache.getPlanName(iterating_Wrapper.inst_memberCoverageExternal.PlanGUID__c.toLowerCase());
                        //checking if the planid is present in the map to fetch pllan configurations
                        if(map_allPlanConfigurations.containsKey(iterating_Wrapper.inst_memberCoverageExternal.PlanGUID__c.toLowerCase())){
                            iterating_Wrapper.related_planConfig = map_allPlanConfigurations.get(iterating_Wrapper.inst_memberCoverageExternal.PlanGUID__c.toLowerCase());
                        }
                        list_AllOverviewRecords.add(iterating_Wrapper);
                    }
                }
            }
        }
		//Returning the list
		System.debug('>>>>>>>>' + list_AllOverviewRecords);
    	return list_AllOverviewRecords;
    }
    
    /***********************************************************************
	Method name: 	fetchLoggedInUser
	Return type:	User from cache class
	***********************************************************************/
	@AuraEnabled
	public static Contact fetchLoggedInUser(){ 
		return wmp_util_cache.getContactRec();
	} 
	
	/***********************************************************************
	Method name: 	updateWelcomeDashboard
	Return type:	Update the contact record to ensure that dashboard doesnt show again
	***********************************************************************/
	@AuraEnabled
	public static Contact updateWelcomeDashboard(){
		Contact inst_contact = new Contact();
		inst_contact = wmp_util_cache.getContactRec();
		inst_contact.Displayed_Welcome_message__c = true;
		//udpating the contact
		update inst_contact;
		
		//now setting the updated contact in the cache class
		wmp_util_cache.ContactRec = inst_contact;
		//write it to cache
		wmp_util_CacheObject inst_wmp_util_CacheObject =  wmp_util_cache.cobj;
		inst_wmp_util_CacheObject.WriteToCache();
		return inst_contact;
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
    
    
}