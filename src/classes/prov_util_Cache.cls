/**********************************************************************************************************************
Name                        :   prov_util_Cache
Purpose                     :   The class that stores the fetches and sets values in the session cache
Created on                  :   1/01/2018
Developed by                :   Todd Tompkins
History
Version#    Sprint#     Date            by                   Comments
1.1         1.0         01/01/2018      Todd Tompkins       

**********************************************************************************************************************/

/* Description  **********************************************************


The actual class stored in the session cache is an instantiation of the prov_util_CacheObject class. However, we do
not intend consuming components or classes to interact directly with the cacheObject, but rather through this cache class.


**************************************************************************/
global without sharing class prov_util_Cache {
    
    /* session cache properties **********************************************************/
    global static   prov_util_CacheObject                                           cobj                                    {
        get{    
            prov_util_CacheObject tobj = (prov_util_CacheObject)Cache.Session.get('ProviderCache');
            if(tobj!=null){
                return tobj;
            } else {
                prov_util_Cache.getCacheData();
                tobj = (prov_util_CacheObject)Cache.Session.get('ProviderCache');
                if(tobj!=null && tobj.cacheFetched!=null && tobj.cacheFetched!=false){
                    return tobj;
                } else {
                    return new prov_util_CacheObject();
                }
            }
        }
    }
    
    @AuraEnabled
    global static String retrieveSessionIdApex() {
        return UserInfo.getSessionId();
    }
    
    @AuraEnabled
    global static boolean                                                           getIsAvailable(){
        return IsAvailable;    
    }
    global static boolean                                                           IsAvailable                             {
        get{
            //|| (userRec==null || userrec.Id != userInfo.getuserID())
            if(cobj.cacheFetched==null || cobj.cacheFetched==false )
                prov_util_Cache.getCacheData();
            return cobj.IsAvailable;
        }
    }
    @AuraEnabled
    global static boolean                                                           getCacheFetched(){
        return cacheFetched;
    }
    
    
    global static boolean                                                           cacheFetched                            {
        get{
            if(cobj.cacheFetched==null || cobj.cacheFetched==false)
                prov_util_Cache.getCacheData();
            return cobj.cacheFetched;
        }
    }
    
    global static Set<String>                                                           VisibleLOB                          {
        get{
            if(cobj.cacheFetched==null || cobj.cacheFetched==false)
                prov_util_Cache.getCacheData();
            return cobj.VisibleLOB;
        }
    }

    
 /* session cache properties **********************************************************/
  
 /* Running Contact-User Properties **********************************************************/    
    //get the Current running user contact rec if avaialable
    @AuraEnabled
    global static   Contact                                                         getContactRec()                         {
        return ContactRec;
    }
    global static   Contact                                                         ContactRec                              {
        get{
            if(!cobj.cacheFetched){
                prov_util_Cache.getCacheData();
            }
            return cobj.ContactRec;
        }
    }
    
    //get the current running user info                 
    @AuraEnabled
    global static   User                                                            getUserRec()                            {
        return UserRec;
    }
    global static   User                                                            UserRec                                 {
        get{
            if(UserRec == null){
                prov_util_Cache.getCacheData();
            }
            return cobj.UserRec;
        }
    }
    global static boolean                                                           isRunning                               {get;set;}
/* Running Contact-User Properties **********************************************************/  

/* Portal Configuration properties  **********************************************************/    
    
    //ConfigurationName represents the DevelopName of the Portal_Configuration__mdx record, identifies the configuration 
    //associated to the current running user
    @AuraEnabled
    global static   String                                                          getConfigurationName()                  {
        return ConfigurationName;
    }
    global static   String                                                          ConfigurationName                       {
        get{
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return cobj.ConfigurationName;
        }
    }
     @AuraEnabled
    global static   String                                                          getDefaultConfigurationName()                   {
        return DefaultConfigurationName;
    }
    global static   String                                                          DefaultConfigurationName                        {
        get{
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return cobj.DefaultConfigurationName;
        }
    }
    
    //Portal Configuration
    @AuraEnabled
    global static   Provider_Portal_Configuration__mdt                                      getPortalConfiguration()                {
        return PortalConfiguration;
    }
    global static   Provider_Portal_Configuration__mdt                                      PortalConfiguration                     {
        get{ 
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return (Provider_Portal_Configuration__mdt) prov_util_DAL.dalQuery('Provider_Portal_Configuration__mdt', 'WHERE DeveloperName = \'' + ConfigurationName + '\'')[0];
        }
    }
    @AuraEnabled
    global static   Provider_Portal_Configuration__mdt                                      getDefaultPortalConfiguration()             {
        return DefaultPortalConfiguration;
    }
    global static   Provider_Portal_Configuration__mdt                                      DefaultPortalConfiguration                      {
        get{ 
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return (Provider_Portal_Configuration__mdt) prov_util_DAL.dalQuery('Provider_Portal_Configuration__mdt', 'WHERE DeveloperName = \'' + DefaultConfigurationName + '\'')[0];
        }
    }
    
    //Portal Configuration
    @AuraEnabled    
    global static   List<Portal_Configuration_Links__mdt>                           getFooterLinks()                        {
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            List<Portal_Configuration_Links__mdt> result = new List<Portal_Configuration_Links__mdt>();
            for(Portal_Configuration_Links__mdt link :  PortalLinks){
                if(link.location__c.tolowerCase()=='footer'){
                    result.add(link);
                }
            }
            return result;
    }
    
    //Portal Configuration
    @AuraEnabled
    global static   List<Portal_Configuration_Links__mdt>                           getPortalLinks()                        {
        return PortalLinks;
    }
    global static   List<Portal_Configuration_Links__mdt>                           PortalLinks                             {
        get{
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return  (List<Portal_Configuration_Links__mdt>)prov_util_DAL.dalQuery('Portal_Configuration_Links__mdt',
                        'WHERE Provider_Portal_Configuration__r.DeveloperName = \'' + ConfigurationName + '\' Order by Display_Order__c ASC');
        }
    } 
    /*
    //Plan Configurations
    @AuraEnabled
    global static   Map<String,Plan_Configuration__mdt>                                     getPlanConfigurations()             {
        return PlanConfigurations;
    }
    global static   Map<String,Plan_Configuration__mdt>                                     PlanConfigurations                      {
        get{
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return cobj.PlanConfigurations;
        }
    }*/

/* Portal Configuration properties  **********************************************************/  

/* Business Verification Properties **********************************************************/
    /*
    //Map of SFID and Business_Verification__c records aassociated to the logged in portal user. Null for Internal Users
    global static   Map<Id,Business_Verification__c>                                VerifiedBusinessMap                         {
        get{
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return cobj.VerifiedBusinesses;
        }
    }*/
    
/* Business Verification Properties **********************************************************/

    @AuraEnabled
    global static String                                                                getCurrentBusinessId(){
        return CurrentBusinessId;
    } 
    
    @AuraEnabled
    global static String                                                                CurrentBusinessId{
        get{
            if(!cobj.cacheFetched){
                prov_util_Cache.getCacheData();
            }
            return cobj.CurrentBusinessId;
        } 
    set; }
    @AuraEnabled
    global static String                                                                getDefaultBusinessId(){
        return DefaultBusinessId;
    } 
    
    @AuraEnabled
    global static String                                                                DefaultBusinessId{
        get{
            if(!cobj.cacheFetched){
                prov_util_Cache.getCacheData();
            }
            return cobj.DefaultBusinessId;
        } 
    set; }
    @AuraEnabled
    global static void                                                              setCurrentBusinessId(String newId){
        newId = newId.substring(0,15);
        System.debug('setCurrentBusinessId::'+newId);
        
        cobj.CurrentBusinessId = newId;
        cobj.WriteToCache();
        cobj.Permissions = cobj.businessId2PermissionsMap.get(newId);
        cobj.WriteToCache();
    }
    
    @AuraEnabled
    global static Account                                                               CurrentBusiness{
        get{
            if(!cobj.cacheFetched){
                prov_util_Cache.getCacheData();
            }
            if(cobj.CurrentBusinessId == null) return new Account();
            Set<String> businessIds = new Set<String>{cobj.CurrentBusinessId};
            return prov_util_DAL.getAccountsById(businessIds)[0];
        }
    set; }
    
    @AuraEnabled
    global static Account                                                               DefaultBusiness{
        get{
            if(!cobj.cacheFetched){
                prov_util_Cache.getCacheData();
            }
            if(cobj.DefaultBusinessId == null) return new Account();
            Set<String> businessIds = new Set<String>{cobj.DefaultBusinessId};
            return prov_util_DAL.getAccountsById(businessIds)[0];
        }
    set; }
    
    @AuraEnabled
    public static prov_util_Permissions                                                             getPermissionObj(String businessId){
        if(!cobj.cacheFetched){
            prov_util_Cache.getCacheData();
        }
        businessId = businessId.substring(0,15);
        return cobj.businessId2PermissionsMap.get(businessId);
        
    }
    /*@AuraEnabled
    global static String                                                                CurrentServiceLocationId{
        get{
            if(!cobj.cacheFetched){
                prov_util_Cache.getCacheData();
            }
            return cobj.CurrentServiceLocationId;
        }
    set; }
    
    @AuraEnabled
    global static Account                                                               CurrentServiceLocation{
        get{
            if(!cobj.cacheFetched){
                prov_util_Cache.getCacheData();
            }
            return cobj.ServiceLocations.get(cobj.CurrentServiceLocationId);
        }
    set; }
    
    @AuraEnabled
    global static String                                                                CurrentProviderId{
        get{
            if(!cobj.cacheFetched){
                prov_util_Cache.getCacheData();
            }
            return cobj.CurrentProviderId;
        }
    set; }
    
    @AuraEnabled
    global static Account                                                                   CurrentProvider{
        get{
            if(!cobj.cacheFetched){
                prov_util_Cache.getCacheData();
            }
            return cobj.Providers.get(cobj.CurrentProviderId);
        }
    set; }
    */
    global static Map<Id, List<String>>                                                      BusinessIdToLocationIds {
        get{
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return cobj.BusinessIdToLocationIds;
        }set;
    }
    global static List<String>                                                              retrieveServiceLocationIdsByBusinessId(String businessId){
        //check to see if business id is in set. if yes return the related list if not return blank lisr
        if(BusinessIdToLocationIds.containsKey(businessId)){
            return BusinessIdToLocationIds.get(businessId);
        }   else {
            return new List<String>();
        }
    } 
    
    global static Map<String, List<Id>>                                                         BusinessIdToProviderIds {
        get{
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return cobj.BusinessIdToProviderIds;
        }set;
    }
    global static List<String>                                                              retrieveProviderIdsByBusinessId(String businessId){
        //check to see if business id is in set. if yes return the related list if not return blank lisr
        if(BusinessIdToProviderIds.containsKey(businessId)){
            return BusinessIdToProviderIds.get(businessId);
        }   else {
            return new List<String>();
        }
    }
    
    global static List<String>                                                                  retrieveNetworkIds(id businessId){
        Set<String> networkIds = cobj.BusinessIdToNetworkIds.get(businessId);
        return new List<String>(networkIds);
    }
    global static List<Networks__c>                                                             retrieveNetworks(id businessId){
        Set<String> networkIds = cobj.BusinessIdToNetworkIds.get(businessId);
        return (List<Networks__c>)prov_util_DAL.dalQuery('Networks__c',
                                    'WHERE Id IN (\'' + String.join(new List<String>(networkIds), '\',\'') + '\')');
    }
      @AuraEnabled
    global static List<Account>                                                         retrieveProviders(String businessId, Date serviceDate){
        List<Account> providerList;
        Set<String> serviceLocationIds= new Set<String>();
        
        for(Id slId : BusinessIdToLocationIds.get(businessId)){
                serviceLocationIds.add(slId);
        }
    
        Set<String> providerIds= new Set<String>();
        Set<String> providerIds2= new Set<String>();
        
        for(Id provId : BusinessIdToProviderIds.get(businessId.substring(0,15))){
            providerIds.add(provId);
        }
        
        for(Providers_Service_Locations__c psl : prov_util_DAL.retrievePSL_WDate(providerIds, serviceLocationIds, new Set<String>{businessId}, serviceDate )){
            providerIds2.add(psl.Provider__c);
        }
        
        providerList = prov_util_DAL.getAccountsById(providerIds2);
        return providerList;
    }
      @AuraEnabled
    global static List<Account>                                                         retrieveProviders(String businessId){
        List<Account> providerList = new List<Account>();
        Set<String> providerIds= new Set<String>();
        
        for(Id provId : BusinessIdToProviderIds.get(businessId.substring(0,15))){
            providerIds.add(provId);
        }
        providerList = prov_util_DAL.getAccountsById(providerIds);
        return providerList;
    } 
    
    global static Map<Id, Map<Id, List<String>>>                                            BusinessId2Location2ProvidersMap {
        get{
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return cobj.BusinessId2Location2ProvidersMap;
        }set;
    }

    global static Map<Id, Map<Id, List<String>>>                                            BusinessId2Provider2LocationMap {
        get{
            if(!cobj.cacheFetched)
                prov_util_Cache.getCacheData();
            return cobj.BusinessId2Provider2LocationMap;
        }set;
    }
    
    @AuraEnabled
    global static List<Account>                                                             retrieveServiceLocation(String businessId, Date serviceDate){
        List<Account> serviceLocationList;
        Set<String> serviceLocationIds= new Set<String>();
        Set<String> serviceLocationIds2= new Set<String>();
        
        for(Id slId : BusinessIdToLocationIds.get(businessId)){
                serviceLocationIds.add(slId);
        }
    
        Set<String> providerIds= new Set<String>();
        
        for(Id provId : BusinessIdToProviderIds.get(businessId.substring(0,15))){
            providerIds.add(provId);
        }
        
        for(Providers_Service_Locations__c psl : prov_util_DAL.retrievePSL_WDate(providerIds, serviceLocationIds, new Set<String>{businessId}, serviceDate )){
            serviceLocationIds2.add(psl.Service_Location__c);
        }
        
        serviceLocationList = prov_util_DAL.getAccountsById(serviceLocationIds2);
        return serviceLocationList;
    }
    @AuraEnabled
    global static List<Account>                                                             retrieveServiceLocation(Id businessId){
        List<Account> serviceLocationList;
        Set<String> serviceLocationIds= new Set<String>();
        
        for(Id slId : BusinessIdToLocationIds.get(businessId)){
            if(!serviceLocationIds.contains(slId)){
                serviceLocationIds.add(slId);
            }
        }
        
        
        serviceLocationList = prov_util_DAL.getAccountsById(serviceLocationIds);
        return serviceLocationList;
    }
    
    @AuraEnabled
    global static List<String>                                                              retrieveActiveServiceLocationIds(Id businessId){
        Set<String> serviceLocationIds= new Set<String>();
        
        for(String slId : cobj.BusId2ActiveLocationMap.get(businessId)){
            serviceLocationIds.add(slId);
        }
        
        
        return new List<String>(serviceLocationIds);
    }
    
    @AuraEnabled
    global static List<Account>                                                         retrieveBusinesses(){ 
        
        return prov_util_DAL.getAccountsById( new Set<String>(cobj.BusinessIdToProviderIds.keyset() ) );
    }
    
    @AuraEnabled
    global static List<Account>                                                         retrieveProviders(Id businessId, Id serviceLocationId){
        List<Account> providerList = new List<Account>();
        Set<String> providerIds= new Set<String>();
        for(Id provId : BusinessId2Location2ProvidersMap.get(businessId).get(serviceLocationId)){
            providerIds.add(provId);
        }
        providerList = prov_util_DAL.getAccountsById(providerIds);
        return providerList;
    }
    
    @AuraEnabled
    global static List<Account>                                                         retrieveProviders(String businessId, Id serviceLocationId, Date serviceDate){
        List<Account> providerList = new List<Account>();
        Set<String> providerIds= new Set<String>();
        
        Set<String> providerIds2= new Set<String>();
        
        for(Id provId : BusinessIdToProviderIds.get(businessId.substring(0,15))){
            providerIds.add(provId);
        }
        
        for(Providers_Service_Locations__c psl : prov_util_DAL.retrievePSL_WDate(providerIds, new Set<String>{serviceLocationId}, new Set<String>{businessId}, serviceDate )){
            providerIds2.add(psl.Provider__c);
        }
        
        providerList = prov_util_DAL.getAccountsById(providerIds2);
        //for(Id provId : BusinessId2Location2ProvidersMap.get(businessId).get(serviceLocationId)){
        //  providerIds.add(provId);
        //}
        //providerList = prov_util_DAL.getAccountsById(providerIds);
        return providerList;
    }
    global static Set<String>                                                           VisiblePlanWWIdSet{get{
        if(!cobj.cacheFetched)
            prov_util_Cache.getCacheData();
        return cobj.BusinessId2PlanWWIdsMap.get(cobj.CurrentBusinessId);
    }set;}
    
    global static Set<String>                                                           getVisibilePlanWWIds(String businessId){
        if(!cobj.cacheFetched)
            prov_util_Cache.getCacheData();
        return cobj.BusinessId2PlanWWIdsMap.get(businessId);
    }
    
    //get visible plans based on business, sl and provider
    @AuraEnabled
    public static List<String>                                                          getPlanGuidsBasedOnBusProvSL(String businessId, String providerId, String serviceLocationId){
        if(!cobj.cacheFetched)
            prov_util_Cache.getCacheData();
        
        return prov_util_Cache.getPlanGuidsBasedOnBusProvSL(businessId, providerId, serviceLocationId, Date.today());
    }
/*
    public static List<String>                                                          getPlanGuidsBasedOnBusProvSL2(String businessId, String providerId, String serviceLocationId, Date serviceDate){
        Set<String> planGuidSet = new Set<String>();

        Set<String> pslIds = new Set<String>();
        List<String> networkIds = new List<String>();
        //get the PSL active during that date
        for(Providers_Service_Locations__c psl :  prov_util_DAL.retrievePSL_WDate( new Set<String>{providerId}, 
                                                                                    new Set<String>{serviceLocationId}, 
                                                                                    new Set<String>{businessId}, 
                                                                                    serviceDate )){ 
            //System.debug('psln:name::'+psl.Name);
            //set the variables that need to be stored
            pslIds.add(psl.Id);
        }
        System.debug('pslSize::'+pslIds.size() +'.  pslIds::'+pslIds);

        if(pslIds.size() > 0){
            for(Providers_Service_Locations_Networks__c psln :  prov_util_DAL.retrievePSLN_WDate(pslIds, serviceDate) ){
                networkIds.add(psln.Network__c);
            }
            System.debug('networkIds::'+networkIds);
            for(Plans_Networks__c pn :  [SELECT id, Plan__c, Plan__r.guid__c
                                            FROM Plans_Networks__c 
                                            WHERE Network__c IN :networkIds ]){
                planGuidSet.add(pn.Plan__r.guid__c.toLowercase());
            } 
        }
        System.debug('planGuidSet::'+planGuidSet);
        return new List<String> (planGuidSet);

    }*/
    public static List<String>                                                          getPlanGuidsBasedOnBusProvSL(String businessId, String providerId, String serviceLocationId, Date serviceDate){
        Set<String> planGuidSet = new Set<String>();

        Set<String> pslIds = new Set<String>();
        List<String> networkIds = new List<String>();
         Set<String> providerSet = new Set<String>();
        Set<String> locationSet = new Set<String>();
        
        //add the item into the set if not blank
        if(providerId != null && providerId != '')
            providerSet.add(providerId);
        if(serviceLocationId != null && serviceLocationId != '')
            locationSet.add(serviceLocationId);
            
        //get the PSL active during that date
        for(Providers_Service_Locations__c psl :  prov_util_DAL.retrievePSL_WDate( providerSet, 
                                                                                    locationSet, 
                                                                                    new Set<String>{businessId}, 
                                                                                    serviceDate )){ 
            //System.debug('psln:name::'+psl.Name);
            //set the variables that need to be stored
            pslIds.add(psl.Id);
        }
        System.debug('pslSize::'+pslIds.size() +'.  pslIds::'+pslIds);

        if(pslIds.size() > 0){
            for(AggregateResult agg:  prov_util_DAL.retrievePSLN_PSL(pslIds, serviceDate) ){
                networkIds.add((String) agg.get('Network__c'));
            }
            System.debug('networkIds::'+networkIds);
            for(Plans_Networks__c pn :  [SELECT id, Plan__c, Plan__r.guid__c
                                            FROM Plans_Networks__c 
                                            WHERE Network__c IN :networkIds ]){
                planGuidSet.add(pn.Plan__r.guid__c.toLowercase());
            } 
        }
        System.debug('planGuidSet::'+planGuidSet);
        return new List<String> (planGuidSet);

    }
/* Business Verification Properties **********************************************************/
/* Permission Properties **********************************************************/
    
    //Permissions
    
    @AuraEnabled
    public static prov_util_Permissions                                                 getCurrentPermissions(){
        if(!cobj.cacheFetched)
            prov_util_Cache.getCacheData();
        return cobj.Permissions;
    }
/* Permission Properties **********************************************************/

/* GET  Cache DataProperties **********************************************************/
  
    @AuraEnabled
   global static prov_util_Cache.LocalCacheWrapper getCacheData(){
        System.debug('START getCacheData2...');
        isRunning=true;
        
        LocalCacheWrapper clientCacheWrapper = new LocalCacheWrapper();
        
        prov_util_CacheObject tobj = new prov_util_CacheObject();
        tobj.cacheFetched = true;
        tobj.CurrentBusinessId = null;
        tobj.IsAvailable = false;
        //get the running user
        tobj.UserRec = (User)prov_util_DAL.dalQueryById('User',UserInfo.getUserId());
        system.debug('RunningUser: ' + tobj.UserRec);
        System.debug('1a:Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        //get the associated contact
        if(tobj.userRec.contactId!=null){
            tobj.ContactRec = (Contact)prov_util_DAL.dalQueryById('Contact', tobj.userRec.contactId);
        } else if(tobj.userRec.contactId==null && tobj.ContactToReview!=null){
            tobj.ContactRec = (Contact)prov_util_DAL.dalQueryById('Contact', tobj.ContactToReview);
        } else if(tobj.userRec.contactId==null && tobj.ContactToReview==null){
            //this is an internal user working without a reference
            try{
                System.debug('1b:Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
                prov_util_MockDataGen.genBaseData();
                List<Contact> cons = prov_util_DAL.dalQuery('Contact','WHERE FirstName = \'Daily\' AND LastName = \'DAdmin\' AND Email = \'iluvcapes@test.com\' ');
                tobj.ContactRec = cons[0];
            } catch(exception ex){
                system.debug('----------------------------------------------------------');
                system.debug('this is an internal user working without a contact reference');
                system.debug(ex.getMessage());
                system.debug(ex.getStackTraceString());
                system.debug('----------------------------------------------------------');
            }
        }
        clientCacheWrapper.currentContact = tobj.ContactRec;
        Map<String, String> businessId2TierAccessMap = new Map<String, String>();
        system.debug('cont: ' + tobj.ContactRec);
        //get ConfigurationName
        try{ 
            //initialize variables             
            List<Account> businessList = new List<Account>();
            List<String> businessGuids = new List<String>();
            Set<String> providerIds = new Set<String>();
            Map<String, List<String>> businessId2PermissionMap = new Map<String, List<String>>();
            Set<String> serviceLocationIds = new Set<String>(); 
            if(tobj.contactRec==null){
                //internal user 
                //tobj.BusinessIdToBusinessVerification = null; 
            } else {
                String fullPermissions = tobj.ContactRec.Provider_Portal_Permissions__c; 
                System.debug('fullPermissions::'+fullPermissions);
                for(String businessArray : fullPermissions.split('\\|')){
                    System.debug('businessArray::'+businessArray);
                    //each item is the business and the service lcoations and providers they can see with the permissions
                    String[] fullArray = businessArray.split(':');
                    businessGuids.add(fullArray[0]);
                    String businessWW = fullArray[0].toLowerCase();
                    businessId2PermissionMap.put(businessWW, new List<String>());
                    businessId2TierAccessMap.put(businessWW, '1');
                    
                    if(fullArray.size() > 1){
                        //service location guids
                        System.debug('about to do SL::'+fullArray);
                        fullArray = fullArray[1].split(';');//0= all service locations; 1 = rest of string (providers and permissions)
                        for(String sl : fullArray[0].split('~')){
                            if(sl != 'ALL' && sl != null){
                                serviceLocationIds.add(sl);
                                businessId2TierAccessMap.put(businessWW, '2');
                            } 
                        }
                        System.debug('about to do provider::'+fullArray);
                        fullArray = fullArray[1].split('\\$');//0= all providers; 1 = rest of string (permissions)
                        for(String provGuid : fullArray[0].split('~')){
                            if(provGuid != 'ALL' && provGuid != null){
                                providerIds.add(provGuid);
                                businessId2TierAccessMap.put(businessWW, '3');
                            }
                        }
                        System.debug('about to do permissions::'+fullArray);
                        //permissions
                        if(fullArray.size() > 1){
                            if(fullArray[1] == 'ALL'){
                                 businessId2PermissionMap.get(businessWW).add('ALL');
                            } else{
                                System.debug('about split permissions::'+fullArray[1]);
                                fullArray = fullArray[1].split('\\.');
                                System.debug('about to loop permissions::'+fullArray);
                                for(String permission : fullArray){
                                    businessId2PermissionMap.get(businessWW).add(permission);
                                }
                            }
                        } else {
                            businessId2PermissionMap.get(businessWW).add('None');
                        }
                    } else {
                        businessId2TierAccessMap.put(businessWW, '1');
                    }
                } 
                System.debug('after loop::'+businessId2PermissionMap);
                System.debug('1:Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
                //calculate the business permissions
                prov_handler_ProviderPermissions.checkBusinessPermissionExistence (businessGuids);
                System.debug('2:Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
                //query for the business
                businessList = [SELECT id, Name, Route_id__c, guid__c, Tax_id_number__c, Phone, tax_id_type__c, npi__c,
                                    (SELECT Business__c, Enable_Billed_Amount__c, Enable_EFT__c, Enable_EOB__c, Enable_FAD__c, Enable_Member_Eligibility__c, 
                                    Enable_Practice_Management__c, Enable_FAD_OON__c, Enable_Fee_Schedule__c, Enable_Member_Intervention__c, Enable_Payment__c,
                                    Enable_Panel_Roster__c, Enable_Referrals__c, Enable_Reports__c, Id, Enable_Broken_Appointment__c, Enable_Claim_PreAuth__c
                                    FROM Provider_Business_Permissions__r) 
                                FROM Account WHERE guid__c in:businessGuids];
                System.debug('businessList::'+businessList);                         
                                         
                
            }
            //loop through businesses and pull the LOBs and map the business
            //map business id to the permissions
            Set<String> tempLob = new Set<String>();
            for(Account business : businessList){
                //businessId2PermissionMap.put(String.valueOf(business.Id).substring(0,15), tempBusinessId2PermissionMap.get(business.guid__c.toLowerCase()));
                clientCacheWrapper.businessMap.put(String.valueOf(business.Id).substring(0,15), business);
                tempLob.add(business.route_id__c );
            }
            Map<String, Provider_Portal_Configuration__mdt> lob2Config = new Map<String, Provider_Portal_Configuration__mdt>();
            Provider_Portal_Configuration__mdt PortalConfigurationTemp = new Provider_Portal_Configuration__mdt();                                                                                               
            //get portal configuration
            for(Provider_Portal_Configuration__mdt config : (List<Provider_Portal_Configuration__mdt>) prov_util_DAL.dalQuery('Provider_Portal_Configuration__mdt',
                   'WHERE RouteId__c IN (\'' + String.join(new List<String>(tempLob), '\',\'') + '\')')){//DeveloperName = \'' + tobj.ConfigurationName + '\' OR 
                clientCacheWrapper.portalConfigs.put(config.DeveloperName, config);
                clientCacheWrapper.lob2PortalName.put(config.RouteID__c.toLowercase(), config.DeveloperName);
                lob2Config.put(config.RouteId__c.toLowerCase(), config);
                if(tobj.ContactRec != null){
                    if(tObj.ContactRec.Portal_Name__c == config.DeveloperName || tobj.DefaultConfigurationName == null){
                        clientCacheWrapper.currentPortalConfig = config.DeveloperName;
                        tobj.ConfigurationName = config.DeveloperName;
                        tobj.DefaultConfigurationName = config.DeveloperName;
                        PortalConfigurationTemp = config;
                    }
                } else if(tobj.DefaultConfigurationName == null){
                    clientCacheWrapper.currentPortalConfig = config.DeveloperName;
                    tobj.ConfigurationName = config.DeveloperName;
                    tobj.DefaultConfigurationName = config.DeveloperName;
                    PortalConfigurationTemp = config;
                }
            }
            system.debug('config name: ' + tobj.ConfigurationName);
            
            //initialize the maps for the cache object
            tobj.businessId2PlanWWIdsMap = new Map<String, Set<String>>();
            tobj.BusinessIdToProviderIds = new Map<String, List<Id>>();
            tobj.BusinessIdToLocationIds = new Map<Id, List<Id>>();
            tobj.BusinessIdToNetworkIds = new Map<Id, Set<String>>();
            tobj.BusinessId2Location2ProvidersMap = new Map<id, Map<Id, List<ID>>>();
            tobj.BusinessId2Provider2LocationMap = new Map<id, Map<Id, List<ID>>>();
            tobj.activeBusinessId2Location2ProvidersMap = new Map<id, Map<Id, set<string>>>();
            tobj.BusId2ActiveLocationMap = new Map<Id, Set<string>>();
            clientCacheWrapper.activeBusinessId2Location2ProvidersMap = new Map<id, Map<Id, set<string>>>();
            
            //map business id to the permissions instead of WW Guid to permissions
            Map<String, List<String>> tempBusinessId2PermissionMap = businessId2PermissionMap;
            Map<String, Provider_Business_Permission__c> busId2PermissionObjMap = new Map<String, Provider_Business_Permission__c>();
            businessId2PermissionMap = new Map<String, List<String>>();
            System.debug('tempBusinessId2PermissionMap::'+tempBusinessId2PermissionMap);
            System.debug('businessId2PermissionMap:before::'+businessId2PermissionMap);
            //initialize variables
            Map<String, String> pslId2BusinessIdMap = new Map<String, String>();
            Map<String, Account> busId2BusinessMap = new Map<String, Account>();
            Set<String> businessIds = new Set<String>();
            Map<String, List<Account>> tin2BusinessMap = new Map<String, List<Account>>();
            
            //loop through the businesses
            for(Account business : businessList){
                //set the id to be the 15 digit id
                String busId = String.valueOf(business.Id).substring(0,15);

                System.debug('businessPermission::'+ business.Provider_Business_Permissions__r);
                //get the permission object for that business
                Provider_Business_Permission__c busPermission = null;

                if(business.Provider_Business_Permissions__r != null && business.Provider_Business_Permissions__r.size() > 0){
                    busPermission = business.Provider_Business_Permissions__r[0];
                }
                busId2PermissionObjMap.put(busId, busPermission);
                businessIds.add(busId);
                busId2BusinessMap.put(busId, business);
                tobj.BusinessIdToProviderIds.put(busId, new List<Id>());
                tobj.BusinessIdToNetworkIds.put(busId, new Set<String>());
                tobj.BusinessIdToLocationIds.put(busId, new List<Id>());
                tobj.BusinessId2Location2ProvidersMap.put(busId, new Map<Id, List<Id>>()  );
                tobj.BusinessId2Provider2LocationMap.put(busId, new Map<Id, List<Id>>()  );
                tobj.BusId2ActiveLocationMap.put(busId, new Set<String>()  );
                tobj.activeBusinessId2Location2ProvidersMap.put(busId, new Map<Id, set<string>>()  );
                clientCacheWrapper.activeBusinessId2Location2ProvidersMap.put(busId, new Map<Id, set<string>>()  );
                tobj.businessId2PlanWWIdsMap.put(busId, new Set<String>());
                    
                businessId2PermissionMap.put(busId, tempBusinessId2PermissionMap.get(business.guid__c.toLowerCase()));
                
                if(tin2BusinessMap.containsKey(business.Tax_Id_Number__c)){
                    tin2BusinessMap.get(business.Tax_ID_Number__c).add(business);
                } else {
                    tin2BusinessMap.put(business.Tax_ID_Number__c, new List<Account>{business});
                }
                
                if(tobj.CurrentBusinessId == null){
                    tobj.CurrentBusinessId = busId;
                    clientCacheWrapper.currentBusId = busId;
                    tobj.DefaultBusinessId = busId;
                }
            }   
            System.debug('businessId2PermissionMap:after::'+businessId2PermissionMap);
            
             //get visible lines of business
            tobj.VisibleLOB = new Set<String>();
            if(tobj.UserRec.Visible_Lines_of_Business__c!=null && tobj.UserRec.Visible_Lines_of_Business__c.trim()!=''){
                system.debug('user set visibleLOB');
                List<RouteIDMap__mdt> routeIds = [SELECT Label, RouteID__c FROM RouteIDMap__mdt];
                Set<String> LOBs = new Set<String>();
                for(String s : tobj.UserRec.Visible_Lines_of_Business__c.toLowerCase().split(';')){
                    LOBs.add(s);
                }
                for(RouteIDMap__mdt route : routeIds){
                    if(LOBs.contains(route.Label.toLowerCase())){
                        tobj.VisibleLOB.add(route.RouteID__c);
                    }
                }
            } else {
                system.debug('portal set visibleLOB');
                if(PortalConfigurationTemp!=null && PortalConfigurationTemp.RouteID__c!=null)
                    //allow the RouteId field on the metadata to specify a number of routeIds
                    if(PortalConfigurationTemp.RouteID__c.contains(';')){
                        for(String s : PortalConfigurationTemp.RouteID__c.split(';')){
                            tobj.VisibleLOB.add(s);
                        }
                    } else {
                        tobj.VisibleLOB.add(PortalConfigurationTemp.RouteID__c);
                    }
            }
            system.debug('vl ' + tobj.VisibleLOB);
            tobj.writeToCache();
            
            integer ed = integer.valueOf(PortalConfigurationTemp.EffectiveDateAdj__c);
            integer td = integer.valueOf(PortalConfigurationTemp.TerminationDateAdj__c)*-1;
            if(ed==null)
                ed=0;
            if(td==null) 
                td=0;
            Date lkEff = Date.today().addDays(ed);
            Date lkTerm = Date.today().addDays(td);
            
            //query for the psls part of that business 
            Set<id> accIds = new Set<id>();
            //map of psl id to record
            Map<Id, Providers_Service_Locations__c> PSLMap = new Map<Id, Providers_Service_Locations__c>();
            //map business id to the psls 
            Map<String, Set<String>> networkIds2PSLIdMap = new Map<String, Set<String>>();
            //Map<String, Set<String> > busId2ProductIdsMap = new Map<String, Set<String>>();
            System.debug('3:Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
            /*
            if(pslId2BusinessIdMap.keyset().size() == 0)return clientCacheWrapper;
            */
             
            Set<Id> networkIds = new Set<id>();
            Set<Id> allLocationIds = new Set<id>();
            Set<Id> allProviderIds = new Set<id>();
            
            
            //Set<Id> activeProviderIds = new Set<id>();
            Map<String, List<String>> networkId2BusinessIdMap = new Map<String, List<String>>();
            //query for the pslns that the psls are part of the business/ location / providers
            for(AggregateResult agg : prov_util_DAL.retrievePSLN_Cache2(providerIds, serviceLocationIds, businessIds, false )){//last attribute gets psln that have termed a year back and currently active
                //get the grouped by variables
                if(agg.get('Business__c') == null || agg.get('Business__c') == '') continue;
                String busId = String.valueOf(agg.get('Business__c')).substring(0,15);
                String networkId = (String)agg.get('Network__c');
                
                //add the network id to the map of business to networks
                tobj.BusinessIdToNetworkIds.get(busId).add(networkId);

                //map the business to the network
                if(networkId2BusinessIdMap.containsKey(networkId)){
                    networkId2BusinessIdMap.get(networkId).add(busId); 
                }else {
                    networkId2BusinessIdMap.put(networkId,  new List<String>{busId});
                }
                
                //add network to list to later be user to query
                networkIds.add(networkId);
            }
            System.debug('networkId2BusinessIdMap::'+networkId2BusinessIdMap);
            Set<Id> tempProviderIds = new Set<Id>();
            Set<Id> tempLocationIds = new Set<Id>();
            List<Id> tempIdList = new List<Id>();
            //query for the psl to populate some of the mappings
            for(Providers_Service_Locations__c psl :  prov_util_DAL.retrievePSL_Cache(providerIds, serviceLocationIds, businessIds )){ 
                //set the variables that need to be stored
                String busId = String.valueOf(psl.Business__c).substring(0,15);
                allLocationIds.add(psl.Service_Location__c);             
                allProviderIds.add(psl.Provider__c);
                
                tempProviderIds = new Set<Id>( tobj.BusinessIdToProviderIds.get(busId) );
                if(!tempProviderIds.contains(psl.Provider__c)){
                    tempProviderIds.add(psl.Provider__c);
                    tempIdList = tobj.BusinessIdToProviderIds.get(busId);
                    tempIdList.add(psl.Provider__c);
                    tobj.BusinessIdToProviderIds.put(busId, tempIdList );
                }
                //System.debug('tempProviderIds::'+tempProviderIds);
                //System.debug('tempProviderIdsInMap::'+tobj.BusinessIdToProviderIds.get(String.valueOf(psl.business__c).substring(0,15)));
                
                //put the location under the business
                tempLocationIds = new Set<Id>( tobj.BusinessIdToLocationIds.get(busId) );
                if(!tempLocationIds.contains(psl.Service_Location__c)){
                    tempLocationIds.add(psl.Service_Location__c);
                    tempIdList = tobj.BusinessIdToLocationIds.get(busId);
                    tempIdList.add(psl.Service_Location__c);
                    tobj.BusinessIdToLocationIds.put(busId, tempIdList );
                }
                
                //map the business to location to provider             
                if(tobj.BusinessId2Location2ProvidersMap.get(busId).containsKey(psl.Service_Location__c)){
                    tempProviderIds = new Set<Id>( tobj.BusinessId2Location2ProvidersMap.get(busId).get(psl.Service_Location__c) );
                    if(!tempProviderIds.contains(psl.Provider__c)){
                        tempProviderIds.add(psl.Provider__c);
                        tempIdList = tobj.BusinessId2Location2ProvidersMap.get(busId).get(psl.Service_Location__c);
                        tempIdList.add(psl.Provider__c);
                        tobj.BusinessId2Location2ProvidersMap.get(busId).put(psl.Service_Location__c,  tempIdList );
                    } 
                }else {
                    tobj.BusinessId2Location2ProvidersMap.get(busId).put(psl.Service_Location__c, new List<Id>{psl.Provider__c});
                }
                
                //map the business to provider to location             
                if(tobj.BusinessId2Provider2LocationMap.get(busId).containsKey(psl.Provider__c)){
                    tempLocationIds = new Set<Id>( tobj.BusinessId2Provider2LocationMap.get(busId).get(psl.Provider__c) );
                    if(!tempLocationIds.contains(psl.Service_Location__c)){
                        tempLocationIds.add(psl.Service_Location__c);
                        tempIdList = tobj.BusinessId2Provider2LocationMap.get(busId).get(psl.Provider__c);
                        tempIdList.add(psl.Service_Location__c);
                        tobj.BusinessId2Provider2LocationMap.get(busId).put(psl.Provider__c, tempIdList);
                    } 
                }else {
                    tobj.BusinessId2Provider2LocationMap.get(busId).put(psl.Provider__c, new List<Id>{psl.Service_Location__c}); 
                }
                
                if(psl.Effective_Date__c <= system.today() && (psl.Termination_Date__c==null || psl.Termination_Date__c>system.today()) ){
                    //activeProviderIds.add(psl.Provider__c);
                    tobj.BusId2ActiveLocationMap.get(busId).add(psl.Service_Location__c);
                    if(tobj.activeBusinessId2Location2ProvidersMap.get(busId).containsKey(psl.Service_Location__c)){
                        clientCacheWrapper.activeBusinessId2Location2ProvidersMap.get(busId).get(psl.Service_Location__c).add(psl.Provider__c);
                        tobj.activeBusinessId2Location2ProvidersMap.get(busId).get(psl.Service_Location__c).add(psl.Provider__c);
                    } else{
                        clientCacheWrapper.activeBusinessId2Location2ProvidersMap.get(busId).put(psl.Service_Location__c, new Set<string>{psl.Provider__c});
                        tobj.activeBusinessId2Location2ProvidersMap.get(busId).put(psl.Service_Location__c, new Set<string>{psl.Provider__c});
                    }
                }
                
                
            }
            Map<String, Set<String>> planId2NetworksMap = new Map<String, Set<String>>();
            //get the plan networks
            for(Plans_Networks__c pn :  [SELECT id, Plan__c, Network__c, Plan__r.guid__c
                                        FROM Plans_Networks__c 
                                        WHERE Network__c IN :networkIds AND Plan__r.Route_Id__c IN:tobj.VisibleLOB]){
                if(planId2NetworksMap.containsKey(pn.Plan__c)){
                    planId2NetworksMap.get(pn.Plan__c).add(pn.Network__c); 
                }else {
                    planId2NetworksMap.put(pn.Plan__c,  new Set<String>{pn.Network__c});
                }
                
                for(String busId : networkId2BusinessIdMap.get(pn.Network__c)){
                    tobj.businessId2PlanWWIdsMap.get( busId ).add(pn.Plan__r.guid__c.toLowerCase());
                }
            }
            System.debug('tobj.businessId2PlanWWIdsMap::'+tobj.businessId2PlanWWIdsMap);
            tobj.writeToCache();
            
            //if(networkIds.size() == 0) return clientCacheWrapper;
            
            System.debug('4:Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
            //query for the plans
            //map the business to the plans 
           //tobj.BusIdProvIdSLId2PlanGuidMap = new Map<String, List<String>>(); 
          
            
            //retrieve the service locations and store them in the client cache wrapper
            for(Account loc : [SELECT id, Service_Location_Name__c, Name, guid__c, route_id__c, BillingStreet,
                                                                        BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingAddress
                                                                        FROM Account WHERE ID IN:allLocationIds] ){
                loc.Id = String.valueOf(loc.Id).substring(0,15);
                clientCacheWrapper.locationMap.put(String.valueOf(loc.Id).substring(0,15), loc);                                                                
            }
            
            //retrieve the providers and store them in the client cache wrapper
            for(Account prov : [SELECT id, Name, first_name__c, last_name__c, guid__c, route_id__c FROM Account WHERE ID IN:allProviderIds] ){
                prov.Id = String.valueOf(prov.Id).substring(0,15);
                clientCacheWrapper.providerMap.put(String.valueOf(prov.Id).substring(0,15), prov);
            }
            
            System.debug('5:Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
            // set the values for the local cahce wrapper stamping all the mapping
            clientCacheWrapper.cBusinessId2LocationIds = tobj.BusinessIdToLocationIds;
            clientCacheWrapper.cBusinessId2ProviderIds = tobj.BusinessIdToProviderIds;
            clientCacheWrapper.cBusinessId2Location2ProvidersMap = tobj.BusinessId2Location2ProvidersMap;
            clientCacheWrapper.cBusinessId2Provider2LocationMap = tobj.BusinessId2Provider2LocationMap ;
            //clientCacheWrapper.cActiveProviderIds = activeProviderIds;
            String businessId = String.valueOf(businessList[0].Id).substring(0,15);
            clientCacheWrapper.cActiveLocationIds = tobj.BusId2ActiveLocationMap.get(businessId);
                 
            System.debug('PortalConfigurationTemp::'+PortalConfigurationTemp);
            //get the current permissions for the current business id
            tobj.businessId2PermissionsMap = new Map<String, prov_util_Permissions>();
            String sofnsdins;
            //set permissions for each business
            for(String busId : tobj.businessId2PlanWWIdsMap.keyset()){ 
                System.debug('busId::'+busId);
                busId = busId.substring(0,15);
                Account tempBusiness = busId2BusinessMap.get(busId);
                System.debug(lob2Config.keyset());
                System.debug(tempBusiness.route_id__c.toLowercase());
                String tierAccess = businessId2TierAccessMap.get(tempBusiness.guid__c.toLowercase());
                //System.debug(busId2ProductIdsMap.keyset());
                prov_util_Permissions permission = new prov_util_Permissions(lob2Config.get(tempBusiness.route_id__c.toLowercase()),
                                                                businessId2PermissionMap.get(busId),
                                                                tempBusiness,
                                                                busId2PermissionObjMap.get(busId));
                permission.tierAccess = tierAccess;
                System.debug('permission::'+permission);  
                System.debug('tierAccess::'+permission.tierAccess);  
                tobj.businessId2PermissionsMap.put(busId, permission);
                clientCacheWrapper.permissionMap.put(busId, permission); 
            }
            System.debug('tobj.businessId2PermissionsMap::'+tobj.businessId2PermissionsMap);
             /*tobj.permissions = new prov_util_Permissions( PortalConfigurationTemp, 
                                tobj.businessId2PlanWWIdsMap.get(tobj.currentBusinessId),
                                new List<String>{'ALL'} );*/    
            //clientCacheWrapper.permissionMap.put(tobj.currentBusinessId, tobj.permissions);       
            tobj.IsAvailable = true;
            //write the object to the cache
            tobj.writeToCache();
            System.debug('6:Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
            clientCacheWrapper.fullyLoaded = true;
            isRunning = false;
        }catch (Exception ex){
            system.debug('----------------------------------------------------------');
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            system.debug('----------------------------------------------------------');
        }
        System.debug('clientCacheWrapper::'+clientCacheWrapper);
        return clientCacheWrapper;
    }
   
    
    /***************************************************************************
    ********************HELPER METHODS******************************************
    ***************************************************************************/
    
    @AuraEnabled
    public static String convert2CSVBody (List<sObject> objList, List<String> headerNames, List<String> apiNames){
        //initialize the variable
        String csvBody = 'data:text/csv;charset=utf-8';
        
        //loop through header Names and map them in
        for(String hName: headerNames){
            csvBody += ',' + hName;
        }
        csvBody += '\r\n';//start new row

        //loop through sobjects
        for(sObject obj : objList){
            for(String apiName : apiNames){
                csvBody += obj.get(apiName) + ',';
            }
            csvBody = csvBody.substring(0, csvBody.length()-1);//remove last comma
            csvBody += '\r\n';//start new row
        }
        //remove the \r\n from the end of the body
        csvBody = csvBody.substring(0, csvBody.length()-4);
        System.debug('csvBody::'+csvBody);
        return csvBody;
    }
     
   
    
    global class LocalCacheWrapper{
        @AuraEnabled
        public Map<String, Account>                             businessMap                                                     {get;set;}
        @AuraEnabled
        public Map<String, Provider_Portal_Configuration__mdt>  portalConfigs                                                   {get;set;}
        @AuraEnabled
        public String                                           currentPortalConfig                                             {get;set;}
        @AuraEnabled
        public String                                           currentBusId                                                    {get;set;}
        @AuraEnabled
        public Contact                                          currentContact                                                  {get;set;}
        @AuraEnabled
        public Boolean                                          fullyLoaded                                                     {get;set;}
        @AuraEnabled
        public Map<String, Account>                             locationMap                                                     {get;set;}
        @AuraEnabled
        public Map<String, Account>                             providerMap                                                     {get;set;}
        @AuraEnabled
        public Map<String, prov_util_Permissions>               permissionMap                                                   {get;set;}
        @AuraEnabled
        public Map<String, String>                              lob2PortalName                                                  {get;set;}
        @AuraEnabled
        public      Map<Id, List<Id>>                           cBusinessId2LocationIds                                         {get;set;}
        @AuraEnabled
        public      Map<String, List<Id>>                       cBusinessId2ProviderIds                                         {get;set;}
        @AuraEnabled
        public      Map<Id, Map<Id, List<Id>>>                  cBusinessId2Location2ProvidersMap                               {get;set;}
        @AuraEnabled
        public      Map<Id, Map<Id, List<Id>>>                  cBusinessId2Provider2LocationMap                                {get;set;}
        @AuraEnabled
        public      Map<Id, Map<Id, set<string>>>               activeBusinessId2Location2ProvidersMap                          {get;set;}
        
        @AuraEnabled
        public      Set<String>                                     cActiveLocationIds                                              {get;set;}
        
        global LocalCacheWrapper(){
            this.businessMap = new Map<String, Account>();
            this.locationMap = new Map<String, Account>();
            this.providerMap = new Map<String, Account>();
            this.portalConfigs = new Map<String, Provider_Portal_Configuration__mdt>();
            this.permissionMap = new Map<String, prov_util_Permissions>();
            this.lob2PortalName = new Map<String, String>();
            this.cBusinessId2LocationIds = new Map<Id, List<Id>>();
            this.cBusinessId2ProviderIds = new Map<String, List<Id>>();
            this.cBusinessId2Location2ProvidersMap = new Map<Id, Map<Id, List<Id>>>();
            this.cBusinessId2Provider2LocationMap = new Map<Id, Map<Id, List<Id>>>();
            this.activeBusinessId2Location2ProvidersMap = new Map<Id, Map<Id, set<string>>>();
            this.cActiveLocationIds = new Set<String>();
            //this.cActiveProviderIds = new Set<Id>();
        }
    }
    
    
    
    
    /***************************************************************************
    ****************************HELPER METHODS *********************************
    ***************************************************************************/
    @AuraEnabled
    public static Integer fetch_countOfOpenCases(String businessId, String configName){
        businessId = businessId.substring(0,15);//make sure this is at least 15 characters
        //get related service locations
        List<Id> serviceLocIds = prov_util_Cache.BusinessIdToLocationIds.get(businessId);
        
        //get related providers
        List<Id> providerIds = prov_util_Cache.BusinessIdToProviderIds.get(businessId);
        
        //get the related networks
        List<String> networkIds = prov_util_Cache.retrieveNetworkIds(currentBusinessId);
        
        
        //get available record types
        /*List<String> recTypeNames = new List<String>{'Void_Claim'};//should only have the developer name (no spaces)
        List<Id> recordTypeIds = new List<Id>();
        for(RecordType recType : [SELECT id FROM RecordType WHERE SobjectType='Case' AND DeveloperName IN:recTypeNames]){
            recordTypeIds.add(recType.Id);
        }*/

        List<String> caseTypes = new List<String>();
        for(Portal_Picklist__mdt pp : [SELECT id, Value__c FROM Portal_Picklist__mdt WHERE Provider_Portal_Configuration__r.DeveloperName =:configName AND Type__c ='Case Type']){
            caseTypes.add(pp.Value__c);
        }
        
        prov_util_Permissions permission = cobj.businessId2PermissionsMap.get(businessId);
        //add case types for other types
        if(permission.claims == 'full'){
            caseTypes.add('Claim Appeal');
            caseTypes.add('Claim Void');
        }
        if(permission.preAuth == 'full')
            caseTypes.add('Authorization & Estimate Appeal');
        if(permission.dentistList == 'full')
            caseTypes.add('Detail Update');
        if(permission.eft == 'full')
            caseTypes.add('EFT Enrollment/Update/Cancellation');
        
        String orderBy  = '';
        
        //list is now populated for the related contact
        List<Case> list_relatedCases = prov_util_DAL.retrieveCases_contactus(businessId, serviceLocIds, providerIds, caseTypes, orderBy);
        
        return list_relatedCases.size();
    }
    
    @AuraEnabled
    public static Integer hasMessagesApex(String currentBusinessId){
        Date today = Date.today();
        //String dateStr = DateTime.newInstance(today.year(),today.month(),today.day()).format('yyyy-MM-dd');
        Integer totalRecs = 0;
        List<String> providerIds = prov_util_Cache.retrieveProviderIdsByBusinessId(currentBusinessId);
        List<String> serviceLocationIds = prov_util_Cache.retrieveServiceLocationIdsByBusinessId(currentBusinessId);
        List<String> networkIds = prov_util_Cache.retrieveNetworkIds(currentBusinessId);
        System.debug('newtworkIds::'+networkIds);
        Set<String> provNotifIdSet = new Set<String>();
        prov_util_Permissions permission = cobj.businessId2PermissionsMap.get(currentBusinessId); 
        List<String> permissionList = permission.permissionList_Notification();
        /*
        for(Provider_Notification_Network__c network : [SELECT id, Provider_Notification__c FROM Provider_Notification_Network__c WHERE Network__c IN:networkIds AND Provider_Notification__r.Effective_Date__c <= TODAY AND (Provider_Notification__r.Expiration_Date__c >= TODAY OR Provider_Notification__r.Expiration_Date__c =null)]){
            provNotifIdSet.add(network.Provider_Notification__c);
        }
        */
        //query for the provider notificiation network to see any notifications related to a network that this business is connected too
        for(AggregateResult aggRes : [SELECT Count(id) ct, Provider_Notification__c provNotif 
                                        FROM Provider_Notification_Network__c 
                                        WHERE  Network__c IN:networkIds AND Provider_Notification__r.Effective_Date__c <= TODAY AND 
                                        (Provider_Notification__r.Expiration_Date__c >= TODAY OR Provider_Notification__r.Expiration_Date__c =null) 
                                        GROUP BY Provider_Notification__c 
                                        HAVING Count(Id) > 0]){
            provNotifIdSet.add((String)aggRes.get('provNotif'));
        }
        String whereClause = ' WHERE ((Business__c = \'' + currentBusinessId + '\' '+
            ' AND (Provider__c =null OR Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\') )'+
            ' AND (Service_Location__c =null OR Service_Location__c IN (\'' + String.join(serviceLocationIds, '\',\'') + '\') ) ) OR (Business__c = null AND Id IN:provNotifIdSet) OR (Portal_Wide_Notification__c =true AND Related_Provider_Portal__c =\'' + ConfigurationName + '\')) '+
            //' (Network__c =null OR Network__c IN (\'' + String.join(networkIds, '\',\'') + '\')) )'+
            ' AND (Related_Functionality__c = null OR Related_Functionality__c IN:permissionList) ' ;
            //' AND Effective_Date__c <= TODAY AND (Expiration_Date__c >= TODAY OR Expiration_Date__c =null)';
            
        //List<Provider_Notification__c> messages = new List<Provider_Notification__c>();
        String query = 'SELECT count() ' + 
            'FROM Provider_Notification__c ' + whereClause ;
            //'ORDER BY ' + sortField + ' ' + sortDirection + ' LIMIT ' + pageSizeInt + ' OFFSET ' + total_offset;

        System.debug('### query: ' + query);
        totalRecs = Database.countQuery(query);
        /*
        for(Provider_Notification__c notif : (List<Provider_Notification__c>)Database.query(query)){
            if(notif.Business__c == null){
                if(notif.Provider_Notification_Networks__r.size() > 0 || notif.Portal_Wide_Notification__c)
                    totalRecs++;
            } else {
                totalRecs++;
            }
        }
        */
        return totalRecs;
    }
    
    @AuraEnabled 
    public static Map<String, String> retrieveMemberInfoLiveAgent(){
        //initialize the variables
        Map<String, String> key2ValueMap = new Map<String, String>();//map of the current member info and the portal info to the value
        Contact contactRec = prov_util_Cache.ContactRec;
        Provider_Portal_Configuration__mdt portal = prov_util_Cache.PortalConfiguration;
        
        //set the contact info for the case
        key2ValueMap.put('FirstName', contactRec.FirstName);
        key2ValueMap.put('LastName', contactRec.LastName);
        key2ValueMap.put('ContactId', contactRec.Id);
        key2ValueMap.put('AccountId', contactRec.AccountId);
        
        //portal information
        key2ValueMap.put('PortalName', portal.Label);
        //if(UserInfo.getLanguage() == 'es')
        //  key2ValueMap.put('LiveChatId', portal.Spanish_Chat_Id__c);
        //else//default to english
            key2ValueMap.put('LiveChatId', portal.Live_Agent_Chat_Id__c);
            
        key2ValueMap.put('RouteId', portal.RouteID__c);
        key2ValueMap.put('OrgId', UserInfo.getOrganizationId());
        key2ValueMap.put('LiveAgentInitId', portal.Live_Agent_Init__c);
        key2ValueMap.put('LiveAgentURL', portal.Live_Agent_Init_URL__c);
        
        //retrun the map
        return key2ValueMap;
    }
    
    @AuraEnabled
    public static Boolean returnNothing(){
        return true;
    }

    @AuraEnabled
    public static Contact setContactDefaultTab(String tabName){
        System.debug('setting default tab');

        System.debug('contact ID = ' + ContactRec.Id);
        System.debug('tabName = ' + tabName);

        if(tabname == ''){
            ContactRec.Default_Dashboard_Starter_Task__c = null;
        } else {
            ContactRec.Default_Dashboard_Starter_Task__c = tabName;
            
        }
        try{
            update ContactRec;
            cobj.ContactRec = ContactRec;
            cobj.writeToCache();
            
        } catch (Exception e){
            System.debug('exception ' + e.getMessage());
            return null;
        }
        return ContactRec;
    }
    
    @AuraEnabled
    public static List<String> availableReferralPlans(){
        List<String> planGuid = new List<String>();
        
        for(Account plan : [SELECT id, guid__c FROM Account WHERE RecordType.DeveloperName='Plan_Account' AND Provider_Portal_Requires_Referral__c = true]){
            planGuid.add(plan.guid__c.tolowercase());
        }
        System.debug('availableReferralPlans::'+planGuid);
        return planGuid;
    }
}