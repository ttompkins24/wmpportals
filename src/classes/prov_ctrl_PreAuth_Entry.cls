public without sharing class prov_ctrl_PreAuth_Entry {
    @AuraEnabled
    public static String deleteClaimItemApex(String claimItemId) {
        List<Claim_Service_Line__c> claimItems = [SELECT Id FROM Claim_Service_Line__c WHERE Id =: claimItemId];
        if(claimItems.size() > 0) {
            delete claimItems;
        }
        return 'Success';
    }


    @AuraEnabled
    public static ClaimWrapper getDraftClaimApex(String claim_id, String businessId) {
        Claim__c claim = [SELECT Id, LastModifiedDate, Claim_Number__c, Is_Submitted__c, Submitted_DateTime__c, Service_Date__c, Provider__c, Service_Location__c,
            Place_of_Treatment__c, Remarks2__c, Is_EPSDT__c, Is_Auth__c, Referral_Number__c, Business__c, Accident_Date__c, Accident_State__c, Accident_Type__c,
            Is_Accident__c, Has_ICD__c, Has_Other_Coverage__c, Claim_Draft_Status__c, Office_Reference_Number__c,
            Patient_Member_Profile_GUID__c, Is_Emergency__c,
            
            Diagnosis_Code_A__c, Diagnosis_Code_B__c, Diagnosis_Code_C__c, Diagnosis_Code_D__c,
            Diagnosis_Code_A_Lookup__c, Diagnosis_Code_B_Lookup__c, Diagnosis_Code_C_Lookup__c, Diagnosis_Code_D_Lookup__c,

            Diagnosis_Code_A_Lookup__r.Code_Type__c, Diagnosis_Code_B_Lookup__r.Code_Type__c, Diagnosis_Code_C_Lookup__r.Code_Type__c, Diagnosis_Code_D_Lookup__r.Code_Type__c,
            Diagnosis_Code_A_Lookup__r.Description__c, Diagnosis_Code_B_Lookup__r.Description__c, Diagnosis_Code_C_Lookup__r.Description__c, Diagnosis_Code_D_Lookup__r.Description__c,
            Diagnosis_Code_A_Lookup__r.Code__c, Diagnosis_Code_B_Lookup__r.Code__c, Diagnosis_Code_C_Lookup__r.Code__c, Diagnosis_Code_D_Lookup__r.Code__c,
            Patient_First_Name__c, Patient_Last_Name__c, Patient_Birth_Date__c, Patient_City__c, Patient_Address1__c, Patient_Address2__c,

            Subscriber_ID__c, Subscriber_First_Name__c, Subscriber_Last_Name__c, Subscriber_Birth_Date__c, Last_Eligibility_Check_Information__c, Last_Eligibility_Check__c, Last_Eligibility_Status__c, Plan_Text__c
            FROM Claim__c WHERE Id =: claim_id];

        ClaimWrapper wrapper = new ClaimWrapper();
        if(claim != NULL && claim.Id != NULL) {
            List<Claim_Service_Line__c> claimItems = [SELECT Id, Surfaces__c, Tooth_Number__c, Service_Date__c, Quantity__c, Quad__c, Billed_Amount__c, Arch__c,
                Procedure_Code__c, Procedure_Code_Lookup__c,  Procedure_Code_Lookup__r.Is_Arch_Required__c, Procedure_Code_Lookup__r.Is_Quad_Required__c,
                Procedure_Code_Lookup__r.Is_Surface_Required__c, Procedure_Code_Lookup__r.Is_Tooth_Required__c, Procedure_Code_Lookup__r.QTY__c, 
                Procedure_Code_Lookup__r.Description__c, Claim__c,
                Diagnosis_Code_A_Lookup__c, Diagnosis_Code_B_Lookup__c, Diagnosis_Code_C_Lookup__c, Diagnosis_Code_D_Lookup__c, 
                Diagnosis_Code_A__c, Diagnosis_Code_B__c, Diagnosis_Code_C__c, Diagnosis_Code_D__c
                FROM Claim_Service_Line__c WHERE Claim__c =: claim.Id];


            // get eligibility information
            mock_MemberCoverage__c coverage;
            Set<String> plans = new Set<String>(prov_util_cache.getPlanGuidsBasedOnBusProvSL(businessId, claim.Provider__c, claim.Service_Location__c));
            Prov_ctrl_MemberEligibility.MemberWrapper searchCriteria = new Prov_ctrl_MemberEligibility.MemberWrapper(claim.Service_Date__c, claim.Patient_Birth_Date__c, claim.Subscriber_ID__c, claim.Patient_First_Name__c, claim.Patient_Last_Name__c, null);
            List<mock_MemberCoverage__c> memCovResults = (List<mock_MemberCoverage__c>) prov_util_MemberEligibilityCallout.requestMemberEligibilityInfo(new List<Prov_ctrl_MemberEligibility.MemberWrapper>{searchCriteria}, businessId);
            List<mock_MemberCoverage__c> availableCovs = new List<mock_MemberCoverage__c>();

 
            for(mock_MemberCoverage__c mc : memCovResults){
                if(plans.contains(mc.PlanGUID__c.toLowercase())){
                    //User entered First Name, Last Name, and Member Number
                    if((claim.Patient_First_Name__c != '' && claim.Patient_First_Name__c != null && claim.Patient_Last_Name__c != '' && claim.Patient_Last_Name__c != null) || (claim.Subscriber_ID__c != ''  && claim.Subscriber_ID__c != null)) {
                        //check if criteria matches member coverage record
                        if((mc.FirstName__c.containsIgnoreCase(claim.Patient_First_Name__c) && mc.LastName__c.containsIgnoreCase(claim.Patient_Last_Name__c)) || (claim.Subscriber_ID__c.equalsIgnoreCase(mc.SubscriberID__c)) && claim.Patient_Birth_Date__c == mc.Birthdate__c){
                            availableCovs.add(mc);
                            if(coverage == NULL) {
                                coverage = mc;
                            }
                        }
                    }
                }
            }
    
            wrapper.claimItems = claimItems;
            wrapper.coverage = coverage;
        } else {
            wrapper.hasError = true;
        }
    
        wrapper.claim = claim;    
        return wrapper;
    }

    @AuraEnabled
    public static ClaimWrapper saveClaimApex(Claim__c claim, String claimItems, String businessId){
        claim.Service_Date__c = Date.Today();
        claim.Claim_Type__c = 'AUTH';
        claim.Is_Auth__c = true;
        claim.Last_Eligibility_Check__c = DateTime.now();
        ClaimWrapper wrapper = new ClaimWrapper();
        wrapper.hasError = false;

        Savepoint sp = Database.setSavepoint();

        try {  
            Prov_ctrl_MemberEligibility.MemberWrapper searchCriteria = new Prov_ctrl_MemberEligibility.MemberWrapper(claim.Service_Date__c, claim.Subscriber_Birth_Date__c, claim.Subscriber_ID__c, claim.Subscriber_First_Name__c, claim.Subscriber_Last_Name__c, null);
            List<mock_MemberCoverage__c> memCovResults = (List<mock_MemberCoverage__c>) prov_util_MemberEligibilityCallout.requestMemberEligibilityInfo(new List<Prov_ctrl_MemberEligibility.MemberWrapper>{searchCriteria}, businessId);

            mock_MemberCoverage__c coverage;
            if(memCovResults != NULL && memCovResults.size() > 0) {
                coverage = memCovResults[0];
            }

            Account location = [SELECT Id, Name, first_name__c, last_name__c, guid__c, npi__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
                FROM Account WHERE Id =: claim.Service_Location__c LIMIT 1];

            Account provider = [SELECT Id, Name, first_name__c, last_name__c, guid__c, npi__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode 
                FROM Account WHERE Id =: claim.Provider__c LIMIT 1];

            List<Provider_License__c> licenses = [SELECT Id, license_id__c FROM Provider_License__c 
                WHERE license_type__c = 'dental' AND license_state__c =: location.BillingState AND Provider__c =: provider.Id];

            System.debug('### got licenses: ' + licenses);
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

            if(claim.Plan_GUID__c != NULL) {
                Account plan = [SELECT Id FROM Account WHERE guid__c =: claim.Plan_GUID__c LIMIT 1];
                claim.Plan__c = plan.Id;
            } 

            if(claim.Has_ICD__c == TRUE) {
                claim.Diagnosis_Code_List__c = 'AB';
            }

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

            List<Claim_Service_Line__c> items = (List<Claim_Service_Line__c>)JSON.deserialize(claimItems, List<Claim_Service_Line__c>.class);
            if(items != NULL && items.size() > 0) {
                Integer index = 1;
                for(Claim_Service_Line__c item : items) {
                    if(item.Claim__c == NULL) { item.Claim__c = claim.Id; }
                    item.Service_Date__c = Date.today();
                    item.Claim_Draft_Status__c = claim.Claim_Draft_Status__c;
                    item.Line_Number__c = index;
                    index = index + 1;
                }
                // update items for validation rules
                Database.UpsertResult[] itemResult = Database.upsert(items, false);
                for(Integer i = 0; i < itemResult.size(); i++){
                    Database.UpsertResult result = itemResult[i];

                    if(!result.isSuccess()){
                        Database.Error errorObj = result.getErrors()[0];                            
                        throw new ClaimEntryException(errorObj, String.valueOf(i), String.valueOf(claim.Id), 'Items');
                    }
                }
            }

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
            wrapper.claimItems = items;
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


    /*RETRIEVE THE PROCEDURE CODES*/
    @AuraEnabled
    public static ProcedureCodeBilledAmountWrapper getProcedureCodeApex(String procedureCode, String providerId, String locationId){
        procedureCode = String.escapeSingleQuotes(procedureCode);  
        procedureCode = procedureCode.toUpperCase();

        String escapedProcedureCode = procedureCode;
        if(escapedProcedureCode.length() == 4)
        	escapedProcedureCode = '%' + escapedProcedureCode + '%';
        	
        List<Procedure_Code__c> codes = [SELECT Id, Name, Description__c, Is_Tooth_Required__c, Is_Surface_Required__c, 
            Class_Code__c, Is_Arch_Required__c, Is_Quad_Required__c, QTY__c
            FROM Procedure_Code__c
            WHERE Name LIKE :escapedProcedureCode ORDER BY Name DESC];


        ProcedureCodeBilledAmountWrapper wrapper = new ProcedureCodeBilledAmountWrapper();
        if(codes != NULL && codes.size() > 0) {
            // get the exact match
            for(Procedure_Code__c code : codes) {
                if(code.Name == procedureCode) {
                    wrapper.procedure_code = code;
                }
            }

            // if we didn't get an exact match, return one that is close
            if(wrapper.procedure_code == NULL) {
                wrapper.procedure_code = codes[0];
            }
            
            List<Billed_Amount_Association__c> associations = [SELECT Id, Billed_Amount__c, Billed_Amount__r.Id 
                FROM Billed_Amount_Association__c WHERE Provider__c =: providerId AND Service_Location__c =: locationId];

            Set<Id> billedAmountIds = new Set<Id>();
            for(Billed_Amount_Association__c association : associations) {
                billedAmountIds.add(association.Billed_Amount__c);
            }

            List<Billed_Amount_Detail__c> details = [SELECT Id, Billed_Value__c
                FROM Billed_Amount_Detail__c WHERE Billed_Amount__c IN: billedAmountIds AND Procedure_Code__c =:  wrapper.procedure_code.Id];

            if(details != NULL && details.size() > 0) {
                wrapper.billed_amount = details[0];
            }
        }
        
        return wrapper;
    }

    @AuraEnabled
    public static List<CodeSets__c> getIcdCodesApex(String code, String codeType, String description, List<String> existingIds) {
        List<String> visbileLOB = new List<String>(prov_util_Cache.VisibleLOB);

        List<CodeSets__c> codes = [SELECT Id, Code_Type__c, Code__c, Description__c
            FROM CodeSets__c 
            WHERE Id NOT IN:existingIds AND (Code__c LIKE :code OR Description__c LIKE :description) AND Code_Type__c LIKE :codeType AND RouteId__c IN : visbileLOB ORDER BY Code__c ASC LIMIT 100]; 
        return codes;
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

        System.debug('### where clause: ' + whereClause);
        
        List<mock_MembersServiceHistory__c> historyWithGuids = new List<mock_MembersServiceHistory__c>();
        for(mock_MembersServiceHistory__c history : memberHistory) {
            if(planGuids.contains(history.PlanGUID__c.toLowerCase())) {
                historyWithGuids.add(history);
            }
        }
        return historyWithGuids;
    }


    @AuraEnabled
    public static PicklistWrapper getPicklistValuesApex(String currentBusinessId) {
        PicklistWrapper wrapper = new PicklistWrapper();
        List<String> visibleLOB = new List<String>(prov_util_Cache.VisibleLOB);
        wrapper.placeOfServicePicklist = [SELECT Id, Code_Type__c, Description__c, Code__c FROM CodeSets__c WHERE Code_Type__c = 'Place of Treatment' AND RouteId__c IN: visibleLOB ORDER BY Description__c ASC];

        return wrapper; 
    }



    // wrapper for callout request for claim search
    public class ClaimWrapper {
        @AuraEnabled public Claim__c claim;
        @AuraEnabled public List<Claim_Service_Line__c> claimItems;
        @AuraEnabled public mock_MemberCoverage__c coverage;
        @AuraEnabled public Boolean hasError;
        @AuraEnabled public Integer errorIndex;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String object_type;
    }


    // wrapper for callout request for claim search
    public class ProcedureCodeBilledAmountWrapper {
        @AuraEnabled public Billed_Amount_Detail__c billed_amount;
        @AuraEnabled public Procedure_Code__c procedure_code;
    }

    // wrapper for callout request for claim search
    public class PicklistWrapper {
        @AuraEnabled public List<CodeSets__c> placeOfServicePicklist;
    }
}