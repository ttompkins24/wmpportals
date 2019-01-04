/**********************************************************************************************************************
Name                        :   WMP_util_Cache
Purpose                     :   The utility that will cache external object and configuration data for reference by
                                Lightning components and custom  pages in the solution
Created on                  :   08/09/2017
Developed by                :   Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.0         1.0         08/9/2017       Patrick Stephens
1.1         1.0         08/15/2017      Patrick Stephens    
1.1         5.0         09/20/2017      Patrick Stephens     reorganized the code and added comments    
1.1         8.0         11/12/2017      Patrick Stephens     radical change required to the logic, all mock_Member__c and
                                                             mock_MemberCoverage__c calls rewritten this was an emergency
                                                             rush change request
**********************************************************************************************************************/
 
/* Description  **********************************************************
The cache class provides an interface layer for components and controllers to access the in-memory session cache. 
Upon portal login or after custom search, an in-memory copy of the external member data hierarchy is created and 
stored in the user's session cache. This class is constructed so that fetching cache properties invoke a getCache 
call if the data is not already rpesent in the cache.

The actual class stored in the session cache is an instantiation of the wmp_util_CacheObject class. However, we do
not intend consuming components or classes to interact directly with the cacheObject, but rather through this cache class.

We use MemberPlan and MemberCoverage interchangeably in this class, this is due to a change of the external object 
from MembersPlans__x to mock_MemberCoverage__c during development. 
**************************************************************************/

global without sharing class wmp_util_Cache {

/* session cache properties **********************************************************/
    global static   wmp_util_CacheObject                                            cobj                                    {
        get{    
            wmp_util_CacheObject tobj = (wmp_util_CacheObject)Cache.Session.get('PortalCache');
            if(tobj!=null){
                return tobj;
            } else {
                wmp_util_Cache.getCacheData();
                tobj = (wmp_util_CacheObject)Cache.Session.get('PortalCache');
                if(tobj!=null && tobj.cacheFetched!=null && tobj.cacheFetched!=false){
                    return tobj;
                } else {
                    return new wmp_util_CacheObject();
                }
            }
        }
    }
    
    @AuraEnabled
    global static boolean                                                           getIsAvailable(){
        return IsAvailable;    
    }
    global static boolean                                                           IsAvailable                             {
        get{
            //|| (userRec==null || userrec.Id != userInfo.getuserID())
            if(cobj.cacheFetched==null || cobj.cacheFetched==false )
                wmp_util_Cache.getCacheData();
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
                wmp_util_Cache.getCacheData();
            return cobj.cacheFetched;
        }
    }
 /* session cache properties **********************************************************/

/* Running Contact-User Properties **********************************************************/    
    //get the current running user contact rec if avaialable
    @AuraEnabled
    global static   Contact                                                         getContactRec()                         {
        return ContactRec;
    }
    global static   Contact                                                         ContactRec                              {
        get{
            if(!cobj.cacheFetched){
                wmp_util_Cache.getCacheData();
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
                wmp_util_Cache.getCacheData();
            }
            return cobj.UserRec;
        }
    }
    global static boolean                                                           isRunning                               {get;set;}
/* Running Contact-User Properties **********************************************************/  
    
/* SubscriberId and PlanID  **********************************************************/

    //this is the value of the in-context memberId - -it is set initially and then each time the user changes the context, eg by 
    //using the navigation controls in the portal
    @AuraEnabled
    global static   String                                                          getSubscriberId()                       {
        return SubscriberId;
    }
    global static   String                                                          SubscriberID                            {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            if(cobj.SubscriberId==null)
                return '';
            return cobj.SubscriberId.toLowerCase();
        }
        set{
            cobj.SubscriberID = value;
            cobj.WriteToCache();
        }
    } 
    
    //this is the value of the in-context planId - -it is set initially and then each time the user changes the context, eg by 
    //using the navigation controls in the portal
    @AuraEnabled
    global static   String                                                          getPlanGUID()                           {
        return PlanGUID;
    } 
    global static   String                                                          PlanGUID                                {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            if(cobj.planGuid==null)
                return '';
            return cobj.PlanGUID.toLowerCase();
        }
        set{
            cobj.PlanGUID = value;
            cobj.WriteToCache();
        }
    } 
    
    //aura enabled method to allow setting of the subscriberID and PlanGUID
    @AuraEnabled 
    public static void setCurrentMemberInfo(String planGuid, String subscriberGuid){
       //set the plan guid
       wmp_util_Cache.PlanGUID = planGuid.toLowerCase();
       
       wmp_util_Cache.SubscriberId = subscriberGuid.toLowerCase();
    }
    
/* SubscriberId and PlanID  **********************************************************/    

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
                wmp_util_Cache.getCacheData();
            return cobj.ConfigurationName;
        }
    }
    
    //Portal Configuration
    @AuraEnabled
    global static   Portal_Configuration__mdt                                       getPortalConfiguration()                {
        return PortalConfiguration;
    }
    global static   Portal_Configuration__mdt                                       PortalConfiguration                     {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.PortalConfiguration;
        }
    }
 
    //Portal Configuration
    @AuraEnabled    
    global static   List<Portal_Configuration_Links__mdt>                           getFooterLinks()                        {
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            if(PortalLinks!=null && PortalLinks.size()>0){
                List<Portal_Configuration_Links__mdt> result = new List<Portal_Configuration_Links__mdt>();
                for(Portal_Configuration_Links__mdt link : PortalLinks){
                    if(link.location__c.tolowerCase()=='footer'){
                        result.add(link);
                    }
                }
                return result;
            }
            return null;
    }
    
    //Portal Configuration
    @AuraEnabled
    global static   List<Portal_Configuration_Links__mdt>                           getPortalLinks()                        {
        return PortalLinks;
    }
    global static   List<Portal_Configuration_Links__mdt>                           PortalLinks                             {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.PortalLinks;
        }
    }
    
    //Plan Configurations
    @AuraEnabled
    global static   Map<String,Plan_Configuration__mdt>                                     getPlanConfigurations()             {
        return PlanConfigurations;
    }
    global static   Map<String,Plan_Configuration__mdt>                                     PlanConfigurations                      {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.PlanConfigurations;
        }
    }

/* Portal Configuration properties  **********************************************************/  

/* CurrentMember - InContext Properties **********************************************************/  

    //get current memberplan
    @AuraEnabled
    global static   mock_MemberCoverage__c                                               getCurrentMemberPlan()                  {
        return CurrentMemberPlan;
    }
    global static   mock_MemberCoverage__c                                               CurrentMemberPlan{
        get{
            mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(subscriberID.toLowerCase(),PlanGUID.toLowerCase());
            if(mp!=null)
                return mp;
            return null;
        }
    }
    //Retrieve all mock_MemberCoverage__c for current member
    @AuraEnabled 
    global static   List<mock_MemberCoverage__c>                                         getCurrentMemberPlans()                 {
        return getMemberPlansList(subscriberId.toLowerCase(),planGUID.toLowerCase());
    }

/* CurrentMember - InContext Properties **********************************************************/ 

/* Fetch Member Attributes  **********************************************************/ 

//get current current Member
    @AuraEnabled
    global static   mock_Member__c                                                       getCurrentMember()                      {
        return CurrentMember;
    }
    global static   mock_Member__c                                                       CurrentMember                           {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return getMember(subscriberID.toLowerCase(),PlanGUID.toLowerCase());
        }
    } 
    //get Date of birth from MemberId and planID
    global static   mock_Member__c                                   getMember(String memberId, string planId){
        mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(memberId.toLowerCase(),planId.toLowerCase());
        system.debug('mp: ' + memberId + planId + ' : ' + mp);
        system.debug('members: ' + Members.keyset());
        if(mp!=null){
            String profileMemberGUID = mp.MemberProfileGUID__c.toLowerCase();
            mock_Member__c mem = Members.get(profileMemberGUID.toLowerCase());
            return mem;
        } else {
            return null;
        }
    }
     
    //get current Members name
    @AuraEnabled
    global static   String                                                          getMemberName()                         {
        return MemberName;
    }
    global static   String                                                          MemberName                              {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return getMemberName(subscriberID.toLowerCase(),PlanGUID.toLowerCase());
        }
    }
    //get Date of birth from MemberId and planID
    global static   String                                      getMemberName(String memberId, string planId){
        system.debug('mname mem and plan: ' + memberId + ' ' + planId);
        mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(memberId.toLowerCase(),planId.toLowerCase());
        if(mp!=null){
            String profileMemberGUID = mp.MemberProfileGUID__c.toLowerCase();
            mock_Member__c mem = Members.get(profileMemberGUID.toLowerCase());
            //TODO: complete name structure
            return mem.FirstName__c + ' ' + mem.LastName__c;
        } else {
            return null;
        }
    }
    
    //get current BirthDate
    @AuraEnabled
    global static   Date                                                            getBirthDate()                          {
        return BirthDate;
    }
    global static   Date                                                            BirthDate                               {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return getBirthdate(subscriberID.toLowerCase(),PlanGUID.toLowerCase());
        }
    }
    //get Date of birth from MemberId and planID
    global static   Date                                        getBirthdate(String memberId, string planId){
        mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(memberId.toLowerCase(),planId.toLowerCase());
        if(mp!=null){
            String profileMemberGUID = mp.MemberProfileGUID__c.toLowerCase();
            mock_Member__c mem = Members.get(profileMemberGUID);
            return mem.Birthdate__c;
        } else {
            return null;
        }
    }

    //get the current Member Number
    @AuraEnabled
    global static   String                                                          getMemberNumber()                       {
        return MemberNumber;
    }
    global static   String                                                          MemberNumber                            {
        get{
            mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(subscriberID.toLowerCase(),PlanGUID.toLowerCase());
            if(mp!=null)
                return mp.SubscriberId__c;
            return null;
        }
    }
    //get the Member Name from MemberId and planID
    global static   String                                      getMemberNumber(String memberId, String planId){
        mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(memberId.toLowerCase(),planId.toLowerCase());
        if(mp!=null)
            return mp.SubscriberId__c;
        return null;
    }
    
    //get current Effective Date
    @AuraEnabled
    global static   Date                                                            getEffectiveDate()                      {
        return EffectiveDate;
    }   
    global static   Date                                                            EffectiveDate                           {
        get{
            mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(subscriberID.toLowerCase(),PlanGUID.toLowerCase());
            if(mp!=null)
                return mp.EffectiveDate__c;
            return null;
        }
    }
    //get Effective Date from MemberId and planID
    global static   Date                                        getEffectiveDate(String memberId, string planId){
        mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(memberId.toLowerCase(),planId.toLowerCase());
        if(mp!=null)
            return mp.EffectiveDate__c;
        return null;
    }
    
    //get current Termination Date
    @AuraEnabled
    global static   Date                                                            getTerminationDate()                    {
        return TerminationDate;
    }
    global static   Date                                                            TerminationDate                         {
        get{
            mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(subscriberID.toLowerCase(),PlanGUID.toLowerCase());
            if(mp!=null)
                return mp.TerminationDate__c;
            return null;
        }
    }
    //get Termination Date from MemberId and planID
    global static   Date                                        getTerminationDate(String memberId, string planId){
        mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(memberId.toLowerCase(),planId.toLowerCase());
        if(mp!=null)
            return mp.TerminationDate__c;
        return null;
    }
    
    //get the active current primary care dentist record
    @AuraEnabled
    global static wmp_class_PrimaryDentistInfo                                      getPrimaryDentist()                     {
        return PrimaryDentist;
    }
    global static wmp_class_PrimaryDentistInfo                                      PrimaryDentist                          {
        get{
            return getPrimaryDentist(subscriberId,planGUID);
        }
    }
    //get the active primary care dentist record by memberId and planId
    global static wmp_class_PrimaryDentistInfo                  getPrimaryDentist(String memberId, string planID){
        mock_MemberCoverage__c mp = getMembersPlansByMemberAndPlan(memberId.toLowerCase(),planId.toLowerCase());
        if(mp!=null){
            string mcd = mp.MemberCoverageGUID__c.toLowerCase();
            mock_MemberPrimaryCareDentist__c pcd = PrimaryDentists.get(mcd);
            if(pcd!=null){
                Account prov = null;
                Providers_Service_Locations__c servLoc = null;
                
                SYstem.debug('provider guid::'+pcd.ProviderGUID__c.toLowerCase());
                if(Providers.containsKey(pcd.ProviderGUID__c.toLowerCase())){
                    prov = Providers.get(pcd.ProviderGUID__c.toLowerCase());
                }
                System.debug('prov::'+prov);
                
                if(ServiceLocations.containsKey(pcd.ProviderGUID__c.toLowerCase() + pcd.ServiceLocationGUID__c.toLowerCase())){
                    servLoc = ServiceLocations.get(pcd.ProviderGUID__c.toLowerCase() + pcd.ServiceLocationGUID__c.toLowerCase());
                }   
                return new wmp_class_PrimaryDentistInfo(pcd,prov,servLoc);
            }
            
        }
        return null;
    }

/* Fetch Member Attributes  **********************************************************/ 

/*  Member Demographics **********************************************************/ 
    
    //Map of MemberProfileGuid to a map of mock_MemberAddress__c object
    @AuraEnabled
    global static   Map<String,Map<String,mock_MemberAddress__c>>                        getMemberAddresses                          {
        get{
            return MemberAddresses;
        }
    }
    @AuraEnabled
    global static   Map<String,mock_MemberAddress__c>                                    getMemberAddresses(String memberProfileGUID){
        system.debug('memAdds: ' + MemberAddresses);
        if(MemberAddresses.containsKey(memberProfileGUID.toLowerCase())){
            return MemberAddresses.get(memberProfileGUID.toLowerCase());
        } else {
            return null;
        }
    }
    public static   Map<String,Map<String,mock_MemberAddress__c>>                        MemberAddresses                             {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.MemberAddresses;
        }
    }
    
    //Map of MemberProfileGuid to a map of mock_MemberPhone__c object
    @AuraEnabled
    global static   Map<String,Map<String,mock_MemberPhone__c>>                          getMemberPhones                         {
        get{
            return MemberPhones;
        }
    }
    @AuraEnabled
    global static   Map<String,mock_MemberPhone__c>                                      getMemberPhones(String memberProfileGUID){
        if(MemberPhones.containsKey(memberProfileGUID.toLowerCase())){
            return MemberPhones.get(memberProfileGUID.toLowerCase());
        } else {
            return null;
        }
    }
    public static   Map<String,Map<String,mock_MemberPhone__c>>                          MemberPhones                            {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.MemberPhones;
        }
    }
/*  Member Demographics **********************************************************/ 

/* MemberPlan -- MemberCoverage Properties  **********************************************************/  

    //Map of MemberCoverageGuid__c to mock_MemberCoverage__c object -- these are the relevant plans that are visible to the 
    //logged in portal user. Null for Internal users
    @AuraEnabled
    global static   Map<String, mock_MemberCoverage__c>                                  getMemberPlans()                        {
        return MemberPlans;
    }
    global static   Map<String, mock_MemberCoverage__c>                                  MemberPlans                             {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.MemberPlans;
        }
    }
        
    
    //Map of MemberPlanGUID to Verified mock_MemberCoverage__c records aassociated to the logged in portal user. Null for Internal Users
    @AuraEnabled
    global static   Map<String,mock_MemberCoverage__c>                                   getVerifiedMembersPlans()               {
        return VerifiedMembersPlans;
    }
    //Map of MemberPlanGUID to Verified mock_MemberCoverage__c records aassociated to the logged in portal user. Null for Internal Users
    global static   Map<String,mock_MemberCoverage__c>                                   VerifiedMembersPlans                    {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.VerifiedMembersPlans;
        }
    }
    
    //Map of ContactId to Verified mock_MemberCoverage__c records aassociated to the logged in portal user.
    global static   Map<String,List<mock_MemberCoverage__c>>                             ContactMemberPlans                      {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.ContactMemberPlans;
        }
    }
    
    //returns a list of all the incontext members mock_MemberCoverage__c records
    @AuraEnabled
    global static   List<mock_MemberCoverage__c>                     getMemberPlansList(String memberId, String planId){
        if(MemberPlans!=null && MemberPlans.size()>0){
            if(String.isNotBlank(memberId) && String.isNotBlank(planId) && MemberAndPlanToGuid!=null){
                List<mock_MemberCoverage__c> result = new List<mock_MemberCoverage__c>();
                for(String mp : MemberAndPlanToGuid.keyset()){
                    if(mp == memberId.toLowerCase()+planId.toLowerCase()){
                        String guid = MemberAndPlanToGuid.get(mp).toLowerCase();
                        result.addAll(ContactMemberPlans.get(MemberPlanGUIDToContact.get(guid)));
                    }
                }
                return result;
            }
        }
        return null;
    }
     
 
    //Retrieve mock_MemberCoverage__c by MemberId and PlanId
    global static mock_MemberCoverage__c                             getMembersPlansByMemberAndPlan (String memberId, String planid){
        system.debug('memId: ' + memberId);
        system.debug('pid: ' + planId);
        system.debug(MemberPlans);
        mock_MemberCoverage__c result = null;
        if(MemberPlans!=null && MemberPlans.size()>0){
            if(String.isNotBlank(memberId) && String.isNotBlank(planId)){
                string comb = memberId.toLowerCase()+planId.toLowerCase(); 
                system.debug('comb: ' + comb);
                system.debug('memberplans keys: ' + memberPlans.keyset());
                system.debug('MemberAndPlanToGuid : ' + MemberAndPlanToGuid);
                if(MemberAndPlanToGuid!=null && MemberAndPlanToGuid.containsKey(comb)){
                    system.debug('contains');
                    String guid = MemberAndPlanToGuid.get(comb).toLowerCase();
                    system.debug('memGuid: ' + guid);
                    result =  MemberPlans.get(guid);    
                }
            }
        }
        system.debug('MemberResult: ' + result);
        return result;
    }

/* MemberPlan -- MemberCoverage Properties  **********************************************************/ 

/* MemberPlan -- MemberCoverage Utility Maps **********************************************************/     
 
    //Map of MemberId + PlanId to MemberPlanGuid
    global static Map<String,String>                                                MemberGuidToMemberAndPlan               {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.MemberGuidToMemberAndPlan;
        }
    }
    
    //Map of MemberId + PlanId to MemberPlanGuid
    global static Map<String,String>                                                MemberAndPlanToGuid                     {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.MemberAndPlanToGuid;
        }
    }
    
    //Map of member and plan to contact Id
    global static   Map<String,String>                                              MemberPlanGUIDToContact                 {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.MemberPlanGUIDToContact;
        }
    }

/* MemberPlan -- MemberCoverage Utility Maps **********************************************************/

/* mock_Member__c Properties **********************************************************/   

    //map of MemberId to mock_Member__c object
    @AuraEnabled
    public static Map<String,mock_Member__c>                                             getMembers()                            {
        return Members;
    }
    public static Map<String,mock_Member__c>                                             Members                                 {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.Members;
        }
    }

/* mock_Member__c Properties **********************************************************/   

/* mock_MemberAccumulator__c Properties **********************************************************/   

    //map of MemberCoverageId to mock_MemberAccumulator__c object
    @AuraEnabled
    public static Map<String,List<mock_MemberAccumulator__c>>                            getMemberAccumulators()                         {
        return MemberAccumulators;
    }
    @AuraEnabled
	public static List<mock_MemberAccumulator__c>										getMemberAccumulatorsByGUID(String memberProfileGUID)							{
        if(memberProfileGUID!=null && MemberAccumulators.containsKey(memberProfileGUID.toLowerCase())){
            List<mock_MemberAccumulator__c> dedupedList = new List<mock_MemberAccumulator__c>();
        	Set<String> AccumGUIDs = new Set<String>();
            for(mock_MemberAccumulator__c memAcc : MemberAccumulators.get(memberProfileGUID.toLowerCase())){
                 if(!AccumGUIDs.contains(memAcc.MemberAccumulatorGUID__c)){
                 	AccumGUIDs.add(memAcc.MemberAccumulatorGUID__c);
                     dedupedList.add(memAcc);
                 }
            }
        	return dedupedList;
        }
        return null;
	} 
    @AuraEnabled 
    public static List<mock_MemberAccumulator__c>                                        getMemberAccumulatorsByGUIDs(String memberProfileGUID, String memberCoverageGUID) {
        System.debug('Accumulators:: ' + MemberAccumulators);
        List<mock_MemberAccumulator__c>  result = new List<mock_MemberAccumulator__c>();
        if(memberProfileGUID!=null && MemberAccumulators.containsKey(memberProfileGUID.toLowerCase())){
        	result = new  List<mock_MemberAccumulator__c>();
            Set<String> AccumGUIDs = new Set<String>();
            for(mock_MemberAccumulator__c memAcc : MemberAccumulators.get(memberProfileGUID.toLowerCase())){
                if(memAcc.MemberCoverageGuid__c.toLowerCase() == memberCoverageGUID.toLowerCase() && !AccumGUIDs.contains(memAcc.MemberAccumulatorGUID__c)){
                   AccumGUIDs.add(memAcc.MemberAccumulatorGUID__c); 
                   result.add(memAcc);
                }
            }
        }

        //check to see if plan is overriding another plan.   If so, add those accumulators
        //list of strings in account ids of overriden plan
        List <String> planOverides = getPlanOverrides(PlanGUID);
        if(planOverides != null){
            //make map of plan id to plan guid from accounts
            Map<String, String> planIdToGuidMap = new Map<String, String>();
            for(Account plan: getPlans().values()){
                planIdToGuidMap.put(String.valueOf(plan.id).left(15),plan.guid__c.toLowercase());
            }
            System.debug('planIdToGuidMap ' + planIdToGuidMap);
                
            //loop through plans and get the plan guid that matches the planId
            Set<String> planGuidSet = new Set<String>();
            for(String s : planOverides){
                planGuidSet.add(planIdToGuidMap.get(s));                
            }
            System.debug('planGuidSet ' + planGuidSet);
            //get memberprofileguids for each plan
            for(String s : planGuidSet){
                System.debug('s1 ' + getSubscriberId()+s);
                System.debug('s2 ' + wmp_util_Cache.cobj.MemberAndPlanToProfileGuid.get(getSubscriberId()+s));
                List<mock_MemberAccumulator__c> tempAcc = getMemberAccumulatorsByGUID(wmp_util_Cache.cobj.MemberAndPlanToProfileGuid.get(getSubscriberId()+s));
               result.addAll(tempAcc); 
            }

        }
        return result;
    } 
    public static Map<String,List<mock_MemberAccumulator__c>>                            MemberAccumulators                                  {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.MemberAccumulators;
        }
    }
  
/* mock_MemberAccumulator__c Properties **********************************************************/   
    
/* mock_MembersServiceHistory__c Properties **********************************************************/   
    
    //map of MemberCoverageId to mock_MembersServiceHistory__c object
    @AuraEnabled
    public static Map<String,List<mock_MembersServiceHistory__c>>                        getMemberServiceHistories()                         {
        return MemberServiceHistories;
    }
    @AuraEnabled
    public static List<mock_MembersServiceHistory__c>                                    getMemberServiceHistoryByGUID(String memberCoverageGUID)                            {
        if(memberCoverageGUID!=null && MemberServiceHistories.containsKey(memberCoverageGUID.toLowerCase()))
            return MemberServiceHistories.get(memberCoverageGUID.toLowerCase());
        return null;
    }
    public static Map<String, List<mock_MembersServiceHistory__c>>                       MemberServiceHistories                              {
        get{
            //get member service histories
            Map<String, List<mock_MembersServiceHistory__c>> result = new Map<String, List<mock_MembersServiceHistory__c>>();
            List<mock_MembersServiceHistory__c>  memServHists = wmp_util_DAL.getMemberServiceHistory(new list<String>(Members.keyset()),VisiblePlanIds);
            if(memServhists.size()>0){
                for(mock_MembersServiceHistory__c memSH : memServHists) {
                    if(!result.containsKey(memSH.MemberProfileGUID__c.toLowerCase()))
                        result.put(memSH.MemberProfileGUID__c.toLowerCase(),new List<mock_MembersServiceHistory__c>());
                    result.get(memSH.MemberProfileGUID__c.toLowerCase()).add(memsH);                
                }
            }  
            return result;
        }
    }
          
/* mock_MembersServiceHistory__c Properties **********************************************************/   
        
/* User PLan Verification Properties **********************************************************/
    
    //Map of SFID and User_Plan_Verification__c records aassociated to the logged in portal user. Null for Internal Users
    global static   Map<Id,User_Plan_Verification__c>                               VerifiedPlans                           {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.VerifiedPlans;
        }
    }
     
    //Map of emberPlanGuid to SF ID for UserPlanVerification
    global static   Map<String, ID>                                                 MemberGuidToPlanVerification            {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.MemberGuidToPlanVerification;
        }
    }
 
/* User PLan Verification Properties **********************************************************/

/* Plan Properties **********************************************************/
    
    //Plan Ids (WindWard Ids) visible to the running User
    global static   List<String>                                                    VisiblePlanIds                          {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return new List<String>(VisiblePlanIdSet);
        }
    }
    
    global static   Set<String>                                                     VisiblePlanIdSet                        {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.VisiblePlanIdSet;
        }
    }
    
    //Map of planOverrides, Overiding plan guid to set of overidden plans
    public static Map<String,Set<String>>                                           getPlanOverrides()                      {
        return planOverrides;
    }
    @AuraEnabled
    public static List<String>                                                      getPlanOverrides(String planGuid)       {
        if(planOverrides!=null && String.isNotBlank(planGuid)){
            if(planOverrides.containsKey(planGuid.toLowerCase()))
                return New List<String>(PlanOverrides.get(planGuid.toLowerCase()));
        }
        return null;
    }
    public static Map<String,Set<String>>                                           PlanOverrides                           {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.planOverridesIds;
        }
    }    
    //map of planguids to Account[Plan] object
    @AuraEnabled
    public static Map<String,Account>                                               getPlans()                              {
        return Plans;
    }
    public static Map<String,Account>                                               Plans                                   {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.Plans;
        }
    }
    
    //get name of current plan 
    @AuraEnabled
    global static   String                                                          getPlanName()                           {
        return PlanName;
    }
    @AuraEnabled
    global static   String                                                          getPlanName(String planGUID)            {
        if(planGUID!=null && Plans.containsKey(planGUID.toLowerCase()))
            return Plans.get(planGUID.toLowerCase()).Name;
        return null;
    }
    global static   String                                                          PlanName                                {
        get{
        if(planGUID!=null && Plans.containsKey(planGUID.toLowerCase()))
            return Plans.get(planGUID.toLowerCase()).Name;
        return null;
        }
    }
    
    
    //get current plan
    @AuraEnabled
    global static   Account                                                         getPlan()                               {
        return Plan;
    }
    global static   Account                                                         Plan                                    {
        get{
            if(planGUID!=null && Plans.containsKey(planGUID.toLowerCase()))
                return Plans.get(planGUID.toLowerCase());
            return null;
        }
    }
    //get plan from MemberId and planID
    global static   Account                                     getPlan(string planId){
        if(planId!=null && Plans.containsKey(planId.toLowerCase()))
            return Plans.get(planId.toLowerCase());
        return null;
    }

/* Plan Properties **********************************************************/
 
/* Primary Dentist & Provider Properties **********************************************************/  
    // make PCD request
    public static   Boolean                                     requestPCDChange(wmp_util_PCDWrapper pcdRequest){
        Boolean result = false;
        try{
            if(pcdRequest!=null && pcdRequest.MemberCoverageGUIDs!=null){
                wmp_util_PCDCalloutWrapper pcdWrapper = new wmp_util_PCDCalloutWrapper();
                pcdWrapper.PCDRequests = new List<wmp_util_PCDCalloutWrapper.PCDRequest>();
                //get userVerification records for the associated contactIds
                Map<String, List<User_Plan_Verification__c>> mcGuidToUPVs = new Map<String, List<User_Plan_Verification__c>>();
                Map<string, string> mpToMCG = new Map<String,String>();
                //get variables
                String routeId = PortalConfiguration.RouteID__c;
                String provId = pcdRequest.ProviderGUID;
                String slId = pcdRequest.ServiceLocationGUID;
                String reason = pcdRequest.reason;
                Set<String> memberIds = new Set<String>();
                Set<String> planIds = new Set<String>();
                System.debug('MPlans: ' + memberPlans);
                //get the subscriber and planIds                
                for(String mcg : pcdRequest.MemberCoverageGUIDs){
                    if(MemberPlans.containsKey(mcg.toLowerCase())){
                        
                        system.debug('PCDContains');
                        String memId = Memberplans.get(mcg.toLowerCase()).SubscriberID__c.toLowerCase();
                        memberIds.add(memId);
                        String pId = MemberPLans.get(mcg.toLowerCase()).PlangUId__c.toLowerCase();
                        planIds.add(pId);
                        mpToMCG.put(memId + pId,mcg.toLowerCase());
                        mcGuidToUPVs.put(mcg.toLowerCase(),new List<User_Plan_Verification__c>());
                        
                    }
                }
                system.debug(mcGuidToUPVs);
                //get the user_plan_verificatin records resident in memory
                //we can't query the db because the plan and membercoverageguid on the record may no longer be active
                List<User_Plan_Verification__c> upvs = VerifiedPlans.values();
                system.debug('upvs: ' + upvs);
                system.debug('M:' + memberIds);
                system.debug('P: ' + planIds);
                //get the upv that matches the subscriber and planId
                for(User_Plan_Verification__c upv : upvs){
                    String memId = upv.Subscriber_ID__c.toLowerCase();
                    String pid = upv.Plan_ID__c.toLowerCase();
                    SYSTEM.DEBUG(MEMiD + ' ' + PID);
                    if(upv.Subscriber_ID__c!=null && upv.Plan_ID__c!=null &&
                       memberIds.contains(memId) && planIds.contains(pId)){
                       String mcg = mpTOMCG.get(memId + pId);
                       mcGuidToUPVs.get(mcg).add(upv);
                    }
                }
                for(String mcg : mcGuidToUPVs.keyset()){
                    wmp_util_PCDCalloutWrapper.PCDRequest pcr = new wmp_util_PCDCalloutWrapper.PCDRequest();
                    pcr.RouteID = routeId;
                    pcr.MemberCoverageGUID = mcg;
                    pcr.ServiceLocationGUID = slId;
                    pcr.ProviderGUID = provId;
                    pcr.TerminationCode = reason;
                    pcr.UserPlanVerificationSFIDs = new List<String>();
                    for(User_Plan_Verification__c upv : mcGuidToUPVs.get(mcg)){
                        pcr.UserPlanVerificationSFIDs.add(upv.Id);
                    }
                    pcdwrapper.PCDRequests.add(pcr);
                }
                
                if(wmp_util_MockData.useMockData){
                    //we are in test or dev, do not make the callout
                    RecordPCDRequest(mcGuidToUPVs);
                    return true; 
                } else {
                    Global_Configuration__c pcdEndpoint = Global_Configuration__c.getInstance('PCDRequestEndpoint');
                    Global_Configuration__c pcdUsername = Global_Configuration__c.getInstance('PCDRequestUsername');
                    Global_Configuration__c pcdPassword = Global_Configuration__c.getInstance('PCDRequestPassword');
                    if(String.IsNotBlank(pcdEndpoint.value__c) && pcdEndpoint.value__c!='null' 
                       && String.IsNotBlank(pcdUsername.value__c) && pcdUsername.value__c!='null'
                       && String.IsNotBlank(pcdPassword.value__c) && pcdPassword.value__c!='null'){
                        //setup basic auth
                        Blob headerValue = Blob.valueOf(pcdUsername.value__c +':' +pcdPassword.value__c);
                        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                        //make a callout to WW to submit the request
                        HTTP h = new HTTP();
                        HTTPRequest req = new HTTPRequest();
                        req.setEndpoint(pcdEndpoint.value__c);
                        req.setMethod('POST');
                        req.setHeader('Content-Type', 'application/json');
                        req.setHeader('Authorization', authorizationHeader);
                        String payload = JSON.serialize(pcdWrapper);
                        system.debug('Payload: ');
                        system.debug(payload);
                        req.setBody(payload);
                           
                        HTTPResponse res = h.send(req);
                        //check for the response
                        system.debug('PCDResponseCode: ' + res.getStatusCode());
                        if(res.getStatusCode()!=200){
                            system.debug('--PCD Change Request-------------------------------------------------------------------------');
                            system.debug('Response failed.');
                            system.debug(res.getStatusCode());
                            system.debug(res.getBody());
                            system.debug('--PCD Change Request-------------------------------------------------------------------------');
                            return false;
                        } else {
                            RecordPCDRequest(mcGuidToUPVs);
                            return true;
                        }
                    } else {
                        system.debug('--PCD Change Request-------------------------------------------------------------------------');
                        system.debug('No valid endpoint in the setting.');
                        system.debug('--PCD Change Request-------------------------------------------------------------------------');
                    }
                }
            }
        } catch (exception ex){
            system.debug('--PCD Change Request-------------------------------------------------------------------------');
            system.debug('PCDRequest: ' + pcdRequest);
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            system.debug('--PCD Change Request-------------------------------------------------------------------------');
        }
        return result;
    }
    
    
    //clear PlanVerificationRecord when a response comes back
    @AuraEnabled
    public static void ClearPCDRequest(String MemberId, String PlanId)                                                      {
        if(MemberAndPlanToGuid.containsKey(memberId + PlanId)){
            String mpGUID = MemberAndPlanToGuid.get(memberId + PlanId);
            if(MemberGuidToPlanVerification.containsKey(mpGUID)){
                Id upvId = MemberGuidToPlanVerification.get(mpGUID);
                User_Plan_Verification__c upv = VerifiedPlans.get(upvId);
                    upv.PCD_Request_Date__c = null;
                    upv.PCD_Request_Note__c = null;
                update upv;
                PCDRequests.remove(mpGUID);
                cobj.WriteToCache();
            }
        }
    }
    
    
    //set PlanVerificationRecord for PCD request when a request is made
    @AuraEnabled
    public static void  RecordPCDRequest(Map<String, List<User_Plan_Verification__c>> mcGuidToUPVs)                             {
        List<User_Plan_Verification__c> upvs = new List<User_Plan_Verification__c>();
        for(String mcg : mcGuidToUPVs.keyset()){
            for(User_Plan_Verification__c upv : mcGuidToUPVs.get(mcg)){            
                upv.PCD_Request_Date__c = System.today();
                upv.PCD_Request_Note__c = 'PCD Requested';
                PCDRequests.put(mcg,'PCD Requested');
                upvs.add(upv);
            }
        }
        update upvs;
        cobj.WriteToCache();

    }
    
    //map of memberPlanGuids to active mock_MemberPrimaryCareDentist__c object
    @AuraEnabled
    public static Map<String,mock_MemberPrimaryCareDentist__c>                           getPrimaryDentists()                    {
        return PrimaryDentists;
    }
    public static Map<String,mock_MemberPrimaryCareDentist__c>                           PrimaryDentists                         {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.PrimaryDentists;
        }
    }
    
    //map of memberPlanGuids to PCDRequests
    @AuraEnabled
    public static Map<String,String>                                                getPCDRequests()                    {
        return PCDRequests;
    }
    @AuraEnabled
    public static String                                                            getPCDRequest(String memberId, String planID){
        if(MemberAndPlanToGuid.containsKey(memberId + PlanId)){
            if(PCDRequests.containsKey(MemberAndPlanToGuid.get(memberId + PlanId))){
                return PCDRequests.get(MemberAndPlanToGuid.get(memberId + PlanId));
            }
        }
        return null;
    }
    @AuraEnabled
    public static String                                                            getPCDRequest(String memberPlanGUID){
        if(PCDRequests.containsKey(memberPlanGUID)){
            return PCDRequests.get(memberPlanGUID);
        }else {
            return null;
        }
    }
    public static Map<String,String>                                                PCDRequests                         {
        get{
            if(!cobj.cacheFetched)
                wmp_util_Cache.getCacheData();
            return cobj.PCDRequests;
        }
    }
    
    public static   Map<String, Account>                                            Providers                               {
        get{
            return cobj.Providers;
        }
    }
    
    public static   Map<String, Providers_Service_Locations__c>                     ServiceLocations                        {
        get{
            return cobj.ServiceLocations;
        }
    }

/* Primary Dentist & Provider Properties **********************************************************/ 

/* Visible Lines Of Business        **********************************************************/

    //get the visible Lines of Business for the current running user
    global static   Set<String>                                                     VisibleLOB                              {
        get{
            return cobj.VisibleLOB;
        }
    }
    //get the visible Lines of Business for the current running user
    global static   List<String>                                                    VisibleLOBList                          {
        get{
            return new list<String>(VisibleLOB);
        }
    }
    
/* Visible Lines Of Business        **********************************************************/
    
/* Cache Population method      **********************************************************/
    
    //wmp_util_Cache.GetCacheData fetches the necessary portal and plan configuration using the running user
    global static   void    GetCacheData(){
        isRunning=true;
        
        wmp_util_CacheObject tobj = new wmp_util_CacheObject();
        tobj.cacheFetched = true;
        
        //get the running user
        tobj.UserRec = (User)wmp_util_DAL.dalQueryById('User',UserInfo.getUserId());
        system.debug('RunningUser: ' + tobj.UserRec);
        //get the associated contact
        if(tobj.userRec.contactId!=null){
            tobj.ContactRec = (Contact)wmp_util_DAL.dalQueryById('Contact', tobj.userRec.contactId);
        } else if(tobj.userRec.contactId==null && tobj.ContactToReview!=null){
            tobj.ContactRec = (Contact)wmp_util_DAL.dalQueryById('Contact', tobj.ContactToReview);
        } else if(tobj.userRec.contactId==null && tobj.ContactToReview==null){
            //this is an internal user working without a reference
            try{
                List<Contact> cons = wmp_util_DAL.dalQuery('Contact','WHERE FirstName = \'Bruce\' AND LastName = \'Wayne\' AND Email = \'iluvbats@test.com\'');
                tobj.ContactRec = cons[0];
            } catch(exception ex){
                system.debug('----------------------------------------------------------');
                system.debug('this is an internal user working without a contact reference');
                system.debug(ex.getMessage());
                system.debug(ex.getStackTraceString());
                system.debug('----------------------------------------------------------');
            }
        }
        system.debug('cont: ' + tobj.ContactRec);
        //get ConfigurationName
        if(tobj.ContactRec!=null){
            tobj.ConfigurationName = tobj.ContactRec.Portal_Name__c;
        } else {
            tobj.ConfigurationName = 'Internal';
        }   
        system.debug('config name: ' + tobj.ConfigurationName);
        //get portal configuration
        List<Portal_Configuration__mdt> configs = (List<Portal_Configuration__mdt>)wmp_util_DAL.dalQuery('Portal_Configuration__mdt',
                                                                                                         'WHERE DeveloperName = \'' + tobj.ConfigurationName + '\'');
        if(configs.size()>0)
            tobj.PortalConfiguration = configs[0];
        
        try{ 
            //get portal configuration links
            tobj.PortalLinks = (List<Portal_Configuration_Links__mdt>)wmp_util_DAL.dalQuery('Portal_Configuration_Links__mdt',
                        'WHERE Portal__r.DeveloperName = \'' + tobj.ConfigurationName + '\' Order by Display_Order__c ASC');
     
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
                if(tobj.PortalConfiguration!=null && tobj.PortalConfiguration.RouteID__c!=null)
                    //allow the RouteId field on the metadata to specify a number of routeIds
                    if(tobj.PortalConfiguration.RouteID__c.contains(';')){
                        for(String s : tobj.PortalConfiguration.RouteID__c.split(';')){
                            tobj.VisibleLOB.add(s);
                        }
                    } else {
                        tobj.VisibleLOB.add(tobj.PortalConfiguration.RouteID__c);
                    }
            }
            system.debug('vl ' + tobj.VisibleLOB);
            tobj.writeToCache();
             
            //query for the verifiedPlans
            if(tobj.contactRec==null){
                //internal user
                tobj.VerifiedPlans = null;
            } else {
                tobj.VerifiedPlans = new Map<id, User_Plan_Verification__c>(
                                (List<User_Plan_Verification__c>)wmp_util_DAL.dalQuery('User_Plan_Verification__c',
                                    'WHERE Member_Contact__c = \'' + tobj.ContactRec.Id + '\' OR Guardian_Contact__c = \'' + tobj.ContactRec.Id + '\'')
                            );
            }
            system.debug('vps: ' + tobj.VerifiedPlans.size());
             
            //get MemberPlans section
            // set temp cacheobject props
            tobj.MemberPlanGUIDToContact = new Map<string,String>();
            tobj.PCDRequests = new Map<String,String>();
            tobj.MemberGuidToPlanVerification = new Map<String,Id>();
            tobj.MemberPlans = new Map<String,mock_MemberCoverage__c>();
            tobj.MemberAndPlanToGuid = new Map<String,String>();
            tobj.MemberGuidToMemberAndPlan = new Map<String,String>();
            tobj.Plans = new Map<String,Account>();
            tobj.ContactMemberPlans = new Map<String,List<mock_MemberCoverage__c>>();
            tobj.VisiblePlanIdSet = new Set<String>();
             
            //set helper props
            Set<String> allPlanIds = new Set<String>();
            integer counter = 0;
            Map<String, mock_MemberCoverage__c> expiredPlans = new Map<String,mock_MemberCoverage__c>();
            Map<string,User_Plan_Verification__c> MemPlanToUPV = new Map<String,User_Plan_Verification__c>();
            integer ed = integer.valueOf(tobj.PortalConfiguration.EffectiveDateAdj__c);
            integer td = integer.valueOf(tobj.PortalConfiguration.TerminationDateAdj__c)*-1;
            if(ed==null)
                ed=0;
            if(td==null)
                td=0;
            Date lkEff = Date.today().addDays(ed);
            Date lkTerm = Date.today().addDays(td);
            Map<String,String> mpguidProfileGuid = new Map<String,String>();
            
            //loop through the verified plan records and pull subscriberId and planguids
            //use those to search the membercoverage table
            Map<String,User_Plan_Verification__c> initialMemPlans = new Map<String,User_Plan_Verification__c>();
            if(tobj.ContactRec!=null && tobj.verifiedPlans!=null){
                for(User_Plan_Verification__c vPlan : tobj.verifiedPlans.values()){
                    if(vPlan.subscriber_ID__c!=null && vplan.plan_Id__c!=null){
                        tobj.MemberAndPlanToGUID.put(vPlan.subscriber_ID__c.toLowerCase() + vplan.plan_Id__c.toLowerCase(),null);
                        MemPlanToUPV.put(vPlan.subscriber_ID__c.toLowerCase() + ';' + vplan.plan_Id__c.toLowerCase(),vplan);
                        if(!initialMemPlans.containsKey(vPlan.subscriber_ID__c.toLowerCase()))
                            initialMemPlans.put(vPlan.subscriber_ID__c.toLowerCase(),vplan);
                        if(vPlan.PCD_Request_Date__c != null && String.IsNotBlank(vPlan.PCD_Request_Note__c)){
                            //this memberplan record has an outstanding PCD request
                            tobj.PCDRequests.put(vPlan.MemberCoverageGuid__c.toLowerCase(),vPlan.PCD_Request_Note__c);
                        }
                    }
                }
            }
           
            system.debug('subPlanGuids: ' + tobj.MemberAndPlanToGUID);
            tobj.MemberPlans = new Map<String, mock_MemberCoverage__c>();
            if(tobj.MemberAndPlanToGUID.size()>0){
                //USE the DAL to query for the membercoverage records
                List<mock_MemberCoverage__c> memberPlanList = wmp_util_DAL.getMembersPlans(new List<string>(MemPlanToUPV.keyset()));
                if(memberPlanList.size()>0){                   
                    system.debug('Check mps: ' + memberPlanList.size());
                    for(mock_MemberCoverage__c mPlan : memberPlanList){
                        mpguidProfileGuid.put(mPlan.MemberCoverageGuid__c,mPlan.MemberProfileGUID__c);
                    }
                }
            } 
            
            system.debug('InitialProfileGuids: ' + mpguidProfileGuid);
            //get universal Ids
            //we use the memberProfielGUID in a government context
            //this may require modification in a commerical portal when the subscriberProfielGUID becomes relevant
            tobj.Members = wmp_util_DAL.getMembersMap(mpguidProfileGuid.values());
            
            //get historical universal Ids
            Set<String> newProfileMemberGuids = new Set<String>();
            Set<String> universalIds = new Set<String>();
            for(mock_Member__c member : Members.values()){
                universalIds.add(member.universalMemberGuid__c.toLowerCase());
            }
            
            //loop though history to find new profielguids
            Map<String,mock_MemberUniversalID__c> history = wmp_util_DAL.getMemberHistoryMap(new List<String>(universalIds));
            if(history!=null){
                system.debug('uHist: ' + history);
                for(mock_MemberUniversalID__c hist : history.values()){
                    //if(!tobj.Members.containsKey(hist.MemberProfileGUID__c.toLowerCase())){
                        newProfileMemberGuids.add(hist.MemberProfileGUID__c.toLowerCase());
                    //} 
                } 
            }
             
            //get all member plans that may have been associated to the profiles
            Map<String,mock_Member__c> allMems = new Map<String,mock_Member__c>();
            Map<String,mock_MemberCoverage__c> allMPlans = new Map<String,mock_MemberCoverage__c>();
            for(String opg : mpguidProfileGuid.values()){
                if(opg!=null&&!newProfileMemberGuids.contains(opg.toLowerCase()))
                    newProfileMemberGuids.add(opg.toLowerCase());
            }
            system.debug('newProfileGuids: ' + newProfileMemberGuids);
            if(newProfileMemberGuids.size()>0){
                //there are new members and potentially new memberplans to retrieve
                allMPlans = wmp_util_DAL.getMembersPlansMapByProfile(new List<String>(newProfileMemberGuids));
            }
            Map<String,String> newSubscriberGUIDToPlanGuid = new Map<String,String>();
            Map<String,string> newMemPlanToCoverageGUID = new Map<String,String>();
            system.debug('allMPlans: ' + allMPlans.size());
            Map<String,String> allPlanGUIDS = new Map<String,String>();
            tobj.MemberAndPlanToProfileGuid = new Map<String,String>();
            for(mock_MemberCoverage__c mc : allMplans.values()){
                if(mc.EffectiveDate__c<=lkEff && (mc.TerminationDate__c>=lkTerm || mc.TerminationDate__c ==  null)){
                    allPlanGUIDS.put(mc.PlanGUID__c.toLowerCase(),mc.MemberCoverageGUID__c.toLowerCase());
                    tobj.MemberAndPlanToProfileGuid.put(mc.SubscriberID__c.toLowerCase()+mc.PlanGUID__c.toLowerCase(),mc.MemberProfileGUID__c.toLowerCase());
                }
            }
            Map<String,String> planIds = new Map<String,String>();
            if(allPlanGUIDS.size()>0){
                system.debug('visLOB: ' + tobj.VisibleLob);
                List<Account> acplans = (List<Account>)wmp_util_DAL.dalQuery('Account','WHERE guid__c in (\''+String.join(new List<String>(allPlanGUIDS.keyset()),'\',\'')+'\') AND route_id__c in (\''+String.join(new List<String>(tobj.VisibleLob),'\',\'')+'\')');          
                tobj.Plans = new Map<String,Account>();
                for(Account acc : acplans){
                    tobj.plans.put(acc.guid__c.toLowerCase(),acc);
                    planIds.put(String.valueOf(acc.id).left(15),acc.guid__c.toLowerCase());
                }
            }
             
            system.debug('Plans: ' + planids);
            //get plan configurations
            Map<String,String>  planOverriddenBy = new Map<String,String>();
            tobj.planOverridesIds = new Map<String,Set<String>>();
            tobj.PlanConfigurations = new Map<String,Plan_Configuration__mdt>();
            List<Plan_Configuration__mdt> planConfigs = (List<Plan_Configuration__mdt>)wmp_util_DAL.dalQuery('Plan_Configuration__mdt',
                        'WHERE Plan_Account_Id__c in (\''+String.join(new List<String>(planIds.keyset()),'\',\'')+'\') OR Plan_Account_Id__c in (\''+String.join(new List<String>(tobj.plans.keyset()),'\',\'')+'\')');
            system.debug('pconfigs: ' + planConfigs);
            for(Plan_Configuration__mdt pc : planConfigs){
                if(String.isNotBlank(pc.OveriddenById__c)){
                    planOverriddenBy.put(planIds.get(pc.Plan_Account_Id__c),pc.OveriddenById__c.toLowerCase());
                    if(!tobj.planOverridesIds.containsKey(pc.OveriddenById__c.toLowerCase()))
                            tobj.planOverridesIds.put(pc.OveriddenById__c.toLowerCase(),new Set<String>());
                    //changed by mike to remove lowercase change to account id
                    tobj.planOverridesIds.get(pc.OveriddenById__c.toLowerCase()).add(pc.Plan_Account_Id__c);
                }
                String acId = pc.Plan_Account_Id__c;
                if(acid.length()>=15 && acid.length()<=18){
                    tobj.PlanConfigurations.put(planIds.get(acId.left(15)),pc);
                } else {
                    tobj.PlanConfigurations.put(acid.toLowerCase(),pc);
                }
            }
            system.debug('planConfig: ' + tobj.PlanConfigurations);
            //loop through all the MemberCoverage records and pull those that are overriden
            Set<String> plansOverriddenNow = new Set<string>();
            Set<String> planGuids = new Set<String>();
            for(String mcg : allMPlans.keyset()){
                mock_MemberCoverage__c mPlan = allMPlans.get(mcg);  
                if(planOverriddenBy.containsKey(mPlan.PlanGUID__c.toLowerCase())){                 
                    if(allPlanGUIDS.containsKey(planOverriddenBy.get(mPlan.PlanGUID__c.toLowerCase()).toLowercase())){
                        allMplans.remove(mcg);
                    }
                } 
            }
            
            for(String mcg : allMPlans.keyset()){
                system.debug('ap mcg: ' + mcg);
                if(!tobj.MemberPlans.containsKey(mcg)){
                    mock_MemberCoverage__c mPlan = allMPlans.get(mcg);  
                    system.debug('ap mp: ' + mplan);
                    //check expiration
                    if(mplan.EffectiveDate__c<=lkEff && (mplan.TerminationDate__c>=lkTerm || mplan.TerminationDate__c ==  null)){
                        //is effective
                        //if we haven't already added this subscriber Id, continue
                        if(!newSubscriberGUIDToPlanGuid.containsKey(mPlan.SubscriberID__c.toLowerCase())){
                            String mpx = mPlan.SubscriberID__c.toLowerCase() + ';' + mPlan.PlanGuid__c.toLowerCase();
                            User_Plan_Verification__c tupv = null;
                            if(initialMemPlans.containsKey(mplan.SubscriberID__c.toLowerCase())){
                                //we have a verification record for this coverage
                                tupv = initialMemPlans.get(mplan.SubscriberID__c.toLowerCase());
                                tobj.MemberPlanGUIDToContact.put(mPlan.MemberCoverageGuid__c.toLowerCase(),tupv.Member_Contact__c);
                                tobj.MemberGuidToPlanVerification.put(mPlan.MemberCoverageGuid__c.toLowerCase(),tupv.Id);
                                //update the coverage guid in the pcdrequest table
                                if(tobj.PCDRequests.containsKey(tupv.MemberCoverageGUID__c.toLowerCase())){
                                    //swap the value
                                    String noteValue = tobj.PCDRequests.get(tupv.MemberCoverageGUID__c.toLowerCase());
                                    tobj.PCDRequests.remove(tupv.MemberCoverageGUID__c.toLowerCase());
                                    tobj.PCDRequests.put(mPlan.MemberCoverageGuid__c.toLowerCase(), noteValue);
                                }
                                
                                tupv.MemberCoverageGUID__c = mPlan.MemberCoverageGuid__c.toLowerCase();
                                tupv.plan_id__c = mplan.planGUID__c;
                                
                                allPlanIds.add(mPlan.PlanGuid__c);
                                tobj.MemberPlans.put(mPlan.MemberCoverageGuid__c.toLowerCase(),mPlan);
                                tobj.MemberAndPlanToGuid.put(mPlan.SubscriberID__c.toLowerCase() + mPlan.PlanGuid__c.toLowerCase(),mPlan.MemberCoverageGuid__c.toLowerCase());
                                tobj.MemberGuidToMemberAndPlan.put(mplan.MemberCoverageGuid__c.toLowerCase(),mPlan.SubscriberID__c.toLowerCase() + mPlan.PlanGuid__c.toLowerCase());
                                
                                string tempContactId = MemberPlanGUIDToContact.get(mPlan.MemberCoverageGuid__c.toLowerCase());
                                system.debug('tempcontactId : ' + tempContactId);
                                if(!tobj.ContactMemberPlans.containsKey(tempContactId))
                                    tobj.ContactMemberPlans.put(tempContactId,new list<mock_MemberCoverage__c>());
                                tobj.ContactMemberPlans.get(tempContactId).add(mplan);
                                 
                                String memConId = tupv.Guardian_Contact__c;
                                String guardconId = tupv.Member_Contact__c;
        
                                system.debug(memConId + ' ' + guardConId);
                                system.debug(tobj.ContactRec.Id);
                                system.debug(mPlan.PlanGUID__c);
                                system.debug(mPlan.SubscriberId__c);
                                system.debug('Check: ' + counter + ' ' + tobj.subscriberId + ' ' +  mPlan.MemberCoverageGuid__c);
                                if(counter==0 && tobj.subscriberId==null 
                                   && (memConId == tobj.ContactRec.Id || guardconId == tobj.ContactRec.Id)){
                                       //this is the current most recent record
                                       tobj.subscriberID = mPlan.SubscriberId__c.toLowerCase();
                                       tobj.PlanGuid = mPlan.PlanGuid__c.toLowerCase();
                                       system.debug('SetCurrent: ' + tobj.SubscriberId + ' ' + tobj.PlanGUID);
                                   }
                                newSubscriberGUIDToPlanGuid.put(mPlan.SubscriberID__c.toLowerCase(),mPlan.PlanGUID__c.toLowerCase());
                                counter++;
                            }
                        }
                    } else {
                        //this plan is not effective
                        expiredPlans.put(mplan.MemberCoverageGUID__c.toLowerCase(),mplan); 
                        system.debug('expired mplan: ' + mplan);
                    }
                }
            }
             
            //get plan group client wwIds
            Map<String,String> plantoGroupClient = new Map<String,String>();
            List<Account> allplans = (List<Account>)wmp_util_DAL.dalQuery('Account','WHERE guid__c in (\''+String.join(new List<String>(tobj.VisiblePlanIdSet),'\',\'')+'\') AND route_id__c in (\''+String.join(new List<String>(tobj.VisibleLob),'\',\'')+'\')');         
            for(Account acc : allplans){
                plantoGroupClient.put(acc.guid__c,acc.group_id__c + ';' + acc.client_id__c);
            }   
       
            for(string mp : tobj.MemberandPlanToGUId.keyset()){
                 if(MemberandPlanToGUId.get(mp)==null){
                     MemberandPlanToGUId.remove(mp);
                 }
            } 
            system.debug('contactMP: ' + tobj.ContactMemberPlans.size());
            //verified membersplans
            tobj.VerifiedMembersPlans = new Map<String,mock_MemberCoverage__c>();
            For(String MemberPlanGUID : tobj.MemberPlans.keyset()){
                    //verification record exists
                    tobj.VerifiedMembersPlans.put(MemberPlanGUID, tobj.MemberPlans.get(MemberPlanGUID));
                    String planID = tobj.MemberPlans.get(MemberPlanGUID).PlanGuid__c.toLowerCase();
                    tobj.VisiblePlanIdSet.add(planId);
            } 
            system.debug('verifiedMemberPans: ' + verifiedMembersPlans);
            //get plans
            system.debug('vis: ' + tobj.VisiblePlanIdSet);
            
            //use the visibleplanIdSet to remove plans not visible from plan configuration set and plan set
            
            
            //get  Primary dentists
            List<mock_MemberPrimaryCareDentist__c> primaries = wmp_util_DAL.getPrimaryDentists(new List<String>(VerifiedMembersPlans.keySet()));
            tobj.PrimaryDentists = new Map<String,mock_MemberPrimaryCareDentist__c>();
            List<String> providerGUIDs = new List<String>();
            List<String> serviceLocationGUIDs = new List<String>();
            //system.debug('primaries: ' + primaries);
            for(mock_MemberPrimaryCareDentist__c mpd : primaries){
            	SYstem.debug('mpd::'+mpd);
                tobj.PrimaryDentists.put(mpd.MemberCoverageGuid__c.toLowerCase(),mpd);
                providerGUIDs.add(mpd.ProviderGUID__c.toLowerCase());
                serviceLocationGUIDs.add(mpd.ServiceLocationGUID__c.toLowerCase());
                system.debug('slguids: ' + mpd.ServiceLocationGUID__c.toLowerCase());
            }
            
            //get providers
            tobj.Providers = new Map<String,Account>();
            if(providerGUIDS.size()>0){ 
                List<Account> provs = (List<Account>)wmp_util_DAL.dalQuery('Account','WHERE guid__c in (\''+String.join(providerGuids,'\',\'')+'\') AND route_id__c in (\''+String.join(new List<String>(tobj.VisibleLob),'\',\'')+'\')');          
                system.debug('provs: ' + provs.size());
                for(Account prov : provs){
                    system.debug('prov=: ' + prov.guid__c.toLowerCase());
                    tobj.Providers.put(prov.guid__c.toLowerCase(), prov);
                }   
            } 
            //get service loactions
            tobj.ServiceLocations = new Map<String,Providers_Service_locations__c>();
            if(serviceLocationGUIDs.size()>0){
                List<Providers_Service_locations__c> locs = (List<Providers_Service_locations__c>)Database.query('SELECT ' + wmp_util_DAL.fieldList('Providers_Service_Locations__c') +
                												',Service_Location__r.Name ' +
                												'FROM Providers_Service_Locations__c '+
               													 ' WHERE providerguid__c in (\''+String.join(new list<String>(tobj.providers.keyset()),'\',\'')+'\')  '+
               													 ' AND service_locationguid__c in (\''+String.join(serviceLocationGUIDs,'\',\'')+'\') AND route_id__c in (\''+String.join(new List<String>(tobj.VisibleLob),'\',\'')+'\')');         
                system.debug('locs: ' + locs.size()); 
                for(Providers_Service_locations__c loc : locs){
                    tobj.ServiceLocations.put(loc.providerguid__c.toLowerCase() + loc.service_locationguid__c.toLowerCase(), loc);
                }   
            }
            system.debug('2newMem: ' + newProfileMemberGuids);
            //get any new mock_Member__c records
            Map<String,mock_Member__c>   newMembers = wmp_util_DAL.getMembersMap(new List<String>(newProfileMemberGuids));
            system.debug('2newmm: ' + newMembers);
            if(newMembers.size()>0){
                for(String mcg :newMembers.keyset()){
                    tobj.Members.put(mcg.toLowerCase(),newMembers.get(mcg.toLowerCase()));
                }
            }
             
            //get member addresses
            tobj.MemberAddresses = new Map<String,Map<String,mock_MemberAddress__c>>();
            List<mock_MemberAddress__c> memAdds = wmp_util_DAL.getMemberAddresses(new List<String>(tobj.Members.keySet()));
            system.debug('adds: ' + memAdds);
            if(memAdds.size()>0){
                for(mock_MemberAddress__c memAdd : memAdds){
                    if(!tobj.MemberAddresses.containsKey(memAdd.MemberProfileGUID__c.toLowerCase()))
                        tobj.MemberAddresses.put(memAdd.MemberProfileGUID__c.toLowerCase(),new Map<String,mock_MemberAddress__c>());
                    tobj.MemberAddresses.get(memAdd.MemberProfileGUID__c.toLowerCase()).put(memAdd.MemberAddressGUID__c,memAdd);
                }
            }
            
            //get member accumulators
            tobj.MemberAccumulators = new Map<String,List<mock_MemberAccumulator__c>>();
            if(MemberPlans.size()>0){
                List<mock_MemberAccumulator__c>  memAccs = wmp_util_DAL.getMemberAccumulators(new list<String>(tobj.Members.keyset()));
                system.debug('memAccs: ' + memAccs);
                if(memAccs.size()>0){
                    for(mock_MemberAccumulator__c memAcc : memAccs){
                            if(!tobj.MemberAccumulators.containsKey(memAcc.MemberProfileGUID__c.toLowerCase()))
                                tobj.MemberAccumulators.put(memAcc.MemberProfileGUID__c.toLowerCase(),new List<mock_MemberAccumulator__c>());
                            tobj.MemberAccumulators.get(memAcc.MemberProfileGUID__c.toLowerCase()).add(memAcc);
                    }
                }
            }

            
            tobj.IsAvailable = true;
            system.debug('GetCacheCompleted!');
            system.debug('defaultMS: ' + tobj.subscriberId + ' ' + tobj.planguid);
            system.debug('MemberPLans: ' + tobj.MemberPlans);
        } catch (exception ex){
            tobj.IsAvailable = false;
            system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());           
            system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        }
        
        tobj.WriteToCache();
        system.debug('pwrite mplans: ' + MemberPlans);
        system.debug('IsCurrent: ' + SubscriberId + ' ' + PlanGUID);
    }
     
    
/* Cache Population method      **********************************************************/
    
/*******HELPER METHODS ***********/

    global static List<Map<String,String>> util_retrievePicklistValues(String picklistType, String language){
        //initialize thw var
        String portalLabel = wmp_util_Cache.cobj.PortalConfiguration.Label;
        List<Map<String,String>> picklistMap = new List<Map<String,String>>();
        
        for(Portal_Picklist__mdt pPicklist : [SELECT Label, English_Label__c, Spanish_Label__c, English_Description__c, Spanish_Description__c, Value__c, Order__c FROM Portal_Picklist__mdt WHERE Portal_Configuration__r.Label = :portalLabel AND Type__c =:picklistType ORDER BY Order__c ASC, English_Label__c ASC]){
            System.debug('pPicklist ::'+pPicklist );
            //picklistMap.put(pPicklist.Value__c, new List<String>());
            Map<String, String> pickMap = new Map<String, String>();
            pickMap.put('Value', pPicklist.Value__c);
            if(language == 'Spanish'){
                //picklistMap.get(pPicklist.Value__c).add( pPicklist.Spanish_Label__c );
                pickMap.put('Label', pPicklist.Spanish_Label__c);
                if(pPicklist.Spanish_Description__c != null)
                    pickMap.put('Description', pPicklist.Spanish_Description__c);
                    //picklistMap.get(pPicklist.Value__c).add( pPicklist.Spanish_Description__c );
            } else {
                pickMap.put('Label', pPicklist.English_Label__c);
                //picklistMap.get(pPicklist.Value__c).add( pPicklist.English_Label__c);
                if(pPicklist.English_Description__c != null)
                    pickMap.put('Description', pPicklist.English_Description__c);
                    //picklistMap.get(pPicklist.Value__c).add( pPicklist.English_Description__c);
                
            }
            picklistMap.add(pickMap);
        }
        
        return picklistMap;
    }
    
    @AuraEnabled 
    public static Map<String, String> retrieveMemberInfoLiveAgent(){
        //initialize the variables
        Map<String, String> key2ValueMap = new Map<String, String>();//map of the current member info and the portal info to the value
        Contact contactRec = wmp_util_Cache.ContactRec;
        Portal_Configuration__mdt portal = wmp_util_Cache.PortalConfiguration;
        
        //set the contact info for the case
        key2ValueMap.put('FirstName', contactRec.FirstName);
        key2ValueMap.put('LastName', contactRec.LastName);
        key2ValueMap.put('ContactId', contactRec.Id);
        key2ValueMap.put('AccountId', contactRec.AccountId);
        
        //portal information
        key2ValueMap.put('PortalName', portal.Label);
        if(UserInfo.getLanguage() == 'es')
            key2ValueMap.put('LiveChatId', portal.Spanish_Chat_Id__c);
        else//default to english
            key2ValueMap.put('LiveChatId', portal.Live_Agent_Chat_Id__c);
            
        key2ValueMap.put('RouteId', portal.RouteID__c);
        key2ValueMap.put('OrgId', UserInfo.getOrganizationId());
        key2ValueMap.put('LiveAgentInitId', portal.Live_Agent_Init__c);
        key2ValueMap.put('LiveAgentURL', portal.Live_Agent_Init_URL__c);
        
        //retrun the map
        return key2ValueMap;
    }
    
    @AuraEnabled
    public static Integer fetch_countOfOpenCases(){
        //to get all the related contacts
        Integer totalResults = 0;
        set<id> set_relatedContact = new Set<Id>();
        
        for(Id iterating_userPlanVerificationId : wmp_util_cache.MemberGuidToPlanVerification.values()){
            //every value is the id of the user plan verification
            if(wmp_util_cache.VerifiedPlans.containsKey(iterating_userPlanVerificationId)){
                //getting the member contacts ids from the same.
                if(wmp_util_cache.VerifiedPlans.get(iterating_userPlanVerificationId).Member_Contact__c != null)
                    set_relatedContact.add(wmp_util_cache.VerifiedPlans.get(iterating_userPlanVerificationId).Member_Contact__c);
            }
        }
        
        if(!set_relatedContact.isEmpty()){
            //now getting the total count
            totalResults                        = [SELECT 
                                                            COUNT()
                                                    FROM
                                                            CASE
                                                    WHERE
                                                            ContactId in:set_relatedContact AND (Status='New' OR Status='In-Progress')
                                                   ];
        }
        return totalResults;
    }
    
    @AuraEnabled
    public static String                        getCaseRTID(String recordTypeName){
        String result = null;
        List<RecordType> rts = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName];
        if(rts.size()>0)
            result = rts[0].Id;
        return result;
    }
    
    //get portal plans -- a list of planGUIDS associated ot the planConfigurations available in the portal
    @AuraEnabled
    public static List<String>                  getPortalPlanList(){
        list<String> result = new List<String>();
        List<Plan_Configuration__mdt> planConfigs = [SELECT DeveloperName, Plan_Account_Id__c 
                                                    FROM Plan_Configuration__mdt 
                                                    WHERE Portal_Configuration__c = :PortalConfiguration.Id];
        system.debug('pconfigs: ' + ' ' + PortalConfiguration.Id + planConfigs);
        if(planConfigs.size()>0){
            List<String> accIds = new List<String>();
            for(Plan_Configuration__mdt pc : planConfigs){
                if(pc.Plan_Account_Id__c!=null)
                    accIds.add(pc.Plan_Account_Id__c);
            }
            List<Account> accs = [SELECT ID, guid__c FROM Account WHERE guid__c in :accIds OR id in :accIds];
            if(accs.size()>0){
                for(Account a : accs){
                    if(a.guid__c!=null)
                        result.add(a.guid__c);
                }
            }
        }
        return result;
    }
/*******HELPER METHODS ***********/

}