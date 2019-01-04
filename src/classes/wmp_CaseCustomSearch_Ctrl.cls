/**********************************************************************************************************************
Name                        : wmp_CaseCustomSearch_Ctrl
Purpose                     : Controller for the Custom Search page
Created on                  : 24th October 2017
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                            By                      Comments
1.0             8           24th October 2017               West Monroe Partners    See header - purpose
 
**********************************************************************************************************************/
public with sharing class wmp_CaseCustomSearch_Ctrl {

    //Id of the case the search originated from
    public Case case1;

    //represents the selection of member or provider
    public string picklistSelection {get; set;}

    //render member/provider picklist
    public boolean renderPicklist {get; set;}

    //render member section
    public boolean renderMemberSection {get; set;}
    
    //render member results section
    public boolean renderMemberResultsSection {get; set;}

    //render provider section
    public boolean renderProviderSection {get; set;}

    //render provider results section
    public boolean renderProviderResultsSection {get; set;}

    //render Search button
    public boolean renderButtons {get; set;}

    //text of the search button
    public String buttonTitle {get; set;}


    /********************************************************************
    * Member search fields
    ********************************************************************/
    public String memberId {
        get;
        set{memberId = String.escapeSingleQuotes(value);}
    }

    public String memberFirstName {
        get;
        set{memberFirstName = String.escapeSingleQuotes(value);}
    }    

    public String memberLastName {
        get;
        set{memberLastName = String.escapeSingleQuotes(value);}
    }

    /********************************************************************
    * Provider search fields
    *********************************************************************/
    public String businessName {get{if(businessName != null){
        businessName = String.escapeSingleQuotes(businessName);
        } return businessName;}
    set;}

    public String providerName {get{if(providerName != null){
        providerName = String.escapeSingleQuotes(providerName);
        } return providerName;}
    set;}

    public String npi {get{if(npi != null){
        npi = String.escapeSingleQuotes(npi);
        } return npi;}
    set;}

    public String tin {get{if(tin != null){
        tin = String.escapeSingleQuotes(tin);
        } return tin;}
    set;}

    /******************************************************************
    * Shared search fields
    ******************************************************************/
    public String billingStreet {
        get;
        set{billingStreet = String.escapeSingleQuotes(value);}
    }
    public String billingCity{
        get;
        set{billingCity = String.escapeSingleQuotes(value);}
    }   
    public String billingState {
         get;
        set{billingState = String.escapeSingleQuotes(value);}
    }
    public String billingZip {
         get;
        set{billingZip = String.escapeSingleQuotes(value);}
    }
    
    //Map of providers returned by the provider search criteria
    public Map<Id, Providers_Service_Locations__c> pslMap {get;set;}

    //Map of User verification plans that match the member search criteria
    public Map<Id, User_Plan_Verification__c> upvMap {get;set;}
    public Map<Id, User_Plan_Verification__c> upvMapFinal {get;set;}

    public Map<Id, Contact> contactMap {get;set;}
    
    //list of members returned by search
    public List<Account> memberList {get; set;}

    //the selected provider in the Provider Search results
    public Id selectedprovider {get;set;}

    //the selected Service Location in the Service Location search results
    public Id selectedServiceLocation {get;set;}

    //the selected Contact in the Member search results
    public Id selectedContact {get;set;}

    //account to hold the date and phone variables from the search
    public Account acct {get;set;}

    public Map<Id,Providers_Service_Locations__c> providers {get; set;}
    public Map<Id,Providers_Service_Locations__c> serviceLocations {get;set;}
    
    //map of member guardians  Key is <subscriberid> - <planid>
    public Map<string, String> guardianMap {get;set;}

    //map to hold plan names.  Key is plan Id, value is plan name
    public Map<String, String> planIdToName {get; set;}


    //member/provider picklist options
    public List<SelectOption> getPicklistOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-None-'));
        options.add(new SelectOption('Member', 'Member'));
        options.add(new SelectOption('Provider', 'Provider'));

        return options;
    }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public wmp_CaseCustomSearch_Ctrl(ApexPages.StandardController stdController) {
        //caseId = stdController.getID();
        renderPicklist = true;
        //caseId = ApexPages.currentPage().getParameters().get('id');

        case1 = (Case) stdController.getRecord();

        System.debug('case: ' + case1);

        acct = new Account();

    }

    /***
    * Turns on and off the Member and Provider Sections based on the Picklist section
    **/
    public void renderDetail() {
        if(picklistSelection == 'Member'){
            renderMemberSection = true;
            renderProviderSection = false;
            buttonTitle = 'Search for Members';
            renderButtons = true;

            providers = null;
            serviceLocations = null;
            pslMap = null;
            renderProviderResultsSection = false;

        } else if(picklistSelection == 'Provider'){
            renderProviderSection = true;
            renderMemberSection = false;
            buttonTitle = 'Search for Providers';
            renderButtons = true;
            upvMap = null;
            renderMemberResultsSection = false;

        } else {
            renderMemberSection = false;    
            renderProviderSection = false;
            renderButtons = false;
            providers = null;
            serviceLocations = null;
            upvMap = null;
            pslMap = null;
            renderProviderResultsSection = false;
            renderMemberResultsSection = false;
        }
    }

    /**
    * Searches for Providers or members that match the entered criteria
    **/
    public void beginSearch() {
        
        if(picklistSelection == 'Member'){
            try{
                memberSearch();
            } catch(CustomSearchException cse) {
                renderMemberResultsSection = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, cse.getMessage()));
            }

        } 
        else if(picklistSelection == 'Provider'){
            try{
                providerSearch();
            } catch(CustomSearchException cse){
                renderProviderResultsSection = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, cse.getMessage()));
            }
        }
    }

    /**
    *    Member Search logic
    *    looks for members that match the provided search inputs 
    *    Acceptable Criteria is:
    *       ID/DOB
    *       Name/DOB
    *       Name/DOB/Address
    *       Name/DOB/Phone
    *       Id/DOB/Phone
    *       Id/DOB/Address
    **/
    public void memberSearch(){
        Id portalRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Portal Contact').getRecordTypeId();
        Id guardianRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Portal Contact').getRecordTypeId();
        Id providerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Portal Contact').getRecordTypeId();
        Id generalRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Portal Contact').getRecordTypeId();

        String query = 'Select id, Member_Contact__r.Portal_Name__c, Member_Contact__r.firstname, Member_Contact__r.lastName, Subscriber_ID__c, Plan_ID__c, '
                        +' MemberCoverageGuid__c, Member_Contact__r.Phone, Guardian_Contact__r.name, Member_Contact__r.Birthdate from '
                        +' User_Plan_Verification__c where ';

        Date d1;
        if(acct.birth_date__c != null){
            d1 = Date.valueOf(acct.birth_date__c);
        }
        System.debug('birthdate: ' + d1);

        //Search criteria section
        if (memberFirstName != '' && memberLastName != '' && acct.birth_date__c != null && billingStreet != '' && billingCity != '' && billingState != '' && billingZip != ''){
            //search by name, birthdate, and address
            System.debug('Criteria 1');
            query += ' Member_Contact__r.firstName = :memberFirstName and Member_Contact__r.lastName = :memberLastName';
           
            search(query, 'nameAddDOB');

        } else if (memberId != '' && acct.birth_date__c != null && billingStreet != '' && billingCity != '' && billingState != '' && billingZip != ''){
            //memberID and DOB Address
            System.debug('Criteria 2');

            query += ' Subscriber_ID__c = :memberId and Member_Contact__r.Birthdate = :d1 ';

            search(query, 'idDOBAdd');
        } else if (memberId != '' && acct.birth_date__c != null && acct.phone != null){
            System.debug('Criteria 3');
            
            query += ' Subscriber_ID__c = :memberId and Member_Contact__r.Birthdate = :d1   ';

            search(query, 'idDOBPhone');
        
       } else if(memberId != '' && acct.birth_date__c != null){
            //birthdate should be available on member contact
            System.debug('Criteria 4');
            System.debug('subId: ' + memberId);
            System.debug('birthdate: ' + acct.birth_date__c);
            
            query += ' Subscriber_ID__c = :memberId and Member_Contact__r.Birthdate = :d1 ';

            System.debug('member query ' + query);
            upvMap = new Map<Id, User_Plan_Verification__c>(
               (List<User_Plan_Verification__c>)Database.query(query));
            System.debug('upv map: ' + upvMap);

        } else if (memberFirstName != '' && memberLastName != '' && acct.birth_date__c != null && acct.phone != null){            
            System.debug('Criteria 5');
            query += ' Member_Contact__r.firstName = :memberFirstName and Member_Contact__r.lastName = :memberLastName' ;

            search(query, 'nameDOBPhone');

        } else if (memberFirstName != '' && memberLastName != '' && acct.birth_date__c != null){
            System.debug('Criteria 6');
            query += ' Member_Contact__r.firstName = :memberFirstName and Member_Contact__r.lastName = :memberLastName ';

            search(query, 'nameDOB');
        //MODIFIED - added new "else if" condition   
        } else if (memberId != ''){
            System.debug('Criteria 7');
            System.debug('subId: ' + memberId);
            
            query += ' Subscriber_ID__c = :memberId'; //should search purely on member ID
            System.debug('member query ' + query);

            upvMap = new Map<Id, User_Plan_Verification__c>(
               (List<User_Plan_Verification__c>)Database.query(query));
            System.debug('upv map: ' + upvMap);

        } else {
            System.debug('Criteria None');
            throw new CustomSearchException('Please use valid search criteria.');
        }

        if(upvMap != null && upvMap.size() > 0 && upvMap.size() < 25){
            //get list of plan names
            Set<String> planIds = new Set<String>();
            for(User_Plan_Verification__c upv : upvMap.values()){
                planIds.add(upv.Plan_ID__c);
            }
            List<Account> planList = [select id, name, guid__c from Account where guid__c in :planIds];
            //add plans to maps
            planIdToName = new Map<String, String>();
            for(Account a : planList){
                planIdToName.put(a.guid__c.toLowerCase(), a.name);
            }

            renderMemberResultsSection = true; 

            //loop through map an combine guardians 
            //key is concat of subId and PlanId
            guardianMap = new Map<String, String>();
            upvMapFinal = new Map<Id, User_Plan_Verification__c>();
            for(User_Plan_Verification__c upv : upvMap.values()) {
                if(upv.Guardian_Contact__c != null){
                    String guardians = guardianMap.get(upv.Subscriber_ID__c.toLowerCase() + '-' + upv.Plan_ID__c.toLowerCase());
                    if(guardians == null){
                        guardians = upv.Guardian_Contact__r.name;
                        System.debug('guardians1 ' + guardians);
                        
                        guardianMap.put(upv.Subscriber_ID__c.toLowerCase() + '-' + upv.Plan_ID__c.toLowerCase(), guardians);
                    } else { 
                        guardians += '; ' + upv.Guardian_Contact__r.name;
                        guardianMap.put(upv.Subscriber_ID__c.toLowerCase() + '-' + upv.Plan_ID__c.toLowerCase(), guardians);
                        
                    }
                    System.debug('guardians2 ' + guardians);
                } else {
                    //add blank entry for no guardian
                    guardianMap.put(upv.Subscriber_ID__c.toLowerCase() + '-' + upv.Plan_ID__c.toLowerCase(), '');
                }
            }  
            System.debug('guardians concat ' + guardianMap ); 

            //remove duplicate entries, add unique contacts to upvMapFinal
            Set<String> contactSet = new Set<String>();
            for(User_Plan_Verification__c upv : upvMap.values()){
                upv.Subscriber_ID__c =upv.Subscriber_ID__c.toLowerCase();
                upv.Plan_ID__c=upv.Plan_ID__c.toLowerCase();
                if(!contactSet.contains(upv.Subscriber_ID__c.toLowerCase()+'-'+upv.Plan_ID__c.toLowerCase())){
                    upvMapFinal.put(upv.id, upv);
                    contactSet.add(upv.Subscriber_ID__c.toLowerCase()+'-'+upv.Plan_ID__c.toLowerCase());
                }
            }

        } else if(upvMap != null && upvMap.size() >= 25){
            throw new CustomSearchException('There are more than 25 members that match your search criteria.  Please add additional criteria.');
        } else {
            throw new CustomSearchException('No matching members found.');
        }

    }

    //manages the member Search
    public void search(String query, String searchType){
        //retrieve UPV records where contact lookup matches name entered
        //user subID and planId from UPV to search for memCoverage record to get MemberProfileGUID
        Map<Id, String> upvToSubPlan = new Map<Id, String>();
        Map<String, String> subPlanToProfileGuid = new Map<String, String>();
        Date d1;
        if(acct.birth_date__c != null){
            d1 = Date.valueOf(acct.birth_date__c);
        }
   
        System.debug('searchType ' + searchType);
        System.debug('member query ' + query);
        upvMap = new Map<Id, User_Plan_Verification__c>(
            (List<User_Plan_Verification__c>)Database.query(query));
        System.debug('upv map: ' + upvMap);
        if(upvMap.size() > 0){
            for(User_Plan_Verification__c upv : upvMap.values()){
                if(upv.Subscriber_ID__c != null && upv.Plan_ID__c != null){
                    upvToSubPlan.put(upv.ID, upv.Subscriber_ID__c + ';' + upv.Plan_ID__c);
                }
            }  

            System.debug('upvToSubPlan: ' + upvToSubPlan);

            //get member coverage records for the contacts passed in
            List<mock_MemberCoverage__c> memCovList = WMP_util_DAL.getMembersPlans(upvToSubPlan.values());
            System.debug('memCovList: ' + memCovList);
            if(MemCovList.size() > 0){
                //build list of memberProfileGUIDs
                for(mock_MemberCoverage__c memberCoverage : MemCovList){
                    subPlanToProfileGuid.put(memberCoverage.SubscriberID__c.toLowerCase() + ';' + memberCoverage.PlanGUID__c.toLowerCase(), memberCoverage.MemberProfileGUID__c);
                }
                System.debug('subPlanToProfileGuid: ' + subPlanToProfileGuid);

                /********************if block for custom searches *************************/
                //Name, Address, DOB
                if(searchType == 'nameAddDOB'){
                    searchMemberByNameAddressDOB(upvToSubPlan, subPlanToProfileGuid, memCovList.get(0).RouteID__c);
                } else if(searchType == 'idDOBAdd'){
                    searchMemberByMemberIdDOBAddress(upvToSubPlan, subPlanToProfileGuid, memCovList.get(0).RouteID__c);
                } else if (searchType == 'idDOBPhone'){
                    searchMemberByMemberIdDOBPhone(upvToSubPlan, subPlanToProfileGuid, memCovList.get(0).RouteID__c);                        
                } else if(searchType == 'nameDOBPhone'){
                    searchMemberByNameDOBPhone(upvToSubPlan, subPlanToProfileGuid, memCovList.get(0).RouteID__c);
                } else if(searchType =='nameDOB'){
                    searchMemberByNameDOB(upvToSubPlan, subPlanToProfileGuid, memCovList.get(0).RouteID__c);
                }
            }
        }
    }

    /**
        Search for members via Name/DOB and MemberAddress
    **/
    public void searchMemberByNameAddressDOB(Map<Id, String> upvToSubPlan, Map<String, String> subPlanToProfileGuid, String routeId){
        //retrieve map of members that match memberprofileguid, name and birthdate
        //retrieve map of memberaddress that match memberprofileguid and address
        //remove from UPV list entries that dont have a corresponding member and address entries 
        //get member records to use for DOB validation
        Map<String,mock_Member__c> memberMap = WMP_util_DAL.getMembersMap(subPlanToProfileGuid.values(), memberFirstName, memberLastName, Date.valueOf(acct.birth_date__c), routeId);

        //get memberAddress records for address verification
        Map<String, mock_MemberAddress__c> memberAddressMap = WMP_util_DAL.getMemberAddressesMap(subPlanToProfileGuid.values(), billingStreet, billingCity, billingState, billingZip, routeId);

        //if a user verification plan doesnt have both an address and a member record, remove from map
        if(memberMap.size() > 0 && memberAddressMap.size() > 0){
            for(User_Plan_Verification__c upv : upvMap.values()){
                if(memberMap.get(subPlanToProfileGuid.get(upvToSubPlan.get(upv.id).toLowerCase()).toLowerCase()) == null || memberAddressMap.get(subPlanToProfileGuid.get(upvToSubPlan.get(upv.id).toLowerCase()).toLowerCase()) == null){
                    //remove upv from map
                    upvMap.remove(upv.id);
                }
            }
        } else {
            throw new CustomSearchException('No matching members found.');
        }
    }

    public void searchMemberByMemberIdDOBAddress(Map<Id, String> upvToSubPlan, Map<String, String> subPlanToProfileGuid, String routeId){
        //retrieve map of memberaddress that match memberprofileguid and address
        //remove from UPV list entries that dont have a corresponding address entry 
        
        //get memberAddress records for address verification
        Map<String, mock_MemberAddress__c> memberAddressMap = WMP_util_DAL.getMemberAddressesMap(subPlanToProfileGuid.values(), billingStreet, billingCity, billingState, billingZip, routeId);

        if(memberAddressMap.size() > 0){
            //if a user verification plan doesnt have address record, remove from map
            for(User_Plan_Verification__c upv : upvMap.values()){
                if(memberAddressMap.get(subPlanToProfileGuid.get(upvToSubPlan.get(upv.id).toLowerCase()).toLowerCase()) == null){
                    //remove upv from map
                    upvMap.remove(upv.id);
                }
            } 
        } else {
            throw new CustomSearchException('No matching members found.');
        }
    }

    public void searchMemberByMemberIdDOBPhone(Map<Id, String> upvToSubPlan, Map<String, String> subPlanToProfileGuid, String routeId){
        //retrieve map of memberPhone that match memberprofileguid and phone
        //remove from UPV list entries that dont have a corresponding phone entry 

        //get memberPhone records 
        String regExp = '[/\\D/g]';
        String phone = acct.phone.replaceAll(regExp, '');
        System.debug('search parameters ' + subPlanToProfileGuid.values() + ' ' + phone + ' ' + routeId);
        Map<String, mock_MemberPhone__c> memberPhoneMap = WMP_util_DAL.getMemberPhoneMap(subPlanToProfileGuid.values(), phone, routeId);
        System.debug('memberPhoneMap: ' + memberPhoneMap);

        if(memberPhoneMap.size() > 0){
            //if a user verification plan doesnt have phone record, remove from map
            for(User_Plan_Verification__c upv : upvMap.values()){
                if(memberPhoneMap.get(subPlanToProfileGuid.get(upvToSubPlan.get(upv.id).toLowerCase()).toLowerCase()) == null){
                    //remove upv from map
                    upvMap.remove(upv.id);
                }
            }
        } else {
            throw new CustomSearchException('No matching members found.');
        }
    }

    public void searchMemberByNameDOBPhone(Map<Id, String> upvToSubPlan, Map<String, String> subPlanToProfileGuid, String routeId){
        //retrieve map of memberPhone that match memberprofileguid and phone
        //retrieve map of members that match name and DOB
        //remove from UPV list entries that dont have a corresponding phone entry or member entry 

        //get memberPhone records 
        String regExp = '[/\\D/g]';
        String phone = acct.phone.replaceAll(regExp, '');
        Map<String, mock_MemberPhone__c> memberPhoneMap = WMP_util_DAL.getMemberPhoneMap(subPlanToProfileGuid.values(), phone, routeId);
        System.debug('memberPhoneMap: ' + memberPhoneMap);

        //get member entries
        Map<String,mock_Member__c> memberMap = WMP_util_DAL.getMembersMap(subPlanToProfileGuid.values(), memberFirstName, memberLastName, Date.valueOf(acct.birth_date__c), routeId);
        System.debug('memberMap: ' + memberMap);

        //if a user verification plan doesnt have phone or member record, remove from map
        if(memberPhoneMap.size() > 0 && memberMap.size() > 0){
            for(User_Plan_Verification__c upv : upvMap.values()){
                System.debug('mapping1: ' + upv.id);
                System.debug('mapping2: ' + upvToSubPlan.get(upv.id));
                System.debug('mapping3: ' +  subPlanToProfileGuid.get(upvToSubPlan.get(upv.id)));
                System.debug('mapping4: ' + memberMap.get(subPlanToProfileGuid.get(upvToSubPlan.get(upv.id))));

                if(memberMap.get(subPlanToProfileGuid.get(upvToSubPlan.get(upv.id).toLowerCase()).toLowerCase()) == null || memberPhoneMap.get(subPlanToProfileGuid.get(upvToSubPlan.get(upv.id).toLowerCase()).toLowerCase()) == null){
                    //remove upv from map
                    upvMap.remove(upv.id);
                }
            }
        } else {
            throw new CustomSearchException('No matching members found.');
        }
    }

    public void searchMemberByNameDOB(Map<Id, String> upvToSubPlan, Map<String, String> subPlanToProfileGuid, String routeId){
        //retrieve map of members that match name and DOB
        //remove from UPV list entries that dont have a corresponding member entry 

        //get member entries
        Map<String,mock_Member__c> memberMap = WMP_util_DAL.getMembersMap(subPlanToProfileGuid.values(), memberFirstName, memberLastName, Date.valueOf(acct.birth_date__c), routeId);
        System.debug('memberMap: ' + memberMap);
        
        //if a user verification plan doesnt have member record, remove from map
        if(memberMap.size() > 0){
            for(User_Plan_Verification__c upv : upvMap.values()){
                System.debug('mapping1: ' + upv.id);
                System.debug('mapping2: ' + upvToSubPlan.get(upv.id));
                System.debug('mapping3: ' +  subPlanToProfileGuid.get(upvToSubPlan.get(upv.id).toLowerCase()));
                System.debug('mapping4: ' + memberMap.get(subPlanToProfileGuid.get(upvToSubPlan.get(upv.id).toLowerCase())));

                if(memberMap.get(subPlanToProfileGuid.get(upvToSubPlan.get(upv.id).toLowerCase()).toLowerCase()) == null){
                    //remove upv from map
                    upvMap.remove(upv.id);
                }
            }
        } else {
            throw new CustomSearchException('No matching members found.');
        }
    }


    /**
        Provider Search logic
        looks for Provider record type accounts that match the provided search inputs 
    **/
    public void providerSearch(){
        //get recordtypeIds for business and provider accounttypes
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Id serviceLocationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Location').getRecordTypeId();
        Id providerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        //String query;
        String query = 'Select id, provider__c, provider__r.name, Service_Location__r.name, provider__r.npi__c, provider__r.guid__c, Service_Location__c, Provider__r.BillingStreet, Provider__r.BillingCity, Provider__r.BillingState, Provider__r.BillingPostalCode, Provider__r.Phone, Service_Location__r.BillingStreet, Service_Location__r.BillingCity, Service_Location__r.BillingState, Service_Location__r.BillingPostalCode, Service_Location__r.Phone from Providers_Service_Locations__c where (provider__r.recordtypeId = :providerRecordTypeId or Service_Location__r.recordTypeId = :serviceLocationRecordTypeId) ';
        // or business__r.recordTypeId = :businessRecordTypeId
        //if business name is filled out, need to search against name field of business recordtype

        //check the search fields, if there are not empty, add to the query
        if(businessName != ''){     
            String t1 = '%'+businessName+'%';     
            query += ' and Service_Location__r.name like :t1';
        } 
        if(providerName != ''){     
            String t2 = '%'+providerName+'%';
            System.debug('t2 ' + t2);
            query += ' and provider__r.name like :t2';
        }   
        if(npi != ''){     
            String t3 = '%'+npi+'%';
            query += ' and provider__r.npi__c like :t3';
        } 
        if(tin != ''){     
            String t4 = '%'+tin+'%';
            query += ' and provider__r.tax_id_number__c like :t4';
        }   
        if(acct.phone != null){     
            String t5 = acct.phone;
            //remove all non digits from phone number
            String regExp = '[/\\D/g]';
            String t5a = t5.replaceAll(regExp, '');
            System.debug('phone ' + t5);
            System.debug('phone DIGITS ONLY ' + t5a);
            query += ' and (Service_Location__r.phone = :t5 OR Service_Location__r.phone = :t5a) ';
        }           
        if(billingStreet != ''){     
            String t6 = '%'+billingStreet+'%';
            query += ' and Service_Location__r.BillingStreet like :t6';
        }      
        if(billingCity != ''){     
            String t7 = '%'+billingCity+'%';
            query += ' and Service_Location__r.billingCity like :t7';
        }   
        if(billingState != ''){     
            String t8 = '%'+billingState+'%';
            query += ' and Service_Location__r.BillingState like :t8';
        }   
        if(billingZip != ''){     
            String t9 = '%'+billingZip+'%';
            query += ' and Service_Location__r.BillingPostalCode like :t9';
        }   

        //add limit
        query += ' limit 100';
        System.debug('query: ' + query);

        //run the query 
        pslMap = new Map<Id, Providers_Service_Locations__c>(
            (List<Providers_Service_Locations__c>)Database.query(query));
        
        if(pslMap.size() > 0 && pslMap.size() < 100){
            //copy to list for usability on visualforce page
            System.debug('List: ' + pslMap);     
            renderProviderResultsSection = true; 
            
            //split the map into providers and service locations and remove duplicates
            providers = new Map<Id,Providers_Service_Locations__c>();
            serviceLocations = new Map<Id,Providers_Service_Locations__c>();
            for(Providers_Service_Locations__c psl : pslMap.values()){
                if(psl.provider__c != null){
                    providers.put(psl.provider__c, psl);
                }
                if(psl.Service_Location__c != null){
                    serviceLocations.put(psl.Service_Location__c, psl);
                }
            }


        } else if(pslMap.size() >= 100){
            throw new CustomSearchException('There are more than 100 Providers that match your search criteria.  Please add additional criteria.');
        } 
        else {
            //no search results found
            System.debug('pslMap is null');
            throw new CustomSearchException('There are no Providers that match the search criteria.');
        }
    }

    /** 
        Takes the accid parameter (PSL Id) and saves it to the selectedProvider variable
    **/
    public PageReference getSelected(){
        if(picklistSelection == 'Provider'){
            System.debug('param ' + ApexPages.currentPage().getParameters().get('pslID'));
            selectedprovider = ApexPages.currentPage().getParameters().get('pslID');
            selectedServiceLocation = ApexPages.currentPage().getParameters().get('slID');
        }
        else if(picklistSelection == 'Member'){
            System.debug('param ' + ApexPages.currentPage().getParameters().get('upvID'));
            selectedContact = ApexPages.currentPage().getParameters().get('upvID');
        }

        return null; 
    }

    /**
        This method saves the select provider to the case provider field
        it then returns the user to the case detail page
    **/
    public PageReference submit(){
        //save provider to case
        //close popup
        Case updatedCase = new Case();
        updatedCase.id = case1.id;

        if(picklistSelection == 'Member' && selectedContact != null){
            //update the following fields on the case
            updatedCase.ContactId = upvMap.get(selectedContact).Member_Contact__c;
            updatedCase.Portal_Name__c = upvMap.get(selectedContact).Member_Contact__r.Portal_Name__c;
            updatedCase.Member_ID__c = upvMap.get(selectedContact).Subscriber_ID__c;
            updatedCase.Member_DOB__c = upvMap.get(selectedContact).Member_Contact__r.Birthdate;
            updatedCase.Subscriber_ID__c = upvMap.get(selectedContact).Subscriber_ID__c;
            updatedCase.Member_Phone_Number__c = upvMap.get(selectedContact).Member_Contact__r.Phone;
            updatedCase.Plan__c = getPlan(upvMap.get(selectedContact).Plan_ID__c);
            updatedCase.Member_Profile_Guid__c = getMemberProfileGUID(upvMap.get(selectedContact).Subscriber_ID__c ,upvMap.get(selectedContact).Plan_ID__c);
            updatedCase.Origin = 'Member Portal';
        }
        

        //organize provider results
        if(picklistSelection == 'Provider' && selectedprovider != null){
            System.debug('submit clicked for ' + selectedProvider);
            Providers_Service_Locations__c psl = pslMap.get(selectedprovider);
            System.debug('selected provider ' + psl);
            updatedCase.Provider__c = psl.provider__c;
            if(psl.Service_Location__c != null){
                updatedCase.Service_Location__c = psl.Service_Location__c; 
            }
            
        }

        //organize service location results
        if(picklistSelection == 'Provider' && selectedServiceLocation != null){
            updatedCase.Service_Location__c = selectedServiceLocation;
            updatedCase.Provider__c = null;

        }

        update updatedCase;

        return new PageReference('/'+case1.id);

    }

    //retrieve the memberProfileGuid for member using the subscriber and plan from the user plan verification record 
    public String getMemberProfileGUID(String subscriberID, String planId){
        String memberProfileGUID;
        Map<String,mock_MemberCoverage__c> memCovMap = WMP_util_DAL.getMembersPlansMap(subscriberID, planId);
        System.debug('MemCovMap ' + memCovMap);

        if(memCovMap.size() > 0){
            memberProfileGUID = memCovMap.values().get(0).MemberProfileGUID__c;
            System.debug('MemberProfileGUID__c: ' + memberProfileGUID);
        } else {
            throw new CustomSearchException('No matching Member record found');
        }

        return memberProfileGUID;

    }

    //retrieve the account that contains the winward plan guid 
    public id getPlan(String planId){
        Id planRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Plan Account').getRecordTypeId();
        //look for account.winwardId = planId
        Account planAcct = [select id, name, guid__c from Account where recordtypeId = :planRecordTypeId and guid__c = :planId];
        System.debug(':planAcct ' + planAcct);

        return planAcct.id;
    }

    public class CustomSearchException extends exception{}
}