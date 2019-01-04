public without sharing class prov_ctrl_Claims_Entry {
    @AuraEnabled
    public static String deleteClaimItemApex(String claimItemId) {
        List<Claim_Service_Line__c> claimItems = [SELECT Id FROM Claim_Service_Line__c WHERE Id =: claimItemId];
        if(claimItems.size() > 0) {
            delete claimItems;
        }
        return 'Success';
    }

    @AuraEnabled
    public static String deleteCobPayerApex(String cobPayerId) {
        List<COB_Payer_Claim__c> cobPayerClaims = [SELECT Id FROM COB_Payer_Claim__c WHERE Id =: cobPayerId];
        if(cobPayerClaims.size() > 0) {
            delete cobPayerClaims;
        }
        return 'Success';
    } 

    @AuraEnabled
    public static String deleteCobPayerItemApex(String payerItemId) {
        List<COB_Payer_Detail__c> cobPayerDetails = [SELECT Id FROM COB_Payer_Detail__c WHERE Id =: payerItemId];
        if(cobPayerDetails.size() > 0) {
            delete cobPayerDetails;
        }
        return 'Success';
    }

    @AuraEnabled
    public static ClaimWrapper getDraftClaimApex(String claim_id, String businessId) {
        System.debug('### claim_id: ' + claim_id);
        System.debug('### business: ' + businessId);

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

            List<COB_Payer_Claim__c> cobPayerClaims = [SELECT Id, Payer_Name__c, Group_ID__c, Subscriber_ID__c,
                Subscriber_First_Name__c, Subscriber_Last_Name__c, Subscriber_Birth_Date__c, Claim__c
                FROM COB_Payer_Claim__c WHERE Claim__c =: claim.Id];

            List<COB_Payer_Detail__c> cobPayerDetails = [SELECT Id, COB_Payer_Claim__c, Claim_Service_Line__c, 
                Paid_Amount__c, Payment_Date__c, COB_Other_Payer__c
                FROM COB_Payer_Detail__c WHERE COB_Payer_Claim__c IN: cobPayerClaims AND Claim_Service_Line__c IN: claimItems];


            // get eligibility information
            mock_MemberCoverage__c coverage;
            Set<String> plans = new Set<String>(prov_util_cache.getPlanGuidsBasedOnBusProvSL(businessId, claim.Provider__c, claim.Service_Location__c));
            Prov_ctrl_MemberEligibility.MemberWrapper searchCriteria = new Prov_ctrl_MemberEligibility.MemberWrapper(claim.Service_Date__c, claim.Patient_Birth_Date__c, claim.Subscriber_ID__c, claim.Patient_First_Name__c, claim.Patient_Last_Name__c, null);
            List<mock_MemberCoverage__c> memCovResults = (List<mock_MemberCoverage__c>) prov_util_MemberEligibilityCallout.requestMemberEligibilityInfo(new List<Prov_ctrl_MemberEligibility.MemberWrapper>{searchCriteria}, businessId);
            List<mock_MemberCoverage__c> availableCovs = new List<mock_MemberCoverage__c>();

            for(mock_MemberCoverage__c mc : memCovResults){
                if(plans.contains(mc.PlanGUID__c.toLowercase())){
                    if((claim.Patient_First_Name__c != '' && claim.Patient_First_Name__c != null && claim.Patient_Last_Name__c != '' && claim.Patient_Last_Name__c != null) || (claim.Subscriber_ID__c != ''  && claim.Subscriber_ID__c != null)) {
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
            wrapper.cobPayerClaims = cobPayerClaims;
            wrapper.cobPayerDetails = cobPayerDetails;
            wrapper.coverage = coverage;
        } else {
            wrapper.hasError = true;
        }
        
        wrapper.claim = claim;
        
        return wrapper;
    }


    @AuraEnabled
    public static ClaimWrapper saveClaimApex(Claim__c claim, String claimItems, String cobPayerClaims,  String cobPayerDetails, String businessId){        
        claim.Claim_Type__c = 'CLAIM';
        claim.Is_Claim__c = true;
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

            Account provider = [SELECT Id, Name, first_name__c, last_name__c, guid__c, npi__c, 
                BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
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
                    item.Claim_Draft_Status__c = claim.Claim_Draft_Status__c;
                    item.Line_Number__c = index;
                    index = index + 1;
                }
                // update items for validation rules
                Database.UpsertResult[] itemResult = Database.upsert(items, false);
                for(Integer i = 0; i < itemResult.size(); i++){
                    Database.UpsertResult result = itemResult[i];

                    System.debug('### result: ' + result);
                    if(!result.isSuccess()){
                        Database.Error errorObj = result.getErrors()[0];                            
                        throw new ClaimEntryException(errorObj, String.valueOf(i), String.valueOf(claim.Id), 'Items');
                    }
                }
            }

            List<COB_Payer_Claim__c> cobItems = (List<COB_Payer_Claim__c>)JSON.deserialize(cobPayerClaims, List<COB_Payer_Claim__c>.class);
            if(cobItems != NULL && cobItems.size() > 0) {
            	Map<Id, CodeSets__c> codeSetId2CodeSetMap = new Map<Id, CodeSets__c>();
                for(COB_Payer_Claim__c item : cobItems) {
                    if(item.Claim__c == NULL) { item.Claim__c = claim.Id; }
                    item.Claim_Draft_Status__c = claim.Claim_Draft_Status__c;
                    if(item.CodeSets__c != null)
                    	codeSetId2CodeSetMap.put(item.CodeSets__c, null);
                }
                
                //query for the code sets
                codeSetId2CodeSetMap = new Map<Id, CodeSets__c>([SELECT id, Code__c,Description__c FROM CodeSets__c WHERE Id IN :codeSetId2CodeSetMap.keyset()]);
                //update the Payer_NAICS_Code__c
                for(COB_Payer_Claim__c item : cobItems) {
                	if(codeSetId2CodeSetMap.containsKey(item.CodeSets__c)){
                		item.Payer_NAICS_Code__c = codeSetId2CodeSetMap.get(item.CodeSets__c).Code__c;
                		item.Payer_Name__c = codeSetId2CodeSetMap.get(item.CodeSets__c).Description__c;
                	}
                }
                // update items
                Database.UpsertResult[] itemResult = Database.upsert(cobItems, false);
                for(Integer i = 0; i < itemResult.size(); i++){
                    Database.UpsertResult result = itemResult[i];

                    if(!result.isSuccess()){
                        Database.Error errorObj = result.getErrors()[0];                            
                        throw new ClaimEntryException(errorObj, String.valueOf(i), String.valueOf(claim.Id), 'COB');
                    }
                }
            }

            // deserialize payer details and upsert
            List<COB_Payer_Detail__c> payerDetails = (List<COB_Payer_Detail__c>)JSON.deserialize(cobPayerDetails, List<COB_Payer_Detail__c>.class);
            if(payerDetails != NULL && payerDetails.size() > 0) {
                for(COB_Payer_Detail__c payerDetail : payerDetails) {
                    // find the claim index line item
                    if(payerDetail.Claim_Service_Line__c == NULL) {
                        payerDetail.Claim_Service_Line__c = items[Integer.valueOf(payerDetail.Claim_Item_Index__c)].Id;
                    }
                    
                    for(COB_Payer_Claim__c item : cobItems) {
                        if(item.Payer_Name__c == payerDetail.COB_Other_Payer__c) {
                            payerDetail.COB_Payer_Claim__c = item.Id;
                            //payerDetail.COB_Other_Payer__c = item.Payer_NAICS_Code__c;
                        }
                    }
                    payerDetail.Claim_Draft_Status__c = claim.Claim_Draft_Status__c;
                }
                
                Database.UpsertResult[] itemResult = Database.upsert(payerDetails, false);
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
            wrapper.cobPayerClaims = cobItems;
            wrapper.cobPayerDetails = payerDetails;
        } catch(ClaimEntryException e) {
            wrapper.errorIndex = NULL;
            if(e.detailId != NULL) {
                wrapper.errorIndex = Integer.valueOf(e.detailId);
            }
            wrapper.hasError = true;
            wrapper.object_type = e.objectType;
            wrapper.errorMessage = e.errorObj.getMessage();
            System.debug('### exception: ' + e);
            Database.rollback(sp);
        }

        System.debug('### wrapper: ' + wrapper);
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
            WHERE Name LIKE :escapedProcedureCode  ORDER BY Name DESC];


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

    @AuraEnabled
    public static List<CodeSets__c> getCobCodesApex(String policy, String payerName, String filterCode, List<string> existingIds) {
        List<CodeSets__c> payers = [SELECT Id, Description__c, Code__c 
            FROM CodeSets__c 
            WHERE Id NOT IN:existingIds AND  (Code__c LIKE :policy OR Description__c LIKE :payerName) AND Code_Type__c = 'NAICS' ORDER BY Code__c ASC LIMIT 100]; 
        return payers;
    }


    @AuraEnabled
    public static PicklistWrapper getPicklistValuesApex(String currentBusinessId) {
        PicklistWrapper wrapper = new PicklistWrapper();
        List<String> visibleLOB = new List<String>(prov_util_Cache.VisibleLOB);
        wrapper.placeOfServicePicklist = [SELECT Id, Code_Type__c, Description__c, Code__c FROM CodeSets__c WHERE Code_Type__c = 'Place of Treatment' AND RouteId__c IN: visibleLOB ORDER BY Description__c ASC];

        return wrapper; 
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
        System.debug('### whereClause: ' + whereClause);
        memberHistory = (List<mock_MembersServiceHistory__c>)prov_util_DAL.dalQuery('mock_MembersServiceHistory__c', whereClause);

        List<mock_MembersServiceHistory__c> historyWithGuids = new List<mock_MembersServiceHistory__c>();
        for(mock_MembersServiceHistory__c history : memberHistory) {
            if(planGuids.contains(history.PlanGUID__c.toLowerCase())) {
                historyWithGuids.add(history);
            }
        }


        return historyWithGuids;
    }

    @AuraEnabled   
    public static ClaimAdditionalInfoWrapper getAdditionalInfo(String memberProfileGUID, String subscriberProfileGUID, String planGUID){
        mock_MemberCoverage__c subscriberCoverage;
        ClaimAdditionalInfoWrapper wrap = new ClaimAdditionalInfoWrapper();
        //if member != subscriber
        System.debug('memberProfileGUID ' + memberProfileGUID);
        System.debug('subscriberProfileGUID ' + subscriberProfileGUID);
        if(memberProfileGUID != subscriberProfileGUID){
            //get subscriber plan
            List<mock_MemberCoverage__c> memCovRecList = new List<mock_MemberCoverage__c>();
            Map<String, mock_MemberCoverage__c> memCovMap = prov_util_DAL.getMembersPlansMapByProfile(subscriberProfileGUID, new List<String>{planGUID});
            System.debug('### memCovMap size: ' + memCovMap.size());
            System.debug('memCovMap: ' + memCovMap);
            if(memCovMap.size() == 0){
                wrap.errorMessage = 'Error, no Coverage found for subscriber';
                return wrap;
            } else if (memCovMap.size() == 1){
                subscriberCoverage = memCovMap.values()[0];
            } else {
                for(mock_MemberCoverage__c mem : memCovMap.values()){
                    memCovRecList.add(mem);
                }
                //add logic to get first non termed coverage or if none, most recent termed coverage 
                subscriberCoverage = memCovRecList[0];
            }
            System.debug('subscriberCoverage ' +  subscriberCoverage);
            //make a wrapper of claim subscriber fields to return
            wrap.Subscriber_Birth_Date = subscriberCoverage.Birthdate__c;
            wrap.Subscriber_First_Name = subscriberCoverage.FirstName__c;
            wrap.Subscriber_Last_Name = subscriberCoverage.LastName__c;
        }

        //get address information
        List<String> guids = new List<String>();
        guids.add(memberProfileGUID);
        if(memberProfileGUID != subscriberProfileGUID){
            guids.add(subscriberProfileGUID);
        }
        
        //odata call for address
        List<mock_MemberAddress__c> addresses = prov_util_DAL.getMemberAddresses(guids);
        System.debug('Addresses size ' + addresses.size());
        System.debug('Addresses ' + addresses);
        mock_MemberAddress__c subscriberAddress = new mock_MemberAddress__c();
        mock_MemberAddress__c patientAddress = new mock_MemberAddress__c();

        //loop through address
        //types: 1.Residence 2.Mail 3.Alternate
        for(mock_MemberAddress__c addr : addresses){
            if(addr.MemberProfileGUID__c.equalsIgnoreCase(memberProfileGUID)){
                if(addr.Type__c == 'Residence'){
                    patientAddress = addr;
                } else if(addr.Type__c == 'Mail' && patientAddress.Type__c != 'Residence'){
                    patientAddress = addr;
                } else if(addr.Type__c == 'Alternate' && (PatientAddress.Type__c != 'Residence' && PatientAddress.Type__c != 'Mail')){
                    patientAddress = addr;
                } //catch all 
                else if(PatientAddress.Type__c != 'Residence' && PatientAddress.Type__c != 'Mail' && PatientAddress.Type__c != 'Alternate'){
                    patientAddress = addr;
                }
            }
            if(addr.MemberProfileGUID__c.equalsIgnoreCase(subscriberProfileGUID)){
                if(addr.Type__c == 'Residence'){
                    subscriberAddress = addr;
                } else if(addr.Type__c == 'Mail' && subscriberAddress.Type__c != 'Residence'){
                    subscriberAddress = addr;
                } else if(addr.Type__c == 'Alternate' && (subscriberAddress.Type__c != 'Residence' && subscriberAddress.Type__c != 'Mail')){
                    subscriberAddress = addr;
                } //catch all
                else if(subscriberAddress.Type__c != 'Residence' && subscriberAddress.Type__c != 'Mail' && subscriberAddress.Type__c != 'Alternate'){
                    subscriberAddress = addr;
                }
            }
        }
        System.debug('subscriberAddress ' + subscriberAddress);
        System.debug('patientAddress ' + patientAddress);

        wrap.Subscriber_Address1 = subscriberAddress.AddressLine1__c;
        wrap.Subscriber_Address2 = subscriberAddress.AddressLine2__c;
        wrap.Subscriber_City = subscriberAddress.City__c;
        wrap.Subscriber_State = subscriberAddress.State__c;
        wrap.Subscriber_Zip = subscriberAddress.Zip__c;                    

        wrap.Patient_Address1 = patientAddress.AddressLine1__c;
        wrap.Patient_Address2 = patientAddress.AddressLine2__c;
        wrap.Patient_City = patientAddress.City__c;
        wrap.Patient_State = patientAddress.State__c;
        wrap.Patient_Zip = patientAddress.Zip__c;

        System.debug('wrap ' + wrap);

        return wrap;
    
    }


    // wrapper for callout request for claim search
    public class ClaimWrapper {
        @AuraEnabled public Claim__c claim;
        @AuraEnabled public List<Claim_Service_Line__c> claimItems;
        @AuraEnabled public List<COB_Payer_Claim__c> cobPayerClaims;
        @AuraEnabled public List<COB_Payer_Detail__c> cobPayerDetails;
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
        @AuraEnabled public List<String> accidentTypePicklists;
    }

    public class ClaimAdditionalInfoWrapper {
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String Subscriber_Address1; //included
        @AuraEnabled public String Subscriber_Address2; //included
        @AuraEnabled public Date Subscriber_Birth_Date;  //included
        @AuraEnabled public String Subscriber_City; //included
        @AuraEnabled public String Subscriber_Employer_Name;
        @AuraEnabled public String Subscriber_First_Name;  //included
        @AuraEnabled public String Subscriber_Gender;
        @AuraEnabled public String Subscriber_Group_ID;
        @AuraEnabled public String Subscriber_ID;  //included
        @AuraEnabled public String Subscriber_Last_Name;  //included
        @AuraEnabled public String Subscriber_Middle_Initial;
        @AuraEnabled public String Subscriber_State; //included
        @AuraEnabled public String Subscriber_Suffix;
        @AuraEnabled public String Subscriber_Zip; //included
        //@AuraEnabled public Boolean Subscriber_Signature;
        //@AuraEnabled public Date Subscriber_Signature_Date;    
        @AuraEnabled public String Patient_Address1; //included
        @AuraEnabled public String Patient_Address2; //included
        @AuraEnabled public Date Patient_Birth_Date;
        @AuraEnabled public String Patient_City; //included
        @AuraEnabled public String Patient_First_Name;
        @AuraEnabled public String Patient_Gender;
        @AuraEnabled public String Patient_Last_Name;
        @AuraEnabled public String Patient_Middle_Initial;
        //@AuraEnabled public String Patient_Relationship;
        //@AuraEnabled public Boolean Patient_Signature;
        //@AuraEnabled public Date Patient_Signature_Date;
        @AuraEnabled public String Patient_State; //included
        @AuraEnabled public String Patient_Suffix;
        @AuraEnabled public String Patient_Zip; //included

    }

    /*****************************************************************
    *********************HELPER FUNCTIONS***************************
    *****************************************************************/
    @AuraEnabled
    public static List<String> availableReferralPlans(){
        return prov_util_Cache.availableReferralPlans(); 
    }
}