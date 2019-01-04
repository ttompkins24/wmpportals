/**********************************************************************************************************************
Purpose						: The controller for the process of setting a new primary dentist for one or all of the members that you manage
Created on					: 9th Oct 2017
Developed by				: Todd Tompkins
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th Oct 2017					Todd Tompkins					See header - purpose
  

**********************************************************************************************************************/
public without sharing class wmp_ctrl_MainDentist {
    
    @AuraEnabled
    public static Portal_Configuration__mdt retrievePortalConfig(){
    	return wmp_util_Cache.PortalConfiguration;
    	
    }
    
    @AuraEnabled
    public static String setPCDForMember(List<String> memCovGuids, String dentistId, String locationId, String reason){
		System.debug('Reason selected ' + reason);

        //get the service location record
		Account serviceLocation = [SELECT id, guid__c FROM Account WHERE id=:locationId];
		
		//get the provider record
		Account provider = [SELECT id, guid__c FROM Account WHERE id=:dentistId];
		System.debug('about to submit...');
		
		//build the wrapper class to send the request
		wmp_util_PCDWrapper pcdWrap = new wmp_util_PCDWrapper();
		pcdWrap.MemberCoverageGUIDs = memCovGuids;
		pcdWrap.ProviderGUID = provider.guid__c;
		pcdWrap.ServiceLocationGuid = serviceLocation.guid__c;
        pcdWrap.reason = reason;
		
		//send the request
		Boolean resultBool = wmp_util_Cache.requestPCDChange(pcdWrap);
		System.debug('return::'+resultBool);
		
    	return resultBool ? 'success' : 'error';
    }
    
    @AuraEnabled
    public static String setPCDForOneMember(List<String> memCovGuids, String dentistId, String locationId, String reason){
    	System.debug('memCovGuids::'+memCovGuids);
        System.debug('Reason selected ' + reason);
	
    	Boolean openRequest = false;
		try{
    		//check to see if this mem cov record has an open request against them
    		System.debug('keyset::'+wmp_util_Cache.MemberGuidToPlanVerification.keyset());
    		Id upvId = wmp_util_Cache.MemberGuidToPlanVerification.get(memCovGuids[0].toLowerCase());
    		User_Plan_Verification__c upv = wmp_util_Cache.VerifiedPlans.get(upvId);
    		
    		if(upv.PCD_Request_Note__c != '' && upv.PCD_Request_Note__c != null)
    			openRequest = true;
		} catch (Exception ex){
			System.debug('error::'+ex.getMessage());
			System.debug('errorLN::'+ex.getLineNumber());
		}
		System.debug('openRequest::'+openRequest);
		if(openRequest == true)
			return 'open';
		else
			return wmp_ctrl_MainDentist.setPCDForMember(memCovGuids, dentistId, locationId, reason);
    }
    
    @AuraEnabled
    public static Map<String, String> setPCDForAllMember(String dentistId, String locationId){
    	System.debug('entering setPCDForAllMember...');
		//initialize the variables
    	Set<String> planGuidSet = new Set<String>();
    	Set<Id> planIdSet = new Set<Id>();
    	Set<Id> networkIdSet = new Set<Id>();
    	Map<String, Set<Id>> planGuid2NetworkIdMap = new Map<String, Set<Id>>();
    	Map<String, String> memCovGuid2StatusMap = new Map<String, String>();
    	Map<Id, Boolean> networkId2AcceptingNewPatientsMap = new Map<Id, Boolean>();
    	Date todaysDate = Date.today();
    	Map<String, Boolean> memCovGuid2OpenRequestMap = new Map<String, Boolean>();//does this member coverage record have an open request against it
    	
    	//retrieve the member coverage record
    	List<mock_MemberCoverage__c> memCovList = wmp_util_Cache.MemberPlans.values();
    	System.debug('memCovList::'+memCovList);
    	
    	//if no member coverage is found, exit method displaying error
    	if(memCovList != null && memCovList.size() > 0){
    		//get all the plan guids from the member coverage records
    		for(mock_MemberCoverage__c memCov : memCovList){
    			Boolean openRequest = false;
    			try{
    			//check to see if this mem cov record has an open request against them
    			Id upvId = wmp_util_Cache.MemberGuidToPlanVerification.get(memCov.MemberCoverageGuid__c.toLowerCase());
    			System.debug('upvId::'+upvId);
    			User_Plan_Verification__c upv = wmp_util_Cache.VerifiedPlans.get(upvId);
    			
    			if(upv.PCD_Request_Note__c != '' && upv.PCD_Request_Note__c != null)
    				openRequest = true;
    			} catch (Exception ex){
    				System.debug('error::'+ex.getMessage());
					System.debug('errorLN::'+ex.getLineNumber());
    			}
    			memCovGuid2OpenRequestMap.put(memCov.MemberCoverageGuid__c, openRequest);
    			//map the plan guid to get info about the plan and the network information
    			planGuidSet.add(memCov.PlanGuid__c);		
    		}
    		System.debug('planGuidSet::'+planGuidSet);
    		
    		//query for the plan records and map the windward guid to the id
    		for(Account plan : [SELECT id, guid__c FROM Account WHERE guid__c IN:planGuidSet]){
    			planIdSet.add(plan.Id);
    		}
    		System.debug('planIdSet::'+planIdSet);
    		
    		//query for the plan networks based on the plan ids
    		for(Plans_Networks__c pNetwork : [SELECT id, Network__c, Plan__c, Plan__r.guid__c FROM Plans_Networks__c WHERE Plan__c IN: planIdSet ]){
    			if(planGuid2NetworkIdMap.containsKey(pNetwork.Plan__r.guid__c)){
    				planGuid2NetworkIdMap.get(pNetwork.Plan__r.guid__c).add(pNetwork.Network__c);
    			} else {
    				planGuid2NetworkIdMap.put(pNetwork.Plan__r.guid__c, new Set<Id>{pNetwork.Network__c});
    			}
    			networkIdSet.add(pNetwork.Network__c);
    			System.debug('planGuid::'+pNetwork.Plan__r.guid__c);
    			System.debug('networkId In Map::'+pNetwork.Network__c);
    		}
    		
    		System.debug('dentistId::'+dentistId);
    		System.debug('locationId::'+locationId);
    		//get the psl for the dentist and location
    		Providers_Service_Locations__c psl = [SELECT id FROM Providers_Service_Locations__c WHERE Provider__c=:dentistId AND Service_Location__c=:locationId ];
    		System.debug('psl::'+psl);
    		//query for the psl networks
    		for( Providers_Service_Locations_Networks__c psln : [SELECT id, is_provider_active__c, network__c, is_accepting_new_patients__c  FROM Providers_Service_Locations_Networks__c WHERE Network__c IN:networkIdSet AND Provider_Service_Location__c =:psl.Id AND is_provider_active__c = true]){
    			if(networkId2AcceptingNewPatientsMap.containsKey(psln.Network__c)){
    				networkId2AcceptingNewPatientsMap.put(psln.Network__c, networkId2AcceptingNewPatientsMap.get(psln.Network__c) && psln.is_accepting_new_patients__c);
    			} else {
    				networkId2AcceptingNewPatientsMap.put(psln.Network__c, psln.is_accepting_new_patients__c);
    			}
    			System.debug('network::'+psln.Network__c);
    			System.debug('networkId2AcceptingNewPatientsMap::'+networkId2AcceptingNewPatientsMap.get(psln.Network__c));
    		}
    		
    		//get all the plan guids from the member coverage records
    		for(mock_MemberCoverage__c memCov : memCovList){
    			Set<id> networkIds = planGuid2NetworkIdMap.containsKey(memCov.PlanGuid__c) ? planGuid2NetworkIdMap.get(memCov.PlanGuid__c) : new Set<Id>();
    			System.debug('network Mem Cov Id::'+networkIds);
    			if(networkIds.size() > 0){
    				Boolean foundSuccess = false;
    				for(Id netId : networkIds){
	    				if(networkId2AcceptingNewPatientsMap.containsKey( netId ) ){
	    					if(networkId2AcceptingNewPatientsMap.get( netId ) == true){
	    						foundSuccess = true;
	    						break;	
	    					}
	    				}
    				}
    				
    				
    				if(!foundSuccess)//not accepting new patients
	    				memCovGuid2StatusMap.put(memCov.MemberCoverageGUID__c, 'error');
	    			else if(memCovGuid2OpenRequestMap.get(memCov.MemberCoverageGuid__c)){//they have a pending request
	    				memCovGuid2StatusMap.put(memCov.MemberCoverageGUID__c, 'open');
	    			}else{//no errors, can successfully change PCD
	    				memCovGuid2StatusMap.put(memCov.MemberCoverageGUID__c, 'success');
	    			}
	    					
    			} else {
    				memCovGuid2StatusMap.put(memCov.MemberCoverageGUID__c, 'error');
    			}
    		}
    		return memCovGuid2StatusMap;
    	}
    	return new Map<String, String>{'all'=>'error'};
    }
    
    @AuraEnabled
    public static Map<String, Map<String, String>> retrieveAllMemberCoverageInfo(){
    	//initialize the var
    	Map<String, Map<String, String>> memCov2FieldMap = new Map<String, Map<String, String>>();
    	Map<String, Account> planGuid2PlanMap = new Map<String, Account>();
    	Map<String, String> fieldMap;
    	
    	//loop through mem coverage records and collect the guids needed
    	for(mock_MemberCoverage__c memCov : wmp_util_Cache.MemberPlans.values()){
    		planGuid2PlanMap.put(memCov.PlanGuid__c, null);
    	}
    	
    	//retrieve the plan names and map it
    	for(Account plan : [SELECT id, guid__c, name FROM Account WHERE guid__c IN: planGuid2PlanMap.keyset()]){
    		planGuid2PlanMap.put(plan.guid__c, plan);
    	}
    	System.debug('planGuid2PlanMap::'+planGuid2PlanMap.values());
    	
    	//loop through the member coverage records and set the fields necessary to show
    	for(mock_MemberCoverage__c memCov : wmp_util_Cache.MemberPlans.values()){
    		//get the plan account
    		Account plan = planGuid2PlanMap.get(memCov.PlanGuid__c);
    		fieldMap = new Map<String, String>();
    		
    		//map the fields
    		fieldMap.put('name', wmp_util_Cache.Members.get(memCov.MemberProfileGuid__c.toLowerCase()).FirstName__c);
    		fieldMap.put('planName', plan.Name);
    		System.debug('fieldMap::'+fieldMap);
    		System.debug('memCovGuid::'+memCov.MemberCoverageGUID__c);
    		//map the mem coverage guid to the field map
    		memCov2FieldMap.put(memCov.MemberCoverageGUID__c, fieldMap);
    	}
    	
    	return memCov2FieldMap;
    }
    
    @AuraEnabled
    public static String retrieveMemberName(String[] memCovGuid){
    	//get the member coverage record
    	System.debug('memCovGuid::'+memCovGuid);
    	System.debug('keyset:::'+wmp_util_Cache.MemberPlans.keyset());
    	mock_MemberCoverage__c memCov = wmp_util_Cache.MemberPlans.get(memCovGuid[0].toLowerCase());
    	
    	//get the member
    	mock_Member__c member = wmp_util_Cache.Members.get(memCov.MemberProfileGuid__c.toLowerCase());
    	
    	return member.FirstName__c;
    }
    
    @AuraEnabled
    public static Boolean retrieveMemberNameIsLocked(String[] memCovGuid){
    	//get the member coverage record
    	System.debug('memCovGuid::'+memCovGuid);
    	System.debug('keyset:::'+wmp_util_Cache.MemberPlans.keyset());
    	mock_MemberCoverage__c memCov = wmp_util_Cache.MemberPlans.get(memCovGuid[0].toLowerCase());
    	
    	String response = wmp_util_Cache.getPCDRequest(memCov.MemberCoverageGuid__c.toLowerCase());
    	
    	return response != null && response != '';
    }

    @AuraEnabled
    public static List<Map<String, String>> fetchPicklistValues_Reason(){

        //initialize var
        Map<String, String> lang2langCodeMap = new Map<String, String>{'en_US'=>'English', 'es' =>'Spanish'};
        String locKey = UserInfo.getLanguage();
        
        //return the specialty info
        return wmp_util_Cache.util_retrievePicklistValues('Reason', lang2langCodeMap.get(locKey));

    } 
}