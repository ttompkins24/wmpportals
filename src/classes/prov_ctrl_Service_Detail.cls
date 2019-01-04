public without sharing class prov_ctrl_Service_Detail {
	@AuraEnabled
	public static Account getServiceLocationbyId(Id servLocId){
        //populate strings with values for DAL query        
        String limitNum = ' LIMIT 1';

        List<Account> serviceOfficeResult = new List<Account>();

        serviceOfficeResult = queryServiceOffice(servLocId,limitNum);
        system.debug('serviceOfficeResult apex: '+serviceOfficeResult[0]);
        return serviceOfficeResult[0];
    }

    @AuraEnabled
    public static String getExistingCaseApex(Id servLocId, Id currentBusinessId) {
        String retVal = null;
        try {
            retVal = [SELECT Id FROM Case WHERE Business_lkup__c =: currentBusinessId AND Service_Location__c =: servLocId AND Subject = 'Service Office Detail Update' AND IsClosed = false LIMIT 1].Id;
        } catch(exception e) {
            system.debug('unable to retrieve existing case: '+ e);
        }
        system.debug('existing case Id: '+retVal);
        return retVal;
    }

	@AuraEnabled
    public static List<Providers_Service_Locations__c> getDentistPSLs(String locAcctId, String fieldS, String directionS, String currentBusinessId) {
        //populate strings with values for DAL query
        currentBusinessId = currentBusinessId.substring(0,15);
        String limitNum = ' LIMIT 1';
        String orderBy = '';
        if(fieldS != null || directionS != null){
            orderBy = ' ORDER BY '+fieldS+' '+directionS;
        }

        system.debug('orderBy apex: '+orderBy);
        List<Providers_Service_Locations__c> dentistResult = queryDentists(locAcctId, currentBusinessId);

        //dentistResult = queryDentists(locAcctId,orderBy);
        system.debug('dentistResult apex: '+dentistResult);
        
        return dentistResult;
    }
    
    private static List<Account> queryServiceOffice(String recordId, String limitNum) {
        String whereClause = ' WHERE Id = \'' + recordId + '\'';
        whereClause += limitNum;
        return (List<Account>)prov_util_DAL.dalQuery('Account', whereClause);
    }

    private static List<Providers_Service_Locations__c> queryDentists(String locationId, String currentBusinessId){
        // retrieve all active PSLs available for the current location
        Set<String> serviceLocationIds = new Set<String>{locationId};
        Set<String> businessIdSet = new Set<String>{currentBusinessId};
        Set<String> providerAccountIds = new Set<String>();
        for(Account provAcct : prov_util_Cache.retrieveProviders(currentBusinessId, locationId, Date.today())) {
            providerAccountIds.add(provAcct.Id);
        }
        List<Providers_Service_Locations__c> returnList = prov_util_DAL.retrievePSL_WDate(providerAccountIds, serviceLocationIds, businessIdSet, Date.today());

        //sort returnlist
        returnList.sort();
        return returnList;
    }
}