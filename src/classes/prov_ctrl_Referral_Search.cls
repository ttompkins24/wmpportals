global without sharing class prov_ctrl_Referral_Search {
	
	public Boolean useMockData {get;set;}
	public String portalURL {get;set;}

	global prov_ctrl_Referral_Search(){
		useMockData = prov_util_MockData.useMockData;
		portalURL = System.Label.Member_Eligibility_VF_URL;
	}
	
	@RemoteAction
	global static object referralHeaders_contin(String json, String businessId){ 
		System.debug('Passed in String: ' + json);
        prov_Wrap_Claim.ReferralHeaderRequestWrapper referralHeader = (prov_Wrap_Claim.ReferralHeaderRequestWrapper) System.JSON.deserialize(json,prov_Wrap_Claim.ReferralHeaderRequestWrapper.class);
		Map<String,List<prov_wrap_Claim.ReferralHeaderResponseWrapper>> referralResponseWrappersMap = new Map<String,List<prov_wrap_Claim.ReferralHeaderResponseWrapper>>();
		List<prov_wrap_Claim.ReferralHeaderResponseWrapper> internalReferralResponseWrappers = new List<prov_wrap_Claim.ReferralHeaderResponseWrapper>();
		Set<String> externalReferralNumbers = new Set<String>();
		
		if(prov_util_MockData.useMockData) { 
            for(Claim__c tempReferral : queryReferralDrafts(1000, businessId, referralHeader, externalReferralNumbers)) {
                prov_wrap_Claim.ReferralHeaderResponseWrapper submittedReferral = transformReferralToWrapper(tempReferral);
                system.debug('submittedReferral: '+submittedReferral);
                internalReferralResponseWrappers.add(submittedReferral);
            }
            referralResponseWrappersMap.put('calloutSuccess', internalReferralResponseWrappers);
            return referralResponseWrappersMap;      
        } else {
            // clone header to update the callout strings or the internal search will fail
            HTTPRequest request = prov_util_ClaimCallout.requestReferralHeadersRemote(referralHeader.clone());
			//Create a continuation for HTTPRequest
	        Continuation con = new Continuation(60);
	        con.state = con.addHttpRequest(request);
	        con.continuationMethod = 'callback';
	        return con;
           
        }
	}
	
	global static object callback(Object state){
        System.debug('in callback');

        HttpResponse res = Continuation.getResponse((String) state);
        System.debug('response ' + res);
        System.debug('response ' + res.getBody());

        if(res.getStatusCode()!=200){
            system.debug('--Referral Search  Search Request-------------------------------------------------------------------------');
            system.debug('Response failed.');
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
            system.debug('--Panel Roster Search Request-------------------------------------------------------------------------');
              String str = '[{"FirstName":"Error","LastName":"timeout"}]';
            return (Object) str; 
        } else {
            system.debug('Referral Search Body success ');
                        
            
	        return res.getBody();
        }
    }
    
    @RemoteAction
    global static Map<String,List<prov_wrap_Claim.ReferralHeaderResponseWrapper>> afterResponseLogic(String response, String businessId, String header){
    	 prov_Wrap_Claim.ReferralHeaderRequestWrapper referralHeader = (prov_Wrap_Claim.ReferralHeaderRequestWrapper) System.JSON.deserialize(header,prov_Wrap_Claim.ReferralHeaderRequestWrapper.class);
        
        List<prov_wrap_Claim.ReferralHeaderResponseWrapper> externalReferralResponseWrappers = new List<prov_wrap_Claim.ReferralHeaderResponseWrapper>();
        List<prov_wrap_Claim.ReferralHeaderResponseWrapper> internalReferralResponseWrappers = new List<prov_wrap_Claim.ReferralHeaderResponseWrapper>();
        Map<String,List<prov_wrap_Claim.ReferralHeaderResponseWrapper>> referralResponseWrappersMap = new Map<String,List<prov_wrap_Claim.ReferralHeaderResponseWrapper>>();

    	prov_wrap_Claim.ReferralHeaderResultWrapper resultWrapper = (prov_wrap_Claim.ReferralHeaderResultWrapper) System.JSON.deserialize(response, prov_wrap_Claim.ReferralHeaderResultWrapper.class);
		system.debug('result wrapper: '+resultWrapper);
		// extract list of individual results from overall wrapper
		externalReferralResponseWrappers = (List<prov_wrap_Claim.ReferralHeaderResponseWrapper>) resultWrapper.SearchResult;
    	Set<String> externalReferralNumbers = new Set<String>();
    	
        if(externalReferralResponseWrappers != null) {
            referralResponseWrappersMap.put('calloutSuccess',externalReferralResponseWrappers);
            system.debug('referralResponseWrappersMap: '+referralResponseWrappersMap);
            externalReferralNumbers = getExternalReferralNumberSet(externalReferralResponseWrappers);
            system.debug('externalReferralNumbers: '+externalReferralNumbers);
        }
        // query and add the referrals from inside SF - limit to 500
        // only search submitted referrals if the status from the search is one of the below
        //if(referralHeader.RequestStatus == null || referralHeader.RequestStatus == 'All' || referralHeader.RequestStatus == 'Accepted' || referralHeader.RequestStatus == '' || referralHeader.RequestStatus == 'Select') {
            for(Claim__c tempReferral : queryReferralDrafts(1000, businessId, referralHeader, externalReferralNumbers)) {
                prov_wrap_Claim.ReferralHeaderResponseWrapper submittedReferral = transformReferralToWrapper(tempReferral);
                system.debug('submittedReferral: '+submittedReferral);
                internalReferralResponseWrappers.add(submittedReferral);
            }
        //}
        // set response map so we can show an error to the user when the callout is a failure
        if(referralResponseWrappersMap.containsKey('calloutSuccess')) {
            referralResponseWrappersMap.get('calloutSuccess').addAll(internalReferralResponseWrappers);
        } else {
            referralResponseWrappersMap.put('calloutError', internalReferralResponseWrappers);
        }
            
    	return referralResponseWrappersMap;
    	
    }
    
    
	/* @AuraEnabled
    public static Map<String,List<prov_wrap_Claim.ReferralHeaderResponseWrapper>> getReferralHeaders(String json, String businessId) {
        system.debug(json);
		system.debug('getReferralHeaders');
        prov_Wrap_Claim.ReferralHeaderRequestWrapper referralHeader = (prov_Wrap_Claim.ReferralHeaderRequestWrapper) System.JSON.deserialize(json,prov_Wrap_Claim.ReferralHeaderRequestWrapper.class);
        
        List<prov_wrap_Claim.ReferralHeaderResponseWrapper> externalReferralResponseWrappers = new List<prov_wrap_Claim.ReferralHeaderResponseWrapper>();
        List<prov_wrap_Claim.ReferralHeaderResponseWrapper> internalReferralResponseWrappers = new List<prov_wrap_Claim.ReferralHeaderResponseWrapper>();
        Map<String,List<prov_wrap_Claim.ReferralHeaderResponseWrapper>> referralResponseWrappersMap = new Map<String,List<prov_wrap_Claim.ReferralHeaderResponseWrapper>>();

        Set<String> externalReferralNumbers = new Set<String>();

        if(prov_util_MockData.useMockData) {
            for(Claim__c tempReferral : queryReferralDrafts(1000, businessId, referralHeader, externalReferralNumbers)) {
                prov_wrap_Claim.ReferralHeaderResponseWrapper submittedReferral = transformReferralToWrapper(tempReferral);
                system.debug('submittedReferral: '+submittedReferral);
                internalReferralResponseWrappers.add(submittedReferral);
            }
            referralResponseWrappersMap.put('calloutSuccess', internalReferralResponseWrappers);            
        } else {
            // clone header to update the callout strings or the internal search will fail
            prov_wrap_Claim.ReferralHeaderRequestWrapper externalHeader = referralHeader.clone();
            externalReferralResponseWrappers = queryExternalReferrals(externalHeader);
            if(externalReferralResponseWrappers != null) {
                referralResponseWrappersMap.put('calloutSuccess',externalReferralResponseWrappers);
                system.debug('referralResponseWrappersMap: '+referralResponseWrappersMap);
                externalReferralNumbers = getExternalReferralNumberSet(externalReferralResponseWrappers);
                system.debug('externalReferralNumbers: '+externalReferralNumbers);
            }
            // query and add the referrals from inside SF - limit to 500
            // only search submitted referrals if the status from the search is one of the below
            if(referralHeader.RequestStatus == null || referralHeader.RequestStatus == 'All' || referralHeader.RequestStatus == 'Accepted' || referralHeader.RequestStatus == '' || referralHeader.RequestStatus == 'Select') {
                for(Claim__c tempReferral : queryReferralDrafts(1000, businessId, referralHeader, externalReferralNumbers)) {
                    prov_wrap_Claim.ReferralHeaderResponseWrapper submittedReferral = transformReferralToWrapper(tempReferral);
                    system.debug('submittedReferral: '+submittedReferral);
                    internalReferralResponseWrappers.add(submittedReferral);
                }
            }
            // set response map so we can show an error to the user when the callout is a failure
            if(referralResponseWrappersMap.containsKey('calloutSuccess')) {
                referralResponseWrappersMap.get('calloutSuccess').addAll(internalReferralResponseWrappers);
            } else {
                referralResponseWrappersMap.put('calloutError', internalReferralResponseWrappers);
            }
        }
		system.debug('referralResponseWrappersMap: '+ referralResponseWrappersMap);
        return referralResponseWrappersMap;
    }*/

	@AuraEnabled
    public static List<Account> getAllAvailableDentists(String currentBusinessId) {
        //populate strings with values for DAL query
        system.debug('prov_ctrl_Referral_Search.currentBusinessId: '+currentBusinessId);
        Id bizId = Id.valueOf(currentBusinessId);
        // system.debug('prov_ctrl_Referral_Search.bizId: '+bizId);
        List<Account> availableDentistsResult = prov_util_Cache.retrieveProviders(bizId);
        availableDentistsResult.sort();
        system.debug('availableDentistsResult apex: '+availableDentistsResult);
        return availableDentistsResult;
    }

	@AuraEnabled
    public static List<Account> getAllAvailableServiceLocations(String currentBusinessId) { 
        //populate strings with values for DAL query
        List<Account> availableServiceLocationResult = prov_util_Cache.retrieveServiceLocation(currentBusinessId);
        availableServiceLocationResult.sort();
        system.debug('availableServiceLocationResult apex: '+availableServiceLocationResult);
        return availableServiceLocationResult;
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

    @TestVisible private static Set<String> getExternalReferralNumberSet(List<prov_wrap_Claim.ReferralHeaderResponseWrapper> referralResponseWrappers) {
        Set<String> referralNumberSet = new Set<String>();
        for(prov_wrap_Claim.ReferralHeaderResponseWrapper tempReferral : referralResponseWrappers) {
            referralNumberSet.add(tempReferral.ClaimNumber);
        }
        return referralNumberSet;
    }
    
    /*private static List<prov_wrap_Claim.ReferralHeaderResponseWrapper> queryExternalReferrals(prov_wrap_Claim.ReferralHeaderRequestWrapper incomingReferralHeaderWrapper) {
        //update referral header fields for multi query
        if(incomingReferralHeaderWrapper.ServiceOfficeGuids != null) {
            String serviceOfficeGuids = createGuidString(incomingReferralHeaderWrapper.ServiceOfficeGuids);
            incomingReferralHeaderWrapper.ServiceOfficeGuids = serviceOfficeGuids;
        }
        if(incomingReferralHeaderWrapper.SubmittingDentistGuids != null) {
            String providerGuids = createGuidString(incomingReferralHeaderWrapper.SubmittingDentistGuids);
            incomingReferralHeaderWrapper.SubmittingDentistGuids = providerGuids;
        }
        return prov_util_ClaimCallout.requestReferralHeaders(incomingReferralHeaderWrapper);
    }*/

    private static List<Claim__c> queryReferralDrafts(Integer limitNum, String businessId, prov_Wrap_Claim.ReferralHeaderRequestWrapper referralHeader, Set<String> externalReferralNumbers) {
        String whereClause = createSubmittedReferralWhereClause(limitNum, businessId, referralHeader, externalReferralNumbers);
      
        return (List<Claim__c>)prov_util_DAL.dalQuery('Claim__c', whereClause);
    } 

    private static prov_wrap_Claim.ReferralHeaderResponseWrapper transformReferralToWrapper(Claim__c tempReferral) {
        prov_wrap_Claim.ReferralHeaderResponseWrapper submittedReferral = new prov_wrap_Claim.ReferralHeaderResponseWrapper();
        submittedReferral.MemberFirstName = tempReferral.Subscriber_First_Name__c;
        submittedReferral.MemberLastName = tempReferral.Subscriber_Last_Name__c;
        submittedReferral.SubmittedDate = tempReferral.Submitted_DateTime__c;
        submittedReferral.MemberId = tempReferral.Subscriber_ID__c;
        submittedReferral.SubmittingProviderAddressLine1 = tempReferral.Treating_Provider_Address1__c;
        submittedReferral.SubmittingProviderCity = tempReferral.Treating_Provider_City__c;
        submittedReferral.SubmittingProviderFirstName = tempReferral.Treating_Provider_First_Name__c;
        submittedReferral.SubmittingProviderLastName = tempReferral.Treating_Provider_Last_Name__c;
        submittedReferral.ReferringProviderLastName = tempReferral.Referral_Treating_Provider_Name__c;
        submittedReferral.Status = tempReferral.Claim_Draft_Status__c;
        submittedReferral.ClaimNumber = tempReferral.Claim_Number__c;
        submittedReferral.SalesforceId = tempReferral.Id; // set SalesforceId for redirect to referral detail 
        return submittedReferral;
    }

    private static String createSubmittedReferralWhereClause(Integer limitNum, String businessId, prov_Wrap_Claim.ReferralHeaderRequestWrapper referralHeader, Set<String> externalReferralNumbers) {
        String whereClause = 'WHERE ';
        // start adding in the search criteria from the referral request wrapper
        // service date will ALWAYS be provided, as it is required on the search page 
        // escaping single quotes on free form input from user to avoid SOQL injection
        if(referralHeader.SubmittedDateStart != null) {
            Date receivedDateStart = referralHeader.SubmittedDateStart;
            system.debug('receivedDateStart: '+receivedDateStart);
            String dateStr = DateTime.newInstance(receivedDateStart, Time.newInstance(0,0,0,0)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            whereClause += 'Submitted_DateTime__c >= '+ dateStr + ' AND ';
        }
        if(referralHeader.SubmittedDateEnd != null) {
            Date receivedDateEnd = referralHeader.SubmittedDateEnd;
            receivedDateEnd = receivedDateEnd.addDays(1);
            system.debug('receivedDateEnd: '+receivedDateEnd);
            String dateStr = DateTime.newInstance(receivedDateEnd, Time.newInstance(0,0,0,0)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            whereClause += 'Submitted_DateTime__c < '+ dateStr + ' AND ';
        }
        if(referralHeader.MemberFirstName != null) {
            String memberFirstName = String.escapeSingleQuotes(referralHeader.MemberFirstName);
            whereClause += 'Subscriber_First_Name__c LIKE \'%' + memberFirstName + '%\'' + ' AND ';
        }
        if(referralHeader.MemberLastName != null) {
            String memberLastName = String.escapeSingleQuotes(referralHeader.MemberLastName);
            whereClause += 'Subscriber_Last_Name__c LIKE \'%' + memberLastName + '%\'' + ' AND ';            
        }
        if(referralHeader.MemberDateOfBirth != null) {
            String memberDOB = String.escapeSingleQuotes(String.valueOf(referralHeader.MemberDateOfBirth));
            whereClause += 'Subscriber_Birth_Date__c = ' + memberDOB + ' AND ';
        }
        if(referralHeader.ServiceOfficeGuids != null) {
            String serviceOfficeGuids = createInClauseString(referralHeader.ServiceOfficeGuids);
            whereClause += 'Service_Location__r.windward_guid__c IN (' + serviceOfficeGuids + ')' + ' AND ';
        }
        if(referralHeader.SubmittingDentistGuids != null) {
            String providerGuids = createInClauseString(referralHeader.SubmittingDentistGuids);
            whereClause += 'Provider__r.windward_guid__c IN (' + providerGuids + ')' + ' AND ';
        }
        if(referralHeader.ReferralNumber != null) {
            String referralNumber = String.escapeSingleQuotes(referralHeader.ReferralNumber);
            whereClause += 'Claim_Number__c = \'' + referralNumber + '\'' + ' AND ';
        }
        if(referralHeader.MemberId != null) {
            String memberNumber = String.escapeSingleQuotes(referralHeader.MemberId);
            whereClause += 'Subscriber_ID__c = \'' + memberNumber + '\'' + ' AND ';
        }
        if(referralHeader.RequestedSpecialty != null) {
            whereClause += 'Requested_Specialty__c = \'' + referralHeader.RequestedSpecialty + '\'' + ' AND ';
        }
        // exclude submitted SF referrals that have been pushed to WW but not deleted from SF yet        
        if(!externalReferralNumbers.isEmpty()) { 
            String externalNumbers = createInClauseStringFromSet(externalReferralNumbers);
            whereClause += 'Claim_Number__c NOT IN (' + externalNumbers + ')' + ' AND ';
        }
        // add in 'static' variables
        whereClause += 'Business__c = \'' + businessId + '\'' + ' AND ';
        if(referralHeader.RequestStatus != '' && referralHeader.RequestStatus != 'All')
        	whereClause += 'Claim_Draft_Status__c = \''+referralHeader.RequestStatus+'\'' + ' AND '; 
        whereClause += 'Claim_Type__c = \'REFERRAL\'';
        whereClause += ' ORDER BY Claim_Number__c DESC';
		if(limitNum != null) {
        	whereClause += ' LIMIT ' + limitNum;
		}
        system.debug('prov_ctrl_Referral_Search whereClause: '+ whereClause);
        return whereClause;
    }

    /*Creates comma separated string for dynamic SOQL 'in' clause*/
    private static String createInClauseString(String searchString) {
        String returnString = '';
        if(searchString.indexOf('; ') > -1) {
            for(String value : searchString.split('; ')) {
                returnString += '\'' + value + '\',';
            }
            system.debug('multiple values in searchString');
        } else {
            returnString = '\'' + searchString + '\'';
            system.debug('single in searchString');
        }
        system.debug('referral search searchString: '+returnString);
        return returnString.removeEnd(',');
    }

    /*Creates comma separated string for dynamic SOQL 'in' clause*/
    @TestVisible private static String createInClauseStringFromSet(Set<String> searchStringSet) {
        String returnString = '';
        for(String referralNumber : searchStringSet) {
            returnString += '\'' + referralNumber + '\',';
        }
        system.debug('referral search searchStringSet: '+returnString);
        return returnString.removeEnd(',');
    }

    /*Creates comma separated string for WW REST callout*/
    @TestVisible private static String createGuidString(String searchString) {
        String returnString = '';
        if(searchString.indexOf(';') > -1) {
            for(String value : searchString.split('; ')) {
                returnString +=  value + ',';
            }
        } else {
            returnString = searchString;
        }
        system.debug('referral search createGuidString: '+returnString);
        return returnString.removeEnd(',');
    }
}