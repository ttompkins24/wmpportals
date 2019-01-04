/*******************************************************************************************************
Name 						: Prov_ctrl_Broken_Appt
Purpose						: Apex controller for Broken Appointment lightning components
								
Created on					: 10 Jan 2018
Developed by				: West Monroe Partners
History
Version#		Sprint#		Date					by  							Comments
1.0				2.0			February 2018		West Monroe Partners					See header - purpose
 
*******************************************************************************************************/

public without sharing class prov_ctrl_Broken_Appt {
	public prov_ctrl_Broken_Appt() {
		
	}

	@AuraEnabled
	public static Account getAllBusinessesPanelRoster(){
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
    //search members based on form input fields
	@AuraEnabled
	public static List<mock_MemberCoverage__c> searchMembers(String businessId, String serviceLocationId, String providerId, String birthDate, String memberNumber, String firstName, String lastName, String routeId){
		
		List<mock_MemberCoverage__c> result = new List<mock_MemberCoverage__c>();
		if(businessId == null || businessId == ''){
			businessId = prov_util_Cache.DefaultBusinessId;
		}
		//System.debug('businessId::'+businessId);
		//System.debug('birthDate::'+birthDate);
		//get all plans for selected business, service location, provider
		System.debug('businessIds::'+prov_util_cache.cobj.BusinessId2PlanWWIdsMap);
		Set<String> plans = new Set<String>(prov_util_cache.getVisibilePlanWWIds(businessId));

        system.debug(plans);
		//System.debug('Provider plans: ' + plans);

		//Set<String> memProvCovSet = new Set<String>();
		mock_MemberCoverage__c memCovFound = null;
		Prov_ctrl_MemberEligibility.MemberWrapper searchCriteria = new Prov_ctrl_MemberEligibility.MemberWrapper(Date.today(), Date.valueOf(birthDate), memberNumber, firstName, lastName, null);
		
		/*searchCriteria.birthDate = birthDate;
		searchCriteria.memberNumber = memberNumber;
		searchCriteria.firstName = firstName;
		searchCriteria.lastName = lastName;
		*/
		//get Member Coverage records for the supplied members
		//List<mock_MemberCoverage__c> memCovResults = getMemberCoverageByNameBirthdateMemberNumberBA(businessId, birthDate, memberNumber, firstName, lastName);
		List<mock_MemberCoverage__c> memCovResults = (List<mock_MemberCoverage__c>) 
												prov_util_MemberEligibilityCallout.requestMemberEligibilityInfo(
																			new List<Prov_ctrl_MemberEligibility.MemberWrapper>{searchCriteria},
																			 businessId);
		System.debug('memCovResults::'+memCovResults); 
		Map<String, List<mock_MemberCoverage__c>> memProMemCovMap = new Map<String, List<mock_MemberCoverage__c>>();
		//create map of memcov memberprofileGuid to member Coverage record
		for(mock_MemberCoverage__c memCov : memCovResults){
			if(plans.contains(memCov.PlanGuid__c.toLowercase()) && memCov.RouteId__c.containsIgnoreCase(routeId)){
            	if(memCovFound == null){
            		memCovFound = memCov;
            		System.debug('memCov Found');
            	} else {
            		System.debug('another mem cov found');
            		if(memCovFound.SUbscriberId__c.toLowercase() != memCov.SubscriberId__c.toLowercase() && memCovFound.MemberProfileGuid__c.toLowercase() != memCov.MemberProfileGuid__c.toLowercase()){
            			//two records are returned with different subscriber id and member profile guid so return not found
	            		System.debug('two different mem covs came back');
            			memCovFound = null;
            			break;
            		}
            	}
        	}
		}

		//move set into List
		/*List<String> memProGuidList = new List<String>(memProvCovSet);

		//if list is 1 and member should be returned, add member coverage record to list
		if(memProGuidList.size() == 1){
			result.add(memProMemCovMap.get(memProGuidList.get(0)).get(0));
			
		}else{
			result = null;
		}*/

		if(memCovFound != null)
        	result.add(memCovFound);
        return result;
	}
    // searches members based on memberprofiel guid passed over from other pages
    @AuraEnabled
    public static List<mock_MemberCoverage__c> getMembers(String profileMemberGuid, String businessId, String routeId){
        List<mock_MemberCoverage__c> result = new List<mock_MemberCoverage__c>();

        mock_MemberCoverage__c memCovFound = null;
        Set<String> plans = new Set<String>(prov_util_cache.getVisibilePlanWWIds(businessId));
        //get Member Coverage records for the supplied members
        List<mock_MemberCoverage__c> memCovResults =  getMembersCovsByGuid(profileMemberGuid, businessId, routeId);
        Map<String, List<mock_MemberCoverage__c>> memProMemCovMap = new Map<String, List<mock_MemberCoverage__c>>();
        //create map of memcov memberprofileGuid to member Coverage record
        for(mock_MemberCoverage__c memCov : memCovResults){
        	if(plans.contains(memCov.PlanGuid__c.toLowercase()) && memCov.RouteId__c.containsIgnoreCase(routeId)){
            	if(memCovFound == null){
            		memCovFound = memCov;
            	} else {
            		if(memCovFound.SUbscriberId__c.toLowercase() != memCov.SubscriberId__c.toLowercase() && memCovFound.MemberProfileGuid__c.toLowercase() != memCov.MemberProfileGuid__c.toLowercase()){
            			//two records are returned with different subscriber id and member profile guid so return not found
            			memCovFound = null;
            			break;
            		}
            	}
        	}
        }       

        //move set into List
        /*List<String> memProGuidList = new List<String>(memProvCovSet);

        //if list is 1 and member should be returned
        if(memProGuidList.size() == 1){
            result.add(memProMemCovMap.get(memProGuidList.get(0)).get(0));
            
        }else{
            result = null;
        }*/
        if(memCovFound != null)
        	result.add(memCovFound);
        return result;
    }

    //returned membercoverage record based on member profiel guid, used in prepopulating member fields on page load
    //To be moved ot DAL class
    public static   List<mock_MemberCoverage__c>                       getMembersCovsByGuid(String profileMemberGuid, String businessId, String routeId){
        List<mock_MemberCoverage__c> mPlans = null;

        //get all plans a business can see
        Set<String> plans = prov_util_Cache.getVisibilePlanWWIds(businessId);
        String lowerCase = profileMemberGuid.toLowerCase();
        String whereClause = 'WHERE ';
            //add birthday
        whereClause += ' MemberProfileGUID__c = \'' + lowerCase + '\'';

        whereClause += ' AND RouteID__c = \''+routeId+'\' ORDER BY LastName__c';

        mPlans = (List<mock_MemberCoverage__c>)prov_util_DAL.dalQuery('mock_MemberCoverage__c', whereClause); 
        
        return mPlans;
        
    }

	
    //creates a broken appointment case from form field inputs
    @AuraEnabled
    public static Case createBrokenAppointment(String bizId, String servLocId, String provId, String fName, String lName, String bDate, String memNum,
                                                String servDate, String patType, String servCat, String reasonCode, String dateReported, String memProGuid, String notes, String portalName){
        Case brokenAppt = new Case();
        brokenAppt.Provider_Portal_Member_First_Name__c = fName;
        brokenAppt.Provider_Portal_Member_Last_Name__c = lName;
        brokenAppt.Member_Profile_Guid__c = memProGuid;
        if(bDate != null && bDate != ''){
        brokenAppt.Member_DOB__c = Date.valueOf(bDate);
        }
        brokenAppt.Subscriber_ID__c = memNum;
		System.debug('servDate::'+servDate);
        if(servDate != null ){
        brokenAppt.Service_Date__c =  Date.valueOf(servDate);
        }
        brokenAppt.Type_of_Patient__c = patType;
        brokenAppt.Service_Category__c = servCat;
        brokenAppt.Reason_Code__c = reasonCode;
        system.debug('dateReported::'+dateReported);
        if(dateReported != null){
        brokenAppt.Date_Reported__c = Date.valueOf(dateReported);
        }
        brokenAppt.Member_Profile_Guid__c = memProGuid;
        brokenAppt.Notes__c = notes;

        //gets contact of current user
        Contact con = prov_util_Cache.ContactRec;
        brokenAppt.Caller_Name__c = con.Name;
        brokenAppt.ContactId = con.Id;

        //get Business Account record and set values on Broken Appointment Case
        Account biz = [SELECT Id, Name, tax_id_number__c FROM Account where Id = :bizId];
        brokenAppt.Business__c = biz.Name;
        brokenAppt.Business_TIN__c = biz.tax_id_number__c;


        //get Provider Account record and set values on Broken Appointment Case
		Account prov; 
		Account loc;
		Account bus; 
		for(Account acc : [SELECT Id, first_name__c, last_name__c, Name, npi__c, guid__c FROM Account where Id = :provId OR id=:servLocId OR Id=:bizId]){
			String accId = acc.Id;
			if(accId.contains(provId)){
				prov = acc;
			} else if(accId.contains(servLocId)){
				loc = acc;
			} else if(accId.contains(bizId)){
				bus = acc;
			}  
		}

        //Set Service location lookup on Broken Appointment
        brokenAppt.Service_Location__c = servLocId;
        brokenAppt.Service_Location_GUID__c = loc.guid__c;
        //get contact related to case
        brokenAppt.Provider__c = prov.Id;
        //brokenAppt.Provider__r.Name = prov.Name;
        brokenAppt.Provider_NPI__c = prov.npi__c;
        brokenAppt.Provider_GUID__c = prov.guid__c;
        brokenAppt.Business_GUID__c = bus.guid__c;

        //set case record type to Broken Appointment
        Id recordTypeId = [select Id from RecordType where DeveloperName = 'Broken_Appointment' limit 1].Id;
        brokenAppt.RecordTypeId = recordTypeId;
        //set Case fields

        brokenAppt.Portal_Name_Text__c = portalName;
        brokenAppt.Origin = 'Provider Portal';
        brokenAppt.Type = 'Provider';
        brokenAppt.SubType__c = 'Broken Appointment';

        //set case status to new
        brokenAppt.Status = 'Closed';
                                                    
        System.debug('brokenAppt::'+brokenAppt);
        //insert record
        insert brokenAppt;

        return brokenAppt;

    }    
        
    

    public class BrokenApptWrapper{
        //Wrapper class to store search criteria information 
        @AuraEnabled
        public String memberFirstName {get; set;}
        @AuraEnabled
        public String memberLastName {get; set;}
        @AuraEnabled
        public String memberNumber {get; set;}
        @AuraEnabled
        public Date memBirthDate {get;set;}
        @AuraEnabled
        public String patientType {get;set;}
        @AuraEnabled
        public Date dateReported {get; set;}
        @AuraEnabled
        public String serviceCat {get;set;}
        @AuraEnabled
        public Date serviceDate {get;set;}
        @AuraEnabled
        public String reasonCode {get;set;}
        @AuraEnabled
        public String notes {get;set;}
        @AuraEnabled
        public string provider {get;set;}
        @AuraEnabled
        public String memProfileGuid {get;set;}
        @AuraEnabled
        public String portalName {get;set;}
    }
    
    //server-side calls to get picklist entry values to populate on forms
    @AuraEnabled
    public static List<Map<String, String>> getPatTypes(){
        
        //List<String> options = new List<String>();
        //Schema.DescribeFieldResult fieldResult = Case.Type_of_Patient__c.getDescribe();
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //for (Schema.PicklistEntry f: ple) {
        //    options.add(f.getValue());
        //}
        //return options;

        List<Map<String, String>> options = new List<map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Case.Type_of_Patient__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            Map<String, String> pklOption = new Map<String, String>();
            pklOption.put('label', f.getLabel());
            pklOption.put('value', f.getValue());
            options.add(pklOption);
        }
        return options; 
    }

    //server-side calls to get picklist entry values to populate on forms
    /*@AuraEnabled
    public static List<String> getServiceCategories(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Service_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getValue());
        }
        return options;
    }*/
    //server-side calls to get picklist entry values to populate on forms
    @AuraEnabled
    public static List<Map<String, String>> getServiceCategories2(){
        List<Map<String, String>> options = new List<map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Case.Service_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
        	Map<String, String> pklOption = new Map<String, String>();
        	pklOption.put('label', f.getLabel());
        	pklOption.put('value', f.getValue());
            options.add(pklOption);
        }
        return options; 
    }

    //server-side calls to get picklist entry values to populate on forms
    /*@AuraEnabled
    public static List<String> getReasonCodes(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Reason_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getValue());
        }
        return options;
    }*/
    //server-side calls to get picklist entry values to populate on forms
    @AuraEnabled
    public static List<Map<String, String>> getReasonCodes2(){
        List<Map<String, String>> options = new List<map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Case.Reason_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            Map<String, String> pklOption = new Map<String, String>();
        	pklOption.put('label', f.getLabel());
        	pklOption.put('value', f.getValue());
            options.add(pklOption);
        }
        return options;
    }
	
}