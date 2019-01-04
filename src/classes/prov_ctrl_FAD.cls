/**********************************************************************************************************************
Purpose						: The controller for the find a dentist result page. Contains the search based on office and dentist,
							pagination of the page
Created on					: 9th Oct 2017
Developed by				: Todd Tompkins
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th Oct 2017					Todd Tompkins					See header - purpose
  

**********************************************************************************************************************/
public without sharing class prov_ctrl_FAD {
     
    public static final Integer RESULTS_PER_PAGE = 5;
    public static final Integer MAX_TOTAL_RESULTS = 50;
    
    /*return the language that the current user is*/
    public static String languageSelected {get{
        if(languageSelected == null){
            //initialize the variables
            Map<String, String> lang2langCodeMap = new Map<String, String>{'en_US'=>'English', 'es' =>'Espanol'};
            String locKey = UserInfo.getLanguage();
            
            System.debug('langSelected::'+locKey);
            
            if(lang2langCodeMap.containsKey(locKey)){
                languageSelected = lang2langCodeMap.get(locKey);
            } else {
                languageSelected = 'English';
            }
        }
        return languageSelected;
    }set;}
    
    /* metadata portal picklist mapping for the specialty mappings */
    public static Map<String, Set<String>> specialtySF2MarketingMap {get{
        if(specialtySF2MarketingMap == null){
            specialtySF2MarketingMap = new Map<String, Set<String>>();
            
            //query all the portal picklist mappings
            for(Portal_Picklist_Mapping__mdt ppm : [SELECT Portal_Picklist__c, Value__c, 
                                                        Portal_Picklist__r.English_Label__c, Portal_Picklist__r.Spanish_Label__c 
                                                        FROM Portal_Picklist_Mapping__mdt ]){
                if(specialtySF2MarketingMap.containsKey(ppm.Value__c)){
                    if(languageSelected == 'Espanol' ){
                        specialtySF2MarketingMap.get(ppm.Value__c).add(ppm.Portal_Picklist__r.Spanish_Label__c );
                    } else {
                        specialtySF2MarketingMap.get(ppm.Value__c).add(ppm.Portal_Picklist__r.English_Label__c);
                    }
                } else {
                    if(languageSelected == 'Espanol' ){
                        specialtySF2MarketingMap.put(ppm.Value__c, new Set<String>{ppm.Portal_Picklist__r.Spanish_Label__c} );
                    } else {
                        specialtySF2MarketingMap.put(ppm.Value__c, new Set<String>{ppm.Portal_Picklist__r.English_Label__c} );
                    }
                }
            }
        }
        return specialtySF2MarketingMap;
    }set;}
    
    @AuraEnabled
    public static List<Map<String, String>> fullResultList {get;set;}
    
    @AuraEnabled
    public static Integer pageNum {get;set;}
    
    @AuraEnabled
    public static Integer totalResults {get;set;}
    
    @AuraEnabled
    public static Integer totalPages {get;set;}
    
    @AuraEnabled
    public static List<Integer> paginationVariables(){
        //intitalize variables
        List<Integer> paginationVars = new List<Integer>();
        
        //add the results to the list to return
        paginationVars.add(totalResults);
        paginationVars.add(totalPages);
        paginationVars.add(RESULTS_PER_PAGE);
        
        //return the list
        return paginationVars;
    }
    
    /*return the fad results where the office is the primary item and dentists are the children under the office */
    @AuraEnabled
    public static List<prov_wrap_FAD> retrieveDentists_Office(Map<String, String> paramMap){
        //initialize the variables
        String configName = prov_util_Cache.ConfigurationName;
        Location geo;//= Location.newInstance(41.8781, -87.6298); //test location - center of chicago
        List<prov_wrap_FAD> resultList = new List<prov_wrap_FAD>();
        Map<Id, Account> id2ProviderAccount = new Map<Id, Account>();
        Map<Id, Id> id2Location2PSLIdMap = new Map<Id, Id>();//Location_is_Active__c
        Map<Id, Providers_Service_Locations__c> id2ProvServLocMap = new Map<Id, Providers_Service_Locations__c>();
        Map<Id, Providers_Service_Locations__c> id2ProvServLocMeetsCriteriaMap = new Map<Id, Providers_Service_Locations__c>();
        Set<Id> networkIds = new Set<Id>();
        List<id> locIdInOrder = new List<Id>();
        Set<id> locIdSet = new Set<Id>();
        Map<Id, List<Id>> servLocId2ProvidsMap = new Map<id, List<Id>>();
        String sortBy = 'distance';
        Map<Id, Account> planMap = new Map<Id, Account>();
        totalResults = 0;
        totalPages = 0;
        Boolean acceptingNewPatients = false;
        Set<String> planIds = new Set<String>();
        
        try{
            //get the plan Ids
            if(paramMap.containsKey('planid')){
                System.debug('planIdS::'+paramMap.get('planid'));
                //Set<String> memCovIds = new Set<String>( EncodingUtil.UrlDecode( , 'UTF-8').split(';'));
                planIds.add(EncodingUtil.UrlDecode( paramMap.get('planid'), 'UTF-8'));
                /*for(String memCovGuid : memCovIds){
                    MemberCoverage__x memCov = prov_util_Cache.VerifiedMembersPlans.get(memCovGuid.toLowerCase());
                    planIds.add( memCov.PlanGuid__c );
                }*/
                //get the plans from the mem coverage guids
                planMap=  new Map<Id, Account> ([SELECT id FROM Account WHERE RecordType.DeveloperName = 'Plan_Account' AND Plan_Group_Name__c IN:planIds]);
            }  
            
            //get the plan networks and gather the network ids
            for(Plans_Networks__c planNet : [SELECT id, Network__c FROM Plans_Networks__c WHERE Plan__c IN: planMap.keyset() ]){
                networkIds.add(planNet.Network__c);
            }
            
            if(paramMap.containsKey('sortBy')){
                if(paramMap.get('sortBy') == 'name'){
                    sortBy = 'name';
                }
            }
            
            //retrieve the locations entered
            String locParam = paramMap.get('loc').trim();
            locParam = String.escapeSingleQuotes(locParam);
            String[] locArray = locParam.split(',');
            if(locArray.size() == 1){//zip code
                for(Zip_Code__c zip : [SELECT id, Zip_Code__c, Longitude__c, Latitude__c FROM Zip_Code__c WHERE Zip_Code__c=:locArray[0] ]){
                    geo = Location.newInstance(zip.Latitude__c, zip.Longitude__c);
                    break;
                }
            } else {//city/state
                for(Zip_Code__c zip : [SELECT id, Zip_Code__c, Longitude__c, Latitude__c FROM Zip_Code__c WHERE City__c LIKE :locArray[0].trim() AND State__c LIKE :locArray[1].trim() ]){
                    geo = Location.newInstance(zip.Latitude__c, zip.Longitude__c);
                    break;
                }
            }
            
            //check to see if they are searching for accepting new patients
            if(paramMap.containsKey('newPatients')){
                if(paramMap.get('newPatients') == 'true'){
                    acceptingNewPatients = true;
                }
            }       
            
            Boolean isHandicap = false;
            //check to see if handicap is in the param map
            if(paramMap.containsKey('handicap')){
                if(paramMap.get('handicap') == 'true'){//check to see if it is true
                    //queryStringL += ' AND has_handicap_access__c = true '; // add the handicap is true for the service locations
                    isHandicap = true;
                }
                
            }

             Boolean outOfNetwork = false;
            //see if allow out of network is true
            if(paramMap.containsKey('outOfNetwork')){
                if(paramMap.get('outOfNetwork') == 'true'){//check to see if it is true
                    //queryStringL += ' AND has_handicap_access__c = true '; // add the handicap is true for the service locations
                    outOfNetwork = true;
                }
                
            }
            
            //add the geolocation
            String distanceGeo = '10';
            if(paramMap.containsKey('distance')){
                //queryStringL += ' AND DISTANCE(BillingAddress, :geo, \'mi\') < '+ String.escapeSingleQuotes(paramMap.get('distance'));
                distanceGeo = String.escapeSingleQuotes(paramMap.get('distance'));
            }
            
            for(Account loc : prov_util_DAL.retrieveSL_FAD(isHandicap, geo, distanceGeo, '')){
            	System.debug('location in range::'+loc.Name);
                //id2LocationAccount.put(loc.id, loc);
                //locIdSet.add(loc.Id);
                locIdSet.add(loc.Id);
            } 
            
            id2ProvServLocMap = new Map<Id, Providers_Service_Locations__c> (prov_util_DAL.retrievePSL_FAD(paramMap, locIdSet, configName, acceptingNewPatients,  ''));
            System.debug('sizeBeforeNetwork::'+id2ProvServLocMap.keyset().size());
            
            
            //add in the order by clause
            String pslnQueryEnd = ' ORDER BY provider_service_location__r.Provider__r.Name ';
            
            List<Id> pslInOrder = new List<Id>();
            Set<Id> serviceLocationIdSet = new Set<Id>();
            Map<Id, Boolean> acceptingNewPatientsMap = new Map<Id, Boolean>();//map of pslId to accepting new patients
            //query for the provider service location networks
            for(Providers_Service_Locations_Networks__c psln : prov_util_DAL.retrievePSLN_FAD(id2ProvServLocMap.keyset(), networkIds, acceptingNewPatients, outOfNetwork, pslnQueryEnd) ) {
                //initialize the fields
                Id pslId = psln.provider_service_location__c;
                
                id2Location2PSLIdMap.put(psln.provider_service_location__r.Service_Location__c, pslId);
                if(id2ProvServLocMap.containsKey(pslId)){
                    id2ProvServLocMeetsCriteriaMap.put(pslId, id2ProvServLocMap.remove(pslId));
                    pslInOrder.add(pslId);
                    serviceLocationIdSet.add(psln.provider_service_location__r.Service_Location__c);
                }
                
                //map the accepting new patients at that service location
                if(acceptingNewPatientsMap.containsKey(pslId)){
                    acceptingNewPatientsMap.put(pslId, acceptingNewPatientsMap.get(pslId) || psln.is_accepting_new_patients__c);
                    
                } else{
                    acceptingNewPatientsMap.put(pslId, psln.is_accepting_new_patients__c);
                }
                
            }
            System.debug('meetsAllCriteriaSize::'+id2ProvServLocMeetsCriteriaMap.keyset().size());
            id2ProvServLocMap = new Map<Id, Providers_Service_Locations__c>();//clear the list to free heap space       
            if(serviceLocationIdSet.size() > 0){
                //loop through the Providers service locations map and map the providers service locs to the serv locs
                for(Providers_Service_Locations__c psl : id2ProvServLocMeetsCriteriaMap.values()){
                    if(servLocId2ProvidsMap.containsKey(psl.Service_Location__c)){
                        servLocId2ProvidsMap.get(psl.Service_Location__c).add(psl.Id);
                    } else {
                        servLocId2ProvidsMap.put(psl.Service_Location__c, new List<Id>{psl.Id});
                    }
                }
                
                //sort the locations
                String locSearch = 'SELECT id, Name FROM Account WHERE Id IN:serviceLocationIdSet ORDER BY ';
                if(sortBy == 'distance'){
                    locSearch += ' DISTANCE(BillingAddress, :geo, \'mi\')';
                }else {
                    locSearch += ' Name';
                }
                
                for(Account loc : (List<Account>) Database.query(locSearch) ){
                    locIdInOrder.add(loc.Id);
                }
                
                Integer numResults = 0;
                //loop through the location Ids that are in order and put them in the final map
                for(id locId : locIdInOrder){
                    if(servLocId2ProvidsMap.containsKey(locId)){//if true, means to add the location to the list and map the dentists
                        prov_wrap_FAD officeWrap = new prov_wrap_FAD();
                        Providers_Service_Locations__c serviceLocation = id2ProvServLocMeetsCriteriaMap.get( id2Location2PSLIdMap.get(locId) );//get the service location based on the id
                        if(acceptingNewPatientsMap.get(serviceLocation.Id) && acceptingNewPatients || (acceptingNewPatients == false)){
                            
                            if(numResults == MAX_TOTAL_RESULTS) break;//if the result size hit MAX_TOTAL_RESULTS, break out of loop
                            Integer numDentists = 0;
                                                    
                            //set the office 
                            officeWrap.main_office(serviceLocation, geo);
                            
                            //loop through the providers service locations to map the dentist info
                            for(Id pslId : servLocId2ProvidsMap.get(locId)){
                                Boolean pslAcceptingNewPatients = acceptingNewPatientsMap.get(pslId) && serviceLocation.is_Accepting_new_Patients__c;
                                if(pslAcceptingNewPatients && acceptingNewPatients || (acceptingNewPatients == false)){
                                    Providers_Service_Locations__c psl = id2ProvServLocMeetsCriteriaMap.get(pslId);
                                    //increase the number of dentists
                                    numDentists++;
                                    System.debug('numDentists::'+numDentists);
                                    Map<String, String> dentistChild = new Map<String, String>();
                                    
                                    //get the specialties
                                    String specialties = psl.Specialties__c;
                                    //convert them into a user friendly view
                                    specialties = convertSpecialtyField(specialties);
                                    
                                    dentistChild = officeWrap.child_dentist(psl, pslAcceptingNewPatients, specialties); 
                                    dentistChild.put('index', ''+numDentists);
                                    if(numDentists <= 2){
                                        officeWrap.children.add(dentistChild);
                                    } else{
                                        officeWrap.moreChildren.add(dentistChild);
                                    }
                                    
                                    if(pslAcceptingNewPatients)
                                        officeWrap.acceptingNewPatients = true;
                                }
                            }
                            
                            if(numDentists > 0){
                                numResults++;
                                //add the officeWrap type to the list               
                                resultList.add(officeWrap);
                            }
                        }
                    }
                }
                
            }
            //set the total num pages
            pageNum = 1;
            //set the total number of results
            totalResults = resultList.size();
            System.debug('totalResults::'+totalResults);
            
            //set the total num of pages
            totalPages = Integer.valueOf( (Decimal.valueOf( totalResults ) / RESULTS_PER_PAGE).round(System.RoundingMode.UP) );
            totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1
            System.debug('totalPages::'+totalPages);
            System.debug('resultList::'+resultList);
        }catch(Exception ex){
            resultList = new List<prov_wrap_FAD>();
            totalResults = 0;
            totalPages = 0;
        }
        //return the resultList
        return resultList;
    }
    
    /* retrieve the fad results where dentist is the main focus and the children office  */
    @AuraEnabled
    public static List<prov_wrap_FAD> retrieveDentists_Dentist(Map<String, String> paramMap){
        //initialize the variables
        String configName = 'GOVProvider';
        Location geo;// = Location.newInstance(41.8781, -87.6298); //test location - center of chicago
        List<prov_wrap_FAD> resultList = new List<prov_wrap_FAD>();
        Map<Id, Providers_Service_Locations__c> id2ProviderAccount = new Map<Id, Providers_Service_Locations__c>();
        Map<Id, Id> id2Location2PSLIdMap = new Map<Id, Id>();
        Map<Id, Account> planMap=  new Map<Id, Account> ();
        Map<Id, Providers_Service_Locations__c> id2ProvServLocMap = new Map<Id, Providers_Service_Locations__c>();
        Map<Id, Providers_Service_Locations__c> id2ProvServLocMeetsCriteriaMap = new Map<Id, Providers_Service_Locations__c>();
        Set<Id> networkIds = new Set<Id>();
        Set<id> locIdSet = new Set<Id>();
        Map<Id, List<Id>> provId2ProvidsMap = new Map<id, List<Id>>();
        String sortBy = 'distance';
        List<Id> provServLocIdsOrder = new List<Id>();
        List<Id> provIdsOrder = new List<Id>();
        totalResults = 0;
        totalPages = 0;
        Boolean acceptingNewPatients = false;
        Set<String> planIds = new Set<String>();
        System.debug('paramMap::'+paramMap);
        try{
            //get the plan Ids
            if(paramMap.containsKey('planid')){
                System.debug('planIdS::'+paramMap.get('planid'));
                //Set<String> memCovIds = new Set<String>( EncodingUtil.UrlDecode( , 'UTF-8').split(';'));
                planIds.add(EncodingUtil.UrlDecode( paramMap.get('planid'), 'UTF-8'));
                /*for(String memCovGuid : memCovIds){
                    MemberCoverage__x memCov = prov_util_Cache.VerifiedMembersPlans.get(memCovGuid.toLowerCase());
                    planIds.add( memCov.PlanGuid__c );
                }*/
                //get the plans from the mem coverage guids
                planMap=  new Map<Id, Account> ([SELECT id FROM Account WHERE RecordType.DeveloperName = 'Plan_Account' AND Plan_Group_Name__c IN:planIds]);
            } 
            
            //get the plan networks and gather the network ids
            for(Plans_Networks__c planNet : [SELECT id, Network__c FROM Plans_Networks__c WHERE Plan__c IN: planMap.keyset() ]){
                networkIds.add(planNet.Network__c);
            }
            System.debug('networkIds::'+networkIds);
            
            //get the sort by needed for the query
            if(paramMap.containsKey('sortBy')){
                if(paramMap.get('sortBy') == 'name'){
                    sortBy = 'name';
                }
            }
            
            
            //check to see if they are searching for accepting new patients
            if(paramMap.containsKey('newPatients')){
                if(paramMap.get('newPatients') == 'true'){
                    acceptingNewPatients = true;
                }
            }   
            
            //retrieve the locations entered
            String locParam = paramMap.get('loc').trim();
            locParam = String.escapeSingleQuotes(locParam);
            String[] locArray = locParam.split(',');
            if(locArray.size() == 1){//zip code
                for(Zip_Code__c zip : [SELECT id, Zip_Code__c, Longitude__c, Latitude__c FROM Zip_Code__c WHERE Zip_Code__c=:locArray[0] ]){
                    geo = Location.newInstance(zip.Latitude__c, zip.Longitude__c);
                    break;
                }
            } else {//city/state
                for(Zip_Code__c zip : [SELECT id, Zip_Code__c, Longitude__c, Latitude__c FROM Zip_Code__c WHERE City__c LIKE :locArray[0].trim() AND State__c LIKE :locArray[1].trim() ]){
                    geo = Location.newInstance(zip.Latitude__c, zip.Longitude__c);
                    break;
                }
            }   
            Boolean isHandicap = false; 
            //check to see if handicap is in the param map
            if(paramMap.containsKey('handicap')){
                if(paramMap.get('handicap') == 'true'){//check to see if it is true
                    isHandicap = true;
                }
            }
            
            Boolean outOfNetwork = false;
            //see if allow out of network is true
            if(paramMap.containsKey('outOfNetwork')){
                if(paramMap.get('outOfNetwork') == 'true'){//check to see if it is true
                    //queryStringL += ' AND has_handicap_access__c = true '; // add the handicap is true for the service locations
                    outOfNetwork = true;
                }
                
            }

            //add the geolocation
            String distanceGeo = '10';
            if(paramMap.containsKey('distance')){
                distanceGeo = String.escapeSingleQuotes(paramMap.get('distance'));
            }
            
            //retrieveSL_FAD_Dentist(Boolean handicap, Location geo, String distance, String orderByS){
            for(Account loc : prov_util_DAL.retrieveSL_FAD(isHandicap, geo, distanceGeo, '')){            	
                //locIdSet.add(loc.Id);
                locIdSet.add(loc.Id);
            }
            System.debug('locIdSet::'+locIdSet);
            
            id2ProvServLocMap = new Map<Id, Providers_Service_Locations__c>(prov_util_DAL.retrievePSL_FAD(paramMap, locIdSet, configName, acceptingNewPatients, ''));
            System.debug('Found PSL size Before Network::'+id2ProvServLocMap.keyset().size());
            
            if(id2ProvServLocMap.keyset().size() > 0){//make sure results from provider service location
                
                //add in the order by clause
                String pslnQueryEnd = ' ORDER BY provider_service_location__r.Provider__r.Name ';
                
                List<Id> pslInOrder = new List<Id>();
                Set<Id> serviceLocationIdSet = new Set<Id>();
                Map<Id, Boolean> acceptingNewPatientsMap = new Map<Id, Boolean>();//map of pslId to accepting new patients
                
                //query for the provider service location networks
                for(Providers_Service_Locations_Networks__c psln : prov_util_DAL.retrievePSLN_FAD(id2ProvServLocMap.keyset(), networkIds, acceptingNewPatients, outOfNetwork, pslnQueryEnd)){
                                                    
                    Id pslId =psln.provider_service_location__c;
                    if(id2ProvServLocMap.containsKey(pslId)){
                        id2ProvServLocMeetsCriteriaMap.put(pslId, id2ProvServLocMap.remove(pslId));
                        provServLocIdsOrder.add(pslId);
                        id2Location2PSLIdMap.put(psln.provider_service_location__r.Provider__c, pslId);
                    } else {
                        System.debug('pslId::'+pslId);
                        System.debug('pslIdsStillTHERE::'+id2ProvServLocMeetsCriteriaMap.keyset());
                        System.debug('psls IN list currently::'+provServLocIdsOrder);
                    }
                        //map the accepting new patients at that service location
                        if(acceptingNewPatientsMap.containsKey(pslId)){
                            acceptingNewPatientsMap.put(pslId, acceptingNewPatientsMap.get(pslId) || psln.is_accepting_new_patients__c);
                            
                        } else{
                            acceptingNewPatientsMap.put(pslId, psln.is_accepting_new_patients__c);
                        }
                    
                
                }
                System.debug('meetsAllCriteriaSize::'+id2ProvServLocMeetsCriteriaMap.keyset().size());
                id2ProvServLocMap = new Map<Id, Providers_Service_Locations__c>();//clear the list to free heap space
                        
                if(provServLocIdsOrder.size() > 0){//makes sure there is results after the network search
                    //loop through the Providers service locations map and map the providers service locs to the serv locs
                    for(Id pslId : provServLocIdsOrder){
                        Id provId = id2ProvServLocMeetsCriteriaMap.get(pslId).Provider__c;
                        
                        if(provId2ProvidsMap.containsKey(provId)){
                            provId2ProvidsMap.get(provId).add(pslId);
                        } else {
                            provId2ProvidsMap.put(provId, new List<Id>{pslId});
                            provIdsOrder.add(provId);
                        } 
                    }
                    
                    //check to see if sortBy is name if so, order the providers by name
                    if(sortBy == 'name'){
                        List<id> tempProvIds = new List<Id>();
                        for(Account dentist : [SELECT id FROM Account WHERE Id IN:provIdsOrder Order BY Name]){
                            tempProvIds.add(dentist.Id);
                        }
                        provIdsOrder = tempProvIds;
                    }
                    
                    Integer numResults = 0;
                    List<String> keysForMap = new List<String>();
                    Map<String, prov_wrap_FAD> key2resultMap = new Map<String, prov_wrap_FAD>();
                    Set<Id> pslIdsAlreadyAdded = new Set<Id>();
                    //loop through the location Ids that are in order and put them in the final map
                    for(id dentistId : provIdsOrder){
                        if(provId2ProvidsMap.containsKey(dentistId)){//if true, means to add the location to the list and map the dentists
                            Providers_Service_Locations__c dentistPSL = id2ProvServLocMeetsCriteriaMap.get( id2Location2PSLIdMap.get(dentistId) );//get the service location based on the id
                            prov_wrap_FAD dentistWrap = new prov_wrap_FAD();
                            if(acceptingNewPatientsMap.get(dentistPSL.Id) && acceptingNewPatients || (acceptingNewPatients == false)){
                                if(numResults == MAX_TOTAL_RESULTS) break;//if the result size hit MAX_TOTAL_RESULTS, break out of loop
                                //initialize the variables
                                Integer numOffices = 0;
                                pslIdsAlreadyAdded = new Set<Id>();
                                
                                dentistWrap.main_dentist(dentistPSL);
                                
                                //loop through the providers service locations to map the dentist info
                                for(Id pslId : provId2ProvidsMap.get(dentistId)){
                                    Boolean pslAcceptingNewPatients = acceptingNewPatientsMap.get(pslId) && dentistPSL.is_Accepting_new_Patients__c;
                                    if(pslAcceptingNewPatients && acceptingNewPatients || (acceptingNewPatients == false)){
                                        //increase the number of dentists
                                        if(pslIdsAlreadyAdded.contains(pslId))
                                            continue;
                                        pslIdsAlreadyAdded.add(pslId);
                                        numOffices++;
                                        Providers_Service_Locations__c psl = id2ProvServLocMeetsCriteriaMap.get(pslId);
                                        Map<String, String> officeMap = new Map<String, String>();
                                        
                                        //get the specialties
                                        String specialties = psl.Specialties__c;
                                        //convert them into a user friendly view
                                        specialties = convertSpecialtyField(specialties);
                                        
                                        officeMap = dentistWrap.child_office(psl, geo, pslAcceptingNewPatients, specialties);
                                       	officeMap.put('index', ''+numOffices);
                                                            
                                        if(numOffices <= 2){
                                            dentistWrap.children.add(officeMap);
                                        } else{
                                            dentistWrap.moreChildren.add(officeMap);
                                        }
                                        
                                        if(pslAcceptingNewPatients)
                                            dentistWrap.acceptingNewPatients = true;
                                    }
                                }
                                
                                if(numOffices > 0){
                                    //sort children by distance
                                    dentistWrap = prov_ctrl_FAD.sortChildrenDentist(dentistWrap);
                                    numResults++;
                                    
                                    if(sortBy == 'distance'){
                                        String distance = String.valueOf( Decimal.valueOf(dentistWrap.children[0].get('distance')) * 10);
                                        while(distance.length() < 5){
                                            distance = '0'+distance;
                                        }
                                        String dentistName = dentistWrap.Name.length() > 5 ? dentistWrap.Name.substring(0,5) : dentistWrap.Name.substring(0, dentistWrap.Name.length());
                                        while(dentistName.length() < 10)
                                            dentistName += 'a';
                                        String key = distance + dentistName + dentistWrap.Id;
                                        key2resultMap.put(key, dentistWrap);
                                        keysForMap.add(key);
                                    }
                                    //add the object to the list
                                    resultList.add(dentistWrap);
                                }
                            }
                        }
                    }
                    System.debug('resultList::'+resultList);
                    
                    if(sortBy == 'distance'){
                        keysForMap.sort();
                        List<prov_wrap_FAD> tempList = new List<prov_wrap_FAD>();
                        for(String key : keysForMap){
                            tempList.add(key2resultMap.get(key));
                        }
                        resultList = tempList;
                    }
                }//makes sure results from network
            }//provServLocIdSet makes sure is not empty
            
            //set the total num pages
            pageNum = 1;
            //set the total number of results
            totalResults = resultList.size();
            
            //set the total num of pages
            totalPages = Integer.valueOf( (Decimal.valueOf( totalResults ) / RESULTS_PER_PAGE).round(System.RoundingMode.UP) );
            totalPages = totalPages == 0 ? 1 : totalPages; //should always return at least 1
        }catch(Exception ex){
             system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());           
            system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            resultList = new List<prov_wrap_FAD>();
            totalResults = 0;
            totalPages = 0;
        }
        //return the resultList
        return resultList;
    }
    
    /* sort the children offices under the dentist by location */
    public static prov_wrap_FAD sortChildrenDentist(prov_wrap_FAD dentistWrap){
        //initialize the var
        List<String> distanceAndName = new List<String>();
        Map<String, Map<String, String>> key2childMap = new Map<String, Map<String, String>>();
        
        for(Integer i = 0;i < dentistWrap.children.size(); i++){
            String key = String.valueOf( Decimal.valueOf(dentistWrap.children[i].get('distance')) * 10);
            while(key.length() < 5){
                key = '0'+key;
            }
            //create the first
            String locName = dentistWrap.children[i].get('name');
            locName = locName.length() > 10 ? locName.substring(0, 10) : locName.substring(0 , locName.length());
            while (locName.length() < 10){
                locName += 'a';
            }
            //add name to the key
            key += locName;
            key += dentistWrap.children[i].get('pslId');
            key2childMap.put( key, dentistWrap.children[i] );
            distanceAndName.add(key);
        }
        //null out children
        dentistWrap.children = new List<Map<String, String>>();
        
        for(Integer i = 0; i < dentistWrap.moreChildren.size(); i++){
            String key = String.valueOf( Decimal.valueOf(dentistWrap.moreChildren[i].get('distance')) * 10);
            while(key.length() < 5){
                key = '0'+key;
            }
            
            //create the first
            String locName = dentistWrap.moreChildren[i].get('name');
            locName = locName.length() > 10 ? locName.substring(0, 10) : locName.substring(0 , locName.length());
            while (locName.length() < 10){
                locName += 'a';
            }
            //add name to the key
            key += locName;
            key += dentistWrap.moreChildren[i].get('pslId');
            key2childMap.put( key, dentistWrap.moreChildren[i] );
            distanceAndName.add(key);
        }
        //null out more children
        dentistWrap.moreChildren = new List<Map<String, String>>();
        
        //sort the distance and name 
        distanceAndName.sort();
        
        Integer counter = 0;
        //loop through and put the children back into the map
        for(String key : distanceAndName){
            if(counter <2){
                dentistWrap.children.add(key2childMap.get(key));
            }   else{
                dentistWrap.moreChildren.add(key2childMap.get(key));
                
            }
            counter++;
        }
        
        return dentistWrap;
    }
    
    //convert the specialty value into the marketing correct values
    public static String convertSpecialtyField(String specialtyOriginal){
        if(specialtyOriginal == '' || specialtyOriginal == null) return '';
        
        //split up the specialty list
        List<String> specialtyList = specialtyOriginal.split(';');
        Set<String> resultSpecialtySet = new Set<String>();
        
        for(String special : specialtyList){
            try{
                for(String cleanName : specialtySF2MarketingMap.get(special)){
                    resultSpecialtySet.add(cleanName);
                }
            }catch(exception ex){}
        }
        List<String> resultSpecialtyList = new List<String>(resultSpecialtySet);
        resultSpecialtyList.sort();
        
        //return the list with commas and a space
        return String.join(resultSpecialtyList, ', ');
    }
    
    //return the portal config from the cache
    @AuraEnabled
    public static Map<String, List<Portal_Picklist__mdt>> loadPicklistValuesApex(String configName){
        //initialize the var
        Map<String, List<Portal_Picklist__mdt>> type2PortalPicklistMap = new Map<String, List<Portal_Picklist__mdt>>();
        //initialize the map
        type2PortalPicklistMap.put('specialty', new List<Portal_Picklist__mdt>());
        type2PortalPicklistMap.put('language', new List<Portal_Picklist__mdt>());
        
        //query for the portal picklist mappings for language and specialty thaT are related to the config
        for(Portal_Picklist__mdt pp : [SELECT English_Label__c, English_Description__c, 
                                    Type__c, Value__c, Spanish_Label__c, Spanish_Description__c FROM Portal_Picklist__mdt
                                    WHERE Provider_Portal_Configuration__r.DeveloperName =:configName AND (Type__c = 'Specialty' OR Type__c='Language') ORDER BY Order__c ASC, English_Label__c ASC]){
            //map the type to the list of portal picklist
            type2PortalPicklistMap.get(pp.Type__c.toLowerCase()).add(pp);
        }
        
        //return the portal configuration
        return type2PortalPicklistMap;
        
    }
    
    @AuraEnabled
    public static List<String> retrievePlanGroupsApex(String businessId){
        //initialize the var
        Set<String> planGroupSet = new Set< String>();

        //retrieve plan guids
        Set<String> planGuidSet = prov_util_Cache.getVisibilePlanWWIds(businessId);
        System.debug('planGuidSet::'+planGuidSet);

        //query for the plans
        for(Account plan : [SELECT id, Plan_Group_Name__c FROM Account WHERE guid__c IN:planGuidSet ORDER BY Plan_Group_Name__c ASC]){
            if(plan.Plan_Group_Name__c != '' && plan.Plan_Group_Name__c != null)
                planGroupSet.add(plan.Plan_Group_Name__c);
        }

        return new List<String>(planGroupSet);

    }
}