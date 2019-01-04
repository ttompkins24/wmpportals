/*
/*******************************************************************************************************
Name 						: prov_ctrl_Dentist_Detail
Purpose						: Controller for the prov_comp_Dentist_Detail  
							  Displays dentist details and related records
Created on					: 19th February 2018
Developed by				: West Monroe Partners
History
Version#		Sprint#		Date					by  							Comments
1.0				3.0			19th February 2018		West Monroe Partners			See header - purpose
 
*******************************************************************************************************
*/
public without sharing class prov_ctrl_Dentist_Detail {

    @AuraEnabled
    public Static PicklistDescribe getFieldPicklistValues(String objectApiName, String fieldApiName){

        PicklistDescribe picklistDescribe = new PicklistDescribe();
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName)
                                                                              .newSObject()
                                                                              .getSObjectType()
                                                                              .getDescribe()
                                                                              .fields.getMap();       
 
        Schema.DescribeFieldResult field = fieldMap.get(fieldApiName).getDescribe();
        String fieldLabel = field.getLabel();
        List<Schema.PicklistEntry>  picklistValues = field.getPickListValues();
          
        List<PickListOption> options = new List<PickListOption>();
        for (Schema.PicklistEntry picklistValue : picklistValues){
            PickListOption option = new PickListOption();
            option.label = picklistValue.getLabel(); 
            option.value = picklistValue.getValue();
            option.isActive = picklistValue.isActive();
            option.isDefaultValue = picklistValue.isDefaultValue();
            options.add(option);
            if(option.isDefaultValue) picklistDescribe.defaultValue = option.label; 
        }
        
        picklistDescribe.apiName = fieldApiName;
        picklistDescribe.label = fieldLabel;
        picklistDescribe.options = options;
        
        return picklistDescribe;
    }  


	@AuraEnabled
	public static DentistDetailWrapper getDentistApex(String psl_id, String businessId){
		DentistDetailWrapper wrapper = new DentistDetailWrapper();
 
 		// Get networks
 		Set<Id> networkIds = new Set<Id>();
 		Providers_Service_Locations__c psl = [SELECT Id, is_treating_special_needs_patients__c, is_accepting_new_patients__c, Languages_Spoken__c, Gender__c, treats_ages_to__c, Specialties__c, treats_ages_from__c, Service_Location_Phone__c, Name, 
 			Provider_Service_Location_Comments__c, Provider__r.Email__c, 

 			Service_Location__r.Id, Service_Location__r.Address__c, Service_Location__r.npi__c, Service_Location__r.Website,
            Service_Location__r.BillingCity, Service_Location__r.BillingState, Service_Location__r.BillingPostalCode, Service_Location__r.BillingStreet, 
 			
 			Provider__r.Id, Provider__r.degree__c, Provider__r.birth_date__c, Provider__r.gender__c,
 			Provider__r.first_name__c, Provider__r.middle_name__c, Provider__r.last_name__c,
 			Provider__r.Name, Provider__r.name_suffix__c, Provider__r.Provider_Affiliation__c, Provider__r.board_cert_name__c,
            Provider__r.board_cert_date__c, Provider__r.certification_status__c, Provider__r.is_board_certified__c,
 			Provider__r.Education__c, Provider__r.npi__c
            
 			FROM Providers_Service_Locations__c 
 			WHERE Id =: psl_id AND Business__c =:businessId LIMIT 1];
 		

        List<Providers_Service_Locations_Networks__c> psl_networks = [SELECT Id, Network__r.Name, Network__r.Effective_Date__c, Network__r.Termination_Date__c, Network__r.Network_Name__c, Network__r.Network_Type__c,
            is_accepting_new_patients__c, termination_date__c, effective_date__c, participation_status__c, Network__r.Id
            FROM Providers_Service_Locations_Networks__c 
            WHERE Provider_Service_Location__r.Id =: psl.Id ORDER BY Network__r.Name ASC];
		
        //get the available service locations for this dentist
        List<String> locAcctIDList = prov_util_Cache.retrieveServiceLocationIdsByBusinessId(businessId);
        
        wrapper.provider_licenses = [SELECT Id, Name, license_state__c, license_type__c, license_id__c
            FROM Provider_License__c WHERE Provider__c =: psl.Provider__r.Id ORDER BY license_type__c];
		wrapper.psl_networks = psl_networks;
		wrapper.psl = psl;

	    // get other locations without the current
	    wrapper.other_locations = [SELECT Id, is_accepting_new_patients__c, Languages_Spoken__c, Gender__c, treats_ages_to__c, Specialties__c, treats_ages_from__c, 
	    	Service_Location_Phone__c, Name, Provider__r.Id, Service_Location__r.Id, Service_Location__r.Name,
	    	Service_Location__r.BillingCity, Service_Location__r.BillingState, Service_Location__r.BillingStreet, Service_Location__r.BillingPostalCode
	    	FROM Providers_Service_Locations__c WHERE Business__c=:businessId AND Service_Location__c IN:locAcctIDList AND Provider__r.Id =: psl.Provider__r.Id AND Id != :psl.Id];

		List<Case> cases = [SELECT Id, Notes__c, Case_Update_JSON__c, Status, Type, SubType__c
			FROM Case 
			WHERE Status = 'New' AND Origin != 'Draft' AND Providers_Service_Locations__c =: psl_id];

		if(cases != NULL && cases.size() > 0) {
			wrapper.caseUpdate = cases[0];
		} 

        wrapper.languagesPicklists = getFieldPicklistValues('Providers_Service_Locations__c', 'Languages_Spoken__c');
		
		return wrapper;  
	}

	/**
	 * Creates a case which represents an update request
	 */
	@AuraEnabled
	public static Case saveDentistUpdateApex(String psl_id, String updateJSON, String notes, String caseId, String business_id){
 		Case updateCase;

        if(caseId != NULL) {
            updateCase = [SELECT Id, Service_Location__c, Provider__c, Route_To__c, Business_lkup__c, RecordTypeId, 
                ContactId, Providers_Service_Locations__c, Practice_Management_Updates__c, AccountId,
                Notes__c, Status, Origin, Type, Subject, SubType__c FROM Case WHERE Id =: caseId];
        } else {
            updateCase = new Case();
        }

        Account acc = [SELECT Name, Id FROM Account WHERE Id =: business_id LIMIT 1];
        Providers_Service_Locations__c psl = [SELECT Id, Name, Provider__c, Provider__r.Name, Service_Location__c, Service_Location__r.Name 
            FROM Providers_Service_Locations__c WHERE Id =: psl_id LIMIT 1];

        updateCase.Provider__c = psl.Provider__c;
        updateCase.AccountId = psl.Service_Location__c;
        updateCase.Service_Location__c = psl.Service_Location__c;

        updateCase.Business_lkup__c = business_id;
        updateCase.Business__c = acc.Name;
        Id recordTypeId = [select Id from RecordType where DeveloperName = 'Practice_Management' limit 1].Id;
        updateCase.RecordTypeId = recordTypeId;
        Contact con = prov_util_Cache.ContactRec;
        updateCase.Route_To__c = 'Provider Operations';
        updateCase.ContactId = con.Id;
		updateCase.Providers_Service_Locations__c = psl_id;
        updateCase.Practice_Management_Updates__c = prov_util_JSON.formatJSON(updateJSON, false);
        updateCase.Notes__c = notes;
        updateCase.Status = 'New';
        updateCase.Origin = 'Provider Portal';
        updateCase.Type = 'Dentist Change';
        updateCase.Subject = 'Provider Detail Update';
        updateCase.SubType__c = 'Updates';
        upsert updateCase;

		return updateCase;
	}

    /**
     * Creates a case which represents an update request
     */
    @AuraEnabled
    public static Case saveDentistWrapperApex(String psl_id, String business_id){
        Case updateCase = new Case();

        Account acc = [SELECT Name FROM Account WHERE Id =: business_id LIMIT 1];
        Providers_Service_Locations__c psl = [SELECT Id, Name, Provider__c, Provider__r.Name, Service_Location__c, Service_Location__r.Name 
            FROM Providers_Service_Locations__c WHERE Id =: psl_id LIMIT 1];

        updateCase.Provider__c = psl.Provider__c;
        updateCase.AccountId = psl.Service_Location__c;
        updateCase.Service_Location__c = psl.Service_Location__c;

        updateCase.Business_lkup__c = business_id;
        updateCase.Business__c = acc.Name;
        
        Id recordTypeId = [select Id from RecordType where DeveloperName = 'Practice_Management' limit 1].Id;
        updateCase.RecordTypeId = recordTypeId;
        Contact con = prov_util_Cache.ContactRec;
        updateCase.Route_To__c = 'Provider Operations';
        updateCase.ContactId = con.Id;
        updateCase.Providers_Service_Locations__c = psl_id;
        updateCase.Status = 'New';
        updateCase.Origin = 'Draft';
        updateCase.Type = 'Dentist Change';
        updateCase.Subject = 'Provider Detail Update';
        updateCase.SubType__c = 'Updates';
        upsert updateCase;

        return updateCase;
    }

    @AuraEnabled
    public static String getExistingCaseApex(Id currentBusinessId, Id providerId) {
        String retVal = null;
        try {
            retVal = [SELECT Id FROM Case WHERE Business_lkup__c =: currentBusinessId AND Provider__c =: providerId AND Subject = 'Provider Detail Update' AND IsClosed = false LIMIT 1].Id;
        } catch(exception e) {
            system.debug('unable to retrieve existing case: '+ e);
        }
        system.debug('existing case Id: '+retVal);
        return retVal;
    }
    
	/* wrapper class for the dentist information */
    public class DentistDetailWrapper {
    	@AuraEnabled public List<Providers_Service_Locations_Networks__c> psl_networks;
    	@AuraEnabled public prov_wrap_DentistList_Provider wrapper; 
        @AuraEnabled public Providers_Service_Locations__c psl;
        @AuraEnabled public List<Providers_Service_Locations__c> other_locations;
        @AuraEnabled public List<Provider_License__c> provider_licenses;
        @AuraEnabled public PicklistDescribe languagesPicklists;
        @AuraEnabled public Case caseUpdate;
    }

    public class PicklistDescribe {
        @AuraEnabled public String apiName;
        @AuraEnabled public String label;
        @AuraEnabled public String defaultValue;
        @AuraEnabled public List<PickListOption> options;
    }

    public class PickListOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public Boolean isDefaultValue;
        @AuraEnabled public String extras;
    }
}