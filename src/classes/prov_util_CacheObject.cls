/**********************************************************************************************************************
Name                        : 	prov_util_CacheObject
Purpose                     : 	The class that stores the cached values in the session cache
Created on                  : 	1/01/2018
Developed by				: 	Todd Tompkins
History
Version#    Sprint#     Date            by                   Comments
1.1			1.0      	01/01/2018		Todd Tompkins	 	

**********************************************************************************************************************/
 
/* Description	**********************************************************


The actual class stored in the session cache is an instantiation of the prov_util_CacheObject class. However, we do
not intend consuming components or classes to interact directly with the cacheObject, but rather through this cache class.


**************************************************************************/
global without sharing class prov_util_CacheObject {
    
    public		Boolean										cacheFetched											{get;set;}
    public		Boolean										isAvailable												{get;set;}
    public		String										CurrentBusinessId										{get;set;}
    public		String										DefaultBusinessId										{get;set;}
    public		ID											ContactToReview											{
    	get{
    		if(ContactToReview==null && prov_util_MockData.UseMockData){
    			List<Contact> tempCons = [SELECT Id FROM Contact WHERE (FirstName = 'Daily' AND LastName = 'DAdmin' AND Email = 'iluvcapes@test.com') 
    										OR (UseAsMockDataRecord__c = true AND Portal_Name__c = 'GOVProvider') ORDER BY LastModifiedDate DESC LIMIT 1];
    			if(tempCons.size()<1){
    				ContactToReview = prov_util_MockDataGen.genBaseData();
    			} else {
    				ContactToReview = tempCons[0].Id; 
    			}
    		}
    		return ContactToReview;
    	}
    	set;}
    	
    //public		Provider_Portal_Configuration__mdt			PortalConfiguration										{get;set;}
     public		String										ConfigurationName										{get;set;}
     public		String										DefaultConfigurationName										{get;set;}

	 //Map of SFID and Business_Verification__c records aassociated to the logged in portal user. Null for Internal Users
    //public 		Map<Id,Business_Verification__c>			VerifiedBusinesses										{get;set;}
    //Map of business SF ID to BusinessVerification
    //public 		Map<String,Business_Verification__c>		BusinessIdToBusinessVerification						{get;set;}
    public      Map<Id, List<Id>> 							BusinessIdToLocationIds									{get;set;}
    public      Map<Id, Set<String>>						BusinessIdToNetworkIds									{get;set;}
    public      Map<String, List<Id>> 						BusinessIdToProviderIds									{get;set;}
    public		Map<Id, Map<Id, List<Id>>> 					BusinessId2Location2ProvidersMap						{get;set;}
    public		Map<Id, Map<Id, set<string>>>				activeBusinessId2Location2ProvidersMap					{get;set;}
    public		Map<Id, Set<String>>						BusId2ActiveLocationMap									{get;set;}
    public		Map<Id, Map<Id, List<Id>>> 					BusinessId2Provider2LocationMap							{get;set;} 
    public 		Map<String, Set<String>> 					BusinessId2PlanWWIdsMap 								{get;set;}
    public 		Map<String, List<String>> 					BusIdProvIdSLId2PlanGuidMap								{get;set;}
    
    /*
	public		Map<String, Account>						Providers												{get;set;}
	public 		Map<String, Account>						Plans													{get;set;}
	public 		Map<String, Account>						ServiceLocations										{get;set;}
	public 		Map<String, Account>						Businesses												{get;set;}
	*/
	//get the current running user contact rec if avaialable
    public 		Contact										ContactRec												{get;set;}
    
    public 		prov_util_Permissions						Permissions												{get;set;}
    public 		Map<String,prov_util_Permissions>			businessId2PermissionsMap								{get;set;}
    
    //get the current running user info					
    public 		User										UserRec													{get;set;}
	//get the visible Lines of Business for the current running user
	public		Set<String>									VisibleLOB												{get;set;}
	
	public 		void										WriteToCache()											{
		Cache.Session.put('ProviderCache',this);
		//System.debug('#################################################');
		//System.debug(Cache.Session.getCapacity() );
		//System.debug(Cache.Session.getAvgValueSize() );
	}
}