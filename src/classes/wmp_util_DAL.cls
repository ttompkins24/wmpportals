/**********************************************************************************************************************
Name                        :   wmp_util_DAL
Purpose                     :   The utility that will contain Helper methods to access member and provider data
Created on                  :   08/15/2017
Developed by                :   Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.0         1.0         08/15/2017      Patrick Stephens    

**********************************************************************************************************************/
global without sharing class wmp_util_DAL {
    /* UserSecurity methods     **********************************************************/
    global static   List<String>                                    VisibleLOB                              {
        get{
            if(wmp_util_Cache.VisibleLOB!=null && wmp_util_Cache.VisibleLOB.size()>0){
                return new List<String>(wmp_util_Cache.VisibleLOB);
            } else {
                return new List<String>{'GOV'};
                //return new List<String>{'GOV','EMBLEM','GOV_MH','COM_DELTA'};
            }
        }
    }                               
    /* UserSecurity methods     **********************************************************/
    
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
            result.put(memhist.MemberUniversalIDGUID__c.toLowerCase(),memhist);
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

    /* User Plan Verification methods       **********************************************************/
    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object by subscriberId and planID
    global static   List<User_Plan_Verification__c>                     getUserPlanVerifications(String memberId, String planId){
        return (List<User_Plan_Verification__c>)dalQuery('User_Plan_Verification__c', 
            'WHERE Subscriber_ID__c =\''+memberId + '\' AND Plan_ID__c =\''+planId+ '\' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') ');
    }
    //returns a map of MemberCoverageGuid__c to mock_MemberCoverage__c object by subscriberId and planID
    global static   List<User_Plan_Verification__c>                     getUserPlanVerifications(String memberId, String planId, string routeId){
        return (List<User_Plan_Verification__c>)dalQuery('User_Plan_Verification__c', 
            'WHERE Subscriber_ID__c =\''+memberId + '\' AND Plan_ID__c =\''+planId+ '\' AND RouteID__c = \''+ routeId+ '\' ');
    }
    
    /* User Plan Verification methods       **********************************************************/
    
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
    
    /* Primary Care Dentist methods     **********************************************************/
    
    /* Member Accumulator methods       **********************************************************/
    
    //returns a list of effective mock_MemberAccumulator__c by list of MemberPlanGuids 
    global static   List<mock_MemberAccumulator__c>                          getMemberAccumulators(List<String> memberProfileGUIDs){
        Date thisDay = date.Today();
        String whereClause = 'WHERE MemberProfileGuid__c in (\''+String.join(memberProfileGUIDs,'\',\'')+'\')';
        whereClause += ' AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\')';
        whereClause += ' AND EffectiveDate__c <= TODAY AND (TerminationDate__c >= TODAY OR TerminationDate__c = null)';
        whereClause += ' AND TreatmentClass__c != \'CO Major Services\'';
        whereClause += ' ORDER BY EffectiveDate__c DESC';
        system.debug('accumDebug: ' + whereClause);
        return (List<mock_MemberAccumulator__c>)dalQuery('mock_MemberAccumulator__c', whereClause);
    }
    
    /* Member Accumulator methods       **********************************************************/
    /* Case methods     **********************************************************/
    global static List<Case>                                            retrieveCases(List<Id> caseIds, String orderBy){
        return (List<Case>)dalQuery('Case', 
            'WHERE (ContactId IN (\'' + String.join(new List<Id>(caseIds), '\', \'') + '\') OR Primary_Contact__c =\''+ wmp_util_Cache.ContactRec.Id + '\')  '+orderBy);//AND RouteID__c in (\''+String.join(VisibleLOB,'\',\'')+'\') -- currently no route id on the case record
    }
    /* Case methods     **********************************************************/
    
    /* Find a Dentist - FAD - methods       **********************************************************/
    //retrieve the provider service location based on the fad requirements - gov portal
    global static List<Providers_Service_Locations__c>                  retrievePSL_FAD(Map<String, String> paramMap, Set<Id> locIdSet, String configName, Boolean acceptingNewPatients, String orderByS){
        //if(queryS == '' || queryS == null) return new List<Providers_Service_Locations__c>();
        
        String queryStringP = 'SELECT id, Service_Location__r.Name, Service_Location__r.BillingAddress, Service_Location__r.BillingCity, ' +
                            'Service_Location__r.BillingState, Service_Location__r.BillingPostalCode,  Service_Location__r.BillingLatitude, '+
                            'Service_Location__r.BillingStreet, Service_Location__r.BillingLongitude, Service_Location__r.Phone, Service_Location__r.has_handicap_access__c, '+
                            'Service_Location__r.supported_languages__c, treats_ages_to__c, treats_ages_from__c, '+
                            'is_treating_special_needs_patients__c, Specialties__c, Provider__r.is_using_sedation__c, '+
                            'Provider__r.Name, Provider__r.supported_languages__c, Provider__r.Gender__c, is_accepting_new_patients__c '+
                            'FROM Providers_Service_Locations__c '+
                            'WHERE Service_Location__c IN:locIdSet ';
    
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
                    queryStringP += ' AND (Provider__r.Name Like \'%' + String.escapeSingleQuotes(EncodingUtil.UrlDecode(paramMap.get('name'), 'UTF-8') ) + 
                            '%\' OR Service_Location__r.Name  Like \'%' + String.escapeSingleQuotes( EncodingUtil.UrlDecode( paramMap.get('name'), 'UTF-8' ) ) + '%\')';
                } 
            }
            
            //add logic for specialty choice                        
            if(paramMap.containsKey('specialty')){
                if(paramMap.get('specialty') != ''){
                    System.debug('specialty::'+paramMap.get('specialty'));
                    //query for the mapping for the specialty
                    List<String> specialtyList = new List<String>();
                    String specialty = String.escapeSingleQuotes( EncodingUtil.UrlDecode( paramMap.get('specialty'), 'UTF-8' ) );
                    System.debug('specialtyDecoded::'+specialty);
                    for(Portal_Picklist_Mapping__mdt ppm : [SELECT Value__c FROM Portal_Picklist_Mapping__mdt 
                                                            WHERE Portal_Picklist__r.Value__c =:specialty  AND  
                                                                    Portal_Picklist__r.Portal_Configuration__r.Label =:configName]){
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
                        String.escapeSingleQuotes( EncodingUtil.UrlDecode( paramMap.get('language'), 'UTF-8' ) ) + 
                        '\') OR Service_Location__r.Supported_Languages__c  includes (\'' + 
                        String.escapeSingleQuotes( EncodingUtil.UrlDecode( paramMap.get('language'), 'UTF-8' ) ) + '\') )';
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
    
     //retrieve the provider service location network.  
    global static List<Providers_Service_Locations_Networks__c>                     retrievePSLN_FAD(Set<Id> provServLocIdSet, Set<Id> networkIds, Boolean acceptingNewPatients, String orderByS){
        String queryStringP = 'SELECT id, provider_service_location__c, provider_service_location__r.Service_Location__c,'+
                                'provider_service_location__r.Provider__c, is_accepting_new_patients__c '+
                                'FROM Providers_Service_Locations_Networks__c '+
                                'WHERE provider_service_location__c IN:provServLocIdSet  ' + 
            					'AND Network__c IN:networkIds AND is_excluded_from_portal__c = false AND Participation_Status__c = \'Par\' ' + 
            					'AND (termination_date__c = null OR termination_date__c >= TODAY) ' + 
            					'AND (effective_date__c = null OR effective_date__c <= TODAY)';
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
    
    /* query methods        **********************************************************/

    global static sObject                                       dalQueryById(String objName, Id objId){
        string whereClause = '';
        if((wmp_util_MockData.UseMockData || Test.IsRunningTest()) && objName.endsWith('__x')){
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
        if((wmp_util_MockData.UseMockData || Test.IsRunningTest()) && objName.endsWith('__x')){
            whereClause = 'WHERE Name in (\''+String.join(objIds,'\',\'')+'\')';
        } else {
            whereClause = 'WHERE Id in (\''+String.join(objIds,'\',\'')+'\')';
        }
        return dalQuery(objName,whereClause);
    }
        
    global static List<sObject>                                 dalQuery(String objName, String whereClause){   
        system.debug('dq objName: ' + objName + ' ' + whereClause);   
        if((wmp_util_MockData.UseMockData || Test.IsRunningTest()) && objName.endsWith('__x')){
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