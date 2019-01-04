public without sharing class prov_ctrl_Referral_Entry { 

    @AuraEnabled
    public static ClaimWrapper saveClaimApex(Claim__c claim, String businessId){
        
        claim.Service_Date__c = Date.Today();
        claim.Claim_Type__c = 'REFERRAL';

        claim.Last_Eligibility_Check__c = DateTime.now();
        ClaimWrapper wrapper = new ClaimWrapper();
        wrapper.hasError = false;

        Savepoint sp = Database.setSavepoint();

        try {  
            //Set<String> plans = new Set<String>(prov_util_cache.getVisibilePlanWWIds(businessId));
            Prov_ctrl_MemberEligibility.MemberWrapper searchCriteria = new Prov_ctrl_MemberEligibility.MemberWrapper(claim.Service_Date__c, claim.Subscriber_Birth_Date__c, claim.Subscriber_ID__c, claim.Subscriber_First_Name__c, claim.Subscriber_Last_Name__c, null);
            List<mock_MemberCoverage__c> memCovResults = (List<mock_MemberCoverage__c>) prov_util_MemberEligibilityCallout.requestMemberEligibilityInfo(new List<Prov_ctrl_MemberEligibility.MemberWrapper>{searchCriteria}, businessId);

            mock_MemberCoverage__c coverage;
            if(memCovResults != NULL && memCovResults.size() > 0) {
                coverage = memCovResults[0];
            }


            Account location = [SELECT Id, Name, first_name__c, last_name__c, guid__c, npi__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
                FROM Account WHERE Id =: claim.Service_Location__c LIMIT 1];

            Account provider = [SELECT Id, Name, first_name__c, last_name__c, guid__c, npi__c, 
                BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
                FROM Account WHERE Id =: claim.Provider__c LIMIT 1];
            
            List<Provider_License__c> licenses = [SELECT Id, license_id__c FROM Provider_License__c 
                WHERE license_type__c = 'dental' AND license_state__c =: location.BillingState AND Provider__c =: provider.Id];

            if(licenses != NULL && licenses.size() > 0) {
                claim.Treating_Provider_License_Number__c = licenses[0].license_id__c;
            }
            
            Account business = [SELECT Id, Name, Phone, first_name__c, last_name__c, tax_id_number__c, guid__c, npi__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
                FROM Account WHERE Id =: businessId LIMIT 1];

            claim.Treating_Provider_NPI__c = provider.NPI__c;
            claim.Billing_Entity_NPI__c = business.npi__c;


            claim.Business_GUID__c = business.guid__c;
            claim.Provider_GUID__c = provider.guid__c;
            claim.Service_Location_GUID__c = location.guid__c;
            claim.Billing_Entity_First_Name__c = business.Name;
            claim.Billing_Entity_Last_Name__c = business.Name;
            claim.Billing_Entity_Tax_ID__c = business.tax_id_number__c;

            //if(claim.Billing_Entity_NPI__c == NULL) claim.Billing_Entity_NPI__c = business.npi__c;
            //if(claim.Billing_Entity_NPI__c == NULL) claim.Billing_Entity_NPI__c = provider.npi__c;

            if(claim.Plan_GUID__c != NULL) {
                Account plan = [SELECT Id FROM Account WHERE guid__c =: claim.Plan_GUID__c LIMIT 1];
                claim.Plan__c = plan.Id;
            } 

            if(claim.Has_ICD__c == TRUE) {
                claim.Diagnosis_Code_List__c = 'AB';
            }
			
			//default requested specialty if internal care transfer is true
			if(claim.Internal_Care_Transfer__c	)
				claim.Requested_Specialty__c = '122300000X';
				
            //claim.Type_of_Referral__c = 
            claim.Treating_Provider_Address1__c = location.BillingStreet;
            claim.Treating_Provider_City__c = location.BillingCity;
            claim.Treating_Provider_State__c = location.BillingState;
            claim.Treating_Provider_Zip__c = location.BillingPostalCode;

            claim.Billing_Entity_Address1__c = location.BillingStreet;
            claim.Billing_Entity_City__c = location.BillingCity;
            claim.Billing_Entity_State__c = location.BillingState;
            claim.Billing_Entity_Zip__c = location.BillingPostalCode;
            claim.Billing_Entity_Phone__c = business.Phone;

            claim.Treating_Provider_First_Name__c = provider.first_name__c;
            claim.Treating_Provider_Last_Name__c = provider.last_name__c;

            if(claim.Claim_Draft_Status__c == 'Submitted') {
                claim.Claim_Number__c = prov_util_Claims.buildNumber();
                claim.Is_Submitted__c = true;
                claim.Submitted_DateTime__c = DateTime.now();
                Database.SaveResult result = Database.update(claim, false);
                if(!result.isSuccess()){
                    Database.Error[] errorObj = result.getErrors();
                    wrapper.hasError = true;
                    throw new ClaimEntryException(errorObj[0], null, String.valueOf(claim.Id), 'Claim');
                }
            } else {
                upsert claim;
            }


            wrapper.claim = claim;
        } catch(ClaimEntryException e) {
            wrapper.errorIndex = NULL;
            if(e.detailId != NULL) {
                wrapper.errorIndex = Integer.valueOf(e.detailId);
            }
            wrapper.hasError = true;
            wrapper.object_type = e.objectType;
            wrapper.errorMessage = e.errorObj.getMessage();
            Database.rollback(sp);
        }

        return wrapper;     
    }


    @AuraEnabled
	public static List<Map<String, String>> retrieveSpecialtyOptions() {
		return util_retrievePicklistValues('Referral Specialty', 'English');
	}

    private static List<Map<String,String>> util_retrievePicklistValues(String picklistType, String language){
		//initialize the picklist values from custom metadata records
		String portalLabel = prov_util_Cache.PortalConfiguration.Label;
		List<Map<String,String>> picklistMap = new List<Map<String,String>>();
		
		for(Portal_Picklist__mdt pPicklist : [SELECT Label, English_Label__c, Spanish_Label__c, English_Description__c, Spanish_Description__c, Value__c, Order__c FROM Portal_Picklist__mdt WHERE Provider_Portal_Configuration__r.Label = :portalLabel AND Type__c =:picklistType ORDER BY Order__c ASC, English_Label__c ASC]) {
			System.debug('pPicklist ::'+pPicklist );
			Map<String, String> pickMap = new Map<String, String>();
			pickMap.put('Value', pPicklist.Value__c);
			if(language == 'Spanish'){
				pickMap.put('Label', pPicklist.Spanish_Label__c);
				if(pPicklist.Spanish_Description__c != null)
					pickMap.put('Description', pPicklist.Spanish_Description__c);
			} else {
				pickMap.put('Label', pPicklist.English_Label__c);
				if(pPicklist.English_Description__c != null)
					pickMap.put('Description', pPicklist.English_Description__c);	
			}
			picklistMap.add(pickMap);
		}
		
		return picklistMap;
	}

    /**
     * Get Service History based on procedure code, start and end date
     */
    @AuraEnabled
    public static List<mock_MembersServiceHistory__c> searchServiceHistoryApex(String currentBusinessId, String procedureCode, String startDate, String endDate, String memberProfileGuid) {
        List<String> visibleLOB = new List<String>(prov_util_Cache.VisibleLOB);

        Date startDateDate, endDateDate;
        if(startDate != NULL && startDate != '') { startDateDate = Date.valueOf(startDate); }
        if(endDate != NULL && endDate != '') { endDateDate = Date.valueOf(endDate); }

        List<String> planGuids = new List<String>();
        if(!Test.isRunningTest()) {
            planGuids.addAll(prov_util_Cache.getVisibilePlanWWIds(currentBusinessId));
        }
        
        List<mock_MembersServiceHistory__c> memberHistory = new List<mock_MembersServiceHistory__c>();

        //return an empty list since parameters a
        String memberProfileWhereClause;
        String dateWhereClause;
        String procedureCodeWhereClause;
        
        memberProfileWhereClause = ' ( MemberProfileGUID__c LIKE \'' + memberProfileGuid + '\' ) AND (ServiceLineStatus__c = \'Paid\') AND ';


        dateWhereClause = '';
        if(endDateDate != NULL) {
            String dateStr = DateTime.newInstance(endDateDate.year(),endDateDate.month(),endDateDate.day()).format('yyyy-MM-dd');
            dateWhereClause += ' ProcedureDate__c <= ' + dateStr + ' AND ';
        }

        if(startDateDate != NULL) {
            String dateStr = DateTime.newInstance(startDateDate.year(),startDateDate.month(),startDateDate.day()).format('yyyy-MM-dd');
            dateWhereClause += ' ProcedureDate__c >= ' + dateStr + ' AND ';
        }

        procedureCodeWhereClause = '';
        if(procedureCode != NULL && procedureCode != '') {
            procedureCodeWhereClause += ' ProcedureCode__c = \'' + procedureCode + '\' AND ';
        }
        
        String whereClause = 'WHERE ' + memberProfileWhereClause + dateWhereClause + procedureCodeWhereClause +' RouteID__c in (\''+String.join(visibleLOB,'\',\'')+'\') ORDER BY ProcedureDate__c DESC';
        memberHistory = (List<mock_MembersServiceHistory__c>)prov_util_DAL.dalQuery('mock_MembersServiceHistory__c', whereClause);

        List<mock_MembersServiceHistory__c> historyWithGuids = new List<mock_MembersServiceHistory__c>();
        for(mock_MembersServiceHistory__c history : memberHistory) {
            if(planGuids.contains(history.PlanGUID__c.toLowerCase())) {
                historyWithGuids.add(history);
            }
        }
        return historyWithGuids;
    }




    // wrapper for callout request for claim search
    public class ClaimWrapper {
        @AuraEnabled public Claim__c claim;
        @AuraEnabled public mock_MemberCoverage__c coverage;
        @AuraEnabled public Boolean hasError;
        @AuraEnabled public Integer errorIndex;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String object_type;
    }
}