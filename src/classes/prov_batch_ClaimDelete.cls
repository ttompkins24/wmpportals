/**********************************************************************************************************************
Name                        :   prov_batch_ClaimDelete
Purpose                     :   The utility that will delete submitted claims from the system
Created on                  :   03/15/2018
Developed by                :   Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.0         4.0         03/15/2018      Patrick Stephens    

**********************************************************************************************************************/
global without sharing class prov_batch_ClaimDelete implements Database.Batchable<sObject>, Schedulable{
	public String query = 'SELECT Id, Is_Submitted__c, Claim_Draft_Status__c, Submitted_DateTime__c FROM Claim__c '+
							' WHERE Is_Submitted__c = true AND Claim_Draft_Status__c = \'Submitted\' AND ';
	global Database.QueryLocator start(Database.BatchableContext BC){
        //get how far back we look in days
        Integer days = 7;
        try{
        	Global_Configuration__c hourDelay = Global_Configuration__c.getInstance('ClaimDeleteDelayDays');
            days = integer.valueOf(hourDelay.value__c);
        } catch (exception ex){
            // use default days
        }
        //if hours are positive, make them negative
        if(days>0)
            days = -1 * days;
        
        //assemble the query
        DateTime todayDT = Datetime.newInstance(Date.today(), Time.newInstance(0,0,0,0));
        String dtFormat = todayDT.addDays(days).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        
        query += ' Submitted_DateTime__c < ' + dtFormat;
        
        system.debug('Batch Claim Delete Start.');
        system.debug('days: ' + days);
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
        
    }
	
    global void execute(SchedulableContext sc) {   
        //execute the batch
        prov_batch_ClaimDelete deleteClaims = new prov_batch_ClaimDelete();
        ID batchprocessid = Database.executeBatch(deleteClaims);
    }
    
    global void execute(Database.BatchableContext BC, List<Claim__c> scope){
        //delete the claims
        List<Database.DeleteResult> deletedRecords = Database.delete(scope, false);
        Set<Id> deletedIds = new Set<Id>();
        for(Database.DeleteResult drc : deletedRecords){
            if(drc.IsSuccess()){
                deletedIds.add(drc.getId());
            } else {
                //log the error
                system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                system.debug('Error Deleting Claim__c: ' + drc.getId());
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
        system.debug('Batch Claim Delete Finsihed.');
    }
}