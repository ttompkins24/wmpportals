/**********************************************************************************************************************
Name                        :   wmp_wrap_Member
Purpose                     :   The class that fetches and stores the values from the member
Created on                  :   1/01/2018
Developed by                :   Todd Tompkins
History
Version#    Sprint#     Date            by                   Comments
1.1         5.0         01/01/2018      Todd Tompkins       

**********************************************************************************************************************/
/*
Parameters it can take:
Sub Id + planId
mem profile guid
mem cov guid

*/

public without sharing class prov_wrap_Member {
    /******************************************************************************
    ********************************INSTANCE/Params ENTERED METHOD**********************************
    *******************************************************************************/
      
    @AuraEnabled
    public String memberProfileGuid  {get;set;}
    @AuraEnabled
    public String universalMemberId  {get;set;}
    @AuraEnabled
    public  String memberCoverageGuid {get;set;}
    
    @AuraEnabled
    public  String serviceLocationGuid {get;set;}
    @AuraEnabled
    public  String providerGuid {get;set;}
    @AuraEnabled
    public  Date serviceDate{get;set;}
    
    
    /******************************************************************************
    ********************************INSTANCE VARIABLES METHOD**********************************
    *******************************************************************************/
    @AuraEnabled
    public  String subscriberId {get;set;}
    @AuraEnabled
    public  String planGuid {get;set;}
    @AuraEnabled
    public  String isEligible {get;set;}
    @AuraEnabled
    public  String eligibilityStatus {get;set;}
    
    //was the member found?
    @AuraEnabled
    public  Boolean isFound {get;set;}
    //has the member data been fetched
    @AuraEnabled
    public  Boolean isFetched {get;set;}

    @AuraEnabled
    public  String currentPlanGuid {get;set;}

    @AuraEnabled
    public  Account currentPlan {get;set;}

    @AuraEnabled
    public  String currentMemCovGuid {get;set;}

    @AuraEnabled
    public  mock_MemberCoverage__c currentMemCov {get;set;}
    
    @AuraEnabled
    public  Map<String, Account> planGuid2PlanMap {get;set;}
    //Map of the plan guid to its accumulators

    @AuraEnabled
    public  List<mock_MemberAddress__c> currentMemAddresses {get;set;}
    
    @AuraEnabled
    public  List<mock_MemberPhone__c>  currentMemPhones {get;set;}

    @AuraEnabled
    public  Map<String,Plans_Networks__c> planGuid2PlanNetwork {get;set;}
    
    @AuraEnabled
    public  List<Plans_Networks__c> networks {get;set;}
    
    @AuraEnabled public Account pcdServiceLocation { get; set; }
    @AuraEnabled public Account pcdProvider { get; set; }
    @AuraEnabled public Account serviceLocationSelected { get; set; }
    @AuraEnabled public Account providerSelected { get; set; }


    @AuraEnabled
    public Boolean fetchOverview {get;set;}
    
    @AuraEnabled
    public mock_MemberPrimaryCareDentist__c PCD {get;set;}
    
   
    
    @AuraEnabled
    public List<mock_MemberCOB__c> COBList{get;set;}
    
    public  Set<String> memProfileGuids {get{
        return memProfileGuids;
    }set;}
    
    
    
    @AuraEnabled
    public  mock_Member__c member {get;set;}
    
     @AuraEnabled
    public  Map<String,mock_Member__c> memberMap {get;set;}
    
    @AuraEnabled
    public Map<String, mock_MemberCoverage__c> planGuid2MemCovMap {get;set;}
    
    /******************************************************************************
    ********************************END INSTANCE VARIABLES METHOD**********************************
    *******************************************************************************/
    
    public prov_wrap_Member(){
        planGuid2MemCovMap = new Map<String, mock_MemberCoverage__c> ();
    }
    
    /******************************************************************************
    ********************************INIT METHOD**********************************
    *******************************************************************************/
    public void fetchMemberData2(){
        System.debug('START fetchMemberData2.............');
        Integer ct = 0;
        isFetched = false;
        isFound = false;
        fetchOverview = false;
        planGuid2PlanMap = new Map<String, Account>();
        Set<String> planGuidSet = new Set<String>();
        Map<String,String> mpguidProfileGuid = new Map<String,String>();
        //memberMap = new Map<String, mock_Member__c>();
        memProfileGuids = new Set<String>();
        try{ 
            System.debug('serviceDate::'+serviceDate);
            List<mock_MemberCoverage__c> memCovList = prov_util_DAL.memberDetail_memCov(UniversalMemberId, memberProfileGuid, serviceDate );
            
            if(memCovList.size() == 0) return;
            integer whileCT = 0;
            while(memCovList[memCovList.size()-1].TerminationDate__c == null && whileCT < 10 && memCovList.size() > 1 ){
                mock_MemberCoverage__c mCov = memCovList.remove(memCovList.size()-1);
                memCovList.add(0, mCov);
                whileCT ++;
            }
            for(mock_MemberCoverage__c memCov : memCovList){
                System.debug('memCov::'+memCov);
                if( serviceDate < memCov.EffectiveDate__c) continue;
                System.debug('mem cov is effective date is less than service date');
                System.debug('effectiveDate::'+(memCov.EffectiveDate__c <= serviceDate ));
                System.debug('expiration date::'+ (serviceDate <= memCov.TerminationDate__c));
                if( (memCov.EffectiveDate__c <= serviceDate &&  (serviceDate <= memCov.TerminationDate__c || memCov.TerminationDate__c == null)) || ct == 0 ){
                    System.debug('plan is in range');
                    
                    if(!planGuid2MemCovMap.containsKey( memCov.PlanGUid__c.toLowerCase() )){
                        memProfileGuids.add(memCov.MemberProfileGuid__c);
                        planGuid2MemCovMap.put(memCov.PlanGUid__c.toLowerCase(), memCov);
                        planGuidSet.add(memCov.PlanGUid__c);
                        
                        System.debug('planGuid::'+planGuid);
                        Boolean isPlanGuidSameAsCurrentPlan = planGuid != null ? planGuid.toLowerCase() == memCov.PlanGUid__c.toLowerCase(): false;
                        System.debug('isPlanGuidSameAsCurrentPlan::'+isPlanGuidSameAsCurrentPlan);
                        //if this is the first time in set the default values
                        if(currentPlanGuid == null || isPlanGuidSameAsCurrentPlan){
                            //set the default plan guid if blank
                            currentPlanGuid = memCov.PlanGuid__c.tolowercase();
                            
                            member = new mock_Member__c(FirstName__c = memCov.FirstName__c, LastName__c= memCov.LastName__c, Birthdate__c = memCov.Birthdate__c, 
                                            Gender__c = memCov.Gender__c, UniversalMemberGUID__c = memCov.UniversalMemberGUID__c, 
                                            MemberProfileGUID__c = memCov.MemberProfileGUID__c,  RouteID__c = memCov.RouteId__c);
                        }                   
                       
                        ct++;
                    }
                }  else if(memCov.EffectiveDate__c <= serviceDate &&  (serviceDate <= memCov.TerminationDate__c || memCov.TerminationDate__c == null)){
                    planGuid2MemCovMap.put(memCov.PlanGUid__c.toLowerCase(), memCov);
                    memProfileGuids.add(memCov.MemberProfileGuid__c);
                }
                
            }
            System.debug('COMPLETED MEM COV LOOPS::'+planGuid2MemCovMap.values());
            //query for the networks
            networks = [SELECT Id, Name, Network__r.Name, Plan__r.Name, Plan__r.guid__c FROM Plans_Networks__c WHERE Plan__r.guid__c IN: planGuidSet];
 
            planGuid2PlanNetwork = new Map<String,Plans_Networks__c>();
            for(Plans_Networks__c network : networks) {
                planGuid2PlanNetwork.put(network.Plan__r.guid__c.tolowercase(), network);
            }
            
            //query for the plans
            for(Account plan : prov_util_DAL.getAccounts(planGuidSet)){
                planGuid2PlanMap.put( plan.guid__c.toLowercase(), plan );
            }
        } catch (Exception ex){
            SYstem.debug('****************************');
            SYstem.debug('Error::'+ex.getMessage());
            SYstem.debug('stack trace::' +ex.getStackTraceString());
            SYstem.debug('****************************');
        } 
        System.debug('END fetchMemberData2.............');
    }
    public void fetchMemberData(){
        //initialize the fields
        isFetched = false;
        isFound = false;
        fetchOverview = false;
        planGuid2PlanMap = new Map<String, Account>();
        Set<String> planGuidSet = new Set<String>();
        Map<String,String> mpguidProfileGuid = new Map<String,String>();
        memberMap = new Map<String, mock_Member__c>();
        System.debug('Entering fetchMemberData...');
        
        try{
            if(memberProfileGuid != null){
                fetchMemberData_memProfile();
            } else if(memberCoverageGuid != null){
                fetchMemberData_memCov();
            }
            System.debug('looping through mem coverage records');
            
            //check to see if the member has been found. if false, return/exit method
            if(!isFound)return;
                
            //loop through the member coverage records and store what you need
            //storing the plan guids that they are part of
            memProfileGuids = new Set<String>();
            for(mock_MemberCoverage__c memCov : memCovGuid2MemCovMap.values()){
                planGuidSet.add(memCov.planGuid__c);
                mpguidProfileGuid.put(memCov.MemberCoverageGuid__c.tolowercase(), memCov.MemberProfileGuid__c.tolowercase());
                memProfileGuids.add(memCov.MemberProfileGuid__c.tolowercase());
                if(currentPlanGuid == null){
                    currentPlanGuid = memCov.PlanGuid__c.tolowercase();
                    currentMemCovGuid = memCov.MemberCoverageGuid__c.tolowercase();
                }
                memberMap.put(memCov.MemberProfileGuid__c.tolowercase(), 
                            new mock_Member__c(FirstName__c = memCov.FirstName__c, LastName__c= memCov.LastName__c, Birthdate__c = memCov.Birthdate__c, Gender__c = memCov.Gender__c,
                            MemberProfileGUID__c = memCov.MemberProfileGUID__c,  RouteID__c = memCov.RouteId__c, UniversalMemberGUID__c = memCov.UniversalMemberGUID__c));
            }   
            System.debug('memberMap::'+memberMap);
            
            
            networks = [SELECT Id, Name, Network__r.Name, Plan__r.Name, Plan__r.guid__c FROM Plans_Networks__c WHERE Plan__r.guid__c IN: planGuidSet];
 
            planGuid2PlanNetwork = new Map<String,Plans_Networks__c>();
            for(Plans_Networks__c network : networks) {
                planGuid2PlanNetwork.put(network.Plan__r.guid__c, network);
            }

            System.debug('serviceLocationGuid::'+serviceLocationGuid);
            System.debug('providerGuid::'+providerGuid);
            if(serviceLocationGuid != NULL && providerGuid != NULL) {
                //String whereClause = 'WHERE ServiceLocationGUID__c = \'' + serviceLocationGuid + '\'';
                //whereClause += ' AND ProviderGUID__c = \'' + providerGuid + '\'';

                //List<MemberPrimaryCareDentist__x> PCDList = (List<MemberPrimaryCareDentist__x>)(prov_util_DAL.dalQuery('MemberPrimaryCareDentist__x', whereClause));
                //if(PCDList.size() > 0) PCD = PCDList[0]; 

                Set<String> windwardGuids = new Set<String>();
                windwardGuids.add(serviceLocationGuid);
                windwardGuids.add(providerGuid);
                List<Account> accounts = prov_util_DAL.getAccounts(windwardGuids);

                for(Account acc : accounts) {
                    if(acc.guid__c == serviceLocationGuid) {
                        pcdServiceLocation = acc;
                    } else if(acc.guid__c == providerGuid) {
                        pcdProvider = acc;
                    }
                }
            }
        
            //query for the plans
            for(Account plan : prov_util_DAL.getAccounts(planGuidSet)){
                planGuid2PlanMap.put( plan.guid__c.toLowercase(), plan );
            }
        } catch(Exception ex){
            system.debug('----------------------------------------------------------');
            system.debug(ex.getMessage());
            system.debug(ex.getLineNumber());
            system.debug(ex.getStackTraceString());
            system.debug('----------------------------------------------------------');
        }
    }

    @AuraEnabled
    public Map<String, mock_MemberCoverage__c> memCovGuid2MemCovMap {get;set;}
    /******************************************************************************
    ********************************HELPER METHOD**********************************
    *******************************************************************************/
    
    /******************************************************************************
    ********************************RETRIEVE THE MEMBER PLAN METHODS***************
    *******************************************************************************/
    public  void fetchMemberData_memProfile(){
        System.debug('Entering fetchMemberData_memProfile...');
        memCovGuid2MemCovMap = prov_util_DAL.getMembersPlansMapByProfile(memberProfileGuid);
        System.debug('retrieved mem coverage records::'+memCovGuid2MemCovMap.keyset());
        if(memCovGuid2MemCovMap.keyset().size() > 0){
            isFound = true;
        }
        isFetched = true;
        System.debug('isfetched is true');  
    }
    
    public  void fetchMemberData_memCov(){
        memCovGuid2MemCovMap = prov_util_DAL.getMembersPlansMap(memberCoverageGuid);
        //check to see if any records were found
        if(memCovGuid2MemCovMap.keyset().size() > 0){
            isFound = true;
        }
        isFetched = true;
    }
    
    /********************************************************************************
    ********************************END HELPER METHOD**********************************
    *******************************************************************************/
}