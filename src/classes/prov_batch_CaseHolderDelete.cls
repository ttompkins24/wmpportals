/******************************************************************
Batch to delete the cases that are temporarily created in order to expeditate the case attachment loading process. These cases are created with Origin
of Draft.  If they are in that status for longer than a day then we need to delete these cases from the system. If the case was submitted
then the origin would be updated to provider portal
******************************************************************/
global without sharing class prov_batch_CaseHolderDelete implements Database.Batchable<sObject>, Schedulable {
    
    public String query = 'SELECT Id FROM Case '+
							' WHERE Origin = \'Draft\' AND ';
	global Database.QueryLocator start(Database.BatchableContext BC){
        //get how far back we look in days
        Integer days = 1;
        
        //if hours are positive, make them negative
        if(days>0)
            days = -1 * days;
        
        //assemble the query
        DateTime todayDT = Datetime.now();
        String dtFormat = todayDT.addDays(days).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        
        query += ' CreatedDate < ' + dtFormat;
        
        system.debug('Batch Case DeleteStart.');
        system.debug('days: ' + days);
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
        
    }
	
    global void execute(SchedulableContext sc) {   
        //execute the batch
        prov_batch_CaseHolderDelete deleteCases = new prov_batch_CaseHolderDelete();
        ID batchprocessid = Database.executeBatch(deleteCases);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope){
        //delete the claims
        List<Database.DeleteResult> deletedRecords = Database.delete(scope, false);
        Set<Id> deletedIds = new Set<Id>();
        for(Database.DeleteResult drc : deletedRecords){
            if(drc.IsSuccess()){
                deletedIds.add(drc.getId());
            } else {
                //log the error
                system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                system.debug('Error Deleting Case: ' + drc.getId());
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
        system.debug('Batch Case Delete Finsihed.');
    }
}