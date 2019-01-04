/*
/*******************************************************************************************************
Name 						: prov_ctrl_Member_Detail
Purpose						: Controller for the prov_comp_Member_Detail 
							  Gets relevant member information.
Created on					: 13rd January 2018
Developed by				: West Monroe Partners
History
Version#		Sprint#		Date					by  							Comments
1.0				1.0			13rd January 2018		West Monroe Partners			See header - purpose
 
*******************************************************************************************************
*/
public without sharing class prov_ctrl_Member_Detail {
  
	// https://dev1-greatdentalplans-community.cs13.force.com/Provider/s/member-detail?date=2018-01-30&location=001W000000cqhhTIAQ&id=Profile1&provider=001W000000cqhhRIAQ
	@AuraEnabled
	public static prov_wrap_Member getMemberApex2(String memberGuid, String universalId, String businessId, String providerId, String locationId, String serviceDate, String planGuid){
		System.debug('STARTING getMemberApex2....');
		//initialize the variables
		System.debug('serviceDate::'+serviceDate);
        String[] serviceDateArray = serviceDate.split('-');
        Date newServiceDate = Date.newInstance(Integer.valueOf(serviceDateArray[0]), Integer.valueOf(serviceDateArray[1]), Integer.valueOf(serviceDateArray[2]));
		
		//set the fields on the member wrapper
		prov_wrap_Member memberWrapper = new prov_wrap_Member();
		try{
			
		
			//set the passed in variables
			memberWrapper.serviceDate = newServiceDate;
			memberWrapper.universalMemberId = universalId;
			if(memberWrapper.universalMemberId == null || memberWrapper.universalMemberId == '')
				memberWrapper.memberProfileGuid = memberGuid;
				
			if(planGuid != null && planGuid != ''){
				System.debug('planGuid::'+planGuid);
				//memberWrapper.currentPlanGuid = planGuid.tolowercase();
				memberWrapper.planGuid = planGuid.tolowercase();
				
			}
	        
	        //get the service location and provider passed in to check eligibility
			Set<String> accIDs = new Set<String>();
			if(providerId != null){
	        	providerId = String.escapeSingleQuotes(providerId);
	        	accIDs.add(providerId);
				
			}
	        if(locationId != null){
	        	locationId = String.escapeSingleQuotes(locationId);
	        	accIDs.add(String.escapeSingleQuotes(locationId));
	        }
	
	        List<Account> accounts = [SELECT Id, guid__c, Name, Service_Location_Name__c FROM Account WHERE Id IN: accIDs];
	        //
	        for(Account acc : accounts) {
		        String accId = acc.Id;
	            if(accId.contains(providerId)) {
	            	memberWrapper.providerGuid = acc.guid__c;
	                memberWrapper.providerSelected = acc;
	            } else if(accId.contains(locationId)) {
					memberWrapper.serviceLocationGuid = acc.guid__c;
					memberWrapper.serviceLocationSelected = acc;
	            }
	        }
			//query for the member coverages and the plans
			memberWrapper.fetchMemberData2();
			
			//get the plans that are covered by the PSL or the business
			mock_MemberCoverage__c memCov = memberWrapper.planGuid2MemCovMap.get( memberWrapper.currentPlanGuid );
			System.debug('default mem cov ::' + memCov);
			System.debug('newServiceDate::'+newServiceDate);
			if(memCov.EffectiveDate__c <= newServiceDate && ( memCov.TerminationDate__c == null || newServiceDate <= memCov.TerminationDate__c) ){
				List<String> availablePlans;
				if(locationId == null){
					availablePlans = new List<String>(prov_util_Cache.getVisibilePlanWWIds(businessId));
				}else {
					availablePlans = prov_util_Cache.getPlanGuidsBasedOnBusProvSL(businessId, providerId, locationId, newServiceDate);
				}
				System.debug('availablePlans::'+availablePlans);
				System.debug('memberWrapper.currentPlanGuid::'+memberWrapper.currentPlanGuid);
				Set<String> availablePlanSet = new Set<String>(availablePlans);
				if(availablePlanSet.contains(memberWrapper.currentPlanGuid )){
					memberWrapper.eligibilityStatus = 'eligible';
				} else {
					memberWrapper.eligibilityStatus = 'outOfNetwork';
				}
			} else { //plan falls outside of service date
				memberWrapper.eligibilityStatus = 'ineligible';
			}
			System.debug('memberWrapper.eligibilityStatus ::'+memberWrapper.eligibilityStatus );
			//see if the plan is eligible
			//memberWrapper.fetchMemberData();
	
		} catch(Exception ex){
			System.debug('****************************************8');
			System.debug('error::'+ex.getMessage());
			System.debug('stack trace :: '+ ex.getStackTraceString() );
			System.debug('****************************************8');
		}
		return memberWrapper;
		
	}
	@AuraEnabled
	public static MemberDetailWrapper getMemberApex(String memberGuid, String providerId, String locationId, String serviceDate){
		Set<String> accIDs = new Set<String>();
        accIDs.add(providerId);
        accIDs.add(locationId);
        List<Account> accounts = [SELECT Id, guid__c FROM Account WHERE Id IN: accIDs];
        String providerGuid;
        String locationGuid;
		System.debug('serviceDate::'+serviceDate);
        String[] serviceDateArray = serviceDate.split('-');
        Date newServiceDate = Date.newInstance(Integer.valueOf(serviceDateArray[0]), Integer.valueOf(serviceDateArray[1]), Integer.valueOf(serviceDateArray[2]));
        for(Account acc : accounts) {
            if(acc.Id == providerId) {
            	providerGuid = acc.guid__c;
            } else if(acc.Id == locationId) {
            	locationGuid = acc.guid__c;
            }
        }

		prov_wrap_Member memberWrapper = new prov_wrap_Member();
		memberWrapper.memberProfileGuid = memberGuid;
		memberWrapper.providerGuid = providerGuid;
		memberWrapper.serviceLocationGuid = locationGuid;
		memberWrapper.fetchMemberData();

		MemberDetailWrapper wrapper = new MemberDetailWrapper();
		wrapper.memberWrapper = memberWrapper;

		// get cache records
		List<String> availablePlanGuids = new List<String>();
		if(providerId != NULL && locationId != NULL) {
			availablePlanGuids = prov_util_Cache.getPlanGuidsBasedOnBusProvSL(prov_util_Cache.CurrentBusinessId, providerId, locationId, newServiceDate);
		} else {
			availablePlanGuids.addAll(prov_util_Cache.getVisibilePlanWWIds(prov_util_Cache.CurrentBusinessId));
		}
		wrapper.availablePlanGuids = availablePlanGuids;
		return wrapper;
	}
//pulled out to make calls in parallel
    //@AuraEnabled
    /*
            //query for the members using member profile guid, map of member profile guid to the member
            memberMap = prov_util_DAL.getMembersMap(mpguidProfileGuid.values());
            currentMemAddresses = prov_util_DAL.getMemberAddresses(mpguidProfileGuid.values());
            currentMemPhones = prov_util_DAL.getMemberPhones(memberProfileGuid);
    */
    @AuraEnabled
	public static Map<String,mock_Member__c> getMemberDetails(String memProfileGuid){
        List<String> mGuids = new List<String>();
        mGuids.add(memProfileGuid);
        return prov_util_DAL.getMembersMap(mGuids);
    }
    @AuraEnabled
	public static List<mock_MemberAddress__c>  getMemberAddresses(String memProfileGuid){
        List<String> mGuids = new List<String>();
        mGuids.add(memProfileGuid);
        return prov_util_DAL.getMemberAddresses(mGuids);
    }
    @AuraEnabled
	public static List<mock_MemberPhone__c> getMemberPhones(string memProfileGuid){
        return prov_util_DAL.getMemberPhones(memProfileGuid);
    }
	public class MemberDetailWrapper {
        @AuraEnabled public prov_wrap_Member memberWrapper;
        @AuraEnabled public List<String> availablePlanGuids;
    }
}