/*******************************************************************************************************
Name 						: Prov_ctrl_BLPpicklists
Purpose						: Apex controller for Prov_ctrl_BLPpicklists lightning component
								
Created on					: 10 Jan 2018
Developed by				: West Monroe Partners
History
Version#		Sprint#		Date					by  							Comments
1.0				1.0			10 Jan 2018				West Monroe Partners			See header - purpose
 
*******************************************************************************************************/ 
public with sharing class Prov_ctrl_BLPpicklists {
	//get the current business
	@AuraEnabled
	public static Account getBusiness(){
		System.debug('current business ' + prov_util_Cache.currentBusiness);
		return prov_util_Cache.currentBusiness;
	}

	//get all locations available to the selected business
	@AuraEnabled
	public static List<Account> getAllLocationsPanelRoster(Id bizAcctID){
		
		List<Account> locAcctList = prov_util_Cache.retrieveServiceLocation(bizAcctID);
		return locAcctList;
	}

	//get all providers available for the selected business and service location
	@AuraEnabled
	public static List<Account> getAllProvidersPanelRoster(Id bizAcctId, Id locAcctId){
		List<Account> provAcctList = prov_util_Cache.retrieveProviders(bizAcctId, locAcctId);
		return provAcctList;
	}

	//get service location record by passing in service location id
	@AuraEnabled
	public static Account getServiceLocationRecord(Id serviceLocationId){
		List<Account> acct = prov_util_DAL.getAccountsById(new Set<String>{serviceLocationId});		
		return acct.get(0);
	}	

	//get provider record by passing in provider id
	@AuraEnabled
	public static Account getProviderRecord(Id providerId){
		List<Account> acct = prov_util_DAL.getAccountsById(new Set<String>{providerId});		
		return acct.get(0);
	}

}