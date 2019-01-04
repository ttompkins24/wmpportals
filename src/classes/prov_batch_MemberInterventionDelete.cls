global without sharing class prov_batch_MemberInterventionDelete implements Database.Batchable<sObject>, Schedulable{
	public String query = 'SELECT Id FROM Member_Intervention__c '+
							' WHERE Intervention_Action__c = \'Dismissed Notice\' OR ';
	global Database.QueryLocator start(Database.BatchableContext BC){
        //get how far back we look in days
        Integer days = 7;
        try{
        	Global_Configuration__c dayDelay = Global_Configuration__c.getInstance('MemberInterventionDeleteDays');
            days = integer.valueOf(dayDelay.value__c);
        } catch (exception ex){
            // use default days
            days = 730;
        }
        //if hours are positive, make them negative
        if(days>0)
            days = -1 * days;
        
        //assemble the query
        DateTime todayDT = Datetime.newInstance(Date.today(), Time.newInstance(0,0,0,0));
        String dtFormat = todayDT.addDays(days).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        
        query += ' CreatedDate < ' + dtFormat;
        
        system.debug('Batch Member Intervention Delete Start.');
        system.debug('days: ' + days);
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
        
    }
	
    global void execute(SchedulableContext sc) {   
        //execute the batch
        prov_batch_MemberInterventionDelete deleteMIs = new prov_batch_MemberInterventionDelete();
        ID batchprocessid = Database.executeBatch(deleteMIs);
    }
    
    global void execute(Database.BatchableContext BC, List<Member_Intervention__c> scope){
        //delete the claims
        List<Database.DeleteResult> deletedRecords = Database.delete(scope, false);
        Set<Id> deletedIds = new Set<Id>();
        for(Database.DeleteResult drc : deletedRecords){
            if(drc.IsSuccess()){
                deletedIds.add(drc.getId());
            } else {
                //log the error
                system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                system.debug('Error Deleting Member_Intervention__c: ' + drc.getId());
                List<Database.Error> errs = drc.getErrors();
                if(errs.size()>0){
                    system.debug('-------------');
                    for(Database.Error err : errs){
                        system.debug(err.getMessage());
                    }
                    system.debug('-------------');
                }
            }
        }
        Database.emptyRecycleBin(new List<Id>(deletedIds));
    }  
    
    global void finish(Database.BatchableContext BC){
        //no current requirement to do anything on close
        system.debug('Batch Member Intervention Delete Finsihed.');
    }
}