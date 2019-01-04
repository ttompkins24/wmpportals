public with sharing class prov_ctrl_ServiceOfficeEdit {
    @AuraEnabled
    public static Account getServiceOfficeInfoDetail(String recordId) {
        //populate strings with values for DAL query
        
        String limitNum = ' LIMIT 1';

        List<Account> serviceOfficeResult = new List<Account>();

        serviceOfficeResult = queryServiceOffice(recordId,limitNum);
        system.debug('serviceOfficeResult apex: '+serviceOfficeResult[0]);
        return serviceOfficeResult[0];
    }

    @AuraEnabled
    public static List<Account> getAllAvailableDentists(String currentBusinessId, String currentLocationId) {
        // retrieve all available providers for the business
        List<Account> availableDentistsResult = new List<Account>();
        Map<Id,Account> allBusinessProviderMap = new Map<Id,Account>();
        Map<Id,Account> existingLocationProviderMap = new Map<Id,Account>();
        
        for(Account provAcct : prov_util_Cache.retrieveProviders(currentBusinessId)) {
            allBusinessProviderMap.put(provAcct.Id, provAcct);
        }
        system.debug('allBusinessProviderMap: '+allBusinessProviderMap);

        // retrieve all active PSLs available for the current location
        for(Account provAcct : prov_util_Cache.retrieveProviders(currentBusinessId, currentLocationId, Date.today())) {
            existingLocationProviderMap.put(provAcct.Id, provAcct);
        }
        // loop through and remove already added providers
        for(Id provAcctId : allBusinessProviderMap.keyset()) {
            if(!existingLocationProviderMap.containsKey(provAcctId)) {
                availableDentistsResult.add(allBusinessProviderMap.get(provAcctId));
            }
        }
        system.debug('availableDentistsResult apex: '+availableDentistsResult);
        availableDentistsResult.sort();
        return availableDentistsResult;
    }

    @AuraEnabled
    public static Case saveServiceOfficeUpdateApex(String updateJSON, Id officeId, String notes, Id businessId) {
        system.debug('update service office');

        Id recordTypeId = [select Id from RecordType where DeveloperName = 'Practice_Management' limit 1].Id;
        Contact con = prov_util_Cache.ContactRec;

        Case updateCase = new Case();

        updateCase.Case_Update_JSON__c = updateJSON;
        updateCase.Practice_Management_Updates__c = prov_util_JSON.formatJSON(updateJSON,false);
        updateCase.ContactId = con.Id;
        updateCase.Origin = 'Provider Portal';
        updateCase.Status = 'New';
        updateCase.Type = 'Dentist Change';
        updateCase.SubType__c = 'Updates';
        updateCase.Subject = 'Service Office Detail Update';
        updateCase.Route_To__c = 'Provider Operations';
        updateCase.Notes__c = notes;
        updateCase.Service_Location__c = officeId;
        updateCase.AccountId = officeId;
        updateCase.RecordTypeId = recordTypeId;
        updateCase.Business_lkup__c = businessId;
        try {
			insert updateCase;

			updateCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :updateCase.Id];
			return updateCase;
		} catch(Exception ex) {
			System.debug('Error draft::'+ex.getMessage());
            System.debug(ex.getStackTraceString());
    		System.debug('Error draft Line Number::'+ex.getLineNumber());
		}		
        return null;
    }

    private static List<Account> queryServiceOffice(String recordId, String limitNum) {
        String whereClause = ' WHERE Id = \'' + recordId + '\'';
        whereClause += limitNum;
        return (List<Account>)prov_util_DAL.dalQuery('Account', whereClause);
    }
}