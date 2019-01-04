/**********************************************************************************************************************
Name                        :   prov_util_DAL
Purpose                     :   The utility that will contain Helper methods to access member and provider data
Created on                  :   01/1/2018
Developed by                :   Todd Tompkins
History
Version#    Sprint#     Date            by                   Comments
1.0         1.0         01/1/2018      WMP

**********************************************************************************************************************/
global without sharing class prov_util_DAL {
    /* UserSecurity methods     **********************************************************/
    global static   List<String>                                    VisibleLOB                              { 
        get{
            if(prov_util_Cache.VisibleLOB!=null && prov_util_Cache.VisibleLOB.size()>0){
                return new List<String>(prov_util_Cache.VisibleLOB);
            } else {
                return new List<String>{'GOV'};
                //return new List<String>{'GOV','EMBLEM','GOV_MH','COM_DELTA'};
            }
        }
    }                               
    /* UserSecurity methods     **********************************************************/
    /* Account methods     **********************************************************/
    
    global static List<Account>                                         getAccounts(Set<String> Guids){
        //if list is empty or null return empty list
        if(Guids == null || Guids.size() == 0) return new List<Account>();
        return (List<Account>) dalQuery('Account',
                ' WHERE guid__c IN (\''+String.join(new List<String>(Guids),'\',\'')+'\') AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY Name ASC');
    }
      
    global static Map<String, Account>                                      getAccountWWMap(Set<String> windwardGuids){
        //if list is empty or null return empty list
        if(windwardGuids == null || windwardGuids.size() == 0) return new Map<String, Account> ();
        Map<String, Account> wwid2AccountMap = new Map<String, Account>();
        
        for(Account acc : (List<Account>) dalQuery('Account',
                ' WHERE guid__c IN (\''+String.join(new List<String>(windwardGuids),'\',\'')+'\') AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY Name ASC')){
            wwid2AccountMap.put( acc.guid__c.toLowercase(), acc );
        }
        return wwid2AccountMap;
    }

    global static List<Account>                                         getAccountsById(Set<String> salesforceIds){
        //if list is empty or null return empty list
        if(salesforceIds == null || salesforceIds.size() == 0) return new List<Account>();
        return (List<Account>) dalQuery('Account',
                ' WHERE Id IN (\''+String.join(new List<String>(salesforceIds),'\',\'')+'\') AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY Name ASC');
    }
    
      
    global static Map<String, Account>                                      getAccountSFMap(Set<String> salesforceIds){
        //if list is empty or null return empty list
        if(salesforceIds == null || salesforceIds.size() == 0) return new Map<String, Account> ();
        return new Map<String, Account>( (List<Account>)dalQuery('Account',
                ' WHERE Id IN (\''+String.join(new List<String>(salesforceIds),'\',\'')+'\') AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY Name ASC'));
    }

     //this method gets a Map of Accounts where the Key is the winward guid
    global static Map<String, Account> getPlansByPlanId(Set<String> planGuids){
        //if list is empty or null return empty list
        if(planGuids == null || planGuids.size() == 0) return new Map<String, Account>();

        List<Account> plans = (List<Account>) dalQuery('Account',
                ' WHERE guid__c IN (\''+String.join(new List<String>(planGuids),'\',\'')+'\') AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\')');

        //put into map
        Map<String,Account> mPlans = new Map<String,Account>();
        for(Account a : plans){
            mPlans.put(a.guid__c.toLowerCase(),a);
        }
        
        return mPlans;

    }

    
    /* Account methods     **********************************************************/
    
    /* MembersPlans methods     **********************************************************/
    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object by MemberCoverageGuid__c
    global static   Map<String,mock_MemberCoverage__c>                       getMembersPlansMapByProfile(String profileMemberGuid){
        List<mock_MemberCoverage__c> mPlans = null;
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
            'WHERE MemberProfileGUID__c = \'' + profileMemberGuid +'\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY EffectiveDate__c DESC');
        Map<String,mock_MemberCoverage__c> result = new Map<String,mock_MemberCoverage__c>();
        for(mock_MemberCoverage__c mp : mPlans){
            result.put(mp.MemberCoverageGuid__c.toLowerCase(),mp);
        }
        return result;
    }
    
    global static List<mock_MemberCoverage__c>                               memberDetail_memCov(String universalId, String memberProfileId){
        String whereClause = ' WHERE ';
        
        if(universalId != '' && universalId != null){
            whereClause += ' UniversalMemberGUID__c=\''+ universalId + '\' AND ';
        }
        
        if(memberProfileId != '' && memberProfileId != null){
            whereClause += ' MemberProfileGUID__c=\''+ memberProfileId + '\' AND ';
            
        }
        
        whereClause +=  ' RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY TerminationDate__c DESC NULLS FIRST  ';
        return (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', whereClause); 
    }
    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object by MemberCoverageGuid__c
    global static   Map<String,mock_MemberCoverage__c>                       getMembersPlansMapByProfile(String profileMemberGuid, List<String> availablePlans){
        List<mock_MemberCoverage__c> mPlans = null;
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
            'WHERE MemberProfileGUID__c = \'' + profileMemberGuid +'\' AND PlanGuid__c in (\''+String.join(availablePlans,'\',\'')+'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY EffectiveDate__c DESC');
        Map<String,mock_MemberCoverage__c> result = new Map<String,mock_MemberCoverage__c>();
        for(mock_MemberCoverage__c mp : mPlans){
            result.put(mp.MemberCoverageGuid__c.toLowerCase(),mp);
        }
        return result;
    }
    
    // method used by the provider portal member detail page
    global static List<mock_MemberCoverage__c>                               memberDetail_memCov(String universalId, String memberProfileId, Date serviceDate){
        //initialize the where clause
        String whereClause = ' WHERE ';
        
        //add universal id to query if not blank
        if(universalId != '' && universalId != null){
            whereClause += ' UniversalMemberGUID__c=\''+ universalId + '\' AND ';
        }
        
        //add member profile guid to query if not blank
        if(memberProfileId != '' && memberProfileId != null){
            whereClause += ' MemberProfileGUID__c=\''+ memberProfileId + '\' AND ';
            
        }
        if(serviceDate != null){
            String dateStr = DateTime.newInstance(serviceDate.year(),serviceDate.month(),serviceDate.day()).format('yyyy-MM-dd');
            whereClause += ' EffectiveDate__c <= ' + dateStr + ' AND ';
            
            
        }
        
        whereClause +=  ' RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY TerminationDate__c DESC NULLS FIRST ';
        return (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', whereClause); 
    }
    
    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object by MemberCoverageGuid__c
    global static   Map<String,mock_MemberCoverage__c>                       getMembersPlansMapByProfile(List<String> profileMemberGuids){
        List<mock_MemberCoverage__c> mPlans = null;
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
            'WHERE MemberProfileGUID__c in (\'' + String.join(profileMemberGuids,'\',\'') +'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY EffectiveDate__c DESC');
        Map<String,mock_MemberCoverage__c> result = new Map<String,mock_MemberCoverage__c>();
        for(mock_MemberCoverage__c mp : mPlans){
            result.put(mp.MemberCoverageGuid__c.toLowerCase(),mp);
        }
        return result;
    }
    
    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object by MemberCoverageGuid__c
    global static   Map<String,mock_MemberCoverage__c>                       getMembersPlansMap(String memberplanGUID){
        List<mock_MemberCoverage__c> mPlans = null;
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
            'WHERE MemberCoverageGuid__c = \'' + memberplanGUID +'\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY EffectiveDate__c DESC');
        Map<String,mock_MemberCoverage__c> result = new Map<String,mock_MemberCoverage__c>();
        for(mock_MemberCoverage__c mp : mPlans){
            result.put(mp.MemberCoverageGuid__c.toLowerCase(),mp);
        }
        return result;
    }
    
    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object by subscriberId and planID
    global static   Map<String,mock_MemberCoverage__c>                       getMembersPlansMap(String memberId, String planId){
        List<mock_MemberCoverage__c> mPlans = null;
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
            'WHERE SubscriberID__c = \'' +  memberId + '\' AND PlanGUID__c = \'' +  planId + '\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY EffectiveDate__c DESC');
        Map<String,mock_MemberCoverage__c> result = new Map<String,mock_MemberCoverage__c>();
        for(mock_MemberCoverage__c mp : mPlans){
            result.put(mp.MemberCoverageGuid__c.toLowerCase(),mp);
        }
        return result;
    }
    
    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object by subscriberId and list of  planIDs
    global static   Map<String,mock_MemberCoverage__c>                       getMembersPlansMap(String memberId, List<String> planIds){
        List<mock_MemberCoverage__c> mPlans = null;
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
            'WHERE SubscriberID__c = \'' + memberId + '\' AND PlanGUID__c in (\''+String.join(planIds,'\',\'')+'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY EffectiveDate__c DESC');
        Map<String,mock_MemberCoverage__c> result = new Map<String,mock_MemberCoverage__c>();
        for(mock_MemberCoverage__c mp : mPlans){
            result.put(mp.MemberCoverageGuid__c.toLowerCase(),mp);
        }
        return result;
    }
    
    //returns a list of MemberCoverageGuid__c by list of SubscriberIdGUIDS 
    global static   List<mock_MemberCoverage__c>                         getMembersPlans(List<String> subPlans){
            list<String> subIds = new List<String>();
            list<String> planIds = new List<String>();
            for(string sp : subplans){
                if(sp.contains(';')){
                    system.debug('sp: ' + sp + ' '  + sp.length());
                    subIds.add(sp.split(';')[0]);
                    planIds.add(sp.split(';')[1]);
                }
            }
            return (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
                'WHERE SubscriberId__c in (\''+String.join(subIds,'\',\'')+'\') AND PlanGUID__c in (\''+String.join(planIds,'\',\'')+'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY EffectiveDate__c DESC');
    }
    
    //returns a list of MemberCoverageGuid__c by subscriberId and planguids 
    global static   Map<String,mock_MemberCoverage__c>                           getMembersPlansBySubscriber(String subscriberId, List<String> planGuidSet){
        List<mock_MemberCoverage__c> mPlans = null;
        //mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
                //'WHERE PlanGUID__c IN (\''+String.join(planGuidSet,'\',\'')+'\') AND (SubscriberID__c = \'' + subscriberId + '\' OR MedicaidID__c = \'' + subscriberId + '\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ');
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
                'WHERE PlanGUID__c IN (\''+String.join(planGuidSet,'\',\'')+'\') AND (SubscriberID__c = \'' + subscriberId + '\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY TerminationDate__c DESC');
        
        Map<String,mock_MemberCoverage__c> result = new Map<String,mock_MemberCoverage__c>();
        for(mock_MemberCoverage__c mp : mPlans){
            result.put(mp.MemberCoverageGuid__c.toLowerCase(),mp);
        }
        return result;
    }
    
    //returns a list of active MemberCoverageGuid__c by subscriberID  
    global static   List<mock_MemberCoverage__c>                           getMembersCovsBySubscriberID(String subscriberId){
        List<mock_MemberCoverage__c> mPlans = null;
        String whereClause = 'WHERE (SubscriberID__c = \'' + subscriberId + '\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY EffectiveDate__c DESC';
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', whereClause);
        
        return mPlans;
    }

    //returns a list of active MemberCoverageGuid__c by subscriberID  
    global static   Map<String,mock_MemberCoverage__c>                           getMembersPlansBySubscriberID(String subscriberId, String routeId){
        List<mock_MemberCoverage__c> mPlans = null;
        //String whereClause = 'WHERE (SubscriberID__c = \'' + subscriberId + '\' OR MedicaidID__c = \'' + subscriberId + '\')';
        String whereClause = 'WHERE (SubscriberID__c = \'' + subscriberId + '\')';
        whereClause += ' AND RouteID__c = \'' + routeId + '\' ORDER BY EffectiveDate__c DESC';
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', whereClause);
        Map<String,mock_MemberCoverage__c> result = new Map<String,mock_MemberCoverage__c>();
        for(mock_MemberCoverage__c mp : mPlans){
            result.put(mp.MemberCoverageGuid__c.toLowerCase(),mp);
        }
        return result;
    }
    
    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object by list of MemberCoverageGuid__c
    global static   Map<String,mock_MemberCoverage__c>                       getMembersPlansMap(List<String> memberPlanGUIDs){
        List<mock_MemberCoverage__c> mPlans = null;
            mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', 
                'WHERE MemberCoverageGuid__c in (\''+String.join(memberPlanGUIDs,'\',\'')+'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY EffectiveDate__c DESC');
        Map<String,mock_MemberCoverage__c> result = new Map<String,mock_MemberCoverage__c>();
        for(mock_MemberCoverage__c mp : mPlans){
            result.put(mp.MemberCoverageGuid__c.toLowerCase(),mp);
        }
        return result;
    }

    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object 
    public static List<mock_MemberCoverage__c>                               getMemberCoverageByNameBirthdateMemberNumber(List<Prov_ctrl_MemberEligibility.MemberWrapper> memberList, String businessId){
        
        //get all plans a business can see
        //Set<String> plans = prov_util_cache.getVisibilePlanWWIds(businessId);
        //System.debug('plans ' + plans);

        List<mock_MemberCoverage__c> mPlans = null;

        String whereClause = 'WHERE ( ';
        for(Prov_ctrl_MemberEligibility.MemberWrapper mem : memberList) {
            //add birthday
            whereClause += ' (Birthdate__c = ' + mem.birthDate.Year() + '-' + String.valueOf(mem.birthDate.Month()).leftPad(2,'0') + '-' + String.valueOf(mem.birthDate.Day()).leftPad(2,'0');  

            //add first name if populated
            if(mem.firstName != '' && mem.firstName != null){
                whereClause += ' AND FirstName__c LIKE \'' + String.escapeSingleQuotes(mem.firstName) + '%\'';      
            }
            //add last name if populated
            if(mem.lastName != '' && mem.lastName != null){
                whereClause += ' AND LastName__c LIKE \'' + String.escapeSingleQuotes(mem.lastName) + '%\'';  
            }
            //add subscriberID if populated
            if(mem.memberNumber != '' && mem.memberNumber != null){
                whereClause += ' AND SubscriberID__c = \'' + String.escapeSingleQuotes(mem.memberNumber) + '\'';  
            }
            whereClause += ') OR ';  
        }
        //delete final OR
        whereClause = whereClause.substring(0, whereClause.length()-3);

        //add plan guids
        //whereClause += ') AND PlanGUID__c IN  (\''+String.join(new List<String>(plans),'\',\'')+'\')';
        whereClause += ') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY LastName__c';
        //whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY TerminationDate__c Desc Nulls first';

        System.debug('whereClause ' + whereClause );

        //run query
        mPlans = (List<mock_MemberCoverage__c>)dalQuery('mock_MemberCoverage__c', whereClause); 
        
        return mPlans;
    }

    

    /* MembersPlans methods     **********************************************************/

    /* Member Guardian methods      **********************************************************/
    //returns a map of profileMemberGuids to mock_Member__c objects by list of profileMemberGUID
    global static   Map<String,List<mock_MemberGuardian__c>>                         getMemberGuardianMap(List<String> memberProfileGUIDs){
        List<mock_MemberGuardian__c> memberGuardians = null;
            memberGuardians = (List<mock_MemberGuardian__c>)dalQuery('mock_MemberGuardian__c', 
                    'WHERE MemberProfileGUID__c in (\''+String.join(memberProfileGUIDs,'\',\'')+'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ');
        
        Map<String,List<mock_MemberGuardian__c>> result = new Map<string,List<mock_MemberGuardian__c>>();
        for(mock_MemberGuardian__c guardian : memberGuardians){
            if(result.containsKey(guardian.MemberProfileGUID__c)){
                result.get(guardian.MemberProfileGUID__c.toLowerCase()).add(guardian);
            }else {
                result.put(guardian.MemberProfileGUID__c.toLowerCase(),new List<mock_MemberGuardian__c>{guardian});
            }
        }
        return result;
    }
    /* Member Guardian methods      **********************************************************/

    /* Members methods      **********************************************************/
    //returns a map of profileMemberGuids to mock_Member__c objects by profileMemberGUID
    global static   List<mock_Member__c>                             getMembers(String profileMemberGUID){
            return (List<mock_Member__c>)dalQuery('mock_Member__c', 
                'WHERE MemberProfileGUID__c = \'' + profileMemberGUID + '\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY UniversalMemberGuid__c');
    }
    
    //returns a map of profileMemberGuids to mock_Member__c objects by profileMemberGUID
    global static   Map<String,mock_Member__c>                           getMembersMap(String profileMemberGUID){
        List<mock_Member__c> members = null;
            members = (List<mock_Member__c>)dalQuery('mock_Member__c', 
                    'WHERE MemberProfileGUID__c = \'' + profileMemberGUID + '\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY UniversalMemberGuid__c');
        Map<String,mock_Member__c> result = new Map<String,mock_Member__c>();
        for(mock_Member__c mem : members){
            result.put(mem.MemberProfileGUID__c.toLowerCase(),mem);
        }
        return result;
    }
     
    //returns a map of profileMemberGuids to mock_Member__c objects by list of profileMemberGUID
    global static   Map<String,mock_Member__c>                           getMembersMap(List<String> profileMemberGUIDs){
        List<mock_Member__c> members = null;
            members = (List<mock_Member__c>)dalQuery('mock_Member__c', 
                    'WHERE MemberProfileGUID__c in (\''+String.join(profileMemberGUIDs,'\',\'')+'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY UniversalMemberGuid__c');
        
        Map<String,mock_Member__c> result = new Map<string,mock_Member__c>();
        for(mock_Member__c mem : members){
            result.put(mem.MemberProfileGUID__c.toLowerCase(),mem);
        }
        return result;
    }
    
    //returns a map of profileMemberGuids to mock_Member__c objects by list of profileMemberGUID, Firstname, LastName and Birthdate
    global static   Map<String,mock_Member__c>                           getMembersMap(List<String> profileMemberGUIDs, String firstName, String lastName, Date birthdate, String routeId){
        List<mock_Member__c> members = null;
        String whereClause = 'WHERE MemberProfileGUID__c in (\''+String.join(profileMemberGUIDs,'\',\'')+'\')';
        whereClause += ' AND FirstName__c = \'' + firstName + '\'';
        whereClause += ' AND LastName__c = \'' + lastName + '\'';
        String dateString = birthdate.year() + '-' + string.valueOf(birthdate.month()).leftPad(2,'0') + '-' + string.valueOf(birthdate.day()).leftPad(2,'0');
        whereClause += ' AND BirthDate__c = ' + dateString;
        whereClause += ' AND RouteID__c = \'' + routeId + '\' ORDER BY UniversalMemberGuid__c';
        members = (List<mock_Member__c>)dalQuery('mock_Member__c', whereClause);
        Map<String,mock_Member__c> result = new Map<string,mock_Member__c>();
        for(mock_Member__c mem : members){
            result.put(mem.MemberProfileGUID__c.toLowerCase(),mem);
        }
        return result;
    }
    /* Members methods      **********************************************************/
    
    /* Members Universal History methods        **********************************************************/
    //returns a map of UniversalMemberGUID__c to MembersUniversalHistory__x objects by UniversalMemberGUIDs
    global static   Map<String,mock_MemberUniversalID__c>                            getMemberHistoryMap(List<String> UniversalMemberGUIDs){
        List<mock_MemberUniversalID__c> members = null;
        members = (List<mock_MemberUniversalID__c>)dalQuery('mock_MemberUniversalID__c', 
                    'WHERE UniversalMemberGUID__c in (\''+String.join(UniversalMemberGUIDs,'\',\'')+'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY UniversalMemberGUID__c DESC');
        Map<String,mock_MemberUniversalID__c> result = new Map<String,mock_MemberUniversalID__c>();
        for(mock_MemberUniversalID__c memhist : members){
            result.put(memhist.UniversalMemberGUID__c.toLowerCase(),memhist);
        }
        return result;
    }
    
    /* Members Universal History methods        **********************************************************/
    
    /* Members Service History methods      **********************************************************/
    //return the member addresses based on the memberProfileGuid
    global static   List<mock_MembersServiceHistory__c>                                  getMemberServiceHistory(List<String> memberProfileGuids, List<String> planGuids){
        List<mock_MembersServiceHistory__c> memberHistory = new List<mock_MembersServiceHistory__c>();
        if((memberProfileGuids == null || memberProfileGuids.size() == 0) && (planGuids == null || planGuids.size() == 0)) return memberHistory;
        //return an empty list since parameters a
        String memberProfileWhereClause;
        String planGuidWhereClause ;
        
        if(memberProfileGuids != null && memberProfileGuids.size() != 0) {
            //create the where clause for Member Profile Guid to make it case insensitive
            memberProfileWhereClause = ' ( ';
            for(String memGuid : memberProfileGuids){
                memberProfileWhereClause += ' MemberProfileGUID__c LIKE \'' + memGuid + '\' OR ';  
            }
            memberProfileWhereClause = memberProfileWhereClause.substring(0, memberProfileWhereClause.length()-4);
            memberProfileWhereClause += ') AND ';
        }
        planGuidWhereClause = '';
        //disabled as part of member change fix 
        if(false && planGuids != null && planGuids.size() != 0) {
            //create the where clause for Member Profile Guid to make it case insensitive
            planGuidWhereClause += ' ( ';
            for(String planGuid : planGuids){
                planGuidWhereClause += ' PlanGUID__c LIKE \'' + planGuid + '\' OR ';  
            }
            planGuidWhereClause = planGuidWhereClause.substring(0, planGuidWhereClause.length()-4);
            planGuidWhereClause += ') AND ';
        }
        
        memberHistory = (List<mock_MembersServiceHistory__c>)dalQuery('mock_MembersServiceHistory__c', 
                    'WHERE ' + memberProfileWhereClause + planGuidWhereClause +'RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY ProcedureDate__c DESC');
        System.debug('memberHistory::'+memberHistory);
        return memberHistory;
    }
    global static   List<mock_MembersServiceHistory__c>                                  getMemberServiceHistory_MemDetail(List<String> memberProfileGuids, List<String> planGuids, INteger pageNum, Integer numResults, String sortByField , String sortDirection){
        List<mock_MembersServiceHistory__c> memberHistory = new List<mock_MembersServiceHistory__c>();
        if((memberProfileGuids == null || memberProfileGuids.size() == 0) && (planGuids == null || planGuids.size() == 0)) return memberHistory;
        //return an empty list since parameters a
        String memberProfileWhereClause;
        String planGuidWhereClause ;
        
        Integer offset = (pageNum-1) * numResults;
        
        if(memberProfileGuids != null && memberProfileGuids.size() != 0) {
            //create the where clause for Member Profile Guid to make it case insensitive
                memberProfileWhereClause += ' MemberProfileGUID__c IN (\'' + String.join(memberProfileGuids, '\',\'') + '\') OR ';  
            memberProfileWhereClause = memberProfileWhereClause.substring(0, memberProfileWhereClause.length()-4);
            memberProfileWhereClause += ') AND ';
        }
        

        //'WHERE  MemberProfileGUID__c IN (\'' + String.join(memberProfileGuids, '\',\'') + '\') AND PlanGuid__c IN (\''+ String.join(planGuids, '\',\'') +'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY ' + sortByField + ' ' + sortDirection + ' LIMIT '+ numResults + ' OFFSET  '+ offset
        String whereClause = 'WHERE  MemberProfileGUID__c IN (\'' + String.join(memberProfileGuids, '\',\'') + '\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') AND ServiceLineStatus__c = \'Paid\'  ORDER BY ' + sortByField + ' ' + sortDirection + ' LIMIT '+ numResults + ' OFFSET  '+ offset;
        memberHistory = (List<mock_MembersServiceHistory__c>)dalQuery('mock_MembersServiceHistory__c', whereClause);
        System.debug('memberHistory::'+memberHistory);
        return memberHistory;
    }
    global static   List<mock_MembersServiceHistory__c>                                 getMemberServiceHistory_MemDetailSize(List<String> memberProfileGuids, List<String> planGuids){
        List<mock_MembersServiceHistory__c> memberHistory = new List<mock_MembersServiceHistory__c>();
        if((memberProfileGuids == null || memberProfileGuids.size() == 0) && (planGuids == null || planGuids.size() == 0)) return memberHistory;
        //return an empty list since parameters a
        String memberProfileWhereClause;
        String planGuidWhereClause ;
                
        if(memberProfileGuids != null && memberProfileGuids.size() != 0) {
            //create the where clause for Member Profile Guid to make it case insensitive
                memberProfileWhereClause += ' MemberProfileGUID__c IN (\'' + String.join(memberProfileGuids, '\',\'') + '\') OR ';  
            memberProfileWhereClause = memberProfileWhereClause.substring(0, memberProfileWhereClause.length()-4);
            memberProfileWhereClause += ') AND ';
        }
        
        // 'WHERE  MemberProfileGUID__c IN (\'' + String.join(memberProfileGuids, '\',\'') + '\') AND PlanGuid__c IN (\''+ String.join(planGuids, '\',\'') +'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')'
        String whereClause = 'WHERE  MemberProfileGUID__c IN (\'' + String.join(memberProfileGuids, '\',\'') + '\')  AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') AND ServiceLineStatus__c = \'Paid\' ';
        memberHistory = (List<mock_MembersServiceHistory__c>)dalQuery('mock_MembersServiceHistory__c', whereClause);
        return memberHistory;
    }

    /* Members Service History methods      **********************************************************/
    /* Members Address methods      **********************************************************/
    //return the member addresses based on the memberProfileGuid
    global static   List<mock_MemberAddress__c>                                  getMemberAddresses(List<String> memberProfileGuids){
        List<mock_MemberAddress__c> memberAddresses = null;
        memberAddresses = (List<mock_MemberAddress__c>)dalQuery('mock_MemberAddress__c', 
                    'WHERE MemberProfileGUID__c in (\''+String.join(memberProfileGuids,'\',\'')+'\') AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY AddressLine1__c ASC');
        return memberAddresses;
    }
    
    //return the member addresses based on the memberAddressGuid
    global static List<mock_MemberAddress__c>                                    getMemberAddress(String memberAddressGuid){
        List<mock_MemberAddress__c> memberAddresses = null;
        memberAddresses = (List<mock_MemberAddress__c>)dalQuery('mock_MemberAddress__c', 
                    'WHERE MemberAddressGUID__c = \''+memberAddressGuid + '\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY AddressLine1__c ASC');
        
        return memberAddresses;
    }
    
        //returns a map of profileMemberGuids to MemberAddress_x objects by list of profileMemberGUID, Street, City, State, and Zipcode
    global static   Map<String,mock_MemberAddress__c>                           getMemberAddressesMap(List<String> profileMemberGUIDs, String street, String city, String state, String zipCode, String routeId){
        List<mock_MemberAddress__c> memberAddresses = null;
        String whereClause = 'WHERE MemberProfileGUID__c in (\''+String.join(profileMemberGUIDs,'\',\'')+'\')';
        whereClause += ' AND AddressLine1__c = \'' + street + '\'';
        whereClause += ' AND City__c = \'' + city + '\'';
        whereClause += ' AND State__c = \'' + state + '\'';
        whereClause += ' AND Zip__c = \'' + zipCode + '\'';
        whereClause += ' AND RouteID__c = \'' + routeId + '\'';
        memberAddresses = (List<mock_MemberAddress__c>)dalQuery('mock_MemberAddress__c', whereClause);
        Map<String,mock_MemberAddress__c> result = new Map<string,mock_MemberAddress__c>();
        for(mock_MemberAddress__c mem : memberAddresses){
            result.put(mem.MemberProfileGUID__c.toLowerCase(),mem);
        }
        return result;
    }

    /* Members Address methods      **********************************************************/
    
     /* Members Phones methods      **********************************************************/
    //return the member Phones based on the memberProfileGuid
    global static   Map<String,mock_MemberPhone__c>                          getMemberPhonesMap(String memberProfileGuid){
        List<mock_MemberPhone__c> memberPhones = null;
        memberPhones = (List<mock_MemberPhone__c>)dalQuery('mock_MemberPhone__c', 
                    'WHERE MemberProfileGUID__c = \''+memberProfileGuid + '\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY Number__c ASC');
        Map<String,mock_MemberPhone__c> result = new Map<String,mock_MemberPhone__c>();
        for(mock_MemberPhone__c phone : memberPhones){
            result.put(phone.MemberPhoneGUID__c.toLowerCase(), phone);
        }
        return result;
    }
    
    

    //return the member Phone based on the memberPhoneGuid
    global static List<mock_MemberPhone__c>                                  getMemberPhones(String memberProfileGuid){
        List<mock_MemberPhone__c> memberPhones = null;
         memberPhones = (List<mock_MemberPhone__c>)dalQuery('mock_MemberPhone__c', 
                    'WHERE MemberProfileGUID__c = \''+memberProfileGuid + '\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY Number__c ASC');
        return memberPhones;  
    }
    
    
    //return the member Phone based on the memberPhoneGuid
    global static List<mock_MemberPhone__c>                                  getMemberPhone(String memberPhoneGuid){
        List<mock_MemberPhone__c> memberPhones = null;
        memberPhones = (List<mock_MemberPhone__c>)dalQuery('mock_MemberPhone__c', 
                    'WHERE MemberPhoneGUID__c = \''+memberPhoneGuid + '\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY Number__c ASC');
        
        return memberPhones;
    }
    
        //returns a map of profileMemberGuids to memberPhone objects by list of profileMemberGUID and phonenumber
    global static   Map<String,mock_MemberPhone__c>                           getMemberPhoneMap(List<String> profileMemberGUIDs, String phoneNumber, String routeId){
        List<mock_MemberPhone__c> memberPhoneList = null;
        String whereClause = 'WHERE MemberProfileGUID__c in (\''+String.join(profileMemberGUIDs,'\',\'')+'\')';
        whereClause += ' AND Number__c = \'' + phoneNumber + '\'';
        whereClause += ' AND RouteID__c = \'' + routeId + '\'';
        memberPhoneList = (List<mock_MemberPhone__c>)dalQuery('mock_MemberPhone__c', whereClause);
        Map<String,mock_MemberPhone__c> result = new Map<string,mock_MemberPhone__c>();
        for(mock_MemberPhone__c mem : memberPhoneList){
            result.put(mem.MemberProfileGUID__c.toLowerCase(),mem);
        }
        return result;
    }
    /* Members Phones methods       **********************************************************/
 
    /* mock_MemberCOB__c methods     **********************************************************/
    global static List<mock_MemberCOB__c>                                            getCOBs(List<String> memberProfileGuids){
        String whereClause = 'WHERE MemberProfileGuid__c in (\''+String.join(memberProfileGuids,'\',\'')+'\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' AND EffectiveDate__c <= TODAY AND (TerminationDate__c >= TODAY OR TerminationDate__c = null)';
        whereClause += ' ORDER BY EffectiveDate__c DESC';
        
        return (List<mock_MemberCOB__c>)dalQuery('mock_MemberCOB__c', whereClause);
    }
    /* mock_MemberCOB__c methods     **********************************************************/
    /* Primary Care Dentist methods     **********************************************************/
    
    //returns a list of mock_MemberPrimaryCareDentist__c by list of MemberPlanGuids 
    global static   List<mock_MemberPrimaryCareDentist__c>                           getPrimaryDentists(List<String> memberPlanGUIDs){
        Date thisDay = date.Today();
        String whereClause = 'WHERE MemberCoverageGuid__c in (\''+String.join(memberPlanGUIDs,'\',\'')+'\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' AND EffectiveDate__c <= TODAY AND (TerminationDate__c >= TODAY OR TerminationDate__c = null)';
        whereClause += ' ORDER BY EffectiveDate__c DESC';
        return (List<mock_MemberPrimaryCareDentist__c>)dalQuery('mock_MemberPrimaryCareDentist__c', whereClause);
    }

    global static   List<mock_MemberPrimaryCareDentist__c>                           getPrimaryDentistsByDate(List<String> memberPlanGUIDs, String memberGuid, Date dateOfService ){
        String dateStr = DateTime.newInstance(dateOfService.year(),dateOfService.month(),dateOfService.day()).format('yyyy-MM-dd');

        String whereClause = 'WHERE ';
        if(memberPlanGuids.size() > 0)
        	whereClause += 'MemberCoverageGuid__c in (\''+String.join(memberPlanGUIDs,'\',\'')+'\')';
        else
        	whereClause += 'MemberProfileGuid__c = \''+ memberGuid + '\' ';
        	
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' AND EffectiveDate__c <= ' + dateStr + ' AND (TerminationDate__c >= ' + dateStr + ' OR TerminationDate__c = null)';
        whereClause += ' ORDER BY EffectiveDate__c DESC';
        return (List<mock_MemberPrimaryCareDentist__c>)dalQuery('mock_MemberPrimaryCareDentist__c', whereClause);
    }
    
    /* Primary Care Dentist methods     **********************************************************/
    global static   List<mock_MemberPrimaryCareDentist__c>                           getTotalPrimaryDentistsPanel(String locAcctId, List<String> planGuidIds, String orderBy, String fnameSearch, String lnameSearch){
        Date thisDay = date.Today();
        String whereClause = 'WHERE ServiceLocationGUID__c = \'' + locAcctId + '\'';
        whereClause += ' AND PlanGuid__c in (\''+String.join(planGuidIds,'\',\'')+'\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' AND EffectiveDate__c <= TODAY AND (TerminationDate__c >= TODAY OR TerminationDate__c = null) ';
        whereClause += fnameSearch;
        whereClause += lnameSearch;
        whereClause += orderBy;
        return (List<mock_MemberPrimaryCareDentist__c>)dalQuery('mock_MemberPrimaryCareDentist__c', whereClause);
    }
    global static   List<mock_MemberPrimaryCareDentist__c>                           getTotalPrimaryDentistsPanel(String locAcctId, String provAcctId, List<String> planGuidIds, String orderBy, String fnameSearch, String lnameSearch){
        Date thisDay = date.Today();
        String whereClause = 'WHERE ServiceLocationGUID__c = \'' + locAcctId + '\'';
        whereClause += ' AND ProviderGUID__c = \'' + provAcctId + '\'';
        whereClause += ' AND PlanGuid__c in (\''+String.join(planGuidIds,'\',\'')+'\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' AND EffectiveDate__c <= TODAY AND (TerminationDate__c >= TODAY OR TerminationDate__c = null) ';
        whereClause += fnameSearch;
        whereClause += lnameSearch;
        whereClause += orderBy;
        return (List<mock_MemberPrimaryCareDentist__c>)dalQuery('mock_MemberPrimaryCareDentist__c', whereClause);
    }
    //to return PCD records for panel Roster
     global static   List<mock_MemberPrimaryCareDentist__c>                           getPrimaryDentistsPanel(String locAcctId, String provAcctId, List<String> planGuidIds, String orderBy, String limitNum, String offSet, String fnameSearch, String lnameSearch){
        Date thisDay = date.Today();
        String whereClause = 'WHERE ServiceLocationGUID__c = \'' + locAcctId + '\'';
        whereClause += ' AND ProviderGUID__c = \'' + provAcctId + '\'';
        whereClause += ' AND PlanGuid__c in (\''+String.join(planGuidIds,'\',\'')+'\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' AND EffectiveDate__c <= TODAY AND (TerminationDate__c >= TODAY OR TerminationDate__c = null) ';
        whereClause += fnameSearch;
        whereClause += lnameSearch;
        whereClause += orderBy;
        whereClause += limitNum;
        whereClause += offset;
        return (List<mock_MemberPrimaryCareDentist__c>)dalQuery('mock_MemberPrimaryCareDentist__c', whereClause);
    }

    //to return PCD records for panel Roster
     global static   List<mock_MemberPrimaryCareDentist__c>                           getPrimaryDentistsPanel(String locAcctId, List<String> planGuidIds, String orderBy, String limitNum, String offSet, String fnameSearch, String lnameSearch){
        Date thisDay = date.Today();
        String whereClause = 'WHERE ServiceLocationGUID__c = \'' + locAcctId + '\'';
        whereClause += ' AND PlanGuid__c in (\''+String.join(planGuidIds,'\',\'')+'\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' AND EffectiveDate__c <= TODAY AND (TerminationDate__c >= TODAY OR TerminationDate__c = null)';
        whereClause += fnameSearch;
        whereClause += lnameSearch;
        whereClause += orderBy;
        whereClause += limitNum;
        whereClause += offset;
        return (List<mock_MemberPrimaryCareDentist__c>)dalQuery('mock_MemberPrimaryCareDentist__c', whereClause);
    }

    //to return PCD record for dentist detail
    global static   mock_MemberPrimaryCareDentist__c[]                           getPrimaryDentistsByPSL(String locAcctId, String provAcctId){
        Date thisDay = date.Today();
        String whereClause = '';
        system.debug(locAcctId);
        if(locAcctId != null && locAcctId != '' && locAcctId != 'Any' && locAcctId != 'undefined'){
            whereClause += 'WHERE ServiceLocation__r.Id = \'' + locAcctId + '\'';
            if(provAcctId != null && provAcctId != '' && provAcctId != 'Any' && provAcctId != 'undefined'){
            whereClause += ' AND Provider__r.Id = \'' + provAcctId + '\'';
            
            }
        }

        if(provAcctId != null && provAcctId != '' && provAcctId != 'Any' && provAcctId != 'undefined'){
            if(locAcctId == null || locAcctId == '' || locAcctId == 'Any' || locAcctId == 'undefined'){
                system.debug('where clause without searching for service location');
            whereClause += 'WHERE Provider__r.Id = \'' + provAcctId + '\'';
            }
        }
        


        system.debug('where clause' + whereClause);
        List<mock_MemberPrimaryCareDentist__c> pcds = (List<mock_MemberPrimaryCareDentist__c>)dalQuery('mock_MemberPrimaryCareDentist__c', whereClause);

        
        return pcds;
    }
    
    //this method returns a map of primary care dentists where the key is member profile guid 
    global static Map<String, mock_MemberPrimaryCareDentist__c> getCPDByPlanAndMemberProfileGUID(Set<String> memberProfileGuids, Set<String> planGuids){

        String whereClause = ' WHERE PlanGuid__c IN (\''+String.join(new List<String>(planGuids),'\',\'')+'\')';
        whereClause += ' AND MemberProfileGUID__c in (\''+String.join(new List<String>(memberProfileGuids),'\',\'')+'\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        List<mock_MemberPrimaryCareDentist__c> pcdList = (List<mock_MemberPrimaryCareDentist__c>) dalQuery('mock_MemberPrimaryCareDentist__c', whereClause);
        
        //put into map
        Map<String,mock_MemberPrimaryCareDentist__c> mPlans = new Map<String,mock_MemberPrimaryCareDentist__c>();
        for(mock_MemberPrimaryCareDentist__c pcd : pcdList){
            mPlans.put(pcd.MemberProfileGuid__c.toLowerCase(),pcd);
        }
        
        return mPlans;
    }

    /* END OF PRIMARY CARE DENTIST METHODS ***************************************/
    /* Member Accumulator methods       **********************************************************/
    global static   List<mock_MemberAccumulator__c>                          getMemberAccumulators(List<String> memberProfileGUIDs){
        return prov_util_DAL.getMemberAccumulators(memberProfileGUIDs, Date.today());
    }
    //returns a list of effective mock_MemberAccumulator__c by list of MemberPlanGuids 
    global static   List<mock_MemberAccumulator__c>                          getMemberAccumulators(List<String> memberProfileGUIDs, Date dateOfService){
        String dateStr = DateTime.newInstance(dateOfService.year(),dateOfService.month(),dateOfService.day()).format('yyyy-MM-dd');
        String whereClause = 'WHERE MemberProfileGuid__c in (\''+String.join(memberProfileGUIDs,'\',\'')+'\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' AND EffectiveDate__c <=' +dateStr+ ' AND (TerminationDate__c >= ' +dateStr+ ' OR TerminationDate__c = null)';
        whereClause += ' ORDER BY EffectiveDate__c DESC';
        system.debug('accumDebug: ' + whereClause);
        return (List<mock_MemberAccumulator__c>)dalQuery('mock_MemberAccumulator__c', whereClause);
    }
    
    /* Member Accumulator methods       **********************************************************/
    /* Case methods     **********************************************************/ //AND Providers_Service_Locations__r.Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\')
                                                                                    //  AND Providers_Service_Locations__r.Service_Location__c IN (\'' + String.join(serviceLocIds, '\',\'') + '\')
    global static List<Case>                                            retrieveCases(String businessId, List<Id> serviceLocIds, List<Id> providerIds, List<String> caseTypes, String orderBy){
        String whereClause = ' WHERE  Business_lkup__c =\'' +businessId+ '\'  AND (Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\') OR Provider__c = null )  AND (Service_Location__c IN (\'' + String.join(serviceLocIds, '\',\'') + '\') OR Service_Location__c = null)   ';
        whereClause += ' AND Origin =\'Provider Portal\' AND (';
        for(String caseT : caseTypes){
            whereClause += ' Subject LIKE \'%'+caseT + '%\' OR'; 
        }
        
        whereClause = whereClause.substring(0, whereClause.length()-3);
        whereClause += ') ' + orderBy;
        System.debug('whereClause::'+whereClause);
            //AND RecordTypeId IN (\'' + String.join(recordTypeIds, '\',\'') + '\')
        return (List<Case>)dalQuery('Case', whereClause);
    }
    
    /* Case methods     **********************************************************/ //AND Providers_Service_Locations__r.Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\')
                                                                                    //  AND Providers_Service_Locations__r.Service_Location__c IN (\'' + String.join(serviceLocIds, '\',\'') + '\')
    global static List<Case>                                            retrieveCases_helpRequest(String businessId, List<Id> serviceLocIds, List<Id> providerIds, Map<String, Object> extraParamMap, List<String> caseTypes, String orderBy){
        String whereClause = ' WHERE  Business_lkup__c =\'' +businessId+ '\'  AND (Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\') OR Provider__c = null )  AND (Service_Location__c IN (\'' + String.join(serviceLocIds, '\',\'') + '\') OR Service_Location__c = null)   ';

        for(String key : extraParamMap.keyset()){
            if(extraParamMap.get(key) != null && extraParamMap.get(key) != '' ){
                if(key != 'startDate' && key != 'endDate'){
                    whereClause += ' AND '+ key + ' LIKE \''+ String.escapeSingleQuotes((String)extraParamMap.get(key)) + '%\' '; 
                } else if(key == 'startDate'){
                    String paramDate = (String)extraParamMap.get(key);
                    String[] paramDateList = paramDate.split('-');
                    String dateStr = DateTime.newInstance(Integer.valueOf(paramDateList[0]),Integer.valueOf(paramDateList[1]),Integer.valueOf(paramDateList[2]), 0, 0, 0).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                    
                    whereClause += ' AND CreatedDate >= '+dateStr;
                } else if(key == 'endDate'){
                    String paramDate = (String)extraParamMap.get(key);
                    String[] paramDateList = paramDate.split('-');
                    Datetime dateT = DateTime.newInstance(Integer.valueOf(paramDateList[0]),Integer.valueOf(paramDateList[1]),Integer.valueOf(paramDateList[2]), 0, 0, 0).addDays(1);
                    String dateStr = dateT.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                    whereClause += ' AND CreatedDate < '+dateStr;
                }
                
            }
        }

        whereClause += ' AND Origin =\'Provider Portal\' AND (';
        for(String caseT : caseTypes){
            whereClause += ' Subject LIKE \'%'+caseT + '%\' OR'; 
        }
        whereClause = whereClause.substring(0, whereClause.length()-3);
        whereClause += ') ' + orderBy;
        
        System.debug('whereClause::'+whereClause);
            //AND RecordTypeId IN (\'' + String.join(recordTypeIds, '\',\'') + '\')
        return (List<Case>)dalQuery('Case', whereClause);
    }
    
    global static List<Case>                                            retrieveCases_contactus(String businessId, List<Id> serviceLocIds, List<Id> providerIds, List<String> caseTypes, String orderBy){
        String whereClause = ' WHERE  Business_lkup__c =\'' +businessId+ '\'  AND (Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\') OR Provider__c = null )  AND (Service_Location__c IN (\'' + String.join(serviceLocIds, '\',\'') + '\') OR Service_Location__c = null)  AND Status=\'New\'  ';
        //String whereClause = ' WHERE  Business_lkup__c =\'' +businessId+ '\'  AND (Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\') OR (Provider__c = null AND Providers_Service_Locations__r.Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\')) ) AND (Service_Location__c IN (\'' + String.join(serviceLocIds, '\',\'') + '\') OR (Service_Location__c = null AND Providers_Service_Locations__r.Service_Location__c IN (\'' + String.join(serviceLocIds, '\',\'') + '\'))) ';
        whereClause += ' AND Origin =\'Provider Portal\' AND (';
        for(String caseT : caseTypes){
            whereClause += ' Subject LIKE \'%'+caseT + '%\' OR'; 
        }
        
        whereClause = whereClause.substring(0, whereClause.length()-3);
        whereClause += ') ' + orderBy;
            //AND RecordTypeId IN (\'' + String.join(recordTypeIds, '\',\'') + '\')
        return (List<Case>)dalQuery('Case', whereClause);
    }
    /* Case methods     **********************************************************/
    /* Providers Service Locations methods     **********************************************************/
    // query for the PSLs that are active on a certain date
    global static List<Providers_Service_Locations__c>                  retrievePSL_WDate(Set<String> providerIds, Set<String> serviceLocationIds, Set<String> businessIdSet, Date dateOfService){
        String dateStr = DateTime.newInstance(dateOfService.year(),dateOfService.month(),dateOfService.day()).format('yyyy-MM-dd');
        String whereClause = 'WHERE Business__c IN(\''+String.join(new List<String>(businessIdSet),'\',\'')+'\') AND ';
         // if provider id or service location id is present then add them to where clause
        if(providerIds.size() > 0 || serviceLocationIds.size() > 0){
            //open quotes
            whereClause += '('; 
            
            //check providerIds
            if(providerIds.size() > 0){
                whereClause += 'Provider__c IN (\''+String.join(new List<String>(providerIds),'\',\'')+'\') ';
            }
            
            //check the service locations
            if(serviceLocationIds.size() > 0){
                if(providerIds.size() > 0)
                    whereClause += ' AND ';
                //add service location ids to query
                whereClause += 'Service_Location__c IN (\''+String.join(new List<String>(serviceLocationIds),'\',\'')+'\')';
            }
            //close the quotes
            whereClause += ') AND ';
        }
        
        whereClause += ' route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\') AND Effective_Date__c <= ' +dateStr+ ' AND (termination_date__c = null OR termination_date__c >= ' +dateStr+ ')' ;
        return (List<Providers_Service_Locations__c>)prov_util_DAL.dalQuery('Providers_Service_Locations__c', whereClause);
    }
    
    global static List<Providers_Service_Locations__c>                  retrievePSL_ProvPermission(Set<String> businessWWSet){
    /* Prov cache retrieve psl - methods       **********************************************************/
        //generate where clause
        String whereClause = 'WHERE Business__r.guid__c IN(\''+String.join(new List<String>(businessWWSet),'\',\'')+'\') AND ';
        //route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\')
        whereClause += '  Effective_Date__c <= TODAY AND (termination_date__c = null OR termination_date__c >= LAST_N_DAYS:365)' ;
        return (List<Providers_Service_Locations__c>)prov_util_DAL.dalQuery('Providers_Service_Locations__c', whereClause);
    }
    
    global static List<Providers_Service_Locations__c>                  retrievePSL_Cache(Set<String> providerIds, Set<String> serviceLocationIds, Set<String> businessIdSet){
    /* Prov cache retrieve psl - methods       **********************************************************/
    //generate where clause
    String whereClause = 'WHERE Business__c IN(\''+String.join(new List<String>(businessIdSet),'\',\'')+'\') AND ';
     
    // if provider id or service location id is present then add them to where clause
    if(providerIds.size() > 0 || serviceLocationIds.size() > 0){
        //open quotes
        whereClause += '('; 
        
        //check providerIds
        if(providerIds.size() > 0){
            whereClause += 'Provider__r.guid__c IN (\''+String.join(new List<String>(providerIds),'\',\'')+'\') ';
        }
        
        //check the service locations
        if(serviceLocationIds.size() > 0){
            if(providerIds.size() > 0)
                whereClause += ' AND ';
            //add service location ids to query
            whereClause += 'Service_Location__r.guid__c IN (\''+String.join(new List<String>(serviceLocationIds),'\',\'')+'\')';
        }
        //close the quotes
        whereClause += ') AND ';
    }
    
    whereClause += ' route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\') AND Effective_Date__c <= TODAY AND (termination_date__c = null OR termination_date__c >= LAST_N_DAYS:365) ORDER BY Service_Location__r.Name ASC, Provider__r.Name ASC' ;
    return (List<Providers_Service_Locations__c>)prov_util_DAL.dalQuery('Providers_Service_Locations__c', whereClause);
                                    
    }

    global static List<Providers_Service_Locations__c>                  retrievePSL_CacheWId(Set<String> providerIds, Set<String> serviceLocationIds, Set<String> businessIdSet){
    /* Prov cache retrieve psl - methods       **********************************************************/
    //generate where clause
    String whereClause = 'WHERE Business__c IN(\''+String.join(new List<String>(businessIdSet),'\',\'')+'\') AND ';
    
    // if provider id or service location id is present then add them to where clause
    if(providerIds.size() > 0 || serviceLocationIds.size() > 0){
        //open quotes
        whereClause += '('; 
        
        //check providerIds
        if(providerIds.size() > 0){
            whereClause += 'Provider__c IN (\''+String.join(new List<String>(providerIds),'\',\'')+'\') ';
        }
        
        //check the service locations
        if(serviceLocationIds.size() > 0){
            if(providerIds.size() > 0)
                whereClause += ' AND ';
            //add service location ids to query
            whereClause += 'Service_Location__c IN (\''+String.join(new List<String>(serviceLocationIds),'\',\'')+'\')';
        }
        //close the quotes
        whereClause += ') AND ';
    }
    
    whereClause += ' route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\') AND Effective_Date__c <= TODAY AND (termination_date__c = null OR termination_date__c >= LAST_N_DAYS:365)' ;
    return (List<Providers_Service_Locations__c>)prov_util_DAL.dalQuery('Providers_Service_Locations__c', whereClause);
                                    
    }
    
    /* Find a Dentist - FAD - methods       **********************************************************/
    //retrieve the provider service location based on the fad requirements - gov portal
    global static List<Providers_Service_Locations__c>                  retrievePSL_FAD(Map<String, String> paramMap, Set<Id> locIdSet, String configName, Boolean acceptingNewPatients, String orderByS){
        //if(queryS == '' || queryS == null) return new List<Providers_Service_Locations__c>();
        
        String queryStringP = 'SELECT id, Service_Location__r.Name, Service_Location__r.BillingAddress, Service_Location__r.BillingCity, Service_Location__r.BillingCountry, ' +
                            'Service_Location__r.BillingState, Service_Location__r.BillingPostalCode,  Service_Location__r.BillingLatitude, '+
                            'Service_Location__r.BillingStreet, Service_Location__r.BillingLongitude, Service_Location__r.Phone, Service_Location__r.has_handicap_access__c, '+
                            'Service_Location__r.supported_languages__c, treats_ages_to__c, treats_ages_from__c, '+
                            'is_treating_special_needs_patients__c, Specialties__c, Provider__r.is_using_sedation__c, '+
                            'Provider__r.Name, Provider__r.supported_languages__c, Provider__r.Gender__c, is_accepting_new_patients__c, '+
                            'Provider__r.NPI__c, Provider__r.guid__c, route_id__c, Service_Location__r.guid__c ' + 
                            'FROM Providers_Service_Locations__c '+
                            'WHERE Service_Location__c IN:locIdSet ' + 
                            'AND is_excluded_from_portal__c = false ';
            queryStringP += ' AND (termination_date__c = null OR termination_date__c >= TODAY) ' + 
                            'AND (effective_date__c = null OR effective_date__c <= TODAY) '; 
            //add logic for gender choice                       
            if(paramMap.containsKey('gender')){
                if(paramMap.get('gender').equalsIgnorecase('male')){
                    queryStringP += ' AND Provider__r.Gender__c LIKE \'Male\'';
                } else if(paramMap.get('gender').equalsIgnorecase('female')){
                    queryStringP += ' AND Provider__r.Gender__c LIKE \'Female\'';
                }
            }
            
            //add logic for name choice                     
            if(paramMap.containsKey('name')){
                if(paramMap.get('name') != ''){
                    queryStringP += ' AND (Provider__r.Name Like \'%' + String.escapeSingleQuotes(EncodingUtil.UrlDecode((String)paramMap.get('name'), 'UTF-8') ) + 
                            '%\' OR Service_Location__r.Name  Like \'%' + String.escapeSingleQuotes( EncodingUtil.UrlDecode( (String)paramMap.get('name'), 'UTF-8' ) ) + '%\')';
                } 
            }
            
            //add logic for specialty choice                        
            if(paramMap.containsKey('specialty')){
                if(paramMap.get('specialty') != ''){
                    System.debug('specialty::'+paramMap.get('specialty'));
                    //query for the mapping for the specialty
                    List<String> specialtyList = new List<String>();
                    String specialty = String.escapeSingleQuotes( EncodingUtil.UrlDecode( (String)paramMap.get('specialty'), 'UTF-8' ) );
                    System.debug('specialtyDecoded::'+specialty);
                    for(Portal_Picklist_Mapping__mdt ppm : [SELECT Value__c FROM Portal_Picklist_Mapping__mdt 
                                                            WHERE Portal_Picklist__r.Value__c =:specialty  AND  
                                                                    Portal_Picklist__r.Provider_Portal_Configuration__r.Label =:configName]){
                        specialtyList.add(ppm.Value__c);
                    }
                    if(specialtyList.size() > 0){
                        queryStringP += ' AND (Specialties__c INCLUDES (\''+String.join(specialtyList, '\',\'') + '\')  )';
                        //queryStringP += ' AND (Provider__r.Specialties__c INCLUDES (\''+String.join(specialtyList, '\',\'') + '\') OR Service_Location__r.Specialties__c  INCLUDES (\''+String.join(specialtyList, '\',\'') + '\')  )';
                    }
                    /*queryStringP += ' AND (Provider__r.Specialties__c includes (\'' + 
                            String.escapeSingleQuotes(EncodingUtil.UrlDecode(paramMap.get('specialty'), 'UTF-8' ) ) + 
                            '\') OR Service_Location__r.Specialties__c  includes (\'' + 
                            String.escapeSingleQuotes( EncodingUtil.UrlDecode( paramMap.get('specialty'), 'UTF-8' ) ) + '\') )';*/
                }
            }
            
            //add logic for language choice                     
            if(paramMap.containsKey('language')){
                if(paramMap.get('language') != ''){
                    queryStringP += ' AND (Provider__r.Supported_Languages__c includes (\'' + 
                        String.escapeSingleQuotes( EncodingUtil.UrlDecode( (String)paramMap.get('language'), 'UTF-8' ) ) + 
                        '\') OR Service_Location__r.Supported_Languages__c  includes (\'' + 
                        String.escapeSingleQuotes( EncodingUtil.UrlDecode( (String)paramMap.get('language'), 'UTF-8' ) ) + '\') )';
                }
            }
            
            //add logic for sedation choice                     
            if(paramMap.containsKey('sedation')){
                if(paramMap.get('sedation') == 'true'){
                    queryStringP += ' AND Provider__r.is_using_sedation__c = true ';//OR Service_Location__r.is_using_sedation__c  =true
                }
            }
            
            //add logic for special needs choice                        
            if(paramMap.containsKey('special')){
                if(paramMap.get('special') == 'true'){
                    queryStringP += ' AND is_treating_special_needs_patients__c = true ';//OR Service_Location__r.is_treating_special_needs_patients__c  =true
                }
            }
            
            //add logic for min age choice                      
            if(paramMap.containsKey('minAge')){
                if(paramMap.get('minAge') != ''){
                    queryStringP += ' AND treats_ages_from__c <= ' + paramMap.get('minAge');//Provider__r. OR Service_Location__r.treats_ages_from__c <=' + paramMap.get('minAge') + 
                }
            }
            
            //add logic for max age choice                      
            if(paramMap.containsKey('maxAge')){
                if(paramMap.get('maxAge') != ''){
                    queryStringP += ' AND treats_ages_to__c >= ' + paramMap.get('maxAge') ;//Provider__r. OR Service_Location__r.treats_ages_to__c >=' + paramMap.get('maxAge') + '
                }
            }
            
            //add logic for accepting new patients                  
            if(acceptingNewPatients){
                queryStringP += ' AND is_accepting_new_patients__c = true';
            }
        //add in the route query param
        queryStringP += ' AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        queryStringP += ' AND Provider__r.route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        
        queryStringP += ' '+ orderByS;
        
        //return the results
        try{
            return (List<Providers_Service_Locations__c>)Database.query (queryStringP);
        }catch(Exception ex){
            System.debug('**********************************');
            System.debug('Error:::'+ex.getMessage());
            System.debug('ln:::'+ex.getLineNumber());
            System.debug('stack_trace:::'+ex.getStackTraceString());
            System.debug('**********************************');
        }
        return new List<Providers_Service_Locations__c>();
    }       
    
    /* Providers Service Locations methods     **********************************************************/
    /* Providers Service Locations Networks methods     **********************************************************/
    
    global static List<Providers_Service_Locations_Networks__c>                  retrievePSLN_WDate(Set<String> pslIdSet, Date dateOfService){ 
        String dateStr = DateTime.newInstance(dateOfService.year(),dateOfService.month(),dateOfService.day()).format('yyyy-MM-dd');
        
        return (List<Providers_Service_Locations_Networks__c>)prov_util_DAL.dalQuery('Providers_Service_Locations_Networks__c',
                                    //query to include the business ids found in the provider user verfication
                                    'WHERE Provider_Service_Location__c IN (\''+String.join(new List<String>(pslIdSet),'\',\'')+'\') AND Effective_Date__c <= '+dateStr+' AND (termination_date__c = null OR termination_date__c >= '+dateStr+') AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\')' );
    }
    /* Prov cache retrieve psl - methods       **********************************************************/
    global static List<Providers_Service_Locations_Networks__c>                  retrievePSLN_Cache(Set<String> pslIdSet){
        /* Prov cache retrieve psln - methods       **********************************************************/
        return (List<Providers_Service_Locations_Networks__c>)prov_util_DAL.dalQuery('Providers_Service_Locations_Networks__c',
                                    //query to include the business ids found in the provider user verfication
                                    'WHERE Provider_Service_Location__c IN (\''+String.join(new List<String>(pslIdSet),'\',\'')+'\') AND Effective_Date__c <= TODAY AND (termination_date__c = null OR termination_date__c >= LAST_N_DAYS:365) AND Network__r.Effective_Date__c <= TODAY AND (Network__r.termination_date__c = null OR Network__r.termination_date__c >= LAST_N_DAYS:365) AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ORDER BY Provider_Service_Location__r.Provider__r.Name ASC' );
    }
    /* Prov cache retrieve psl - methods       **********************************************************/
    global static List<AggregateResult>                  retrievePSLN_Cache2(Set<String> providerIds, Set<String> serviceLocationIds, Set<String> businessIdSet, Boolean activeOnly){
        /* Prov cache retrieve psln - methods       **********************************************************/
        String whereClause = ' WHERE Business__c IN (\''+String.join(new List<String>(businessIdSet),'\',\'')+'\')  ';
        if(providerIds.size() > 0){
            whereClause += ' AND Provider_Service_Location__r.Provider__r.guid__c IN (\''+String.join(new List<String>(providerIds),'\',\'')+'\')  ';
        }
        if(serviceLocationIds.size() > 0){
            whereClause += ' AND Provider_Service_Location__r.Service_Location__r.guid__c IN (\''+String.join(new List<String>(serviceLocationIds),'\',\'')+'\')  ';
        }
        if(activeOnly){
            whereClause += ' AND Effective_Date__c <= TODAY AND (termination_date__c = null OR termination_date__c >= TODAY) ';
        } else {
            whereClause += ' AND Effective_Date__c <= TODAY AND (termination_date__c = null OR termination_date__c >= LAST_N_DAYS:365) ';
        }
        
        String fullQuery = 'SELECT Count(Id) ct, Business__c , Network__c  FROM Providers_Service_Locations_Networks__c' + 
                                            whereClause + 
                                            ' GROUP BY Business__c, Network__c ';
        System.debug('fullQuery::'+fullQuery);
        return (List<AggregateResult>) Database.query(fullQuery);
    }
    
    /* Prov cache retrieve psl - methods       **********************************************************/
    global static List<AggregateResult>                  retrievePSLN_PSL(Set<String> pslIds, date serviceDate){
        /* Prov cache retrieve psln - methods       **********************************************************/
        String whereClause = ' WHERE Provider_Service_Location__c IN (\''+String.join(new List<String>(pslIds),'\',\'')+'\')  ';
        
        whereClause += ' AND Effective_Date__c <= :serviceDate AND (termination_date__c = null OR termination_date__c >= :serviceDate) ';
        
        String fullQuery = 'SELECT Provider_Service_Location__c , Network__c  FROM Providers_Service_Locations_Networks__c' + 
                                            whereClause + 
                                            ' GROUP BY Provider_Service_Location__c, Network__c ';
        System.debug('fullQuery::'+fullQuery);
        return (List<AggregateResult>) Database.query(fullQuery);
    }
    
    /* Prov cache retrieve psl - methods       **********************************************************/
    global static List<Providers_Service_Locations_Networks__c>                  retrievePSLN_ProvPermission(Set<String> pslIdSet){
        /* Prov cache retrieve psln - methods       **********************************************************/
        return (List<Providers_Service_Locations_Networks__c>)prov_util_DAL.dalQuery('Providers_Service_Locations_Networks__c',
                                    //query to include the business ids found in the provider user verfication
                                    'WHERE Provider_Service_Location__c IN (\''+String.join(new List<String>(pslIdSet),'\',\'')+'\') AND Effective_Date__c <= TODAY AND (termination_date__c = null OR termination_date__c >= LAST_N_DAYS:365) ' );
        //AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\')
    }
     //retrieve the provider service location network.  
    global static List<Providers_Service_Locations_Networks__c>                     retrievePSLN_FAD(Set<Id> provServLocIdSet, Set<Id> networkIds, Boolean acceptingNewPatients, String orderByS){
        return prov_util_DAL.retrievePSLN_FAD(provServLocIdSet, networkIds, acceptingNewPatients, false, orderByS);
    }
     //retrieve the provider service location network.  
    global static List<Providers_Service_Locations_Networks__c>                     retrievePSLN_FAD(Set<Id> provServLocIdSet, Set<Id> networkIds, Boolean acceptingNewPatients, Boolean outOfNetwork, String orderByS){
        String queryStringP = 'SELECT id, provider_service_location__c, provider_service_location__r.Service_Location__c,'+
                                'provider_service_location__r.Provider__c, is_accepting_new_patients__c '+
                                'FROM Providers_Service_Locations_Networks__c '+
                                'WHERE provider_service_location__c IN:provServLocIdSet  ';

        if(!outOfNetwork){//if out of network is false which means it should only return results based on the network
            queryStringP +=  ' AND Network__c IN:networkIds ';
        }
        queryStringP += '  AND is_excluded_from_portal__c = false  ' + 
                        '  AND participation_status__c LIKE \'PAR\'  ' + 
                            'AND (termination_date__c = null OR termination_date__c >= TODAY) ' + 
                            'AND (effective_date__c = null OR effective_date__c <= TODAY)';
                                //AND Participation_Status__c = \'Par\'
        system.debug('FADQ: ' + queryStringP);
        //if only looking for patients that are accepting new patients add this parameter           
        if(acceptingNewPatients){
            queryStringP += ' AND is_accepting_new_patients__c = true';
        }
        
        //add in the route query param
        queryStringP += ' AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        
        queryStringP += ' '+ orderByS;
        
        
        try{
            return (List<Providers_Service_Locations_Networks__c>)Database.query (queryStringP);
        }catch(Exception ex){
            System.debug('**********************************');
            System.debug('Error:::'+ex.getMessage());
            System.debug('ln:::'+ex.getLineNumber());
            System.debug('stack_trace:::'+ex.getStackTraceString());
            System.debug('**********************************');
        }
        return new List<Providers_Service_Locations_Networks__c>();
    }
    /* Providers Service Loactions Networks methods     **********************************************************/
    
      //retrieve the provider service location network.  
    global static List<Account>                                         retrieveSL_FAD(Boolean handicap, Location geo, String distance, String orderByS){
        //query for the locations that meet the criteria
        String queryStringL = 'SELECT id, Name, BillingAddress, BillingStreet, BillingCity, BillingState, BillingPostalCode,  BillingLatitude, BillingLongitude, Phone, '+
                        'has_handicap_access__c '+
                        ' FROM Account WHERE RecordType.DeveloperName=\'Service_Location\' ';

        //check to see if handicap is in the param map
        if(handicap){//check to see if it is true
            queryStringL += ' AND has_handicap_access__c = true '; // add the handicap is true for the service locations
        }
        
        //add the geolocation
       if(!Test.isRunningTest()) queryStringL += ' AND DISTANCE(BillingAddress, :geo, \'mi\') < '+ distance;
            
        //add in the route query param
        queryStringL += ' AND route_id__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        
        queryStringL += ' '+ orderByS;
        //System.debug('SL query::'+queryStringL);
        try{
            return (List<Account>)Database.query (queryStringL);
        }catch(Exception ex){
            System.debug('**********************************');
            System.debug('Error:::'+ex.getMessage());
            System.debug('ln:::'+ex.getLineNumber());
            System.debug('stack_trace:::'+ex.getStackTraceString());
            System.debug('**********************************');
        }
        return new List<Account>();
    }
    /* Find a Dentist - FAD - methods       **********************************************************/
    /* Search Criteria - methods       **********************************************************/
    global static List<Search_Criteria__c >                         retrieveSearchCriteria(List<id> PSLIds, String portalName){
        //generate where clause
        String whereClause = 'WHERE Provider_Service_Location__c in (\''+String.join(PSLIds,'\',\'')+'\')';
        whereClause += ' AND Portal_Name__c = \'' + portalName + '\'';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' ORDER BY LastModifiedDate DESC';
        return (List<Search_Criteria__c>)dalQuery('Search_Criteria__c', whereClause);
    }
    /* Search Criteria - methods       **********************************************************/
    
    /* query methods        **********************************************************/

    global static sObject                                       dalQueryById(String objName, Id objId){
        string whereClause = '';
        if((prov_util_MockData.UseMockData || Test.IsRunningTest()) && objName.endsWith('__x')){
            whereClause = 'WHERE Name = \''+ objId +'\'';
        } else{
            whereClause = 'WHERE Id = \''+ objId +'\'';
        }
        list<sobject> sobjs = dalQuery(objName,whereClause);
        if(sobjs.size()>0)
            return sobjs[0];
        return null;
    }
     
    global static List<sObject>                                 dalQueryByIds(String objName, List<Id> objIds){
        String whereClause = '';
        if((prov_util_MockData.UseMockData || Test.IsRunningTest()) && objName.endsWith('__x')){
            whereClause = 'WHERE Name in (\''+String.join(objIds,'\',\'')+'\')';
        } else {
            whereClause = 'WHERE Id in (\''+String.join(objIds,'\',\'')+'\')';
        }
        return dalQuery(objName,whereClause);
    }
        
    global static List<sObject>                                 dalQuery(String objName, String whereClause){   
        system.debug('dq objName: ' + objName + ' ' + whereClause);   
        if((prov_util_MockData.UseMockData || Test.IsRunningTest()) && objName.endsWith('__x')){
            string mObjName = 'mock_' + objName.replace('__x','__c');
            String ssoql = soqlSELECT(mObjName) + whereClause;
            system.debug('DAL_SOQL: ' + ssoql);
            return wmp_util_MockHelper.translate(objName, Database.query(ssoql));
        }
        return Database.query(soqlSELECT(objName) + whereClause);
    }                           
    
    global static String                                        soqlSelect(String objName){
        return 'SELECT ' + fieldList(objName) + ' FROM ' + objName + ' ';
    }
    
    global static string                                        fieldList(String objName){
        return String.join(wmp_util_Helper.getFieldNamesList(objName, false) , ',');
    }
    /* query methods        **********************************************************/
}