public without sharing class prov_ctrl_File_Case {
	@AuraEnabled
	public static List<Map<String, String>> retrieveCaseTypeInfo() {
    	return util_retrievePicklistValues('Case Type', 'English');
	}

	@AuraEnabled
	public static Map<String,Provider_Case_Setting__mdt> retrieveCaseSettingMap() {
		return util_retrieveProviderCaseSettingsMap();
	}

	@AuraEnabled
	public static Map<String,List<String>> retrieveCaseFieldValuesApex() {
		Map<String,List<String>> optionsMap = new Map<String,List<String>>();
		List<String> timeOptions = new List<String>();
		List<String> zoneOptions = new List<String>();

		// retrieve time field values
		Schema.DescribeFieldResult timeFieldResult = Case.Requested_Contact_Time__c.getDescribe();
		List<Schema.PicklistEntry> timePLE = timeFieldResult.getPicklistValues();
		for(Schema.PicklistEntry timeVal : timePLE) {
			timeOptions.add(timeVal.getLabel());
		}

		// retrieve timezone field values
		Schema.DescribeFieldResult zoneFieldResult = Case.Requested_Contact_Time_Zone__c.getDescribe();
		List<Schema.PicklistEntry> zonePLE = zoneFieldResult.getPicklistValues();
		for(Schema.PicklistEntry zoneVal : zonePLE) {
			zoneOptions.add(zoneVal.getLabel());
		}
		optionsMap.put('times',timeOptions);
		optionsMap.put('zones',zoneOptions);
		system.debug('case picklist values: '+optionsMap);
		return optionsMap;
	}

	@AuraEnabled
	public static Case createDraftCaseApex(Map<String, String> paramMap, Provider_Case_Setting__mdt caseSetting) {
		Case newCase = util_generateCaseShell(paramMap, caseSetting);
		system.debug('caseSetting draft: '+caseSetting);

		// set the origin to draft so we can batch clean them out if the user does not finish creating the case
        newCase.Origin = 'Draft';

		system.debug('newCase draft: '+ newCase);
		try {
			upsert newCase;

			newCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :newCase.Id];
			return newCase;
		} catch(Exception ex) {
			System.debug('Error draft::'+ex.getMessage());
            System.debug(ex.getStackTraceString());
    		System.debug('Error draft Line Number::'+ex.getLineNumber());
		}		
		return null;  
	}

	@AuraEnabled
	public static Case createCaseApex(Map<String, String> paramMap, Provider_Case_Setting__mdt caseSetting, String existingCaseId) {
		Case newCase;
		if(existingCaseId != null) {
			newCase = [SELECT Id FROM Case WHERE Id = : existingCaseId];
		} else {
			newCase = util_generateCaseShell(paramMap,caseSetting);
		}
		system.debug('caseSetting: '+caseSetting);

		// set the origin to provider so we know this is a finalized case
		newCase.Origin = 'Provider Portal';

		system.debug('newCase: '+ newCase);
		try {
			upsert newCase;

			newCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :newCase.Id];
			return newCase;
		} catch(Exception ex) {
			System.debug('Error::'+ex.getMessage());
            system.debug(ex.getStackTraceString());
    		System.debug('Error Line Number::'+ex.getLineNumber());
		}
		return null;
	}

	// create case shell
	private static Case util_generateCaseShell(Map<String, String> paramMap, Provider_Case_Setting__mdt caseSetting) {
		Case newCase = new Case();
		
		newCase.ContactId = prov_util_Cache.ContactRec.Id;

		newCase.Subject = caseSetting.Portal_Picklist__r.Value__c;
		newCase.Type = caseSetting.Case_Type__c;
		newCase.SubType__c = caseSetting.Case_SubType__c;
		newCase.Route_To__c = caseSetting.Route_To__c;
		newCase.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = :caseSetting.Case_Owner__c LIMIT 1].Id;
		newCase.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :caseSetting.Case_Record_Type__c LIMIT 1].Id;

		newCase.Description = paramMap.get('requestDesc');
		newCase.Desired_Resolution__c = paramMap.get('resultDesc');
		newCase.Provider_Portal_Member_First_Name__c = paramMap.get('memberFirstName');
		newCase.Provider_Portal_Member_Last_Name__c = paramMap.get('memberLastName');
		newCase.Member_ID__c = paramMap.get('memberNumber');
		newCase.Service_Location__c = paramMap.get('locationChosen');
		newCase.Provider__c = paramMap.get('providerChosen');
		newCase.AccountId = paramMap.get('locationChosen');
		newCase.Business_lkup__c = paramMap.get('businessId');
		newCase.Claim_Auth__c = paramMap.get('claimAuthNumber');
		newCase.Meeting_Logistics_Phone__c = paramMap.get('phoneNumber');
		if(paramMap.get('contactDate') != null) {
			Date newDate2 = date.valueOf(paramMap.get('contactDate'));
			newCase.Meeting_Logistics_Contact_Date__c = newDate2;
		}	
		newCase.Requested_Contact_Time__c = paramMap.get('timeChosen');
		newCase.Requested_Contact_Time_Zone__c = paramMap.get('zoneChosen');

 		newCase.Status = 'New';
		newCase.Priority = 'Medium';
		newCase.Submitted_By__c = 'Provider';

		return newCase;
	}

	private static Map<String,Provider_Case_Setting__mdt> util_retrieveProviderCaseSettingsMap() {
		String portalLabel = prov_util_Cache.PortalConfiguration.Label;
		Map<String,Provider_Case_Setting__mdt> providerCaseSettingMap = new Map<String,Provider_Case_Setting__mdt>();

		for(Provider_Case_Setting__mdt caseSetting : [SELECT Label, Case_Owner__c, Case_Record_Type__c, Case_SubType__c, Case_Type__c, Portal_Picklist__r.Value__c, Provider_Portal_Configuration__c, Show_Claim_Auth_Number__c, Show_Member_Info__c, Route_To__c, Show_Additional_Meeting_Info__c FROM Provider_Case_Setting__mdt WHERE Provider_Portal_Configuration__r.Label = :portalLabel]) {
			providerCaseSettingMap.put(caseSetting.Portal_Picklist__r.Value__c, caseSetting);
		}
		system.debug('providerCaseSettingMap: '+providerCaseSettingMap);
		return providerCaseSettingMap;
	}

	private static List<Map<String,String>> util_retrievePicklistValues(String picklistType, String language){
		//initialize the picklist values from custom metadata records
		String portalLabel = prov_util_Cache.PortalConfiguration.Label;
		List<Map<String,String>> picklistMap = new List<Map<String,String>>();
		
		for(Portal_Picklist__mdt pPicklist : [SELECT Label, English_Label__c, Spanish_Label__c, English_Description__c, Spanish_Description__c, Value__c, Order__c FROM Portal_Picklist__mdt WHERE Provider_Portal_Configuration__r.Label = :portalLabel AND Type__c =:picklistType ORDER BY Order__c ASC, English_Label__c ASC]) {
			System.debug('pPicklist ::'+pPicklist );
			Map<String, String> pickMap = new Map<String, String>();
			pickMap.put('Value', pPicklist.Value__c);
			if(language == 'English') {
				pickMap.put('Label', pPicklist.English_Label__c);
				if(pPicklist.English_Description__c != null) {
					pickMap.put('Description', pPicklist.English_Description__c);
                }
			}
			picklistMap.add(pickMap);
		}
		
		return picklistMap;
	}
}