public without sharing class prov_ctrl_Member_Intervention {
	public prov_ctrl_Member_Intervention() {
		
	}

	//gets list of member interventions from SFDC based on filter criteria
	@AuraEnabled
	public static List<Member_Intervention__c> retrieveInterventions(String bizAcctId, String locAcctId, String provAcctId,  String firstNameSearch, String lastNameSearch, String memNumSearch, String priorEventDateStartSearch, String priorEventDateStopSearch, String sortField, String direction,  String numResultsS,  String pageNumS){

	    List<String> provAcctIDList = new List<String>();

	    String notice = 'New Notice';

	    bizAcctId = bizAcctId.substring(0,15);

	    if(provAcctId == null || provAcctId == 'Any'){
	        provAcctIDList = prov_util_Cache.retrieveProviderIdsByBusinessId(bizAcctId);
	    }


	    Integer intpage = 1;
    	Integer numResults = 10;

    	//sets page number variable
	    if(pageNumS != null && pageNumS != '')              intpage = Integer.valueOf(pageNumS);
	    system.debug('intpage '+intpage);
	    //sets results per page  variable
	    if(numResultsS != null && numResultsS != '')        numResults = Integer.valueOf(numResultsS);
	    //generate string for checking filter fields in SOQL query is those fields are selected
	    String searchLikeFirstName = '';
        String searchLikeLastName = '';
        String searchLikeMemNum = '';
        String searchLikeIntMesaure = '';
        if (firstNameSearch != null && firstNameSearch != ''){
            searchLikeFirstName = ' AND Member_First_Name__c LIKE \'' + firstNameSearch + '%\'';
        }
        if(lastNameSearch != null && lastNameSearch != ''){
            searchLikeLastName = ' AND Member_Last_Name__c LIKE \'' + lastNameSearch + '%\'';
        }
        if(memNumSearch != null && memNumSearch != ''){
            searchLikeMemNum = ' AND Member_Subscriber_Id__c LIKE \'' + memNumSearch + '%\'';
        }

        String searchGreaterThanPriorEventStartDate = '';
        String searchLessThanPriorEventStopDate = '';
        system.debug(priorEventDateStartSearch);
        if(priorEventDateStartSearch != null && priorEventDateStartSearch != ''){
        	
        	searchGreaterThanPriorEventStartDate = ' AND Last_Service_Date__c >= ' + priorEventDateStartSearch;
        }

        system.debug(priorEventDateStopSearch);
        if(priorEventDateStopSearch != null && priorEventDateStopSearch != ''){
        	
        	searchLessThanPriorEventStopDate = ' AND Last_Service_Date__c <= ' + priorEventDateStopSearch;
        }


	    System.debug('bizAcctId::'+bizAcctId);
	    System.debug('provAcctIDList::'+provAcctIDList);
	    System.debug('businessIds::'+prov_util_Cache.cobj.BusinessIdToProviderIds.keyset());
	    System.debug('providerIds::'+prov_util_Cache.cobj.BusinessIdToProviderIds.get(bizAcctId));
	    //get all plans a business can see
	    Set<String> plans = prov_util_Cache.getVisibilePlanWWIds(bizAcctId);
	    //create where clause for dynamic query
		String whereClause = 'SELECT id, Name, Member_Subscriber_Id__c, Member_Last_Name__c, Member_First_Name__c, Member_Birthdate__c, Member_Phone__c, Last_Service_Date__c, Intervention_Measure__c, Intervention_Steps__c,Intervention_Action__c ';
		whereClause += 				' FROM Member_Intervention__c'; 
    	whereClause += ' WHERE Business__c = :bizAcctId' ;
    	whereClause += ' AND Service_Location__c = :locAcctId';    
    	whereClause += ' AND Intervention_Action__c = :notice';
    	if(provAcctId == null || provAcctId == '' || provAcctId == 'Any'){
            whereClause += ' AND Provider__c IN :provAcctIDList';
        } else {
    	   whereClause += ' AND Provider__c = :provAcctId';
        }

        whereClause += searchLikeFirstName;
        whereClause += searchLikeLastName;
        whereClause += searchLikeMemNum;
        whereClause += searchGreaterThanPriorEventStartDate;
        whereClause += searchLessThanPriorEventStopDate;


        String order = '';
	    if(sortField != null || direction != null){
	    	order = ' ORDER BY '+sortField+' '+direction;
	    }else{
	    	order = ' ORDER BY Last_Service_Date__c ASC';
	    }
	    //limit query to 1000
	    String limitNum = ' LIMIT 1000';
	    whereClause += order;
	    whereClause += limitNum;
	        system.debug(whereClause);

        List<Member_Intervention__c> memInt = Database.query(whereClause);
        system.debug(memint);

        //set total number of records
        totalNumRecords = memInt.size();
        system.debug(totalNumRecords);
        //set total number of pages
        totalPages = Integer.valueOf( (Decimal.valueOf( totalNumRecords ) / numResults).round(System.RoundingMode.UP) );
        totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1   
        pageNum = intpage;


        return memInt;
	}

	//update multiple Member Interventions with intervention action selected on page
	@AuraEnabled
	public static List<Member_Intervention__c> updateInterventionActions(String interventionJSON){
		List<Member_Intervention__c> memIntRecords = (List<Member_Intervention__c>) System.JSON.deserialize(interventionJSON,List<Member_Intervention__c>.class);
		system.debug(memIntRecords);
		List<Member_Intervention__c> updatedMemIntRecs = new List<Member_Intervention__c>();
		for(Member_Intervention__c memInt : memIntRecords){
			memInt.Intervention_Action__c = 'Dismissed Notice';
			updatedMemIntRecs.add(memInt);
		}
		update updatedMemIntRecs;

		return updatedMemIntRecs;
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

}