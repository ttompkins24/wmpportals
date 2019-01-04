/**********************************************************************************************************************
Name 						: WMP_ctrl_IDCardPDF
Purpose						: The controller for the visual force page that takes the parameters from the URL parameters
								and then query the knowledge articles.
Created on					: 9th August 2017
Developed by				: WMp- S$
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th August 2017					WMP-S$					See header - purpose
  

**********************************************************************************************************************/
public without sharing class WMP_ctrl_IDCardPDF {  
      
    //creating the knowledge article variable that access the information on the  page
    @testVisible private sObject generic_knowledgeArticle;
    private list<string> fieldQueried_list;
    public string strng_pageRendering {get; set;}
    public list<string> listOfStringsToDisplay{get; set;}
    public string redirectURL {get; set;}
    public Account serviceLocation {get;set;}
    public string planId {get;set;}
    //used to determine if the front and the back have to be displayed side by side
    public boolean bln_isNonPDFIdCard{get; set;} 
    public boolean pcdRequestInProgress {get;set;}
    public String  memberName	{get{
        return wmp_util_Cache.MemberName;
    }}
    //The surrounding text string if pdf version is chosen
    /*********************************************************************************
    Method Name 						: WMP_ctrl_IDCardPDF
    Purpose								: Constructor of the class
    									  1. Get the parameter from the Lightning component
    									  2. Query the knowledge article based on the parameter
    									  3. Display the information on page
    *********************************************************************************/
    public WMP_ctrl_IDCardPDF(){
    	  
    	System.debug('In Constructor');
    	//Getting the variables from the parameters passed from the Lightning component
    	String articleType_strng = ApexPages.currentPage().getParameters().get('articleType');
    	String fieldsToQuery_strng = ApexPages.currentPage().getParameters().get('queryFields');
    	//String language_strng = ApexPages.currentPage().getParameters().get('lang');
    	String language_strng = '';
    	if(articleType_strng != System.Label.ID_Card_Template)
    		language_strng = UserInfo.getLanguage();
    	else
    		language_strng = 'en_US'; 
    	planId = ApexPages.currentPage().getParameters().get('whatid');
    	String dataCategory_strng = ApexPages.currentPage().getParameters().get('portalText');
    	String knwldge_articleTitle = ApexPages.currentPage().getParameters().get('articleTitle');
    	System.debug('knwldge_articleTitle::'+knwldge_articleTitle);
    	String isPDF =  ApexPages.currentPage().getParameters().get('isPDF');
    	
        mock_MemberCoverage__c mcg = wmp_util_Cache.getCurrentMemberPlan();
        if(mcg!=null && String.isNotBlank(mcg.MemberCoverageGUID__c)){
            if(wmp_util_Cache.MemberGuidToPlanVerification.containsKey(mcg.MemberCoverageGUID__c.toLowerCase())){
                Id upvId = wmp_util_Cache.MemberGuidToPlanVerification.get(mcg.MemberCoverageGUID__c.toLowerCase());
                user_plan_verification__c upv = [SELECT ID, PCD_Request_Date__c FROM user_plan_verification__c WHERE Id =:upvId];
                pcdRequestInProgress = (upv.PCD_Request_Date__c!=null);
            }
            
        }
        
        
    	redirectURL = System.Label.CommunityURL +'/apex/WMP_vf_IDCardPDF?whatid='+planId+'&articleType='+articleType_strng+'&queryFields=Surrounding_HTML_Text__c,'+fieldsToQuery_strng+'&lang='+language_strng+'&portalText='+dataCategory_strng+'&articleTitle='+knwldge_articleTitle+'&isPDF=true';
    	//setting strng_pageRendering based on the boolean value
    	if(isPDF == 'true'){
    		strng_pageRendering = 'pdf'; 
    	}else{
    		strng_pageRendering = null;
    	}
    	//varibale initialization
    	fieldQueried_list = new list<string>();
    	generic_knowledgeArticle = Schema.getGlobalDescribe().get(articleType_strng).newSObject(null, true);
    	System.debug('knowledgeArticle:: ' + generic_knowledgeArticle);
        listOfStringsToDisplay = new list<String>();
    	system.debug('PD: ' + wmp_util_Cache.PrimaryDentist);
        if(wmp_util_Cache.PrimaryDentist!=null){
            Id serviceLocationId = wmp_util_Cache.PrimaryDentist.ServiceLocation.Service_Location__c;
            if(serviceLocationId != null)
                serviceLocation = [SELECT id, Phone, Name FROM Account WHERE Id=:serviceLocationId];
        }
        
        
    	//debugging strings that have been recieved
    	System.debug('articleType_strng >> ' +  articleType_strng);
    	System.debug('fieldsToQuery_strng >> ' +  fieldsToQuery_strng);
    	System.debug('language_strng >> ' +  language_strng);
    	System.debug('dataCategory_strng >> ' +  dataCategory_strng);
    	
    	//Building the query string
    	String queryString = '';
        String statusLabel;
        if(Test.isRunningTest()){
            statusLabel = 'Draft';
        } else {
            statusLabel = System.Label.PublishStatus;
        }
    	queryString = 'SELECT ' 
    					+ fieldsToQuery_strng 
    					+ ' FROM ' 
    					+ articleType_strng
    					+ ' WHERE ' 
    					+ 'PublishStatus = \''+statusLabel+'\''
    					+ ' AND '
    					+ 'Language=\''
    					+ language_strng
    					+ '\' AND '
    					+ ' Title =\''
    					+ knwldge_articleTitle
    					+ '\' WITH DATA CATEGORY ' 
    					+ System.Label.Parent_Data_Category
    					+ ' AT ('
    					+ dataCategory_strng
    					+ ')';
    	
    	System.debug('query string >> ' +  queryString);
    	try{
    		list<sObject> sObject_list_knwldgeArticles = Database.query(queryString);
            System.debug('sObject_list_knwldgeArticles:: ' + sObject_list_knwldgeArticles);
    		/*************************************************************************************
	    			There are 2 levels of tokenization
	    			1. ID card placement tokenization
	    				Parse through the surrounding text and check for occurences of 
	    				%%FRONT%%
	    				%%BACK%%
	    				These 2 texts are stored in custom labels and can be replaced by admin/developer/adminveloper
	    				and replace them with the strings of front and back respectively
	    				
	    			2. Parse through the update string of surrounding text with front and back HTML and look
	    				for %%xxxx%% notation and replace them with information from the cache class
	    		
	    		Should pass a list of strings and recieve the tokenized list of strings
	    		
	    	***************************************************************************************/
    		if(!sObject_list_knwldgeArticles.isEmpty()){
    		
	    		//Assigning it to the generic sObject
		    	generic_knowledgeArticle = sObject_list_knwldgeArticles[0];
		    		
	    		//assigning based on the request
	    		//if pdf is expected - and is of the type id card, then assign to string, else to generic knowledge article
	    		if(strng_pageRendering != null && articleType_strng == System.Label.ID_Card_Template){
	    			/********************************************************************************
	    			ID card placement tokenization
	    				Parse through the surrounding text and check for occurences of 
	    				%%FRONT%%
	    				%%BACK%%
	    				These 2 texts are stored in custom labels and can be replaced by admin/developer/adminveloper
	    				and replace them with the strings of front and back respectively
	    				
	    			********************************************************************************/
	    			bln_isNonPDFIdCard = false;
	    			//call the tokenization class and pass the 3 strings as parameters
	    			//strng_IdCardTokenizedSurroundingText should be returned with dynamic information
	    			String strng_IdCardTokenizedSurroundingText =  mtd_idCard_positionTokenization(	(String)generic_knowledgeArticle.get('Surrounding_HTML_Text__c'),
	    																						   	(String)generic_knowledgeArticle.get('Front_HTML_tokenized__c'),
	    																							(String)generic_knowledgeArticle.get('Back_HTML_tokenized__c'));
	    			
	    			listOfStringsToDisplay.add(strng_IdCardTokenizedSurroundingText);
	    			System.debug('In if');
	    		}else if(strng_pageRendering == null && articleType_strng == System.Label.ID_Card_Template){
	    			bln_isNonPDFIdCard = true;
	    			//getting the list of fields
		    		fieldQueried_list = fieldsToQuery_strng.split(',');    
		    		
		    		//assigning to the list of strings to pass to the tokenization logic
		    		for(String iterating_field : fieldQueried_list){
		    			listOfStringsToDisplay.add((String)generic_knowledgeArticle.get(iterating_field));
		    		}
		    		System.debug('In else if');		
	    		}else{
	    			System.debug('In else');
					bln_isNonPDFIdCard = false;
		    		//getting the list of fields
		    		fieldQueried_list = fieldsToQuery_strng.split(',');    
		    		
		    		//assigning to the list of strings to pass to the tokenization logic
		    		for(String iterating_field : fieldQueried_list){
		    			listOfStringsToDisplay.add((String)generic_knowledgeArticle.get(iterating_field));
		    		}		
	    		}
	    		/*************************************************************************************************
	    		Parse through the update string of surrounding text with front and back HTML and look
	    				for %%xxxx%% notation and replace them with information from the cache class
	    		*************************************************************************************************/
	    		System.debug('>> The query result is >> ' + listOfStringsToDisplay);
	    		//sending only if the listOfStringsToDisplay is not empty
	    		if(!listOfStringsToDisplay.isEmpty()){
	    			mtd_idCard_infoTokenization();
	    		}
	    	}else{
	    		//Error handling case
	    		//Error_KnowledgeArticle_Setup
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Error_KnowledgeArticle_Setup));
	    	}
	    
    	}catch(Exception exp){
    		//Throw an apex error message
    		//Error_KnowledgeArticle_Setup
    		System.debug('Exception is >> '+ exp.getMessage());
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Error_KnowledgeArticle_Setup));
    	}
    		 
    }
    
    /*********************************************************************************
    Method Name 						: mtd_idCard_positionTokenization
    Purpose								: The following are completed in the method:
    										1. Pass the surrounding text 
    											front text
    											back text
    										2. Replace the surrounding text with front and back fields
    *********************************************************************************/
    
    private string mtd_idCard_positionTokenization( String surroundText, 
    												String frontIDCardText, 
    												String backIDCardText){
    	
    	System.debug('tokenization >>'+ System.Label.BackHTMLTokenizationText + ' >> ' + System.Label.FrontHTMLTokenizationText); 
    	//The replacement texts are stored in the custom labels
    	//Replacing the back side of the card
    	list<String> list_splitSurroundingText = surroundText.split(System.Label.ID_Card_Position_token);
    	String modifiedSurroundText = '';
    	//checking for placeholders
    	if(!list_splitSurroundingText.isEmpty()){
			//parsing throught the list of strings
	    	for(Integer iterating_int = 0; iterating_int < list_splitSurroundingText.size(); iterating_int++){
	    		
	    		//Checking if the text is "front" token
	    		if(list_splitSurroundingText[iterating_int] == System.Label.FrontHTMLTokenizationText)
	    			list_splitSurroundingText[iterating_int] = frontIDCardText;
	    		
	    		//Checking if the text is "back" token
	    		if(list_splitSurroundingText[iterating_int] == System.Label.BackHTMLTokenizationText)
	    			list_splitSurroundingText[iterating_int] = backIDCardText;
				
				//Adding to the text
				modifiedSurroundText += list_splitSurroundingText[iterating_int];	    		
	    	}
	    	list_splitSurroundingText = new list<String>();
    	}else{
    		modifiedSurroundText = surroundText;
    	}
    	return modifiedSurroundText;
    }
    
    /*********************************************************************************
    Method Name 						: mtd_idCard_infoTokenization
    Purpose								: The following are completed in the method:
    										1. Pass the tokenized string
    										2. Look for tokenization character
    										3. Replace them with values/handle the error messages on screen
    										4. Display the ID card with dynamic values
    *********************************************************************************/
    @testVisible private void mtd_idCard_infoTokenization(){
    	
    	System.debug('In info tokenization');
    	//We have to parse throught the list - listOfStringsToDisplay
    	for(Integer iterating_int = 0; iterating_int < listOfStringsToDisplay.size(); iterating_int++){
    		//Our aim to get the fiels from MemberPlans__x and Members__x and provider information from the providers table(Account)
    		list<String> list_splitUsingToken = new list<String>();
    		list_splitUsingToken = listOfStringsToDisplay[iterating_int].split(System.Label.ID_Card_information_token);
    		
    		//iterating through the split list
    		for(Integer iterating_inner_int = 0; iterating_inner_int < list_splitUsingToken.size(); iterating_inner_int++){
    			//checking for the hierarchy token
    			/****************************************************************************
    				So what is this hierarchy token
    				eg you want the member name. In salesforce default 
    				notation it is Member.Name
    				But if the text is not tokenized properly, we might end up 
    				considering sentence completion fullstops as information token
    				To avoid this confusion we are  using a custom delimiter between sObject 
    				and the field information
    				We call this hierarchy delimiter/token
    			*****************************************************************************/
    			//getting  back to where we left -- checking for the hierarchy token
    			if(list_splitUsingToken[iterating_inner_int].indexOf(System.Label.ID_Card_hierarchy_token) != -1){
    				//we know that the delimiter exists, hence splitting it. We will have 2 parts of the information
    				//Information prefix - Member/Provider
    				//Field level information
    				list<String> fieldSplitter_list = new list<String>();
    				fieldSplitter_list = list_splitUsingToken[iterating_inner_int].split(System.Label.ID_Card_hierarchy_token);
    				
    				//Member_Tokenization - keyword used to reference all member related demographic information
    				//MemberPlan_Tokenization - keyword used to reference  all plan related information for the member
    				//Provider_Tokenization - keyword used to reference all the primary provider related information
    				try{
    					if(fieldSplitter_list[0] == System.Label.Member_Tokenization){
    						//getting the values from current member 
    						System.debug('fieldSplitter_list[1]::'+fieldSplitter_list[1]);
    						if(fieldSplitter_list[1]  != System.Label.DateOfBirth_ID_card_check){
	    						if(wmp_util_cache.CurrentMember.get(fieldSplitter_list[1]) != null && ((String) wmp_util_cache.CurrentMember.get(fieldSplitter_list[1])).length() > 0)
	    							list_splitUsingToken[iterating_inner_int] = ((String) wmp_util_cache.CurrentMember.get(fieldSplitter_list[1])).toUpperCase();
	    						else
	    							list_splitUsingToken[iterating_inner_int] = '';	
    						}else{
    							Date inst_date = ((Date) wmp_util_cache.CurrentMember.get(fieldSplitter_list[1]));
								System.debug('Effective date >> ' +  inst_date);
								if(inst_date != null)
									list_splitUsingToken[iterating_inner_int] = inst_date.month()+'.'+inst_date.day()+'.'+inst_date.year();
								else
									list_splitUsingToken[iterating_inner_int] = '';
    						}
    					}
    					else if(fieldSplitter_list[0] == System.Label.MemberPlan_Tokenization){
    						//getting the values from current member plan 
    						//Checking if its effective date or date of birth
    						if(fieldSplitter_list[1] != System.Label.Effective_Date_IDCard_Check){
	    						if(wmp_util_cache.CurrentMemberPlan.get(fieldSplitter_list[1]) != null 
	    							&&
	    							((String) wmp_util_cache.CurrentMemberPlan.get(fieldSplitter_list[1])).length() > 0
	    						)
	    							list_splitUsingToken[iterating_inner_int] = ((String) wmp_util_cache.CurrentMemberPlan.get(fieldSplitter_list[1])).toUpperCase();
	    						else
	    							list_splitUsingToken[iterating_inner_int] = '';
    						}else{
    							if(wmp_util_cache.CurrentMemberPlan.get(fieldSplitter_list[1]) != null){
    								Date inst_date = ((Date) wmp_util_cache.CurrentMemberPlan.get(fieldSplitter_list[1]));
    								System.debug('Effective date >> ' +  inst_date);
    								list_splitUsingToken[iterating_inner_int] = inst_date.month()+'.'+inst_date.day()+'.'+inst_date.year();
    							}else
    								list_splitUsingToken[iterating_inner_int] = '';
    								
							}
    					}else if(fieldSplitter_list[0] == System.Label.Provider_Tokenization){
    						//getting the values from primary provider
    						//Only name of the provider and the contact number of the provider is chosen
    						//checking for name - and fetching from cache class
    						System.debug('fieldSplitter_list[1]::'+fieldSplitter_list[1]);
    						System.debug('fieldSplitter_list[1]::'+System.Label.Provider_Phone);
    						if(fieldSplitter_list[1] ==  System.Label.Provider_Name){
    							if(wmp_util_cache.PrimaryDentist.Name != null && ((String) wmp_util_cache.PrimaryDentist.Name).length() > 0)
    								list_splitUsingToken[iterating_inner_int] = ((String) wmp_util_cache.PrimaryDentist.Name).toUpperCase();
    							else
    								list_splitUsingToken[iterating_inner_int] = '';
    						}
    						//checking for phone - and fetching from cache class
    						if(fieldSplitter_list[1] ==  System.Label.Provider_Phone){
    							if(wmp_util_cache.PrimaryDentist.ServiceLocation.Service_Location__c != null && serviceLocation.Phone != null)
    								list_splitUsingToken[iterating_inner_int] = (String)serviceLocation.Phone;
    							else
    								list_splitUsingToken[iterating_inner_int] = '';
    						}
    						
    					}else if(fieldSplitter_list[0] == System.Label.Plan_Tokenization){
    						//getting the plan name
    						if(fieldSplitter_list[1] == System.Label.Plan_Name_Tokenization){
    							if(((String) wmp_util_cache.getPlanName(planId)).length()> 0)
    								list_splitUsingToken[iterating_inner_int] = ((String) wmp_util_cache.getPlanName(planId)).toUpperCase();
    							else
    								list_splitUsingToken[iterating_inner_int] = '';
    						}
    					}
    				}catch(Exception e){
    					//Error handling
    					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Error_KnowledgeArticle_Setup));
    				}
    			}
    		}
    		String finalString = '';
    		//Adding it back to the final list
    		for(String iterating_string : list_splitUsingToken){
    			//listOfStringsToDisplay[iterating_int] += iterating_string;
    			if(iterating_string.contains('@@'))
                    iterating_string = '';
    			finalString += iterating_string;
    		}	
    		listOfStringsToDisplay[iterating_int] = finalString;
    	}
    }
    /***********************************************************************
	Method name: 	getCurrentMemberPlans
	Return type:	mock_Member__c from cache class
	***********************************************************************/
	@AuraEnabled
	public static list<mock_MemberCoverage__c> fetchCurrentMemberPlans(){ 
		return wmp_util_cache.getCurrentMemberPlans(); 
	}
	/***********************************************************************
	Method name: 	getCurrentMemberPlans
	Return type:	mock_Member__c from cache class
	***********************************************************************/
	@AuraEnabled
	public static Plan_Configuration__mdt fetchCurrentPlanConfiguration(String subgroupID){ 
		//using the method in the benefits class to fetch the account id from the subgroupId
		//Id accountId = wmp_ctrl_myBenefits.fetchRelatedPlanAccountId(subgroupId);
		//System.debug('Id Account Name >> ' +  accountId + ' >> ' +  subgroupId);
		if(subgroupID != null &&  subgroupID != ''){
			try{
	    		Map<String,Plan_Configuration__mdt>	map_allPlans = wmp_util_cache.getPlanConfigurations();
	    		
	    		if(map_allPlans.containsKey(subgroupID.toLowerCase()))
	    			return map_allPlans.get(subgroupID.toLowerCase());
	    		else
	    			return null;
	    	}catch(Exception exp){
	    		return null; 
	    	}
		}else{
			return null;
		}
		//return wmp_util_cache.getMemberPlans().values(); 
	}
	/***********************************************************************
	Method name: 	getCurrentMember
	Return type:	mock_Member__c from cache class
	***********************************************************************/
	@AuraEnabled
	public static mock_Member__c fetchCurrentMember(){ 
		return wmp_util_cache.getCurrentMember();
	}
	/***********************************************************************
	Method name: 	fetchVerifiedMemberPlansAccounts
	Return type:	list of accounts
					There are 2 steps:
					# 1 fetch all the related member plan GUIDs from the cache class
					# 2 fetch the related account Id via a query and display as dropdown
	***********************************************************************/
    @AuraEnabled
    public static list<Account> fetchMemberPlansAccounts(){
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
            system.debug('verifiedMemberPlans ' + set_verifiedMemberPlans);
    		for(Account iterating_account : [		SELECT ID
    												   ,Name
    												   ,guid__c 
    					 				   		FROM ACCOUNT
    									   		WHERE
    									   			guid__c IN:set_verifiedMemberPlans
    									  ]){
    			//build a map with guid as the key
    			map_planGuid_account.put(iterating_account.guid__c, iterating_account);
    		}
    		
    		//reiterating the member plan map to fetch the list of account
    		for(mock_MemberCoverage__c iterating_memberPlan :  wmp_util_cache.getCurrentMemberPlans()){
    			//getting the concerned account based on planguid
    			system.debug('accmap: ' + map_planGuid_account);
    			Account inst_account = map_planGuid_account.get(iterating_memberPlan.PlanGuid__c);
    			String orginalAccountName = inst_account.Name;
    			//adding the name of the person to the account name
    			inst_account.Name = wmp_util_cache.getMemberName(iterating_memberPlan.SubscriberID__c, iterating_memberPlan.PlanGuid__c) + System.Label.s_Plan + '(' + inst_account.Name + ')';
    			System.debug(inst_account.Name);
    			list_verifiedPlanAccounts.add(inst_account);
    			//inst_account.Name = orginalAccountName;
    			Account temp_account = new Account(Id = inst_account.Id,
    											   Name = orginalAccountName,
    											   guid__c = inst_account.guid__c
    												);	
    			map_planGuid_account.put(inst_account.guid__c, temp_account);
    		}
    		
    		return list_verifiedPlanAccounts;
    	}catch(Exception exp){
            system.debug(exp.getStackTraceString());
    		return null;
    	}
    } 
}