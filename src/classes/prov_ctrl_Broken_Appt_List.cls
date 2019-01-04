/*******************************************************************************************************
Name                        : Prov_ctrl_Broken_Appt_List
Purpose                     : Apex controller for Broken Appointment List lightning components
                                
Created on                  : February 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                    by                              Comments
1.0             2.0         February 2018       West Monroe Partners                    See header - purpose
 
*******************************************************************************************************/


public without sharing class prov_ctrl_Broken_Appt_List {
	public prov_ctrl_Broken_Appt_List() {
		
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
    
    //server-side calls to get picklist entry values to populate on forms
    public static Map<String, String> getServiceCategories(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Case.Service_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
			options.put(f.getValue(), f.getLabel());
        }
        return options; 
    }
    //server-side calls to get picklist entry values to populate on forms
    public static Map<String, String> getReasonCodes(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Case.Reason_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
			options.put(f.getValue(), f.getLabel());
        }
        return options;
    }
	

	@AuraEnabled
	public static List<Case> getBrokenAppointments(String servLocId, String providerId, String fName,String lName,String memNum, String pageNumS, String fieldS, String directionS, String numResultsS){

	Integer page = 1;
    Integer numResults = 20;
    if(pageNumS != null && pageNumS != '')              page = Integer.valueOf(pageNumS);
    system.debug('page '+page);
    if(numResultsS != null && numResultsS != '')        numResults = Integer.valueOf(numResultsS);
    if(fieldS == null || fieldS == '')        fieldS = 'Service_Date__c';
    if(directionS == null || directionS == '')   directionS = 'DESC';
    //get record type
    Id recordTypeId = [select Id from RecordType where DeveloperName = 'Broken_Appointment' limit 1].Id;

    //generate dynamic WHERE clause for query of cases
    String whereClause = 'SELECT id, Provider__r.Name, Member_Profile_Guid__c, Provider__c, Portal_Name__c, Provider_Portal_Member_First_Name__c, Provider_Portal_Member_Last_Name__c, Member_DOB__c, Member_ID__c, Type_of_Patient__c, Subscriber_ID__c, Reason_Code__c, Date_Reported__c, Service_Date__c, Service_Category__c';
	whereClause += 				' FROM Case'; 
    whereClause += ' WHERE Service_Location__c = :servLocId';

    whereClause += ' AND RecordTypeId = :recordTypeId';
    if(providerId != null && providerId != ''){
        
	whereClause +=				' AND Provider__c = :providerId';
    }

	if(fName != null){
	whereClause +=				' AND Provider_Portal_Member_First_Name__c LIKE \'' + fName + '%\'';
		
	}
	if(lName != null){
	whereClause +=			    ' AND Provider_Portal_Member_Last_Name__c LIKE \'' + lName + '%\'';
		
	}
	if(memNum != null){
	whereClause +=				' AND Subscriber_ID__c LIKE \'' + memNum + '%\'';
		
	}
    


    //set order by block for SOQL query based on field name and direction params
	String order = '';
    if(fieldS != null || directionS != null){
    	order = ' ORDER BY '+fieldS+' '+directionS;
    }
    //limit query to 1000
    String limitNum = ' LIMIT 1000';

    whereClause += order;
    whereClause += limitNum;

	List<Case> caseList = Database.query(whereClause);

	Map<String, String> reasonCodeMap = getReasonCodes();
	//Map<String, String> serviceCatMap = getServiceCategories();
	
	for(Case c : caseList){
		//map the reason code value to the label of the picklist
		if(reasonCodeMap.containsKey(c.Reason_Code__c)){
			c.Reason_Code__c = reasonCodeMap.get(c.Reason_Code__c);
		}
		
		//map the service category value to the label of the picklist
		/*if(serviceCatMap.containsKey(c.Service_Category__c)){
			c.Service_Category__c = serviceCatMap.get(c.Service_Category__c);
		}*/
	}
	
		//set total number of records
        totalNumRecords = caseList.size();
        system.debug(totalNumRecords);
        //set total number of pages
        totalPages = Integer.valueOf( (Decimal.valueOf( totalNumRecords ) / numResults).round(System.RoundingMode.UP) );
        totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1   
        pageNum = page;
        return caseList;
	}

	
}