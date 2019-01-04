/**********************************************************************************************************************
Name                        : 	wmp_util_CacheObject
Purpose                     : 	The class that stores the cached values in the session cache
Created on                  : 	08/09/2017
Developed by				: 	Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.1			5.0      	09/20/2017		Patrick Stephens	 	

**********************************************************************************************************************/

/* Description	**********************************************************


The actual class sotred in the session cache is an instantiation of the wmp_util_CacheObject class. However, we do
not intend consuming components or classes to interact directly with the cacheObject, but rather through this cache class.

We use MemberPlan and MemberCoverage interchangeably in this class, this is due to a change of the external object 
from MembersPlans__c to mock_MemberCoverage__c during development. 

**************************************************************************/

global without sharing class wmp_util_CacheObject {
    public		Boolean										cacheFetched											{get;set;}
    public		Boolean										isAvailable												{get;set;}
    public		String										SubscriberId											{get;set;}
    public		ID											ContactToReview											{
    	get{
    		if(ContactToReview==null && wmp_util_MockData.UseMockData){
    			List<Contact> tempCons = [SELECT Id FROM Contact WHERE (FirstName = 'Bruce' AND LastName = 'Wayne' AND Email = 'iluvbats@test.com') 
    										OR UseAsMockDataRecord__c = true ORDER BY LastModifiedDate DESC LIMIT 1];
    			if(tempCons.size()<1){
    				ContactToReview = wmp_util_MockDataGen.genBaseData();
    			} else {
    				ContactToReview = tempCons[0].Id; 
    			}
    		}
    		return ContactToReview;
    	}
    	set;}
    public		String										PlanGUID												{get;set;}
    public		String										ConfigurationName										{get;set;}
    public		Portal_Configuration__mdt					PortalConfiguration										{get;set;}
    public  	List<Portal_Configuration_Links__mdt>		PortalLinks												{get;set;}
    public 		Map<String, mock_MemberCoverage__c>				MemberPlans												{get;set;}
	
	//map of PlanGUID to planConfiguration
	public		Map<String,PLan_Configuration__mdt>			PlanConfigurations										{get;set;}
	
    //map of plans overrides to planguids that are overridden
    public		Map<String,Set<String>>						planOverridesIds										{get;set;}
    
	//Map of MemberProfileGUID to a map of MemberAddressGUID to mock_MemberAddress__c objects
    public		Map<String,Map<String,mock_MemberAddress__c>>	MemberAddresses											{get;set;}
    
    //Map of MemberProfileGUID to a map of MemberAddressGUID to mock_MemberPhone__c objects
    public		Map<String,Map<String,mock_MemberPhone__c>>		MemberPhones											{get;set;}
    
	//Map of MemberId + PlanId to MemberPlanGuid
    public		Map<String,String>							MemberAndPlanToGuid										{get;set;}
	
    //Map of MemberId + PlanId to MemberProfileGuid
    public		Map<String,String>							MemberAndPlanToProfileGuid								{get;set;}
    
    //Map of ContactToMemberCoverageGuid
    public		Map<String,String>							MemberPlanGUIDToContact									{get;set;}
    
    //Map of MemberId + PlanId to MemberPlanGuid
    public 		Map<String,String>							MemberGuidToMemberAndPlan								{get;set;}
    
    //Map of emberPlanGuid to SF ID for UserPlanVerification
    public 		Map<String,ID>								MemberGuidToPlanVerification							{get;set;}
    
    //Map of SFID and User_Plan_Verification__c records aassociated to the logged in portal user. Null for Internal Users
    public 		Map<Id,User_Plan_Verification__c>			VerifiedPlans											{get;set;}
 
    
    //Map of Verified mock_MemberCoverage__c records aassociated to the logged in portal user. Null for Internal Users
    public 	Map<String,mock_MemberCoverage__c>					VerifiedMembersPlans									{get;set;}
    
    //Map of Verified mock_MemberCoverage__c records to their contact Id
    public 	Map<String,List<mock_MemberCoverage__c>>				ContactMemberPlans										{get;set;}
   	
    public	Set<String>										VisiblePlanIdSet										{get;set;}

    //get the current running user contact rec if avaialable
    public 	Contact											ContactRec												{get;set;}
    
    //get the current running user info					
    public 	User											UserRec													{get;set;}
	
	//map of MemberId to mock_Member__c object
    public Map<String,mock_Member__c>							Members													{get;set;}
    
    //map of planguids to Account[Plan] object
    public Map<String,Account>								Plans													{get;set;}
    
    //map of memberPlanGuids  to active mock_MemberPrimaryCareDentist__c object
    public Map<String,mock_MemberPrimaryCareDentist__c>			PrimaryDentists											{get;set;}
    
    //map of memberPlanGuids  to PrimaryDentistRequests
    public Map<String,String>								PCDRequests												{get;set;}
    
    //get the visible Lines of Business for the current running user
	public	Set<String>										VisibleLOB												{get;set;}


	public Map<String, Account>								Providers												{get;set;}
	
	public Map<String, Providers_Service_Locations__c>		ServiceLocations										{get;set;}
	
	//map of memberCoverageGUID to a list of mock_MemberAccumulator__c
	public Map<String,List<mock_MemberAccumulator__c>>			MemberAccumulators										{get;set;}
    
	   
	public 		void										WriteToCache()											{
		Cache.Session.put('PortalCache',this);
	}
}