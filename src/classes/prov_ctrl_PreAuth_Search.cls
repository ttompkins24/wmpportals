global with sharing class prov_ctrl_PreAuth_Search {
	
    public String portalURL {get;set;}

    public prov_ctrl_PreAuth_Search() { 
        portalURL = System.Label.Member_Eligibility_VF_URL;
    }

    @RemoteAction
    global static object searchPreAuthsRemote(String header, String businessId){
        system.debug('header ' + header);
        system.debug('businessId ' + businessId);
        prov_Wrap_Claim.ClaimHeaderRequestWrapper authHeader = (prov_Wrap_Claim.ClaimHeaderRequestWrapper) System.JSON.deserialize(header,prov_Wrap_Claim.ClaimHeaderRequestWrapper.class);
        system.debug('authHeader ' + authHeader);

        HttpRequest preAuthRequest = prov_util_ClaimCallout.requestClaimHeadersRemote(authHeader);

        //create a continuation for callout
        Continuation con = new Continuation(20);
        String request = con.addHttpRequest(preAuthRequest);
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
            system.debug('--Pre Auth Request -------------------------------------------------------------------------');
            system.debug('Response failed.');
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
            system.debug('--Pre Auth Request-------------------------------------------------------------------------');
            return null;
        } else {
            system.debug('Pre Auth Request: ' + res.getBody());
            return res.getBody();
        }
    }

    @RemoteAction
    global static String postProcess(String resultsStr, String header, String businessId){
        
        //process results
        // turn result into overall result wrapper
        prov_wrap_Claim.ClaimHeaderResultWrapper resultWrapper = (prov_wrap_Claim.ClaimHeaderResultWrapper) System.JSON.deserialize(resultsStr, prov_wrap_Claim.ClaimHeaderResultWrapper.class);
        system.debug('result wrapper: '+resultWrapper);
        
        prov_Wrap_Claim.ClaimHeaderRequestWrapper authHeader = (prov_Wrap_Claim.ClaimHeaderRequestWrapper) System.JSON.deserialize(header,prov_Wrap_Claim.ClaimHeaderRequestWrapper.class);

        // extract list of individual results from overall wrapper
        List<prov_wrap_Claim.ClaimHeaderResponseWrapper> returnedClaims = (List<prov_wrap_Claim.ClaimHeaderResponseWrapper>) resultWrapper.SearchResult;

        List<prov_wrap_Claim.ClaimHeaderResponseWrapper> internalAuthResponseWrappers = new List<prov_wrap_Claim.ClaimHeaderResponseWrapper>();
        Map<String,List<prov_wrap_Claim.ClaimHeaderResponseWrapper>> authResponseWrappersMap = new Map<String,List<prov_wrap_Claim.ClaimHeaderResponseWrapper>>();

        Set<String> externalAuthNumbers = new Set<String>();

        if(returnedClaims != null) {
            authResponseWrappersMap.put('calloutSuccess',returnedClaims);
            system.debug('claimResponseWrappersMap: '+authResponseWrappersMap);
            externalAuthNumbers = getExternalAuthNumberSet(returnedClaims);
            system.debug('externalAuthNumbers: '+externalAuthNumbers);
        }
        // query and add the auths from inside SF - limit to 500
        // only search submitted auths if the status from the search is one of the below
        if(authHeader.StatusCategory == null || authHeader.StatusCategory == 'All' || authHeader.StatusCategory == 'Accepted' || authHeader.StatusCategory == '' || authHeader.StatusCategory == 'Select') {
            for(Claim__c tempAuth : queryAuthDrafts(1000, businessId, authHeader, externalAuthNumbers)) {
                prov_wrap_Claim.ClaimHeaderResponseWrapper submittedAuth = transformAuthToWrapper(tempAuth);
                system.debug('submittedAuth: '+submittedAuth);
                internalAuthResponseWrappers.add(submittedAuth);
            }
        }
        // set response map so we can show an error to the user when the callout is a failure
        if(authResponseWrappersMap.containsKey('calloutSuccess')) {
            authResponseWrappersMap.get('calloutSuccess').addAll(internalAuthResponseWrappers);
        } else {
            authResponseWrappersMap.put('calloutError', internalAuthResponseWrappers);
        }
            
        //return response wrapper as string
        return JSON.serialize(authResponseWrappersMap);
    }

	@AuraEnabled
    public static List<Account> getAllAvailableDentists(String currentBusinessId) {
        //populate strings with values for DAL query
        system.debug('prov_ctrl_PreAuth_Search.currentBusinessId: '+currentBusinessId);
        Id bizId = Id.valueOf(currentBusinessId);
        // system.debug('prov_ctrl_PreAuth_Search.bizId: '+bizId);
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

    @TestVisible private static Set<String> getExternalAuthNumberSet(List<prov_wrap_Claim.ClaimHeaderResponseWrapper> authResponseWrappers) {
        Set<String> authNumberSet = new Set<String>();
        for(prov_wrap_Claim.ClaimHeaderResponseWrapper tempAuth : authResponseWrappers) {
            authNumberSet.add(tempAuth.ClaimNumber);
        }
        return authNumberSet;
    }

    private static List<Claim__c> queryAuthDrafts(Integer limitNum, String businessId, prov_Wrap_Claim.ClaimHeaderRequestWrapper authHeader, Set<String> externalAuthNumbers) {
        String whereClause = createSubmittedAuthWhereClause(limitNum, businessId, authHeader, externalAuthNumbers);
      
        return (List<Claim__c>)prov_util_DAL.dalQuery('Claim__c', whereClause);
    }

    private static prov_wrap_Claim.ClaimHeaderResponseWrapper transformAuthToWrapper(Claim__c tempAuth) {
        prov_wrap_Claim.ClaimHeaderResponseWrapper submittedAuth = new prov_wrap_Claim.ClaimHeaderResponseWrapper();
        submittedAuth.MemberFirstName = tempAuth.Subscriber_First_Name__c;
        submittedAuth.MemberLastName = tempAuth.Subscriber_Last_Name__c;
        if(tempAuth.Service_Date__c != null) {
            submittedAuth.ServiceDate = DateTime.newInstance(tempAuth.Service_Date__c.year(),tempAuth.Service_Date__c.month(),tempAuth.Service_Date__c.day());
        }
        submittedAuth.ServiceOfficeAddress1 = tempAuth.Treating_Provider_Address1__c;
        submittedAuth.ServiceOfficeCity = tempAuth.Treating_Provider_City__c;
        submittedAuth.TreatingDentistFirstName = tempAuth.Treating_Provider_First_Name__c;
        submittedAuth.TreatingDentistLastName = tempAuth.Treating_Provider_Last_Name__c;
        submittedAuth.StatusCategory = tempAuth.Claim_Draft_Status__c;
        submittedAuth.ClaimNumber = tempAuth.Claim_Number__c;
        submittedAuth.BilledAmount = tempAuth.Total_Billed_Amount__c;
        submittedAuth.PaidAmount = 0;
        submittedAuth.SalesforceId = tempAuth.Id; // set SalesforceId for redirect to pre-auth detail 
        return submittedAuth;
    }

    private static String createSubmittedAuthWhereClause (Integer limitNum, String businessId, prov_Wrap_Claim.ClaimHeaderRequestWrapper authHeader, Set<String> externalAuthNumbers) {
        String whereClause = 'WHERE ';
        // start adding in the search criteria from the pre-auth request wrapper 
        // escaping single quotes on free form input from user to avoid SOQL injection
        if(authHeader.ReceivedDateStart != null) {
            Date receivedDateStart = authHeader.ReceivedDateStart;
            system.debug('receivedDateStart: '+receivedDateStart);
            String dateStr = DateTime.newInstance(receivedDateStart, Time.newInstance(0,0,0,0)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            whereClause += 'Submitted_DateTime__c >= '+ dateStr + ' AND ';
        }
        if(authHeader.ReceivedDateEnd != null) {
            Date receivedDateEnd = authHeader.ReceivedDateEnd;
            receivedDateEnd = receivedDateEnd.addDays(1);
            system.debug('receivedDateEnd: '+receivedDateEnd);
            String dateStr = DateTime.newInstance(receivedDateEnd, Time.newInstance(0,0,0,0)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            whereClause += 'Submitted_DateTime__c < '+ dateStr + ' AND ';
        }
        if(authHeader.MemberFirstName != null) {
            String memberFirstName = String.escapeSingleQuotes(authHeader.MemberFirstName);
            whereClause += 'Subscriber_First_Name__c LIKE \'%' + memberFirstName + '%\'' + ' AND ';
        }
        if(authHeader.MemberLastName != null) {
            String memberLastName = String.escapeSingleQuotes(authHeader.MemberLastName);
            whereClause += 'Subscriber_Last_Name__c LIKE \'%' + memberLastName + '%\'' + ' AND ';            
        }
        if(authHeader.MemBirthDate != null) {
            String memberDOB = String.escapeSingleQuotes(String.valueOf(authHeader.MemBirthDate));
            whereClause += 'Subscriber_Birth_Date__c = ' + memberDOB + ' AND ';
        }
        if(authHeader.ServiceOfficeGuids != null) {
            String serviceOfficeGuids = createInClauseString(authHeader.ServiceOfficeGuids);
            whereClause += 'Service_Location__r.windward_guid__c IN (' + serviceOfficeGuids + ')' + ' AND ';
        }
        if(authHeader.TreatingDentistGuids != null) {
            String providerGuids = createInClauseString(authHeader.TreatingDentistGuids);
            whereClause += 'Provider__r.windward_guid__c IN (' + providerGuids + ')' + ' AND ';
        }
        if(authHeader.ClaimNumber != null) {
            String authNumber = String.escapeSingleQuotes(authHeader.ClaimNumber);
            whereClause += 'Claim_Number__c = \'' + authNumber + '\'' + ' AND ';
        }
        if(authHeader.MemberId != null) {
            String memberNumber = String.escapeSingleQuotes(authHeader.MemberId);
            whereClause += 'Subscriber_ID__c = \'' + memberNumber + '\'' + ' AND ';
        }
        // exclude submitted SF auths that have been pushed to WW but not deleted from SF yet
        if(!externalAuthNumbers.isEmpty()) {
            String externalNumbers = createInClauseStringFromSet(externalAuthNumbers);
            whereClause += 'Claim_Number__c NOT IN (' + externalNumbers + ')' + ' AND ';
        }
        // add in 'static' variables
        whereClause += 'Business__c = \'' + businessId + '\'' + ' AND ';
        if(authHeader.StatusCategory != '' && authHeader.StatusCategory != 'All')
        	whereClause += 'Claim_Draft_Status__c = \''+authHeader.StatusCategory+'\'' + ' AND '; 
        whereClause += 'Claim_Type__c = \'AUTH\'';
        whereClause += ' ORDER BY Claim_Number__c DESC';
		if(limitNum != null) {
        	whereClause += ' LIMIT ' + limitNum;
		}
        system.debug('prov_ctrl_PreAuth_Search whereClause: '+ whereClause);
        return whereClause;
    }

    /*Creates comma separated string for dynamic SOQL 'in' clause*/
    private static String createInClauseString(String searchString) {
        String returnString = '';
        if(searchString.indexOf(';') > -1) {
            for(String value : searchString.split('; ')) {
                returnString += '\'' + value + '\',';
            }
        } else {
            returnString = '\'' + searchString + '\'';
        }
        system.debug('pre-auth search searchString: '+returnString);
        return returnString.removeEnd(',');
    }

    /*Creates comma separated string for dynamic SOQL 'in' clause*/
    @TestVisible private static String createInClauseStringFromSet(Set<String> searchStringSet) {
        String returnString = '';
        for(String authNumber : searchStringSet) {
            returnString += '\'' + authNumber + '\',';
        }
        system.debug('auth search searchStringSet: '+returnString);
        return returnString.removeEnd(',');
    }

    /*Creates comma separated string for WW REST callout*/
    @TestVisible private static String createGuidString(String searchString) {
        String returnString = '';
        if(searchString.indexOf('; ') > -1) {
            for(String value : searchString.split('; ')) {
                returnString +=  value + ',';
            }
        } else {
            returnString = searchString;
        }
        system.debug('claim search searchString: '+returnString);
        return returnString.removeEnd(',');
    }
}