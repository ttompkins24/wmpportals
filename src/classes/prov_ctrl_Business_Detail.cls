/*
/*******************************************************************************************************
Name                        : prov_ctrl_Business_Detail
Purpose                     : Controller for the prov_comp_Business_Detail  
                              Displays Business details and related records
Created on                  : 19th February 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                    by                              Comments
1.0             3.0         19th February 2018      West Monroe Partners            See header - purpose
 
*******************************************************************************************************
*/

public without sharing class prov_ctrl_Business_Detail {
	public prov_ctrl_Business_Detail() {
		
	}

	@AuraEnabled
	public static Account getAllBusinessesBusinessDetail(){
		Account bizAcct = prov_util_Cache.CurrentBusiness;
		return bizAcct;
	}

    @AuraEnabled
    public static String getExistingCaseApex(Id currentBusinessId) {
        String retVal = null;
        try {
            retVal = [SELECT Id FROM Case WHERE Business_lkup__c =: currentBusinessId AND Subject = 'Business Detail Update' AND IsClosed = false LIMIT 1].Id;
        } catch(exception e) {
            system.debug('unable to retrieve existing case: '+ e);
        }
        system.debug('existing case Id: '+retVal);
        return retVal;
    }

	@AuraEnabled
	public static List<Account> getAllLocationsBusinessDetail(String bizAcctId, String pageNumS, String numResultsS, String fieldS, String directionS){
        bizAcctId = bizAcctId.substring(0,15);
		List<String> locAcctIDList = prov_util_Cache.retrieveServiceLocationIdsByBusinessId(bizAcctId);

		Integer locPage = 1;
        Integer locNumResults = 10;
        system.debug(pageNumS);
        //sets page number variable
        if(pageNumS != null && pageNumS != ''){
            locPage = Integer.valueOf(pageNumS);
            }              
        //sets results per page  variable
        if(numResultsS != null && numResultsS != '')        locNumResults = Integer.valueOf(numResultsS);

        //sets default sorted field and direction if they are not specified
        if(fieldS == null || fieldS == '')        fieldS = 'Name';
        if(directionS == null || directionS == '')   directionS = 'ASC';

        //add sorting
        String whereClause = 'SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone';
        whereClause +=              ' FROM Account'; 
        whereClause += ' WHERE Id IN :locAcctIDList';

        String order = '';
        if(fieldS != null || directionS != null){
            order = ' ORDER BY '+fieldS+' '+directionS;
        }

        whereClause += order;
        system.debug(whereClause);

        List<Account> locAcctList = Database.query(whereClause);

        totalNumRecords = locAcctList.size();
        //set total number of pages
        totalPages = Integer.valueOf( (Decimal.valueOf( totalNumRecords ) / locNumResults).round(System.RoundingMode.UP) );
        totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1   
        pageNum = locPage;
		return locAcctList;
	}

	@AuraEnabled
    public static Integer totalPages {get;set;}
    @AuraEnabled
    public static Integer pageNum {get;set;}
    @AuraEnabled
    public static Integer totalNumRecords {get;set;}

    @AuraEnabled
    public static List<Integer> paginationVariables(){

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
	public static String saveBusinessUpdateApex(String updateJSON, String bizAcctId, String notes, String visibleLOB){
        system.debug('update new business');

		String businessCaseString = '';
 		Case updateCase = new Case();
        updateCase.Type = 'Dentist Change';
        updateCase.SubType__c = 'Updates';

        Id recordTypeId = [select Id from RecordType where DeveloperName = 'Practice_Management' limit 1].Id;
        updateCase.RecordTypeId = recordTypeId;

        Contact con = prov_util_Cache.ContactRec;
        updateCase.ContactId = con.Id;
        updateCase.Origin = 'Provider Portal';
        updateCase.Status = 'New';

        updateCase.Portal_Name_Text__c = visibleLOB;
        updateCase.Subject = 'Business Detail Update';
        updateCase.Route_To__c = 'Provider Operations';
        Account biz = [SELECT Id, Name, tax_id_number__c FROM Account where Id = :bizAcctId];
        updateCase.Business__c = biz.Name;
        updateCase.Business_TIN__c = biz.tax_id_number__c;
        updateCase.AccountId = biz.Id;
        updateCase.Business_lkup__c = biz.Id;
        updateCase.Notes__c = notes;

        updateCase.Practice_Management_Updates__c = prov_util_JSON.formatJSON(updateJSON,false);
        //updateCase.Case_Update_JSON__c = updateJSON;

        insert updateCase;

        String caseNum = [select id, CaseNumber FROM Case where id = :updateCase.id LIMIT 1].CaseNumber;

		return caseNum;
	}

    //server-side calls to get picklist entry values to populate on forms
    @AuraEnabled
    public static List<String> getProvTypes(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.provider_type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getValue());
        }
        return options;
    }

}