/*
/*******************************************************************************************************
Name                        : prov_ctrl_SearchCriteria
Purpose                     : Controller for the prov_comp_SearchCriteria_Manage and prov_comp_SearchCriteria_Modal. 
                              Displays list of saved search criteria. Allows user to edit, open, delete the saved search criteria records.
Created on                  : 13rd January 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                    by                              Comments
1.0             1.0         13rd January 2018       West Monroe Partners            See header - purpose
 
*******************************************************************************************************
*/
public without sharing class prov_ctrl_SearchCriteria { 
    
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
    /*
        Retrieve the list of search criteria items by business id
    */
   
     @AuraEnabled
    public static List<Search_Criteria__c> loadSearchCriteriaApex(String pageNumS, String numResultsS, String sortByField, String sortDirection, String businessId, String routeId){
        //intialize the variables  
        List<String> businessIds = new List<String>{ businessId }; //current business id that the user is looking at
        List<String> serviceLocationIds = prov_util_Cache.retrieveServiceLocationIdsByBusinessId(businessIds[0] );
        System.debug('serviceLocationIds::'+serviceLocationIds);
        //serviceLocationIds.addAll( );
        List<String> providerIds = prov_util_Cache.retrieveProviderIdsByBusinessId(businessIds[0] ) ;
        List<Search_Criteria__c> returnList = new List<Search_Criteria__c>();
        Set<ID> providerServiceLocationIds = new Set<ID>();
        Integer pageNum = 1; //default value
        Integer numResults = 20; //set default value
        //System.debug('pageNumS::'+pageNumS);
        //System.debug('numResultsS::'+numResultsS);
        //System.debug('sortByField::'+sortByField);
        //System.debug('sortDirection::'+sortDirection);
        
        //check to see if blank, if so then set default 
        if(pageNumS != null && pageNumS != '')              pageNum = Integer.valueOf(pageNumS);
        if(numResultsS != null && numResultsS != '')        numResults = Integer.valueOf(numResultsS);
        if(sortByField == null || sortByField == '')        sortByField = 'LastModifiedDate';
        if(sortDirection == null || sortDirection == '')    sortDirection = 'DESC';
        
        try{
            //query PSLs
            for(Providers_Service_Locations__c PSL : prov_util_DAL.retrievePSL_CacheWId(new Set<String>(providerIds), 
                                                                                    new Set<String>(serviceLocationIds), 
                                                                                    new Set<String>(businessIds) )){
                //collect the psl ids
                providerServiceLocationIds.add(PSL.Id);
            }

            System.debug('providerServiceLocationIds::'+providerServiceLocationIds);
            //query to get total num of results
            totalNumRecords = [SELECT id
                            FROM Search_Criteria__c 
                            WHERE Provider_Service_Location__c IN: providerServiceLocationIds ].size();  
                        
            totalPages = Integer.valueOf( (Decimal.valueOf( totalNumRecords ) / numResults).round(System.RoundingMode.UP) );
            totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1
            //query for the search criteria items
            return (List<Search_Criteria__c>) Database.query('SELECT id, Provider_Service_Location__c, Created_By_Contact__c, Created_By_Contact__r.Name, Name, LastModifiedDate , ' + 
                                    'Provider_Service_Location__r.Service_Location__r.Name, Provider_Service_Location__r.Provider__r.Name ' + 
                                    'FROM Search_Criteria__c '+
                                    'WHERE Provider_Service_Location__c IN:providerServiceLocationIds ' + 
                                    'ORDER BY '+sortByField + ' ' + sortDirection + 
                                    ' LIMIT '+numResults + ' OFFSET '+((pageNum-1)*numResults) );
        } catch (exception ex){
            system.debug('----------------------------------------------------------');
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            system.debug('----------------------------------------------------------');
        }               
        return new List<Search_Criteria__c>();   
    }
    
    
    @AuraEnabled
    public static Boolean deleteSearchCriteriaApex(String searchCriteriaId){
        //create a save point to allow rollback in case of error
        Savepoint sp = Database.setSavepoint();
        try{
            //delete the selected search criteria
            delete new Search_Criteria__c(Id=searchCriteriaId);
        } catch(Exception ex){
            //rollback to before the delete
            Database.rollback(sp);
            System.debug('Error::'+ex.getMessage());
            System.debug('Error::'+ex.getStackTraceString());
            return false;
        }
        return true;
    }
    
    /*
        Update the search criteria's name from the passed in parameters
    */
    @AuraEnabled
    public static Boolean updateSearchCriteriaApex(String searchCriteriaId, String newName){
        //create a save point to allow rollback in case of error
        Savepoint sp = Database.setSavepoint();
        try{
            //update the search criteria record
            update new Search_Criteria__c(Id=searchCriteriaId, Name=newName);
        } catch(Exception ex){
            //rollback to before the delete
            Database.rollback(sp);
            System.debug('Error::'+ex.getMessage());
            System.debug('Error::'+ex.getStackTraceString());
            return false;
        }
        return true;
    }
}