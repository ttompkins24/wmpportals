/**********************************************************************************************************************
Name 						: wmp_ctrl_myBenefits
Purpose						: The controller for the component that displays the my benefits page
Created on					: 30th August 2017
Developed by				: Santosh Kumar Sriram
History
Version#		Sprint#		Date							By  						Comments
1.0				1.0			30th August 2017				Santosh Kumar Sriram		See header - purpose
  

**********************************************************************************************************************/
public without sharing class wmp_ctrl_myBenefits {
	
	/***********************************************************************
	Method name: 	getCurrentMember
	Return type:	mock_Member__c from cache class
	***********************************************************************/
	@AuraEnabled
	public static mock_Member__c fetchCurrentMember(){ 
		return wmp_util_cache.getCurrentMember();
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
	Method name: 	getCurrentMemberPlans
	Return type:	mock_Member__c from cache class
	***********************************************************************/
	@AuraEnabled
	public static String fetchPlanName(String planId){
		System.debug('planId >> '+ planId);
		System.debug('planId >> '+ wmp_util_cache.getPlanName(planId.toLowerCase())); 
		return wmp_util_cache.getPlanName(planId.toLowerCase()); 
	}
	
	/***********************************************************************
	Method name: 	getRelatedKnowledgeArticle
	Return type:	My_Benefits__kav from the knowledge article table
	***********************************************************************/
    @AuraEnabled 
    public static boolean showAccumulators(string subgroupId){
        system.debug('sgid: ' + subgroupId);
        if(subgroupID != null &&  subgroupID != ''){
			map<String,Plan_Configuration__mdt>	map_allPlans = wmp_util_cache.getPlanConfigurations();
            system.debug(map_allPlans);
            if(map_allPlans.containsKey(subgroupID.toLowerCase())){
                return (Boolean)map_allPlans.get(subgroupID.toLowerCase()).ShowAccumulators__c;
            }
        }
        return false;
    }

	@AuraEnabled
	public static My_Benefits__kav getRelatedKnowledgeArticle(String subgroupID){
		//fetch related account id from the subgroupID
		Id related_planAccountId = fetchRelatedPlanAccountId(subgroupID);
		System.debug('>>>>>' + related_planAccountId);
		System.debug('>>>>>subgroupId::' + subgroupID);
		String knowledgeArticleTitle = '';
		if(subgroupID != null &&  subgroupID != ''){
			map<String,Plan_Configuration__mdt>	map_allPlans = wmp_util_cache.getPlanConfigurations();
            if(map_allPlans.containsKey(subgroupID.toLowerCase())){
				knowledgeArticleTitle = map_allPlans.get(subgroupID.toLowerCase()).myBenefits_knowledge_article_title__c;
            }
		}else{
			return null;
		}
		/******************************
		Mini byte
		So whats the logic here
		Every my benefits document is related to a plan account
		So we are fetching the account id based on subgroupid
		Then we will query for knowledge article related to the plan
		 -- Admins pls maintain only one my benefits document per plan account
		*****************************/
		//fetch related knowledge article
		My_Benefits__kav inst_myKnowledgeArticle = fetchRelatedKnowledgeArticle(knowledgeArticleTitle);
		System.debug('inst_myKnowledgeArticle::'+inst_myKnowledgeArticle);
		return inst_myKnowledgeArticle;
	}
	
	/***********************************************************************
	Method name: 	getRelatedPlanAccountIdFromSubgroupId
	Return type:	ID - account id from further querying
	Parameters:		String - subgroup Id from the planGuid field in the member plan
	***********************************************************************/
    @testVisible public static id fetchRelatedPlanAccountId(String strng_subgroupID){
    	try{
    		System.debug('>>>>' + strng_subgroupID);
    		Account inst_relatedAccount = [		SELECT ID 
    					 				   		FROM ACCOUNT
    									   		WHERE
    									   			guid__c LIKE:strng_subgroupID
    									  ];
    		return inst_relatedAccount.id;
    	}catch(Exception exp){
    		return null;
    	}
    }
    /***********************************************************************
	Method name: 	fetchVerifiedMemberPlansAccounts
	Return type:	list of accounts
					There are 2 steps:
					# 1 fetch all the related member plan GUIDs from the cache class
					# 2 fetch the related account Id via a query and display as dropdown
	***********************************************************************/
    @AuraEnabled
    public static list<Account> fetchVerifiedMemberPlansAccounts(){
    	list<Account> list_verifiedPlanAccounts = new list<Account>();
    	try{
    		set<string> set_verifiedMemberPlans = new set<string>();
    		map<string, account> map_planGuid_account = new map<string, account>();
    		//Step1 - get all the related Member plans
    		for(mock_MemberCoverage__c iterating_memberPlan :  wmp_util_cache.getCurrentMemberPlans()){
    			set_verifiedMemberPlans.add(iterating_memberPlan.PlanGuid__c);
    		}
    		/*
    		list_verifiedPlanAccounts = [		SELECT ID
    												   ,Name
    												   ,guid__c 
    					 				   		FROM ACCOUNT
    									   		WHERE
    									   			guid__c IN:set_verifiedMemberPlans
    									  ];
    		return list_verifiedPlanAccounts;*/
    		for(Account iterating_account : [		SELECT ID
    												   ,Name 
    												   ,guid__c 
    					 				   		FROM ACCOUNT
    									   		WHERE
    									   			guid__c IN:set_verifiedMemberPlans
    									  ]){
    			//build a map with guid as the key
    			map_planGuid_account.put(iterating_account.guid__c.toLowerCase(), iterating_account);
    		}
    		
    		//reiterating the member plan map to fetch the list of account
    		for(mock_MemberCoverage__c iterating_memberPlan :  wmp_util_cache.getCurrentMemberPlans()){
    			//getting the concerned account based on planguid
    			Account inst_account = map_planGuid_account.get(iterating_memberPlan.PlanGuid__c.toLowerCase());
    			String orginalAccountName = inst_account.Name;
    			//adding the name of the person to the account name
    			inst_account.Name =  inst_account.Name + ' '+ System.Label.Effective + ' '+ iterating_memberPlan.EffectiveDate__c.month()+'-'+iterating_memberPlan.EffectiveDate__c.day()+'-'+iterating_memberPlan.EffectiveDate__c.year();
    			System.debug(inst_account.Name);
    			list_verifiedPlanAccounts.add(inst_account);
    			//inst_account.Name = orginalAccountName;
    			Account temp_account = new Account(Id = inst_account.Id,
    											   Name = orginalAccountName,
    											   guid__c = inst_account.guid__c
    												);	
    			map_planGuid_account.put(inst_account.guid__c.toLowerCase(), temp_account);
    		}
    		
    		return list_verifiedPlanAccounts;
    	}catch(Exception exp){
    		return null;
    	}
    } 
    /***********************************************************************
	Method name: 	fetchVerifiedMemberPlansAccounts
	Return type:	list of accounts
					There are 2 steps:
					# 1 fetch all the related member plan GUIDs from the cache class
					# 2 fetch the related account Id via a query and display as dropdown
	***********************************************************************/
    @AuraEnabled
    public static list<Account> fetchVerifiedMemberPlansAccounts_friendlyNames(){
    	list<Account> list_verifiedPlanAccounts = new list<Account>();
    	try{
    		set<string> set_verifiedMemberPlans = new set<string>();
    		map<string, account> map_planGuid_account = new map<string, account>();
    		//Step1 - get all the related Member plans
    		for(mock_MemberCoverage__c iterating_memberPlan :  wmp_util_cache.getMemberPlans().values()){
    			set_verifiedMemberPlans.add(iterating_memberPlan.PlanGuid__c.toLowerCase());
    		}
    		/*
    		list_verifiedPlanAccounts = [		SELECT ID
    												   ,Name
    												   ,guid__c 
    					 				   		FROM ACCOUNT
    									   		WHERE
    									   			guid__c IN:set_verifiedMemberPlans
    									  ];
    		return list_verifiedPlanAccounts;*/
    		for(Account iterating_account : [		SELECT ID
    												   ,Name
    												   ,guid__c 
    					 				   		FROM ACCOUNT
    									   		WHERE
    									   			guid__c IN:set_verifiedMemberPlans
    									  ]){
    			//build a map with guid as the key
    			map_planGuid_account.put(iterating_account.guid__c.toLowerCase(), iterating_account);
    		}
    		
    		//reiterating the member plan map to fetch the list of account
    		for(mock_MemberCoverage__c iterating_memberPlan :  wmp_util_cache.getMemberPlans().values()){
    			//getting the concerned account based on planguid
    			Account inst_account = map_planGuid_account.get(iterating_memberPlan.PlanGuid__c.toLowerCase());
    			String orginalAccountName = inst_account.Name;
    			//adding the name of the person to the account name
    			inst_account.Name = wmp_util_cache.getMemberName(iterating_memberPlan.SubscriberID__c.toLowerCase(), iterating_memberPlan.PlanGuid__c.toLowerCase()) + System.Label.s_Plan + '(' + inst_account.Name + ')';
    			System.debug(inst_account.Name);
    			list_verifiedPlanAccounts.add(inst_account);
    			//inst_account.Name = orginalAccountName;
    			Account temp_account = new Account(Id = inst_account.Id,
    											   Name = orginalAccountName,
    											   guid__c = inst_account.guid__c
    												);	
    			map_planGuid_account.put(inst_account.guid__c.toLowerCase(), temp_account);
    		}
    		
    		return list_verifiedPlanAccounts;
    	}catch(Exception exp){
    		return null;
    	}
    } 
    /***********************************************************************
	Method name: 	fetchNewCurrentMemberPlan
	Return type:	
	Parameters:		the list of specialities fron the account object
	***********************************************************************/
	@AuraEnabled
	public static mock_MemberCoverage__c fetchNewCurrentMemberPlan(string planId, string subscriberId){
		System.debug('^^^^^' + planId);
		System.debug('^^^^^' + subscriberId);
		System.debug('^^^^^' + wmp_util_cache.getMembersPlansByMemberAndPlan(subscriberId, planId));
		return wmp_util_cache.getMembersPlansByMemberAndPlan(subscriberId.toLowerCase(), planId.toLowerCase());
	}
    /***********************************************************************
	Method name: 	fetchSpecialitiesPicklistValues
	Return type:	list<string>
	Parameters:		the list of specialities fron the account object
	***********************************************************************/
   /* @AuraEnabled
    public static list<string> fetchSpecialitiesPicklistValues(){
    	List<String> options = new List<String>();
    	//Adding select to the list
    	options.add(System.Label.Select);
		Schema.DescribeFieldResult fieldResult = Account.Specialties__c.getDescribe();
		list<Schema.PicklistEntry> list_picklistEntry = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry iterating_picklistEntry: list_picklistEntry) {
		    options.add(iterating_picklistEntry.getLabel());
		}
		return options;
    }*/
    /***********************************************************************
	Method name: 	fetchRelatedKnowledgeArticle 
	Return type:	My_Benefits__kav - the related knowledge article to view
	Parameters:		Id - account id from the subgroupID plan
	***********************************************************************/
    @testVisible private static My_Benefits__kav fetchRelatedKnowledgeArticle(String articleTitle){
    	try{
    		/*My_Benefits__kav inst_myBenefitsArticle = [		SELECT 
    															Id,
    															Benefits_covered_Surrounding_Text__c,
    															Covered__c,
    															Member_Handbook_English__Name__s,
    															Member_Handbook_Spanish__Name__s,
    															Benefits_Summary_English__Name__s,
    															Benefits_Summary_Spanish__Name__s,
    										   					Member_Handbook_surrounding_text__c,
    										   					Member_Handbook_is_File__c,
    										   					Member_Handbook_English_Link__c,
    										   					Member_Handbook_Spanish_Link__c,
    										   					Benefits_Summary_is_File__c,
    										   					Benefits_Summary_English_Link__c,
    										   					Benefits_Summary_Spanish_Link__c,
    															Not_Covered__c,
    															My_Benefifts_Name__c
    														FROM 
    															My_Benefits__kav
    														WHERE 
    															PublishStatus = 'Draft'
    															AND
    															Plan__c =:planId
    															AND 
    															Language = 'en_US'
    												  ];
    		return inst_myBenefitsArticle;*/
    		list<My_Benefits__kav> list_allRelatedBenefits = wmp_util_Helper.getObjects('My_Benefits__kav',' WHERE PublishStatus = \'' + System.Label.PublishStatus + '\' AND Title= \'' + articleTitle + '\' AND Language= \''+ UserInfo.getLanguage()+ '\'', true);
	    		if(!list_allRelatedBenefits.isEmpty()){
	    			My_Benefits__kav inst_myBenefitsArticle = list_allRelatedBenefits[0];
	    			return inst_myBenefitsArticle;
	    		}else
	    			return null;
    	}catch(Exception exp){
    		return null;
    	}
    }
    
    @AuraEnabled
    public static List<Map<String, String>> fetchPicklistValues_Speciality(){
		//initialize var
		List<Portal_Picklist__mdt> portalList = new List<Portal_Picklist__mdt>();
		Map<String, String> lang2langCodeMap = new Map<String, String>{'en_US'=>'English', 'es' =>'Spanish'};
    	String locKey = UserInfo.getLanguage();
		
        //return the specialty info
        return wmp_util_Cache.util_retrievePicklistValues('Specialty', lang2langCodeMap.get(locKey));

    } 
    
     @AuraEnabled
    public static List<Map<String, String>> fetchPicklistValues_Language(){
		//initialize var
		List<Portal_Picklist__mdt> portalList = new List<Portal_Picklist__mdt>();
		Map<String, String> lang2langCodeMap = new Map<String, String>{'en_US'=>'English', 'es' =>'Spanish'};
    	String locKey = UserInfo.getLanguage();
		
        //return the language Info
        return wmp_util_Cache.util_retrievePicklistValues('Language', lang2langCodeMap.get(locKey));

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
    @AuraEnabled
	public static Map<String,String> retrieveMemberPlans(){
		//initialize variables
		Map<String, String> memCoverageGuid2MemNamePlanMap = new Map<String, String>();
		//Map<String, String> memberGuidToMemberAndPlan = wmp_util_Cache.MemberGuidToMemberAndPlan;
		Map<String, String> planGuid2PlanNameMap = new Map<String, String>();
		
		for(mock_MemberCoverage__c mc : wmp_util_Cache.MemberPlans.values()){
			planGuid2PlanNameMap.put(mc.PlanGuid__c.toLowerCase(), null);
		}
		
		//query for the plan names
		for(Account acc : [SELECT id, Name, guid__c FROM Account WHERE guid__c IN:planGuid2PlanNameMap.keyset()]){
			planGuid2PlanNameMap.put(acc.guid__c.toLowerCase(), acc.Name);
		}
		
		//loop through the member coverage and map the mem coverage guid to the member name and plan name
		for(mock_MemberCoverage__c mc : wmp_util_Cache.MemberPlans.values()){
			//initialize the fields
			String labelName = '';
			
			//get the member
			mock_Member__c member = wmp_util_Cache.getMember(mc.SubscriberId__c.toLowerCase(), mc.PlanGuid__c.toLowerCase());
			
			//construct the label
			labelName += member.FirstName__c + ' (' + planGuid2PlanNameMap.get(mc.PlanGuid__c.toLowerCase())  + ')';
			//map the mem coverage guid to the generated label
			memCoverageGuid2MemNamePlanMap.put(mc.MemberCoverageGuid__c, labelName);
		}
		
		return memCoverageGuid2MemNamePlanMap;
	}
	/***********************************************************************
	Method name: 	fetchRelatedZipCode
	Return type:	
					There are 2 steps:
					# 1 fetch all the related member plan GUIDs from the cache class
					# 2 fetch the related account Id via a query and display as dropdown
	***********************************************************************/
    @AuraEnabled
    public static String fetchRelatedZipCode(Double dc_lat, Double dc_long){
		
	
		//initialize variables
		Zip_Code__c inst_zipCodeBackToLC = new Zip_Code__c();
		//query for the zip code object based on the values
		if(dc_lat != null 
		  &&
		  dc_long != null 
		  ){
			for(Zip_Code__c iteratingZip : Database.query('SELECT Id,'+
																'City__c,'+
																'Latitude__c,'+
																'Longitude__c,'+
																'Zip_Code__c, '+
																'Location__c '+
															'FROM '+
																'Zip_Code__c '+
															'WHERE '+
															' Location__Latitude__s != null '+
															' AND ' +
															' Location__Longitude__s != null '+
															' AND '+
															' DISTANCE(Location__c, GEOLOCATION(' + dc_lat +','+ dc_long + '),\'mi\') < 50'+
															'ORDER BY  '+
																'DISTANCE(Location__c, GEOLOCATION(' + dc_lat +','+ dc_long + '),\'mi\') ASC ' +
															'LIMIT 1')
												   ){
				//for the first value that satisfies this condition, we will exist the condition
				inst_zipCodeBackToLC = iteratingZip;
				break;
			}
		}
		System.debug('&&&&&&&&&&&' + inst_zipCodeBackToLC);
		if(inst_zipCodeBackToLC != null)
			return inst_zipCodeBackToLC.Zip_Code__c;
		else 
			return '';
	}
}