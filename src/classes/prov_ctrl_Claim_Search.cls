global without sharing class prov_ctrl_Claim_Search {

    public String portalURL {get;set;}

	public Boolean useMockData {get;set;}

	public prov_ctrl_Claim_Search() {
		portalURL = System.Label.Member_Eligibility_VF_URL;
		useMockData = prov_util_MockData.useMockData;
	}

    @RemoteAction
    global static object searchClaimsRemote(String header, String businessId){
        system.debug('header ' + header);
        system.debug('businessId ' + businessId);
        prov_Wrap_Claim.ClaimHeaderRequestWrapper claimHeader = (prov_Wrap_Claim.ClaimHeaderRequestWrapper) System.JSON.deserialize(header,prov_Wrap_Claim.ClaimHeaderRequestWrapper.class);
        system.debug('claimHeader ' + claimHeader);

        HttpRequest claimRequest = prov_util_ClaimCallout.requestClaimHeadersRemote(claimHeader);

        //create a continuation for callout
        Continuation con = new Continuation(20);
        String request = con.addHttpRequest(claimRequest);
        con.state = request;
        con.continuationMethod = 'callback';
        return con;
    }

    global static object callback(Object state){
        System.debug('in callback');

        HttpResponse res; 

        if(!Test.isRunningTest()){
            res = Continuation.getResponse((String) state);
            System.debug('response ' + res);
            System.debug('response ' + res.getBody());
        } else {
            //make httpResponse here
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"SearchResult":[{"BusinessGuid":"083149db-9c70-4d09-b21e-87150336cd65","ServiceOfficeGuid":"74e893fa-4db5-47d3-a429-8e5695ec048b","TreatingDentistGuid":"285f48b0-d961-45d0-a8ee-d84c3524a839","ClaimNumber":"101429348730100","ClaimGuid":"341b8cde-895e-40c2-99d2-bb7d33364a14","StatusCategory":"Finalized","ClaimType":"AUTH","PlanGuid":"5881abae-9db1-40e2-9c66-82fcce7d131d","PlanName":"TX Medicaid Child (Under 21)","MemberId":"208473936","UniversalMemberGuid":"1a0ea11b-2d5c-ec6b-409e-6fd7167c3aed","MemberFirstName":"Wallace","MemberLastName":"Ayers","TreatingDentistFirstName":"Jovani","TreatingDentistLastName":"Stout","ServiceOfficeAddress1":"William Street","ServiceOfficeAddress2":"","ServiceOfficeCity":"NORTH RICHLAND HILLS","ReceivedDate":"2015-10-22T00:00:00","ServiceDate":"2015-10-26T00:00:00","BilledAmount":700.00,"PaidAmount":176.40}],"TotalCount":1,"QueryTotalTimeMs":166}');  
        }

        //200 code is good, all others is error
        if(res.getStatusCode()!=200){
            system.debug('--Claim Request -------------------------------------------------------------------------');
            system.debug('Response failed.');
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
            system.debug('--Claim Request-------------------------------------------------------------------------');
            return null;
        } else {
            system.debug('Claim Request: ' + res.getBody());
            return res.getBody();
        }
    }

    @RemoteAction
    global static String postProcess(String resultsStr, String header, String businessId){
        //process results
        // turn result into overall result wrapper
        prov_wrap_Claim.ClaimHeaderResultWrapper resultWrapper = (prov_wrap_Claim.ClaimHeaderResultWrapper) System.JSON.deserialize(resultsStr, prov_wrap_Claim.ClaimHeaderResultWrapper.class);
        system.debug('result wrapper: '+resultWrapper);
        
        prov_Wrap_Claim.ClaimHeaderRequestWrapper claimHeader = (prov_Wrap_Claim.ClaimHeaderRequestWrapper) System.JSON.deserialize(header,prov_Wrap_Claim.ClaimHeaderRequestWrapper.class);

        // extract list of individual results from overall wrapper
        List<prov_wrap_Claim.ClaimHeaderResponseWrapper> returnedClaims = (List<prov_wrap_Claim.ClaimHeaderResponseWrapper>) resultWrapper.SearchResult;

        List<prov_wrap_Claim.ClaimHeaderResponseWrapper> internalClaimResponseWrappers = new List<prov_wrap_Claim.ClaimHeaderResponseWrapper>();
        Map<String,List<prov_wrap_Claim.ClaimHeaderResponseWrapper>> claimResponseWrappersMap = new Map<String,List<prov_wrap_Claim.ClaimHeaderResponseWrapper>>();

        Set<String> externalClaimNumbers = new Set<String>();

        if(returnedClaims != null) {
            claimResponseWrappersMap.put('calloutSuccess',returnedClaims);
            system.debug('claimResponseWrappersMap: '+claimResponseWrappersMap);
            externalClaimNumbers = getExternalClaimNumberSet(returnedClaims);
            system.debug('externalClaimNumbers: '+externalClaimNumbers);
        }
        // query and add the claims from inside SF - limit to 500
        // only search submitted claims if the status from the search is one of the below
        //if(claimHeader.StatusCategory == null || claimHeader.StatusCategory == 'All' || claimHeader.StatusCategory == 'Accepted' || claimHeader.StatusCategory == '' || claimHeader.StatusCategory == 'Select') {
            for(Claim__c tempClaim : queryClaimDrafts(1000, businessId, claimHeader, externalClaimNumbers)) {
                prov_wrap_Claim.ClaimHeaderResponseWrapper submittedClaim = transformClaimToWrapper(tempClaim);
                system.debug('submittedClaim: '+submittedClaim);
                internalClaimResponseWrappers.add(submittedClaim);
            }
        //}
        // set response map so we can show an error to the user when the callout is a failure
        if(claimResponseWrappersMap.containsKey('calloutSuccess')) {
            claimResponseWrappersMap.get('calloutSuccess').addAll(internalClaimResponseWrappers);
        } else {
            claimResponseWrappersMap.put('calloutError', internalClaimResponseWrappers);
        }
            
        //return response wrapper as string
        return JSON.serialize(claimResponseWrappersMap);
    }

	@AuraEnabled
    public static List<Account> getAllAvailableDentists(String currentBusinessId) {
        //populate strings with values for DAL query
        system.debug('prov_ctrl_Claim_Search.currentBusinessId: '+currentBusinessId);
        Id bizId = Id.valueOf(currentBusinessId);
        // system.debug('prov_ctrl_Claim_Search.bizId: '+bizId);
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

    @TestVisible private static Set<String> getExternalClaimNumberSet(List<prov_wrap_Claim.ClaimHeaderResponseWrapper> claimResponseWrappers) {
        Set<String> claimNumberSet = new Set<String>();
        for(prov_wrap_Claim.ClaimHeaderResponseWrapper tempClaim : claimResponseWrappers) {
            claimNumberSet.add(tempClaim.ClaimNumber);
        }
        return claimNumberSet;
    }

    private static List<Claim__c> queryClaimDrafts(Integer limitNum, String businessId, prov_Wrap_Claim.ClaimHeaderRequestWrapper claimHeader, Set<String> externalClaimNumbers) {
        String whereClause = createSubmittedClaimWhereClause(limitNum, businessId, claimHeader, externalClaimNumbers);
      
        return (List<Claim__c>)prov_util_DAL.dalQuery('Claim__c', whereClause);
    }

    private static prov_wrap_Claim.ClaimHeaderResponseWrapper transformClaimToWrapper(Claim__c tempClaim) {
        prov_wrap_Claim.ClaimHeaderResponseWrapper submittedClaim = new prov_wrap_Claim.ClaimHeaderResponseWrapper();
        submittedClaim.MemberFirstName = tempClaim.Subscriber_First_Name__c;
        submittedClaim.MemberLastName = tempClaim.Subscriber_Last_Name__c;
        if(tempClaim.Service_Date__c != null) {
            submittedClaim.ServiceDate = DateTime.newInstance(tempClaim.Service_Date__c.year(),tempClaim.Service_Date__c.month(),tempClaim.Service_Date__c.day());
        }
        submittedClaim.ServiceOfficeAddress1 = tempClaim.Treating_Provider_Address1__c;
        submittedClaim.ServiceOfficeCity = tempClaim.Treating_Provider_City__c;
        submittedClaim.TreatingDentistFirstName = tempClaim.Treating_Provider_First_Name__c;
        submittedClaim.TreatingDentistLastName = tempClaim.Treating_Provider_Last_Name__c;
        submittedClaim.StatusCategory = tempClaim.Claim_Draft_Status__c;
        submittedClaim.ClaimNumber = tempClaim.Claim_Number__c;
        submittedClaim.BilledAmount = tempClaim.Total_Billed_Amount__c;
        submittedClaim.PaidAmount = 0;
        submittedClaim.SalesforceId = tempClaim.Id; // set SalesforceId for redirect to claim detail 
        return submittedClaim;
    }

    private static String createSubmittedClaimWhereClause(Integer limitNum, String businessId, prov_Wrap_Claim.ClaimHeaderRequestWrapper claimHeader, Set<String> externalClaimNumbers) {
        String whereClause = 'WHERE ';
        // start adding in the search criteria from the claim request wrapper
        // escaping single quotes on free form input from user to avoid SOQL injection
        if(claimHeader.DateOfServiceStart != null) {
            String serviceStart = String.escapeSingleQuotes(String.valueOf(claimHeader.DateOfServiceStart));            
            whereClause += 'Service_Date__c >= '+ serviceStart + ' AND ';
        }
        if(claimHeader.DateOfServiceEnd != null) {
            String serviceEnd = String.escapeSingleQuotes(String.valueOf(claimHeader.DateOfServiceEnd));
            whereClause += 'Service_Date__c <= '+ serviceEnd + ' AND ';
        }
        if(claimHeader.ReceivedDateStart != null) {
            Date receivedDateStart = claimHeader.ReceivedDateStart;
            system.debug('receivedDateStart: '+receivedDateStart);
            String dateStr = DateTime.newInstance(receivedDateStart, Time.newInstance(0,0,0,0)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            whereClause += 'Submitted_DateTime__c >= '+ dateStr + ' AND ';
        }
        if(claimHeader.ReceivedDateEnd != null) {
            Date receivedDateEnd = claimHeader.ReceivedDateEnd;
            receivedDateEnd = receivedDateEnd.addDays(1);
            system.debug('receivedDateEnd: '+receivedDateEnd);
            String dateStr = DateTime.newInstance(receivedDateEnd, Time.newInstance(0,0,0,0)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            whereClause += 'Submitted_DateTime__c < '+ dateStr + ' AND ';
        }
        if(claimHeader.MemberFirstName != null) {
            String memberFirstName = String.escapeSingleQuotes(claimHeader.MemberFirstName);
            whereClause += 'Subscriber_First_Name__c LIKE \'%' + memberFirstName + '%\'' + ' AND ';
        }
        if(claimHeader.MemberLastName != null) {
            String memberLastName = String.escapeSingleQuotes(claimHeader.MemberLastName);
            whereClause += 'Subscriber_Last_Name__c LIKE \'%' + memberLastName + '%\'' + ' AND ';            
        }
        if(claimHeader.MemBirthDate != null) {
            String memberDOB = String.escapeSingleQuotes(String.valueOf(claimHeader.MemBirthDate));
            whereClause += 'Subscriber_Birth_Date__c = ' + memberDOB + ' AND ';
        }
        if(claimHeader.ServiceOfficeGuids != null) {
            String serviceOfficeGuids = createInClauseString(claimHeader.ServiceOfficeGuids);
            whereClause += 'Service_Location__r.windward_guid__c in (' + serviceOfficeGuids + ')' + ' AND ';
        }
        if(claimHeader.TreatingDentistGuids != null) {
            String providerGuids = createInClauseString(claimHeader.TreatingDentistGuids);
            whereClause += 'Provider__r.windward_guid__c in (' + providerGuids + ')' + ' AND ';
        }
        if(claimHeader.ClaimNumber != null) {
            String claimNumber = String.escapeSingleQuotes(claimHeader.ClaimNumber);
            whereClause += 'Claim_Number__c = \'' + claimNumber + '\'' + ' AND ';
        }
        if(claimHeader.MemberId != null) {
            String memberNumber = String.escapeSingleQuotes(claimHeader.MemberId);
            whereClause += 'Subscriber_ID__c = \'' + memberNumber + '\'' + ' AND ';
        }        
        // exclude submitted SF claims that have been pushed to WW but not deleted from SF yet        
        if(!externalClaimNumbers.isEmpty()) { 
            String externalNumbers = createInClauseStringFromSet(externalClaimNumbers);
            whereClause += 'Claim_Number__c NOT IN (' + externalNumbers + ')' + ' AND ';
        }
        // add in 'static' variables
        whereClause += 'Business__c = \'' + businessId + '\'' + ' AND ';
        if(claimHeader.StatusCategory != '' && claimHeader.StatusCategory != 'All')
        whereClause += 'Claim_Draft_Status__c = \''+claimHeader.StatusCategory+'\'' + ' AND '; 
        whereClause += 'Claim_Type__c = \'CLAIM\'';
        whereClause += ' ORDER BY Claim_Number__c DESC';
		if(limitNum != null) {
        	whereClause += ' LIMIT ' + limitNum;
		}
        system.debug('prov_ctrl_Claim_Search whereClause: '+ whereClause);
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
        system.debug('claim search searchString: '+returnString);
        return returnString.removeEnd(',');
    }

    /*Creates comma separated string for dynamic SOQL 'in' clause*/
    @TestVisible private static String createInClauseStringFromSet(Set<String> searchStringSet) {
        String returnString = '';
        for(String claimNumber : searchStringSet) {
            returnString += '\'' + claimNumber + '\',';
        }
        system.debug('claim search searchStringSet: '+returnString);
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
        system.debug('claim search createGuidString: '+returnString);
        return returnString.removeEnd(',');
    }
}