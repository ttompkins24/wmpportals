/*******************************************************************************************************
Name 						: Prov_ctrl_Dentist_List
Purpose						: Apex controller for Broken Appointment lightning components
								
Created on					: February 2018
Developed by				: West Monroe Partners
History
Version#		Sprint#		Date					by  							Comments
1.0				3.0			February 2018		West Monroe Partners					See header - purpose
 
*******************************************************************************************************/


public without sharing class prov_ctrl_Dentist_List {


	@AuraEnabled
	public static Account getAllBusinessesDentistList(String businessId){
		Account bizAcct = prov_util_DAL.getAccountsById(new Set<String>{businessId})[0];
		return bizAcct;
	}

    @AuraEnabled
    public static List<Account> getAllProvDentistListBiz(Id bizAcctId){
        today = Date.today();
       
        List<Account> provAcctList = prov_util_Cache.retrieveProviders(bizAcctId, today);
        return provAcctList;
    }

    

	@AuraEnabled
	public static List<Account> getAllLocationsDentistList(String bizAcctId, String locAcctId, String pageNumS, String numResultsS, String fieldS, String directionS){
        today = Date.today();
        List<String> locAcctIDList = new List<String>();
        locAcctIDList = prov_util_Cache.retrieveActiveServiceLocationIds(bizAcctId);

        //add sorting
        String whereClause = 'SELECT id, Name, BillingStreet, Service_Location_Name__c, BillingCity, BillingState, BillingPostalCode, Phone';
        whereClause +=              ' FROM Account'; 
        whereClause += ' WHERE Id IN :locAcctIDList ORDER BY Name ASC';

        List<Account> locAcctList = Database.query(whereClause);

		return locAcctList;

	}
	
	@AuraEnabled
	public static Map<String, List<object>> getLocationsAndProviders(String bizAcctId, String locAcctId, String provAcctId){
		System.debug('bizAcctId::'+bizAcctId);
		System.debug('locAcctId::'+locAcctId);
		System.debug('provAcctId::'+provAcctId);
        //initialize the variables
        List<String> locAcctIDList = new List<String>();
        List<String> provAcctIDList = new List<String>();
        Map<String, List<object>> resultMap = new Map<String, List<object>>();
        
        if((locAcctId == null || locAcctId == 'Any') && (provAcctId == null || provAcctId == 'Any')){
            locAcctIDList = prov_util_Cache.retrieveActiveServiceLocationIds(bizAcctId);
        	provAcctIDList = prov_util_Cache.retrieveProviderIdsByBusinessId(bizAcctId);
        } else if(locAcctId != null && locAcctId != 'Any' && provAcctId != null && provAcctId != 'Any'){ //both service location and provider are selected
        	locAcctIDList.add(locAcctId);
        	provAcctIDList.add(provAcctId);
		}else {
        	if(locAcctId == null  || locAcctId == 'Any' ){//provider is selected
	        	provAcctIDList.add(provAcctId);
	        	locAcctIDList = prov_util_Cache.BusinessId2Provider2LocationMap.get(bizAcctId).get(provAcctId);
        	} else {//location is selected and provider is null
	        	locAcctIDList.add(locAcctId);
	        	provAcctIDList = prov_util_Cache.retrieveProviderIdsByBusinessId(bizAcctId);
        	}
        }
        System.debug('locAcctIDList::'+locAcctIDList);
        System.debug('provAcctIDList::'+provAcctIDList);
        
        //add sorting
        List<Account> serviceLocations = [SELECT id, Name, BillingStreet, Service_Location_Name__c, BillingCity, BillingState, BillingPostalCode, Phone
        								 FROM Account
        								 WHERE Id IN:locAcctIDList ORDER BY Name ASC limit 1000];
        								 
        List<Providers_Service_Locations__c> pslList = [SELECT id, Name, Provider__c, Provider__r.Id, Provider__r.Name, Service_Location__c, 
        								Service_Location__r.BillingStreet, Service_Location__r.BillingCity, Service_Location__r.BillingState, 
        								Service_Location__r.BillingPostalCode, Service_Location__r.Phone, Provider__r.npi__c, Business__c
						   				 FROM Providers_Service_Locations__c  
						    			WHERE Business__c = :bizAcctId AND Service_Location__c IN:locAcctIDList AND Provider__c IN:provAcctIDList
						    			AND Effective_Date__c <= TODAY AND (termination_date__c >= TODAY OR termination_date__c = null)
						    			ORDER BY Provider__r.Name ASC limit 40000];
		System.debug('pslList size::'+pslList.size());
		resultMap.put('locations', serviceLocations);
		resultMap.put('providers', pslList);
		return resultMap;

	}


	@AuraEnabled
	public static List<Account> getAllProvDentistList(String bizAcctId, String locAcctId){

        today = Date.today();
        List<Account> provAcctList = new List<Account>();
        if(locAcctId == null || locAcctId == 'Any'){
            provAcctList = prov_util_Cache.retrieveProviders(bizAcctId, today);
        }
        else{
            provAcctList = prov_util_Cache.retrieveProviders(bizAcctId, locAcctId, today);
        }
        
		return provAcctList;
	}



    @AuraEnabled
    public static Date today {get;set;}

	
}