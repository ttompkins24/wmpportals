/*
/***********************************************************************
Name                        : prov_ctrl_Billed_Amount
Purpose                     : Controller for the prov_comp_Billed_Amount 
                              Gets relevant billed amount information.
Created on                  : February 6th, 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                    by                              
1.0             1.0         6th February 2018       West Monroe Partners            
 
************************************************************************
*/
public without sharing class prov_ctrl_Billed_Amount {
    
    @AuraEnabled
    public static Integer totalPages {get;set;}
    
    @AuraEnabled
    public static Integer totalNumRecords {get;set;}
    
    @AuraEnabled
    public static List<Integer> paginationVariables(){
        //intitalize variables
        List<Integer> paginationVars = new List<Integer>();
        
        //add the results to the list to return
        paginationVars.add(totalPages);
        paginationVars.add(totalNumRecords);
        //return the list
        return paginationVars;
    }
    
    @AuraEnabled
    public static BilledAmountWrapper getBilledAmountApex(String businessId, String pageNumS, String numResultsS, String sortByField, String sortDirection){
        System.debug('START getBilledAmountApex...'+businessId);
        //initialize the variables
        Integer pageNum = 1; //default value
        Integer numResults = 20; //set default value
        BilledAmountWrapper wrapper = new BilledAmountWrapper();
        totalPages = 1;
        totalNumRecords = 0;
        
        //initialize variables for pagination/ sort
        if(pageNumS != null && pageNumS != '')              pageNum = Integer.valueOf(pageNumS);
        if(numResultsS != null && numResultsS != '')        numResults = Integer.valueOf(numResultsS);
        if(sortByField == null || sortByField == '')        sortByField = 'Name';
        if(sortDirection == null || sortDirection == '')    sortDirection = 'ASC';
        
        if(businessId == null || businessId == '')
            businessId = prov_util_Cache.CurrentBusinessId;
        Account business = [SELECT Name, Id FROM Account WHERE Id =: businessId];
        List<Billed_Amount__c> billed_amounts;
        List<Billed_Amount__c> fullList;
        prov_util_CacheObject cacheObj = prov_util_Cache.cobj;
        prov_util_Permissions permissionObj = cacheObj.businessId2PermissionsMap.get(businessId.substring(0,15));
        
        
        System.debug('permissionObj::'+permissionObj);
        if( permissionObj.admin ==false || permissionObj.admin == null   ){
            List<Id> providerIds = prov_util_Cache.BusinessIdToProviderIds.get(businessId);
            List<String> servLocationIds = prov_util_Cache.BusinessIdToLocationIds.get(businessId);
            Set<Id> businessAmountIds = new Set<Id>();
            for(Billed_Amount_Association__c baa :[SELECT Id, Billed_Amount__c
                                                    FROM Billed_Amount_Association__c
                                                    WHERE Provider__c IN:providerIds AND Service_Location__c IN: servLocationIds AND Billed_Amount__r.Business__c =:businessId]){
                //collect the info needed
                businessAmountIds.add(baa.Billed_Amount__c);                                                
            }
            System.debug('businessAmountIds::'+businessAmountIds);
            System.debug('cacheObj.ContactToReview::'+cacheObj.ContactRec.Id);
            System.debug('cacheObj.VisibleLOB::'+cacheObj.VisibleLOB);
            
            fullList =(List<Billed_Amount__c>)Database.query('SELECT Id FROM Billed_Amount__c WHERE ((Business__c =: businessId AND Created_By_Contact__c =\'' + cacheObj.ContactRec.Id + '\') OR Id=:businessAmountIds) AND RouteId__c includes (\'' +String.join( new List<String>(cacheObj.VisibleLOB), '\',\'')+ '\')');
            totalPages = Integer.valueOf( (Decimal.valueOf( fullList.size() ) / numResults).round(System.RoundingMode.UP) );
            totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1
            totalNumRecords = fullList.size();
            billed_amounts = (List<Billed_Amount__c>)Database.query('SELECT Id, Name, Created_By_Contact__r.Name, RouteId__c ' +        
            ' FROM Billed_Amount__c WHERE ((Business__c =\''+ businessId+'\' AND Created_By_Contact__c =\'' + cacheObj.ContactRec.Id + '\') OR Id IN:businessAmountIds) AND RouteId__c INCLUDES (\''+ String.join( new List<String>(cacheObj.VisibleLOB), '\',\'')+ '\') '+ 
            ' ORDER BY '+sortByField + ' ' + sortDirection + 
            ' LIMIT ' + numResults  + ' OFFSET '+((pageNum-1)*numResults) );
 
        } else{
            String someVar;
            fullList =(List<Billed_Amount__c>)Database.query('SELECT Id FROM Billed_Amount__c WHERE Business__c =\''+ businessId +'\' AND RouteId__c includes (\'' +String.join( new List<String>(cacheObj.VisibleLOB), '\',\'')+ '\')');
            System.debug('fullList::'+fullList.size());
            totalPages = Integer.valueOf( (Decimal.valueOf( fullList.size() ) / numResults).round(System.RoundingMode.UP) );
            System.debug('totalPages::'+totalPages);
            totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1
             totalNumRecords = fullList.size();       
            billed_amounts = (List<Billed_Amount__c>)Database.query('SELECT Id, Name, Created_By_Contact__r.Name, RouteId__c ' +        
                ' FROM Billed_Amount__c WHERE Business__c =\''+ businessId+'\'  AND RouteId__c INCLUDES (\''+ String.join( new List<String>(cacheObj.VisibleLOB), '\',\'')+ '\') ' +
                ' ORDER BY '+sortByField + ' ' + sortDirection +
                ' LIMIT ' + numResults  + ' OFFSET '+((pageNum-1)*numResults) );
            System.debug('billed_amounts::'+billed_amounts);
        }
        wrapper.billed_amounts = billed_amounts;
        wrapper.business = business;
        System.debug('wrapper.billed_amounts::'+wrapper.billed_amounts);
        System.debug(' wrapper.business::'+ wrapper.business);
        return wrapper;
    }
/*
    @AuraEnabled
    public static BilledAmountWrapper saveBilledAmountApex(String billedAmountName) {
        Billed_Amount__c newBilledAmountGroup = new Billed_Amount__c();

        Contact currentContact = prov_util_Cache.getContactRec();
        newBilledAmountGroup.Created_By_Contact__c = currentContact.Id;
        newBilledAmountGroup.Name = billedAmountName;
        newBilledAmountGroup.Business__c = prov_util_Cache.CurrentBusinessId;
        newBilledAmountGroup.RouteId__c = String.join(new List<String>(prov_util_Cache.VisibleLOB),'\';\'');

        insert newBilledAmountGroup;

        return getBilledAmountApex();
    }*/
    
    @AuraEnabled
    public static String handleDeleteApex(Id billedAmountId){
        Savepoint sp = Database.setSavepoint();
        try{
            delete new Billed_Amount__c(Id=billedAmountId);
        } catch(exception ex){
            Database.rollback(sp);
            System.debug('message::'+ex.getMessage());
            System.debug('stack::'+ex.getStackTraceString());
            return ex.getMessage();
        }
        return '';
    }

    public class BilledAmountWrapper {
        @AuraEnabled public Account business {get;set;}
        @AuraEnabled public List<Billed_Amount__c> billed_amounts{get;set;}
    }
}