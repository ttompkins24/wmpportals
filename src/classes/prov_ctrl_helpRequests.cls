/**********************************************************************************************************************
Name 						: prov_ctrl_helpRequests
Purpose						: The controller for the component that displays the help requests page
Created on					: January 2018
Developed by				: West Monroe Partners
History
Version#		Sprint#		Date							By  						Comments
1.0				1.0			January 2018				West Monroe Partners		See header - purpose
  

**********************************************************************************************************************/
public without sharing class prov_ctrl_helpRequests {
    
    /********************************************************************************************************************
	Method name 							: fetch_relatedCaseDetails
	Purpose									: There are 3 steps
											  1. Get the verified member plans and their related User plan verification records
											  2. Get the related member contact records
											  3. Fetch all the related case details on this record
											   
	********************************************************************************************************************/
	@AuraEnabled
    public static list<Case> fetch_relatedCaseDetails(String businessId, String limitValue, String pageNum, String sortByField, String sortDirection, String configName, String extraFilters){
    	System.debug('Extra params :: '+extraFilters);
    	Map<String, Object> extraParamMap = (Map<String, Object>)JSON.deserializeUntyped(extraFilters);
    	System.debug('Extra params map:: '+extraParamMap);
    	
		businessId = businessId.substring(0,15);
    	if( sortByField == null)
    		sortByField = 'CreatedDate';
    	if(sortDirection == null)
    		sortDirection = 'DESC';
    	if(pageNum == null)
    		pageNum = '1';
    	System.debug('pageNum::'+pageNum);
    	Integer pageNumInt = Integer.valueOf(pageNum);
    	if(limitValue == null)
    		limitValue = '20';	
    	Integer limitValueNum = Integer.valueOf(limitValue);
    	
    	list<Case> list_relatedCases = new list<Case>();
    	list<Case> list_relatedCasesTemp = new list<Case>();
    	
		//get related service locations
		List<Id> serviceLocIds = prov_util_Cache.BusinessIdToLocationIds.get(businessId);
		
		//get related providers
		List<Id> providerIds = prov_util_Cache.BusinessIdToProviderIds.get(businessId);
    	
		System.debug('configName::'+configName);
        List<String> caseTypes = new List<String>();
        for(Portal_Picklist__mdt pp : [SELECT id, Value__c FROM Portal_Picklist__mdt WHERE Provider_Portal_Configuration__r.DeveloperName =:configName AND Type__c ='Case Type']){
            caseTypes.add(pp.Value__c);
        }
        System.debug('caseTypes::'+caseTypes);
        
       prov_util_Permissions permission = prov_util_Cache.cobj.businessId2PermissionsMap.get(businessId);
        //add case types for other types
        if(permission.claims == 'full'){
        	caseTypes.add('Claim Appeal');
        	caseTypes.add('Claim Void');
        }
        if(permission.preAuth == 'full')
        	caseTypes.add('Authorization & Estimate Appeal');
        if(permission.dentistList == 'full')
        	caseTypes.add('Detail Update');
        if(permission.eft == 'full')
	        caseTypes.add('EFT Enrollment/Update/Cancellation');
    	
    	/*//get available record types
    	List<String> recTypeNames = new List<String>{'Void_Claim'};//should only have the developer name (no spaces)
    	List<Id> recordTypeIds = new List<Id>();
    	for(RecordType recType : [SELECT id FROM RecordType WHERE SobjectType='Case' AND DeveloperName IN:recTypeNames]){
    		recordTypeIds.add(recType.Id);
    	}*/
    	
		String orderBy  = ' ORDER BY ' + sortByField + ' ' + sortDirection;
		//adding limitValue
		//orderBy += ' LIMIT ' + limitValue;
		orderBy += ' LIMIT ' + 1000;
		//adding offsetValue
		//orderBy += ' OFFSET ' + ((pageNumInt-1) * limitValueNum);
		
		//list is now populated for the related contact
		list_relatedCases = prov_util_DAL.retrieveCases_helpRequest(businessId, serviceLocIds, providerIds, extraParamMap, caseTypes, orderBy);
		System.debug(list_relatedCases.size() + '^^^^^^^^^^^^^^^^^^^^^ '+ list_relatedCases + '#################');
    	
    	totalNumRecords = list_relatedCases.size();
    	
    	totalPages = Integer.valueOf( (Decimal.valueOf( totalNumRecords ) / limitValueNum).round(System.RoundingMode.UP) );
        totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1
	    	
    		//iterating through the cases
    	for(Integer i = (pageNumInt-1) * limitValueNum ; i < list_relatedCases.size(); i++){
    		if(list_relatedCases[i].Description != null ){
                Integer indexOfStar = list_relatedCases[i].Description.indexOf('******');
                if(indexOfStar > 0)
                	list_relatedCases[i].Description = list_relatedCases[i].Description.substring(0, indexOfStar);
                
                if(list_relatedCases[i].Description.length() > 80){
                	list_relatedCases[i].Description = list_relatedCases[i].Description.substring(0,79) + System.label.more;
                }
            }
    		list_relatedCasesTemp.add(list_relatedCases[i]);
    		if(list_relatedCasesTemp.size() == limitValueNum)
    			break;
    	}
    	System.debug('list_relatedCasesTemp::'+list_relatedCasesTemp);
    	return list_relatedCasesTemp;
    }	
    
    @AuraEnabled
	public static Integer totalPages {get;set;}
	
	@AuraEnabled 
	public static Integer totalNumRecords {get;set;}
	
	@AuraEnabled
    public static List<Integer> paginationVariables(){
        //intitalize variables
        List<Integer> paginationVars = new List<Integer>();
        
        //add the results to the list to return
        paginationVars.add(totalPages);
        paginationVars.add(totalNumRecords);
        //return the list
        return paginationVars;
    }      
    /********************************************************************************************************************
	Method name 							: fetch_relatedContacts
	Purpose									: 
	********************************************************************************************************************/
	@testVisible
	private static set<Id> fetch_relatedContacts(){
		set<id> set_relatedContact = new set<Id>(); 
		//what are the parameters for provider level
    	
    	List<Contact> cons = [SELECT id, Name FROM Contact];
    	for (Contact con : cons){
    		set_relatedContact.add(con.id);
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