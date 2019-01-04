/**********************************************************************************************************************
Name 						: wmp_ctrl_helpRequests
Purpose						: The controller for the component that displays the help requests page
Created on					: 10th October 2017
Developed by				: Santosh Kumar Sriram
History
Version#		Sprint#		Date							By  						Comments
1.0				1.0			10th October 2017				Santosh Kumar Sriram		See header - purpose
  

**********************************************************************************************************************/
public without sharing class wmp_ctrl_helpRequests {
    
    /********************************************************************************************************************
	Method name 							: fetch_relatedCaseDetails
	Purpose									: There are 3 steps
											  1. Get the verified member plans and their related User plan verification records
											  2. Get the related member contact records
											  3. Fetch all the related case details on this record
											   
	********************************************************************************************************************/
	@AuraEnabled
    public static list<Case> fetch_relatedCaseDetails(Integer limitValue, Integer offsetValue){
    	list<Case> list_relatedCases = new list<Case>();
    	//to get all the related contacts
    	set<id> set_relatedContact = fetch_relatedContacts();
    	System.debug(set_relatedContact);
    	//constructing the where clause of the query
    	if(!set_relatedContact.isEmpty()){
    		String orderBy  = ' ORDER BY Status DESC, CreatedDate DESC ';
    		//adding limitValue
    		orderBy += ' LIMIT ' + limitValue;
    		//adding offsetValue
    		orderBy += ' OFFSET ' + offsetValue;
    		//list is now populated for the related contact
    		list_relatedCases = wmp_util_DAL.retrieveCases(new List<Id>(set_relatedContact), orderBy);
    		System.debug(list_relatedCases.size() + '^^^^^^^^^^^^^^^^^^^^^ '+ list_relatedCases + '#################');
    	}
    	
    		//iterating through the cases
    	for(Case iterating_case :list_relatedCases){
    		if(iterating_case.Description != null && iterating_case.Description.length() > 80)
    			iterating_case.Description = iterating_case.Description.substring(0,79) + System.label.more;
    	}
    	return list_relatedCases;
    }
    
    /********************************************************************************************************************
	Method name 							: fetch_relatedContacts
	Purpose									: 1. Get the related member contact records
	********************************************************************************************************************/
	@testVisible
	private static set<Id> fetch_relatedContacts(){
		set<id> set_relatedContact = new set<Id>(); //used to get the related contact to whom the cases are associated to
    	//getting all the related member coverage and the user verficiations record
    	//via the wmp_util_cache.MemberGuidToPlanVerfication. this returns the map<string,id>
    	//the key is the membercoverage guid.
    	//we get the user plan verfication ids
    	//we dont have to query for user plan verification records
    	//we can use the wmp_util_cache.VerifiedPlans to get the related user plan verfication records
    	//iterating through the list of MemberGuidToPlanVerfication
    	for(Id iterating_userPlanVerificationId : wmp_util_cache.MemberGuidToPlanVerification.values()){
    		//every value is the id of the user plan verification
    		if(wmp_util_cache.VerifiedPlans.containsKey(iterating_userPlanVerificationId)){
    			//getting the member contacts ids from the same.
    			if(wmp_util_cache.VerifiedPlans.get(iterating_userPlanVerificationId).Member_Contact__c != null)
    				set_relatedContact.add(wmp_util_cache.VerifiedPlans.get(iterating_userPlanVerificationId).Member_Contact__c);
    		}
    	}
    	
    	return set_relatedContact;
	}
	
	
    /********************************************************************************************************************
	Method name 							: fetch_countOfCases
	Purpose									: 1. Get the related member contact records
											  2. Get the case count
	********************************************************************************************************************/	
	@AuraEnabled
	public static Integer fetch_countOfCases(){
		//to get all the related contacts
		Integer totalResults = 0;
    	set<id> set_relatedContact = fetch_relatedContacts();
    	if(!set_relatedContact.isEmpty()){
    		//now getting the total count
    		totalResults						= [SELECT 
    														COUNT()
    												FROM
    														CASE
    												WHERE
    														ContactId in:set_relatedContact 
    											   ];
    	}
    	return totalResults;
	}
}