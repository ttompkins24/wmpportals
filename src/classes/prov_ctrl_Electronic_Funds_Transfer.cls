//*******************************************************************************************************
//Name                        : prov_ctrl_Electronic_Funds_Transfer
//Purpose                     : Allows users to set an account to send funds to
//Created on                  : May 2018
//Developed by                : West Monroe Partners
//History
//Version#        Sprint#     Date                    by                              Comments
//1.0             7        May 2018       West Monroe Partners            See header - purpose
 
//*******************************************************************************************************
//

public without sharing class prov_ctrl_Electronic_Funds_Transfer {
	public prov_ctrl_Electronic_Funds_Transfer() {
		
	}

	@AuraEnabled
	public static Account getCurrentBusiness(){
		Account bizAcct = prov_util_Cache.CurrentBusiness;
		return bizAcct;
	}

	@AuraEnabled
	public static List<Account> getAllLocations(Id bizAcctId){
		List<Account> locAcctList = prov_util_Cache.retrieveServiceLocation(bizAcctId);
		return locAcctList;
	}

    @AuraEnabled
    public static Boolean checkHasActiveEftPsl(String bizAcctId){

        String whereClause = 'SELECT Id, Name, Is_EFT_Enrolled__c, Provider__c, Provider__r.Id, Provider__r.Name, Provider__r.npi__c, guid__c';
        whereClause +=              ' FROM Providers_Service_Locations__c'; 
        whereClause += ' WHERE Business__c = :bizAcctId';
        whereClause += ' AND Is_EFT_Enrolled__c = true';


        List<Providers_Service_Locations__c> psl = Database.query(whereClause);
        system.debug(psl);
        Boolean hasEFtStatus = true;

        if(psl.size() == 0 ){
            system.debug('here');
            hasEFtStatus = false;
        }

        return hasEFtStatus;
    }

	@AuraEnabled
	public static List<Providers_Service_Locations__c> getNewProviderServiceLocations(String bizAcctId, String servLocId){

		bizAcctId = bizAcctId.substring(0,15);

		String whereClause = 'SELECT Id, Name, Is_EFT_Enrolled__c, Provider__c, Provider__r.Id, Provider__r.Name, Provider__r.npi__c, guid__c';
		whereClause += 				' FROM Providers_Service_Locations__c'; 
    	whereClause += ' WHERE Business__c = :bizAcctId';
        whereClause += ' AND Service_Location__c = :servLocId';
        whereClause += ' AND Is_EFT_Enrolled__c = false';
        whereClause += ' AND (termination_date__c >= TODAY OR termination_date__c = null)';
        whereClause += ' ORDER BY Provider__r.Name ASC';
      
      	system.debug(whereClause);
        List<Providers_Service_Locations__c> psl = Database.query(whereClause);
        system.debug('psl' +  psl);
		return psl;
	}
	//gets PSLs that already have EFTs created
	@AuraEnabled
	public static List<Providers_Service_Locations__c> getEFTProviderServiceLocations(String bizAcctId, String servLocId){

		bizAcctId = bizAcctId.substring(0,15);

		String whereClause = 'SELECT Id, Name, Is_EFT_Enrolled__c, Provider__c, Provider__r.Id, Provider__r.Name, Provider__r.npi__c, guid__c';
		whereClause += 				' FROM Providers_Service_Locations__c'; 
    	whereClause += ' WHERE Business__c = :bizAcctId';
        whereClause += ' AND Service_Location__c = :servLocId';
        whereClause += ' AND Is_EFT_Enrolled__c = true';
        whereClause += ' AND (termination_date__c >= TODAY OR termination_date__c = null)';
        whereClause += ' ORDER BY Provider__r.Name ASC';

        system.debug(whereClause);
        List<Providers_Service_Locations__c> psl = Database.query(whereClause);


		return psl;
	}

	@AuraEnabled
	public static Case createCase(string caseId, string eftJson, string changesJson, String locAcctId){

		system.debug(changesJson);

		Case eftCase;
        if(caseId != null && caseId != '') {
            eftCase = [SELECT Id, Route_To__c, RecordTypeId, ContactId, Providers_Service_Locations__c, Practice_Management_Updates__c,
                Notes__c, Status, Origin, Type, Subject, SubType__c FROM Case WHERE Id =: caseId];
        } else {
            eftCase = new Case();
        }



		system.debug('eftcase json string::' + eftJson);
		//deserialize json string and then 
		EFTCaseWrapper caseJson = (EFTCaseWrapper) System.JSON.deserialize(eftJson,EFTCaseWrapper.class);

		system.debug(caseJson);

		Account business = prov_util_Cache.CurrentBusiness;
        eftCase.Business__c = business.Name;
        eftCase.Business_lkup__c = business.Id;
        eftCase.Business_TIN__c = business.tax_id_number__c;
        eftCase.AccountId = business.Id;

		eftCase.Bank_Name__c = caseJson.BankName;
		eftCase.EFT_Account_Holder_Name__c = caseJson.AccountHolderName;
		eftCase.EFT_Bank_Account_Number__c  = caseJson.AccountNumber;
		eftCase.EFT_Routing_Number__c  = caseJson.RoutingNumber;
		eftCase.Bank_Phone_Number__c = caseJson.BankPhone;
		eftCase.Desired_Start_Date__c = caseJson.DesiredStartDate;
		eftCase.EFTAlternate_Contact_First_Name__c = caseJson.ContactFirstName;
		eftCase.EFT_Alternate_Contact_Last_Name__c = caseJson.ContactLastName;
		eftCase.EFT_Alternate_Contact_Phone__c = caseJson.ContactPhone;
		eftCase.EFT_Alternate_Contact_Email__c = caseJson.ContactEmail;
		eftCase.Bank_Account_Type__c = caseJson.BankAccountType;
		eftCase.Practice_Management_Updates__c = prov_util_JSON.formatJSON(changesJson,false);

        //encrypted fields

        if(locAcctId != null && locAcctId != '' && locAcctId != 'All'){
            eftCase.Service_Location__c = locAcctId;
        }

		Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EFT_Enrollment_Update_Cancellation' LIMIT 1].Id;
        eftCase.RecordTypeId = recordTypeId;

        eftCase.CG_A_Classification__c = 'Administrative';
        eftCase.Type = 'Provider Update';
        eftCase.SubType__c = 'EFT';
        eftCase.Route_To__c = 'Provider Operations';

        Group providerOpsQueue = [SELECT Id FROM Group Where Type = 'Queue' AND DeveloperName = 'Provider_Operations'];
        eftCase.OwnerId = providerOpsQueue.Id;

        Contact con = prov_util_Cache.ContactRec;
        eftCase.ContactId = con.Id;

        eftCase.Subject = 'EFT Enrollment/Update/Cancellation';
        eftCase.Status = 'New';
        eftCase.Origin = 'Provider Portal';
        eftCase.Priority = 'Medium';


        //what kind of EFT request is it?
        eftCase.EFT_Modification__c = caseJson.EftMod;
        

		//insert the case
		upsert eftCase;

		//get the case number
		Case returnedEftCase = [SELECT Id, CaseNumber FROM Case WHERE Subject = :eftCase.Subject ORDER BY CreatedDate DESC LIMIT 1];
		system.debug(returnedEftCase);
		//return the case to client-side

		return returnedEftCase;
	}

	@AuraEnabled
	public static Contact retrieveCurrentContact(){

		Contact con = prov_util_Cache.getContactRec();
		//con.Phone = '111-111-1111';
		return con;

	}


	public class EFTCaseWrapper{
		@AuraEnabled
		public String BankName {get;set;}
        @AuraEnabled
		public String AccountHolderName {get;set;}
		@AuraEnabled
		public String AccountNumber {get;set;}
		@AuraEnabled
		public String RoutingNumber {get;set;}
		@AuraEnabled
		public String BankAccountType {get;set;}
		@AuraEnabled
		public String BankPhone {get;set;}
		@AuraEnabled
		public Date DesiredStartDate {get;set;}
		@AuraEnabled
        public String ContactFirstName {get; set;}
        @AuraEnabled
        public String ContactLastName {get; set;}
        @AuraEnabled
        public String ContactPhone {get;set;}
        @AuraEnabled
		public String ContactEmail {get;set;}
		@AuraEnabled
		public String EftMod {get;set;}

	}

	/**
     * Creates a case which represents an update request
     */
    @AuraEnabled
    public static Case saveEFTCaseWrapperApex(){
        Case updateCase = new Case();

        Contact con = prov_util_Cache.ContactRec;
        updateCase.Route_To__c = 'DentaQuest Portal Cases';
        updateCase.Status = 'New';
        updateCase.Origin = 'Draft';
        updateCase.Type = 'Provider Updates';
        updateCase.Subject = 'Provider EFT Update';
        updateCase.SubType__c = 'EFT';
        upsert updateCase;

        return updateCase;
    }

    @AuraEnabled
    public static Map<String, String> eftAllServLocsMap(String bizId){
    	system.debug(bizId);
    	List<Providers_Service_Locations__c> pslList = [SELECT id, Provider__r.Name, Provider__r.provider_gid__c, Service_Location__r.Name, Service_Location__r.location_gid__c 
    	FROM Providers_Service_Locations__c WHERE Business__c = :bizId];

    	List<Providers_Service_Locations__c> pslLocationList = [SELECT id, Service_Location__r.Name, Service_Location__r.location_gid__c 
    	FROM Providers_Service_Locations__c WHERE Business__c = :bizId];
    	//generate map

    	Map<String,String> eftChangesMap = new Map<String, String>();

        eftChangesMap.put('Service Location Name', 'Service Location GID');

        for(Providers_Service_Locations__c pslLoc : pslLocationList){
            eftChangesMap.put(pslLoc.Service_Location__r.Name, String.valueOf(pslLoc.Service_Location__r.location_gid__c));
        }

        eftChangesMap.put('Provider Name', 'Provider GID');

    	for(Providers_Service_Locations__c psl : pslList){

    		eftChangesMap.put(psl.Provider__r.Name,  String.valueOf(psl.Provider__r.provider_gid__c));
    		

    	}

    	


    	system.debug(eftChangesMap);

    	return eftChangesMap;
    }

    @AuraEnabled
    public static Map<String, String> eftOneServLocMap(String locId, List<String> pslIdString){
    	Map<String,String> eftChangesMap = new Map<String, String>();
    	List<Providers_Service_Locations__c> pslList = [SELECT Id, guid__c, Provider__r.Name, Provider__r.provider_gid__c, Service_Location__r.Name, Service_Location__r.location_gid__c 
    	FROM Providers_Service_Locations__c WHERE guid__c IN :pslIdString];

    	List<Providers_Service_Locations__c> pslLocationList = [SELECT id, Service_Location__r.Name, Service_Location__r.location_gid__c 
    	FROM Providers_Service_Locations__c WHERE Service_Location__c = :locId];
    	eftChangesMap.put('Service Location Name', 'Service Location GID');
    	for(Providers_Service_Locations__c pslLoc : pslLocationList){
    		eftChangesMap.put(pslLoc.Service_Location__r.Name, String.valueOf(pslLoc.Service_Location__r.location_gid__c));
    	}
    	eftChangesMap.put('Provider Name', 'Provider GID');
    	for(Providers_Service_Locations__c psl : pslList){

    		eftChangesMap.put(psl.Provider__r.Name,  String.valueOf(psl.Provider__r.provider_gid__c));
    	}

    	
    	return eftChangesMap;
    }

}