global without sharing class Prov_ctrl_PanelRoster {
	public String portalURL {get;set;}

	public Prov_ctrl_PanelRoster() {
		portalURL = System.Label.Member_Eligibility_VF_URL;
	}

	@AuraEnabled
	global static Account getAllBusinessesPanelRoster(){
		Account bizAcct = prov_util_Cache.CurrentBusiness;
		return bizAcct;
	}

	@AuraEnabled
	public static List<Account> getAllLocationsPanelRoster(Id bizAcctId){
		List<Account> locAcctList = prov_util_Cache.retrieveServiceLocation(bizAcctId);
		return locAcctList;
	}

	@AuraEnabled
	public static List<Account> getAllProvPanelRoster(Id bizAcctId, Id locAcctId){
		List<Account> provAcctList = prov_util_Cache.retrieveProviders(bizAcctId, locAcctId);
		return provAcctList;
	}

    @AuraEnabled
    public static Integer totalPages {get;set;}
    @AuraEnabled
    public static Integer pageNum {get;set;}
    @AuraEnabled
    public static Integer totalNumRecords {get;set;}
    
    @AuraEnabled
    public static List<Integer> paginationVariables(){
        //intitalize variables
        List<Integer> paginationVars = new List<Integer>();
        if(totalPages == null){
            totalPages = 1;
        }

        if(pageNum == null){
            pageNum = 1;
        }

        if(totalNumRecords == null){
            totalNumRecords = 1;
        }
        //add the results to the list to return
        paginationVars.add(totalPages);
        paginationVars.add(totalNumRecords);
        paginationVars.add(pageNum);
        //return the list
        return paginationVars;
    }

    @AuraEnabled
    public static mock_MemberCoverage__c getMemCovRecord(String memProGuidS){
        system.debug(memProGuidS);
        //query member coverage record if it isn't available in the client-side cache
        List<mock_MemberCoverage__c> memCovRecList = new List<mock_MemberCoverage__c>();
        Map<String, mock_MemberCoverage__c> memCovMap = prov_util_DAL.getMembersPlansMapByProfile(memproGuidS);
        for(mock_MemberCoverage__c mem : memCovMap.values()){
            memCovRecList.add(mem);
        }
        return memCovRecList[0];
    }

    //When a T1 user is searching by Provider only, send the BusinessGUID and the ProviderGUID
    //When a T2 user is searching by Provider only, send the BusinessGUID, ProviderGUID, and list of Service Location guids they have access to
	@RemoteAction
	global static object getPanelRosterResults(String str){
		System.debug('Passed in String: ' + str);
        Account bizAcct = prov_util_Cache.CurrentBusiness;

		//rehydrate JSON string into Search Wrapper class
		PanelRosterParam sw = (PanelRosterParam) System.JSON.deserialize(str, PanelRosterParam.class);
		System.debug('sw: ' + sw);
		//initialize params
		Integer page = 1;
        Integer numResults = 20;
        String sortField = sw.sortField;
        String sortDirection = sw.sortDirection;
        if(sw.pageNumS != null && sw.pageNumS != '')              page = Integer.valueOf(sw.pageNumS);
        system.debug('page '+page);
        if(sw.numResultsS != null && sw.numResultsS != '')        numResults = Integer.valueOf(sw.numResultsS);
        if(sortField == null || sortField == '')       	 	sortField = 'MemberId';
        if(sortDirection == null || sortDirection == '')   	sortDirection = 'DESC';
        
		String firstNameSearch = sw.firstNameSearch == null || sw.firstNameSearch == ''? null :  String.escapeSingleQuotes(sw.firstNameSearch);
    	String lastNameSearch = sw.lastNameSearch == null || sw.lastNameSearch == ''? null :  String.escapeSingleQuotes(sw.lastNameSearch);

        System.debug(':::permissions ' + prov_util_Cache.getPermissionObj(bizAcct.Id));
        System.debug(':::admin ' + prov_util_Cache.getPermissionObj(bizAcct.Id).admin);
        String tierAccess = prov_util_Cache.getPermissionObj(bizAcct.Id).tierAccess;
        System.debug(':::tierAccess ' + tierAccess);
        //if T2 include location ID
        String locAcctIdString;
        //if not t1, only get locations they can view
        
        if(sw.locAcctId != null && sw.locAcctId != '' && sw.locAcctId != 'Any'){
            locAcctIdString = [SELECT guid__c from Account Where id = :sw.locAcctId].guid__c;
        } else {
            if(tierAccess != '1'){  
                System.debug('::Non Tier 1 user');  
                //get string of windward guids for Location Acct that they can see
                locAcctIdString = '';
                List<Account> locs = prov_util_Cache.retrieveServiceLocation(bizAcct.Id);
                List<String> locWWIds = new List<String>();

                for(Account loc : locs){
                    locWWIds.add(loc.guid__c);                    
                }

                locAcctIdString = String.join(locWWIds, ',');
                
                system.debug('location ww guids'+locAcctIdString);
            } else {
                System.debug('::Tier 1 user');  
            }
        }
        
        //get string of windward guids for Provider Acct
    	String provAcctIdString = null;
        if(sw.provAcctId != null && sw.provAcctId != '' && sw.provAcctId != 'Any'){
            provAcctIdString = [SELECT guid__c from Account Where id = :sw.provAcctId].guid__c;
        }  

        //get matching plan guids
    	//String bizAcctString = bizAcctId; 
    	
    	//planGUIDStringSet = prov_util_Cache.cobj.BusinessId2PlanWWIdsMap.get(bizAcctId);
    	//convert plan guid set to plan guid list
    	//List<String> planGuidStringList = new List<String>(planGUIDStringSet);

        //populate strings with values for DAL query
    	String order = '';
    	if(sortField != null || sortDirection != null){
    		order = ' ORDER BY '+sortField+' '+sortDirection;
    	}
        String limitNum = ' LIMIT ' + numResults;
        String offset = ' Offset ' + ((page-1)*numResults);
        /*
        public String SortField{get;set;}
    	public String SortDirection{get;set;}
    	public Integer PageNumber{get;set;}
    	public Integer RecordsPerPage{get;set;}
        */
                                                     
    	PanelRosterCalloutWrapper calloutWrapper = new PanelRosterCalloutWrapper();
        calloutWrapper.BusinessGUID = bizAcct.guid__c;
    	calloutWrapper.ServiceOfficeGUIDs = locAcctIdString;
    	//calloutWrapper.ServiceLocationGUID = '4D2B79C5-48B9-42B9-AA32-5829A895ECB2';
    	calloutWrapper.ProviderGuid = provAcctIdString;
    	calloutWrapper.FirstName  = firstNameSearch;
    	calloutWrapper.LastName = lastNameSearch;
    	calloutWrapper.SortField = sortField;
    	calloutWrapper.SortDirection = sortDirection;
    	calloutWrapper.PageNumber = page;
    	calloutWrapper.RecordsPerPage = numResults;
    	//calloutWrapper.ProviderGuid = null;
    	calloutWrapper.RouteId = sw.routeId;
    	calloutWrapper.DownloadRecords = false;
    	PanelRosterHeaderResponseWrapper resHeaderWrapper = new PanelRosterHeaderResponseWrapper();
        resHeaderWrapper.Total = 1;
        
        system.debug('calloutWrapper' + calloutWrapper);
		if(prov_util_MockData.useMockData){
            System.debug('is Mock Data');
            System.debug('prov acct' +sw.provAcctId);
            System.debug('loc acct' + sw.locAcctId);
            //we are in test or dev, do not make the callout 
            mock_MemberPrimaryCareDentist__c[] mPCDList = prov_util_DAL.getPrimaryDentistsByPSL(sw.locAcctId, sw.provAcctId);
            system.debug('mock PCD list' + mPCDList);
            resHeaderWrapper.Total = 0;
            //system.debug('pcd member guid::' + mPCD.MemberProfileGuid__c);
			for(mock_MemberPrimaryCareDentist__c mPCD : mPCDList){
				
	            PanelRosterResponseWrapper wrapper = new PanelRosterResponseWrapper();
	                
	            wrapper.FirstName = mPCD.FirstName__c;
	            wrapper.LastName = mPCD.LastName__c;
	            wrapper.MemberId = mPCD.Subscriber_Id__c;
	            wrapper.BirthDate = mPCD.Birthdate__c;
	            wrapper.EffectiveDate = mPCD.EffectiveDate__c;
	            wrapper.PlanGuid = mPCD.PlanGuid__c;
	            wrapper.MemberProfileGuid =mPCD.MemberProfileGuid__c;
	            wrapper.UniversalMemberGuid = mPCD.MemberProfileGuid__c; 
	            wrapper.Address = '210 W PAISANO LN,,WESLACO,TX,78599';
	            wrapper.ProviderGuid = '444-333123';
	            wrapper.PhoneNumber = '222-222-2222';
	            wrapper.Language = 'English';
	
	            resHeaderWrapper.PanelRosterRecords.add(wrapper);
	            resHeaderWrapper.Total += 1;
			}

            system.debug('resheaderwrapper ::: ' + resHeaderWrapper);

            String panelRosterResult = JSON.serialize(resHeaderWrapper); 
            System.debug('panel roster results: ' + panelRosterResult);
            return panelRosterResult; 
        } else {
			
			HTTPRequest request = calloutWrapper.retrieveRecords_continuation();
			//Create a continuation for HTTPRequest
	        Continuation con = new Continuation(60);
	        con.state = con.addHttpRequest(request);
	        con.continuationMethod = 'callback';
	        return con;
       } 
	}
	
	global static object callback(Object state){
        System.debug('chatURL: ' + prov_util_Cache.getPortalConfiguration().Live_Agent_Init_URL__c);
        String url = prov_util_Cache.getPortalConfiguration().Live_Agent_Init_URL__c;
        System.debug('JSURL: '  + url.substring(0, url.length()-4) + 'content/g/js/32.0/prechat.js');

        System.debug('in callback');
		
        HttpResponse res = Continuation.getResponse((String) state);
        System.debug('response ' + res);
        System.debug('response ' + res.getBody());

        if(res.getStatusCode()!=200){
            system.debug('--Panel Roster Search Request-------------------------------------------------------------------------');
            system.debug('Response failed.');
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
            system.debug('--Panel Roster Search Request-------------------------------------------------------------------------');
              String str = '{"FirstName":"Error","LastName":"timeout"}';
            return (Object) str; 
        } else {
            system.debug('Panel Roster Body success ');
                        
	        return res.getBody();
        }
    }
    
    @RemoteAction
    global static List<prov_wrap_PanelRoster> afterResponseLogic(String response){
        system.debug('after response logic::' + response);
    	PanelRosterHeaderResponseWrapper resultHeader = ( PanelRosterHeaderResponseWrapper)JSON.deserialize(response, PanelRosterHeaderResponseWrapper.class);
    	List<PanelRosterResponseWrapper> resultList = new List<PanelRosterResponseWrapper>();
    	List<prov_wrap_PanelRoster> finalResults = new List<prov_wrap_PanelRoster>();
    	Map<String,List<Account>> pcdGuidAcctMap = new Map<String,List<Account>>();
        Map<String,Account> planGuidAcctMap = new Map<String,Account>();
        
        resultHeader.status = 'SUCCESS'; 
        system.debug('panel roster response header wrapper' + resultHeader);
        
		SYstem.debug('retrieveRecords End...'); 
		
		if(resultHeader != null){
		    if(resultHeader.Total != null){
				resultList = resultHeader.PanelRosterRecords;
				totalNumRecords = resultHeader.Total;
		    }
		}
        system.debug('panel roster result Header' + resultHeader);
        system.debug('panel roster result list' + resultList);
        
        try{
			/*
            if(provAcctId == null){
                system.debug('in if');
                totalPCDList = prov_util_DAL.getTotalPrimaryDentistsPanel(locAcctIdString, planGuidStringList, order, searchLikeFirstName, searchLikeLastName);
                
            }else{
                system.debug('in else');
                totalPCDList = prov_util_DAL.getTotalPrimaryDentistsPanel(locAcctIdString, provAcctIdString, planGuidStringList, order, searchLikeFirstName, searchLikeLastName);
                

            }*/
            if(resultList.size() > 0){

                system.debug(resultList);
	            Set<String> planGuidSet  = new Set<String>();
	            for(PanelRosterResponseWrapper memPCD : resultList){
                    system.debug('memPCD in loop from resultList' + memPCD);
	            	//if name is entered, remove the results that didnt meet the criteria
	            	
	            	//initialize the wrapper
	            	prov_wrap_PanelRoster prWrapper = new prov_wrap_PanelRoster();
	                //populate wrapper record with values from returned list from DAL
                    if(memPCD.BirthDate != null){
	                prWrapper.birthDate = memPCD.BirthDate.dateGMT();
                        
                    }
	                prWrapper.firstName = memPCD.FirstName;
	                prWrapper.lastName = memPCD.LastName;
	                prWrapper.memberNumber = memPCD.MemberId;
	                prWrapper.effectiveDate = memPCD.EffectiveDate.dateGMT();
	                prWrapper.memberProfileGuid = memPCD.MemberProfileGUID;
                    prWrapper.universalMemberGuid = memPCD.UniversalMemberGuid;
                    prWrapper.phone = memPCD.PhoneNumber;
                    prWrapper.ProviderName = memPCD.ProviderName;
	                prWrapper.ServiceOfficeAddress = memPCD.ServiceOfficeAddress;
                    if(memPCD.Address != null)
	                	memPCD.Address = memPCD.Address.replaceAll(',,', ', ');
                    else 
                        memPCD.Address = ''; 
	                prWrapper.address = memPCD.Address;
	                prWrapper.language = memPCD.Language;
	                prWrapper.routeId = String.join(new List<String>(prov_util_Cache.VisibleLOB), ';');
	                
	                if(memPCD.ProviderGuid != null && memPCD.ProviderGuid != ''){
	                	prWrapper.pcdGuid = memPCD.ProviderGuid;
	                	planGuidSet.add(memPCD.ProviderGuid);
	                } else {
	                	prWrapper.pcdGuid = memPCD.ServiceLocationGuid;
	                	planGuidSet.add(memPCD.ServiceLocationGuid);
	                }
	                
	                
	                planGuidSet.add(memPCD.PlanGUID);
	                prWrapper.planGuid = memPCD.PlanGuid;
	                /*if(memPCD.ProviderGUID__c != null){
	                    pcdGuidHolder = memPCD.ProviderGUID__c;
	                    prWrapper.pcdGuid = memPCD.ProviderGUID__c;
	                }else{
	                    pcdGuidHolder = memPCD.ServiceLocationGUID__c;
	                    prWrapper.pcdGuid = memPCD.ServiceLocationGUID__c;
	                }
					*/
	                //system.debug('memPCD' +memPCD);
	                system.debug('prWrapper::' +prWrapper);
                    system.debug('prWrapper::' +prWrapper.memberProfileGuid);
	
	                //system.debug('lower case pcd guid' + prWrapper.mempcdGuid.toLowerCase());
	                //populate map with Wrapper records
	
	                finalResults.add(prWrapper);
	            }
	
                system.debug('finalResults' + finalResults);
	            system.debug('finalResults size' + finalResults.size());
	            //add plans to map
	            for(Account planAcct : [SELECT id, guid__c, Name FROM Account Where guid__c IN :planGuidSet]){
	            	planGuidAcctMap.put(planAcct.guid__c.toLowerCase(), planAcct);
	            }
	
	            for(prov_wrap_PanelRoster wmpGuidWrap : finalResults){
	                //set plan Name on wrapper based on matching plan Account record
	                if(planGuidAcctMap.containsKey(wmpGuidWrap.planGuid.toLowerCase()))
	                	wmpGuidWrap.planName = planGuidAcctMap.get(wmpGuidWrap.planGuid.toLowerCase()).Name;
	                	
	                if(planGuidAcctMap.containsKey(wmpGuidWrap.pcdGuid.toLowerCase())){
	                	wmpGuidWrap.pcdName = planGuidAcctMap.get(wmpGuidWrap.pcdGuid.toLowerCase()).Name;
	                }
	            }
	
            }
        }   catch (exception ex){
            system.debug('----------------------------------------------------------');
            system.debug('Error Message::'+ex.getMessage());
            system.debug('Stack Trace::'+ex.getStackTraceString());
            system.debug('----------------------------------------------------------');
        }
        //responseWrapper = ( List<PanelRosterResponseWrapper>)JSON.deserialize(res.getBody(), List<PanelRosterResponseWrapper>.class);
        //System.debug('result::'+responseWrapper);
        
        //for(HTTPResponseWrap respWrap : responseList){
        //	result.add( respWrap.covertToMemberCoverage() );
        //}
        return finalResults;
    }
	
	public class PanelRosterParam {
		public String bizAcctId {get;set;}
		public String locAcctId {get;set;}
		public String provAcctId {get;set;}
		public String firstNameSearch {get;set;}
		public String lastNameSearch {get;set;}
		public String sortDirection {get;set;}
		public String pageNumS {get;set;}
		public String sortField {get;set;}
		public String numResultsS {get;set;}
		public String routeId {get;set;}
        public String download {get;set;}
	}
    //get list of members for panel roster
	@AuraEnabled
    public static List<prov_wrap_PanelRoster> retrievePanelRoster(String bizAcctId, String locAcctId, String provAcctId,
                                                 String firstNameSearch, String lastNameSearch, 
                                                 String sortDirection, String pageNumS, String sortField, String numResultsS, String routeId){
        System.debug('sortDirection::'+sortDirection);
        system.debug('locAcctId' + locAcctId);
        system.debug('provAcctId' +provAcctId);
        //list for all member PCDs
        List<mock_MemberPrimaryCareDentist__c>  totalPCDList = new List<mock_MemberPrimaryCareDentist__c>();
        //list for member PCDs on the current page
        List<mock_MemberPrimaryCareDentist__c>  returnPagePCDList = new List<mock_MemberPrimaryCareDentist__c>();
        //list of wrapper class values for return values on the page
        //List<prov_wrap_PanelRoster> resultList = new List<prov_wrap_PanelRoster>();
        List<prov_wrap_PanelRoster> resultPageList = new List<prov_wrap_PanelRoster>();
        Map<String,List<Account>> pcdGuidAcctMap = new Map<String,List<Account>>();
        Map<String,Account> planGuidAcctMap = new Map<String,Account>();
        String planGuidHolder = '';
        String pcdGuidHolder = '';
        Set<String> planGUIDStringSet = new Set<String>();
        Set<ID> pcdIds = new Set<ID>();
        Integer page = 1;
        Integer numResults = 20;
        if(pageNumS != null && pageNumS != '')              page = Integer.valueOf(pageNumS);
        system.debug('page '+page);
        if(numResultsS != null && numResultsS != '')        numResults = Integer.valueOf(numResultsS);
        if(sortField == null || sortField == '')            sortField = 'MemberId';
        if(sortDirection == null || sortDirection == '')    sortDirection = 'DESC';
        system.debug(numResults);
        //convert Ids to strings
        String locAcctIdString = '';
        String provAcctIdString = '';
        totalNumRecords = 0;
        firstNameSearch = firstNameSearch == null || firstNameSearch == ''? '' :  String.escapeSingleQuotes(firstNameSearch);
        lastNameSearch = lastNameSearch == null || lastNameSearch == ''? '' :  String.escapeSingleQuotes(lastNameSearch);

        //get string of windward guids for Location Acct and Provider Acct
      	Account bizAcct = prov_util_Cache.CurrentBusiness;
        if(locAcctId != null && locAcctId != '' && locAcctId != 'Any'){
            locAcctIdString = [SELECT guid__c from Account Where id = :locAcctId].guid__c;
        }else {
            List<Account> locs = prov_util_Cache.retrieveServiceLocation(bizAcctId);
            List<String> locWWIds = new List<String>();
            //
            for(Account loc : locs){
                locWWIds.add(loc.guid__c);
                
            }
            locAcctIdString = String.join(locWWIds, ',');

        }
        system.debug('location ww guids'+locAcctIdString);
        if(provAcctId != null && provAcctId != '' && provAcctId != 'Any' && provAcctId != 'undefined'){
            system.debug('assigning ww guid for provider Id');
            provAcctIdString = [SELECT guid__c from Account Where id = :provAcctId].guid__c;
        }

        //get matching plan guids
        //String bizAcctString = bizAcctId;
        
       // planGUIDStringSet = prov_util_Cache.cobj.BusinessId2PlanWWIdsMap.get(bizAcctId);
        //convert plan guid set to plan guid list
       // List<String> planGuidStringList = new List<String>(planGUIDStringSet);

        //populate strings with values for DAL query
        String order = '';
        if(sortField != null || sortDirection != null){
            order = ' ORDER BY '+sortField+' '+sortDirection;
        }
        String limitNum = ' LIMIT ' + numResults;
        String offset = ' Offset ' + ((page-1)*numResults);
        /*
        public String SortField{get;set;}
        public String SortDirection{get;set;}
        public Integer PageNumber{get;set;}
        public Integer RecordsPerPage{get;set;}
        */
                                                     
        PanelRosterCalloutWrapper calloutWrapper = new PanelRosterCalloutWrapper();
        calloutWrapper.ServiceOfficeGUIDs = locAcctIdString;
        //calloutWrapper.ServiceLocationGUID = '4D2B79C5-48B9-42B9-AA32-5829A895ECB2';
        calloutWrapper.ProviderGuid = provAcctIdString;
        calloutWrapper.FirstName  = firstNameSearch;
        calloutWrapper.LastName = lastNameSearch;
        calloutWrapper.SortField = sortField;
        calloutWrapper.SortDirection = sortDirection;
        calloutWrapper.PageNumber = page;
        calloutWrapper.RecordsPerPage = numResults;
        //calloutWrapper.ProviderGuid = null;
        calloutWrapper.RouteId = routeId;
        calloutWrapper.DownloadRecords = false;

        system.debug('callout Wrapper' + calloutWrapper);
        
        System.debug('retrieveRecords...'); 
        PanelRosterHeaderResponseWrapper resultHeader = calloutWrapper.retrieveRecords(locAcctId, provAcctId);
        List<PanelRosterResponseWrapper> resultList = new List<PanelRosterResponseWrapper>();
        SYstem.debug('retrieveRecords End...');
        
        if(resultHeader != null){
            if(resultHeader.Total != null){
                resultList = resultHeader.PanelRosterRecords;
                totalNumRecords = resultHeader.Total;
            }
        }
        system.debug('panel roster result Header' + resultHeader);
        system.debug('panel roster result list' + resultList);
        //populate string vlaues for LIKE portion of query
        /*
        String searchLikeFirstName = '';
        String searchLikeLastName = '';
        if (firstNameSearch != null){
            searchLikeFirstName = ' AND FirstName__c LIKE \'' + firstNameSearch + '%\'';
        }
        if(lastNameSearch != null){
            searchLikeLastName = ' AND LastName__c LIKE \'' + lastNameSearch + '%\'';
        }
        */
        try{
            /*
            if(provAcctId == null){
                system.debug('in if');
                totalPCDList = prov_util_DAL.getTotalPrimaryDentistsPanel(locAcctIdString, planGuidStringList, order, searchLikeFirstName, searchLikeLastName);
                
            }else{
                system.debug('in else');
                totalPCDList = prov_util_DAL.getTotalPrimaryDentistsPanel(locAcctIdString, provAcctIdString, planGuidStringList, order, searchLikeFirstName, searchLikeLastName);
                

            }*/
            if(resultList.size() > 0){

                system.debug('result list size line 179 ' + resultList.size());
                Set<String> planGuidSet  = new Set<String>();
                for(PanelRosterResponseWrapper memPCD : resultList){
                    system.debug('memPCD in loop from resultList' + memPCD);
                    //if name is entered, remove the results that didnt meet the criteria
                    /*if(firstNameSearch !=null){
                        if(!memPCD.FirstName.containsIgnoreCase(firstNameSearch)){
                            totalNumRecords --;
                            System.debug('first name does not meet criteria');
                            continue;
                        }
                    }
                    //if last name is entered, remove the results that didnt meet the criteria
                    if(lastNameSearch != null){
                        if(!memPCD.LastName.containsIgnoreCase(lastNameSearch)){
                            totalNumRecords--;
                            System.debug('last name does not meet criteria');
                            continue;
                        }
                    }
                    */

                    system.debug('memberPCD record in retreive Panel Roster from print page' + memPCD);
                    //initialize the wrapper
                    prov_wrap_PanelRoster prWrapper = new prov_wrap_PanelRoster();
                    //populate wrapper record with values from returned list from DAL
                    if(memPCD.BirthDate != null){
                    prWrapper.birthDate = memPCD.BirthDate.dateGMT();
                        
                    }
                    prWrapper.firstName = memPCD.FirstName;
                    prWrapper.lastName = memPCD.LastName;
                    prWrapper.memberNumber = memPCD.MemberId;
                    prWrapper.effectiveDate = memPCD.EffectiveDate.dateGMT();
                    prWrapper.memberProfileGuid = memPCD.MemberProfileGUID;
                    prWrapper.universalMemberGuid = memPCD.UniversalMemberGuid;
                    prWrapper.phone = memPCD.PhoneNumber;
                    if(memPCD.Address != null)
                        memPCD.Address = memPCD.Address.replaceAll(',,', ', ');
                    else 
                        memPCD.Address = '';
                    prWrapper.address = memPCD.Address;
                    prWrapper.language = memPCD.Language;
                    prWrapper.routeId = String.join(new List<String>(prov_util_Cache.VisibleLOB), ';');
                    
                    if(memPCD.ProviderGuid != null && memPCD.ProviderGuid != ''){
                        prWrapper.pcdGuid = memPCD.ProviderGuid;
                        planGuidSet.add(memPCD.ProviderGuid);
                    } else {
                        prWrapper.pcdGuid = locAcctIdString;
                        planGuidSet.add(locAcctIdString);
                    }
                    
                    
                    planGuidSet.add(memPCD.PlanGUID);
                    prWrapper.planGuid = memPCD.PlanGuid;
                    /*if(memPCD.ProviderGUID__c != null){
                        pcdGuidHolder = memPCD.ProviderGUID__c;
                        prWrapper.pcdGuid = memPCD.ProviderGUID__c;
                    }else{
                        pcdGuidHolder = memPCD.ServiceLocationGUID__c;
                        prWrapper.pcdGuid = memPCD.ServiceLocationGUID__c;
                    }
                    */
                    //system.debug('memPCD' +memPCD);
                    system.debug('prWrapper::' +prWrapper);
                    system.debug('prWrapper::' +prWrapper.memberProfileGuid);
    
                    //system.debug('lower case pcd guid' + prWrapper.mempcdGuid.toLowerCase());
                    //populate map with Wrapper records
                    system.debug(prWrapper.memberProfileGuid.toLowerCase());
                    resultPageList.add(prWrapper);
                    system.debug('1');
                }
    
                system.debug('resultPageList' + resultPageList);
                system.debug('resultPageList length ' + resultPageList.size());
                //add plans to map
                for(Account planAcct : [SELECT id, guid__c, Name FROM Account Where guid__c IN :planGuidSet]){
                    planGuidAcctMap.put(planAcct.guid__c.toLowerCase(), planAcct);
                }
    
                for(prov_wrap_PanelRoster wmpGuidWrap : resultPageList){
                    //set plan Name on wrapper based on matching plan Account record
                    if(planGuidAcctMap.containsKey(wmpGuidWrap.planGuid.toLowerCase()))
                        wmpGuidWrap.planName = planGuidAcctMap.get(wmpGuidWrap.planGuid.toLowerCase()).Name;
                        
                    if(planGuidAcctMap.containsKey(wmpGuidWrap.pcdGuid.toLowerCase())){
                        wmpGuidWrap.pcdName = planGuidAcctMap.get(wmpGuidWrap.pcdGuid.toLowerCase()).Name;
                    }
                }
    
                List<mock_MemberCoverage__c> memCovRecList = new List<mock_MemberCoverage__c>();
            }

            }   catch (exception ex){
            system.debug('----------------------------------------------------------');
            system.debug('Error Message::'+ex.getMessage());
            system.debug('Stack Trace::'+ex.getStackTraceString());
            system.debug('----------------------------------------------------------');
        }
            //set total number of records
            //totalNumRecords = resultMap.values().size();
            //set total number of pages
            totalPages = Integer.valueOf( (Decimal.valueOf( totalNumRecords ) / numResults).round(System.RoundingMode.UP) );
            totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1   
            pageNum = page;
        return resultPageList;
    }
    

    public class PanelRosterCalloutWrapper{
        public String BusinessGUID {get;set;}
    	public String ServiceOfficeGUIDs {get;set;}
    	public String ProviderGUID {get;set;}
    	public String FirstName {get;set;}
    	public String LastName {get;set;}
    	public String SortField{get;set;}
    	public String SortDirection{get;set;}
    	public Integer PageNumber{get;set;}
    	public Integer RecordsPerPage{get;set;}
    	public String RouteID {get;set;}
    	public Boolean DownloadRecords {get;set;}
    	
    	
    	public PanelRosterCalloutWrapper(){
    		
    	}
    	
    	public PanelRosterHeaderResponseWrapper retrieveRecords(String locAcctId, String provAcctId){

    		PanelRosterHeaderResponseWrapper resHeaderWrapper =new PanelRosterHeaderResponseWrapper();
    		System.debug('retrieveRecords.....');

    		if(prov_util_MockData.useMockData){
                System.debug('is Mock Data');
                System.debug('prov acct' +provAcctId);
                //we are in test or dev, do not make the callout
                mock_MemberPrimaryCareDentist__c[] mPCDList = prov_util_DAL.getPrimaryDentistsByPSL(locAcctId, provAcctId);
                system.debug('mock PCD list' + mPCDList);
				resHeaderWrapper.Total = 0;
				for(mock_MemberPrimaryCareDentist__c mPCD : mPCDList){
	                PanelRosterResponseWrapper wrapper = new PanelRosterResponseWrapper();
	                
	                wrapper.FirstName = mPCD.FirstName__c;
	                wrapper.LastName = mPCD.LastName__c;
	                wrapper.MemberId = mPCD.Subscriber_Id__c;
	                wrapper.BirthDate = Date.Today();
	                wrapper.EffectiveDate = mPCD.EffectiveDate__c;
	                wrapper.PlanGuid = mPCD.PlanGuid__c;
	                wrapper.MemberProfileGuid = '02425782-ce23-4f39-b5fe-a15a99c4105d';
	                wrapper.Address = '210 W PAISANO LN,,WESLACO,TX,78599';
	                wrapper.ProviderGuid = '444-333123';
	                wrapper.PhoneNumber = '222-222-2222';
	                wrapper.Language = 'English';
	
	                resHeaderWrapper.PanelRosterRecords.add(wrapper);
	                resHeaderWrapper.Total += 1;
				}

                system.debug('resheaderwrapper ::: ' + resHeaderWrapper);

                return  resHeaderWrapper;
            } else {
            	System.debug('prov_util_MockData.useMockData::'+prov_util_MockData.useMockData);
                Global_Configuration__c calloutEndpoint = Global_Configuration__c.getInstance('PanelRosterEndpoint');
                Global_Configuration__c calloutUsername = Global_Configuration__c.getInstance('PCDRequestUsername');
                Global_Configuration__c calloutPassword = Global_Configuration__c.getInstance('PCDRequestPassword');
                if(String.IsNotBlank(calloutEndpoint.value__c) && calloutEndpoint.value__c!='null' 
                   && String.IsNotBlank(calloutUsername.value__c) && calloutUsername.value__c!='null'
                   && String.IsNotBlank(calloutPassword.value__c) && calloutPassword.value__c!='null'){
                    //setup basic auth
                    Blob headerValue = Blob.valueOf(calloutUsername.value__c +':' +calloutPassword.value__c);
    				String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    //make a callout to WW to submit the request
                    System.debug('headerValue::'+calloutUsername.value__c +':' +calloutPassword.value__c);
                    System.debug('calloutEndpoint::'+calloutEndpoint.Value__c);
                    HTTP h = new HTTP();
                    HTTPRequest req = new HTTPRequest();
                    req.setEndpoint(calloutEndpoint.Value__c);
                    req.setMethod('GET');
                    req.setTimeout(10000);
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization', authorizationHeader);
                    String payload = JSON.serialize(this);
                    system.debug('Payload: ');
                    system.debug(payload);
                    req.setBody(payload);
                       
                    HTTPResponse res = h.send(req);
                    //check for the response
                    system.debug('Panel Roster ResponseCode: ' + res.getStatusCode());
                    if(res.getStatusCode()!=200){
                        system.debug('--Panel Roster  Request-------------------------------------------------------------------------');
                        system.debug('Response failed.');
                        system.debug(res.getStatusCode());
                        system.debug(res.getBody());
                        system.debug('--Panel Roster  Request-------------------------------------------------------------------------');
                        //result.add(new mock_MemberCoverage__c(FirstName__c = 'Error', LastName__c = 'timeout') );
                        PanelRosterHeaderResponseWrapper responseErrorMess = new PanelRosterHeaderResponseWrapper();
                        responseErrorMess.status = 'timeout';
                        
                        return responseErrorMess; 
                    } else {
                        system.debug('Panel Roster Body: ' + res.getBody());
                        
                        resHeaderWrapper = ( PanelRosterHeaderResponseWrapper)JSON.deserialize(res.getBody(), PanelRosterHeaderResponseWrapper.class);
                        resHeaderWrapper.status = 'SUCCESS';
                        system.debug('panel roster response header wrapper' + resHeaderWrapper);
                        
                        //responseWrapper = ( List<PanelRosterResponseWrapper>)JSON.deserialize(res.getBody(), List<PanelRosterResponseWrapper>.class);
                        //System.debug('result::'+responseWrapper);
                        
                        //for(HTTPResponseWrap respWrap : responseList){
                        //	result.add( respWrap.covertToMemberCoverage() );
                        //}
                        return resHeaderWrapper;
                    }
                } else {
                    system.debug('--Panel Roster  Request-------------------------------------------------------------------------');
                    system.debug('No valid endpoint in the setting.');
                    system.debug('--Panel Roster  Request-------------------------------------------------------------------------');
                } 
            }
            return resHeaderWrapper;
    	}
    	
    	public HttpRequest retrieveRecords_continuation(){
        	System.debug('prov_util_MockData.useMockData::'+prov_util_MockData.useMockData);
            Global_Configuration__c calloutEndpoint = Global_Configuration__c.getInstance('PanelRosterEndpoint');
            Global_Configuration__c calloutUsername = Global_Configuration__c.getInstance('PCDRequestUsername');
            Global_Configuration__c calloutPassword = Global_Configuration__c.getInstance('PCDRequestPassword');
            if(String.IsNotBlank(calloutEndpoint.value__c) && calloutEndpoint.value__c!='null' 
               && String.IsNotBlank(calloutUsername.value__c) && calloutUsername.value__c!='null'
               && String.IsNotBlank(calloutPassword.value__c) && calloutPassword.value__c!='null'){
                //setup basic auth
                Blob headerValue = Blob.valueOf(calloutUsername.value__c +':' +calloutPassword.value__c);
				String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                //make a callout to WW to submit the request
                System.debug('headerValue::'+calloutUsername.value__c +':' +calloutPassword.value__c);
                System.debug('calloutEndpoint::'+calloutEndpoint.Value__c);
                HTTP h = new HTTP();
                HTTPRequest req = new HTTPRequest();
                req.setEndpoint(calloutEndpoint.Value__c);
                req.setMethod('POST');
                req.setTimeout(60000);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', authorizationHeader);
                String payload = JSON.serialize(this);
                system.debug('Payload: ');
                system.debug(payload);
                req.setBody(payload);
                
                return req;  
                
            } else {
                system.debug('--Panel Roster  Request-------------------------------------------------------------------------');
                system.debug('No valid endpoint in the setting.');
                system.debug('--Panel Roster  Request-------------------------------------------------------------------------');
                return null;
            } 
    	}
    }
    public class PanelRosterResponseWrapper{
    	/*[{"MemberProfileGuid":"02425782-ce23-4f39-b5fe-a15a99c4105d",
    		"FirstName":"CATHY",
    		"LastName":"BATES",
    		"MemberId":"517990952",
    		"BirthDate":"1997-10-23T00:00:00",
    		"EffectiveDate":"2017-03-21T00:00:00",
    		"PlanGuid":"5881abae-9db1-40e2-9c66-82fcce7d131d",
    		"Address":"210 W PAISANO LN,,WESLACO,TX,78599",
    		"PhoneNumber":"9569981808",
    		"Language":null},*/
    	@AuraEnabled
    	public String MemberProfileGuid {get;set;}
        @AuraEnabled
        public String UniversalMemberGuid {get;set;}
    	@AuraEnabled
    	public String FirstName {get;set;}
    	@AuraEnabled
    	public String LastName {get;set;}
    	@AuraEnabled
    	public String MemberId {get;set;}
    	@AuraEnabled
    	public Datetime BirthDate {get;set;}
    	@AuraEnabled
    	public Datetime EffectiveDate {get;set;}
    	@AuraEnabled
    	public String PlanGuid {get;set;}
    	@AuraEnabled
    	public String Address {get;set;}
    	@AuraEnabled
    	public String PhoneNumber {get;set;}
    	@AuraEnabled
    	public String Language {get;set;}
    	@AuraEnabled
    	public String ProviderGuid {get;set;}
    	@AuraEnabled
    	public String ServiceLocationGuid {get;set;}
        @AuraEnabled
        public String ProviderName {get;set;}
        @AuraEnabled
        public String ServiceOfficeAddress {get; set;} 
    	
        public PanelRosterResponseWrapper(){
    		
    	}
    }
    
    public class PanelRosterHeaderResponseWrapper{
    	public Integer Total {get;set;}
    	public Integer PageNumber {get;set;}
    	public Integer PageSize {get;set;}
    	public Integer TotalPages {get;set;}
    	public List<PanelRosterResponseWrapper> PanelRosterRecords {get;set;}
    	public String status {get;set;}
    	public PanelRosterHeaderResponseWrapper(){
    		status = 'error';

            PanelRosterRecords = new List<PanelRosterResponseWrapper>();
    	}
    }
}