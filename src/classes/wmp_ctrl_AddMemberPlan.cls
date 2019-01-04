/**********************************************************************************************************************
Purpose						: The controller for the process of adding another member plan that you can manage. This includes yourslef and dependents
Created on					: 9th Oct 2017
Developed by				: Todd Tompkins
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th Oct 2017					Todd Tompkins					See header - purpose
  

**********************************************************************************************************************/
public without sharing class wmp_ctrl_AddMemberPlan {
     
     /* verify the member plan and if it is verified then create the user plan verification */
    @AuraEnabled
    public static String verifyMemberPlan(Map<String, String> paramMap){
    	//initialize the variables
    	List<String> availablePlanGuids = new List<String>(wmp_util_Cache.getPortalPlanList());
    	Map<String, mock_Member__c> memberMap = new Map<String, mock_Member__c>();
    	String portalName = wmp_util_Cache.PortalConfiguration.DeveloperName;
    	String routeID = wmp_util_Cache.PortalConfiguration.RouteID__c;
    	
    	//get current member information
    	String firstName = wmp_util_Cache.ContactRec.FirstName;
    	String lastName = wmp_util_Cache.ContactRec.LastName;
    	Id contactId = wmp_util_Cache.ContactRec.Id;
    	
    	//get the params that are passed to the Verify Member Plan
    	String memberId = paramMap.containsKey('memberId') ? paramMap.get('memberId') : '';
    	Integer dobDay =  paramMap.containsKey('dobDay') ? Integer.valueOf( paramMap.get('dobDay') ) : 1;
    	Integer dobMonth =  paramMap.containsKey('dobMonth') ? Integer.valueOf( paramMap.get('dobMonth') ) : 1;
    	Integer dobYear =  paramMap.containsKey('dobYear') ? Integer.valueOf( paramMap.get('dobYear') ) : Date.today().year() + 100;
    	
    	//create the birthdate 
    	Date birthdate = Date.newInstance(dobYear, dobMonth, dobDay);
    	
    	try{ 
    		System.debug('availablePlanGuids::'+availablePlanGuids);
    		//query for the member coverage record
    		Map<String, mock_MemberCoverage__c> memCoverageMap = wmp_util_DAL.getMembersPlansBySubscriber(String.escapeSingleQuotes(memberId), availablePlanGuids);
    		
    		//check to see if the member coverage record is returned
    		if(memCoverageMap.keyset().size() > 0){
    			//loop through the member coverage records and map the member profile guid
    			for(mock_MemberCoverage__c memCoverage : memCoverageMap.values()){
    				memberMap.put(memCoverage.MemberProfileGuid__c.toLowerCase(), null);
    			}
    			
    			//query for the members 
    			memberMap = wmp_util_DAL.getMembersMap( new List<String>( memberMap.keyset() ) );
    			
    			//make sure there are members
    			if(memberMap.keyset().size() > 0){
    				String planGuid = '';
    				String memCovId = '';
    				
    				//loop through memcoverage and verify the info on the mem coverage and the members
    				for(mock_MemberCoverage__c memCoverage : memCoverageMap.values()){
    					if(memberMap.containsKey(memCoverage.MemberProfileGuid__c.toLowerCase())){
    						//get the member based on the member profile guid
    						mock_Member__c member = memberMap.get(memCoverage.MemberProfileGuid__c.toLowerCase());
    						
    						//validate the birthdate and firstname and lastname
    						if(firstName.equalsIgnoreCase(member.FirstName__c) && lastName.equalsIgnoreCase(member.LastName__c) && birthdate == member.Birthdate__c){
    							planGuid = memCoverage.PlanGuid__c;
    							memCovId = memCoverage.MemberCoverageGUID__c;
    							break;
    						}
	    				}
    				}
    				
    				//if planGuid is not blank then create the verification record
    				if(planGuid != ''){
						//create the verification record
						String userPlanVerficationResponse = wmp_util_MemCoverageVerification.createUserPlanVerification(
														firstName, lastName, planGuid, memCovId, String.escapeSingleQuotes(memberId), contactId, null);
						System.debug('userPlanVerficationResponse::'+userPlanVerficationResponse);
						
						//return the first name and last name so it can be added to the member plan list
						//will return 'Error', the new persons first name or 'Exists' if the user verification record already exists
			    		return userPlanVerficationResponse ;
    				}
    			}    			
    		} 
    		System.debug('return error');
    		return 'Error';
    	} catch(Exception ex){
    		System.debug('******************Error******************');
			System.debug('message::'+ex.getMessage() );
			System.debug('lineNumber::'+ex.getLineNumber() );
    		System.debug('******************Error******************');
    		System.debug('return error');
    		return 'Error';
    	}
    	return 'Error';
    }
    
    /*  Verify that the info that is passed is a valid member plan and the person trying to add the plan is a valid guardian */
    @AuraEnabled
    public static String verifyGuardianMemberPlan(Map<String, String> paramMap){
    	//initialize the variables
        List<String> availablePlanGuids = new List<String>(wmp_util_Cache.getPortalPlanList());
    	Map<String, mock_Member__c> memberMap = new Map<String, mock_Member__c>();
    	Map<String, List<mock_MemberGuardian__c>> memGuardianMap = new Map<String, List<mock_MemberGuardian__c>>();//mem coverage guid 2 the list of member guardian records
    	String portalName = wmp_util_Cache.PortalConfiguration.DeveloperName;
    	String routeID = wmp_util_Cache.PortalConfiguration.RouteID__c;
    	Map<String,List<mock_MemberGuardian__c>> memProfileGuid2MemGuardianMap = new Map<String,List<mock_MemberGuardian__c>>();
    	
    	//get current member information
    	Id guardianId = wmp_util_Cache.ContactRec.Id;
    	
    	//get the params that are passed to the Verify Member Plan
    	String memberId = paramMap.containsKey('memberId') ? paramMap.get('memberId') : '';
    	String memberFirstName = paramMap.containsKey('firstName') ? paramMap.get('firstName') : '';
    	String memberLastName = paramMap.containsKey('lastName') ? paramMap.get('lastName') : '';
    	String guardianFirstName = paramMap.containsKey('guardianFirstName') ? paramMap.get('guardianFirstName') : '';
    	String guardianLastName = paramMap.containsKey('guardianLastName') ? paramMap.get('guardianLastName') : '';
    	Integer dobDay =  paramMap.containsKey('dobDay') ? Integer.valueOf( paramMap.get('dobDay') ) : 1;
    	Integer dobMonth =  paramMap.containsKey('dobMonth') ? Integer.valueOf( paramMap.get('dobMonth') ) : 1;
    	Integer dobYear =  paramMap.containsKey('dobYear') ? Integer.valueOf( paramMap.get('dobYear') ) : Date.today().year() + 100;
    	
    	//create the birthdate 
    	Date birthdate = Date.newInstance(dobYear, dobMonth, dobDay);
    	
    	try{
    		//query for the member coverage record
    		Map<String, mock_MemberCoverage__c> memCoverageMap = wmp_util_DAL.getMembersPlansBySubscriber(String.escapeSingleQuotes(memberId), availablePlanGuids);
    		
    		//check to see if the member coverage record is returned
    		if(memCoverageMap.keyset().size() > 0){
    			//loop through the member coverage records and map the member profile guid
    			for(mock_MemberCoverage__c memCoverage : memCoverageMap.values()){
    				memberMap.put(memCoverage.MemberProfileGuid__c.toLowerCase(), null);
    			}
    			
    			//query for the members 
    			memberMap = wmp_util_DAL.getMembersMap( new List<String>( memberMap.keyset() ) );
    			
    			//query for the guardians
    			memProfileGuid2MemGuardianMap = wmp_util_DAL.getMemberGuardianMap( new List<String>( memberMap.keyset() ) );
    			
    			//make sure there are members
    			if(memberMap.keyset().size() > 0){
    				String planGuid = '';
    				String memCovId = '';
					mock_MemberGuardian__c selectedGuardian = null;
    				
    				//loop through memcoverage and verify the info on the mem coverage and the members
    				for(mock_MemberCoverage__c memCoverage : memCoverageMap.values()){
                            System.debug('memCoverage:::' + memCoverage);
                        if(memberMap.containsKey(memCoverage.MemberProfileGuid__c.toLowerCase()) && memProfileGuid2MemGuardianMap.containsKey(memCoverage.MemberProfileGuid__c.toLowerCase()) ){
                            //get the member based on the member profile guid
                            mock_Member__c member = memberMap.get(memCoverage.MemberProfileGuid__c.toLowerCase());
                            System.debug('availablePlanGuids:::' + availablePlanGuids);
    						System.debug('Member:::' + member);
    						//validate the birthdate and firstname and lastname
    						if(memberFirstName.equalsIgnoreCase(member.FirstName__c) && memberLastName.equalsIgnoreCase(member.LastName__c) && birthdate == member.Birthdate__c ){
    							for(mock_MemberGuardian__c guardian : memProfileGuid2MemGuardianMap.get(memCoverage.MemberProfileGuid__c.toLowerCase())){
    								if(guardianFirstname.equalsIgnoreCase(guardian.Firstname__c) && guardianLastname.equalsIgnoreCase(guardian.Lastname__c)){
		    							planGuid = memCoverage.PlanGuid__c;
		    							memCovId = memCoverage.MemberCoverageGUID__c;
    									selectedGuardian = guardian;
    									break;
    								}
    							}
    							break;
    						}
	    				}
    				}
    				
    				//if planGuid is not blank then create the verification record
    				if(planGuid != ''){
    					//retrieve the contact id for the member
    					String contactId = wmp_util_MemCoverageVerification.getContactRec(
    													memberFirstName, memberLastName, portalName, routeID, String.escapeSingleQuotes(memberId), planGuid);
    													
    					if(contactId != 'Error'){
							//create the verification record
							String userPlanVerficationResponse = wmp_util_MemCoverageVerification.createUserPlanVerification(
															memberFirstName, memberLastName, planGuid, memCovId, String.escapeSingleQuotes(memberId), contactId, guardianId);
							System.debug('userPlanVerficationResponse::'+userPlanVerficationResponse);
							
							//return the first name and last name so it can be added to the member plan list
							//will return 'Error', the new persons first name or 'Exists' if the user verification record already exists
				    		return userPlanVerficationResponse ;
    					}
    				}
    			}    			
    		} 
    		return 'Error';
    	} catch(Exception ex){
    		System.debug('******************Error******************');
			System.debug('message::'+ex.getMessage() );
			System.debug('lineNumber::'+ex.getLineNumber() );
    		System.debug('******************Error******************');
    		return 'Error';
    	}
    	return 'Error';
    }
    
    /*** return the user first name **/
    @AuraEnabled
    public static String getUserName(){
    	return wmp_util_Cache.ContactRec.FirstName;
    }
    
     /*** return the members **/
    @AuraEnabled
    public static List<mock_Member__c> getMembers(){
    	System.debug('members::'+wmp_util_Cache.Members.values());
        Map<String,mock_Member__c> result = new Map<String,mock_Member__c>();
        for(mock_Member__c memb : wmp_util_Cache.Members.values()){
            String memKey = memb.LastName__c + string.valueOf(memb.Birthdate__c);  
            if(!result.containsKey(memKey)){
                result.put(memKey,memb);
            }
        }
    	return result.values();
    }
    /* reload the cache data*/
    @AuraEnabled
    public static void reloadCacheData(){
    	wmp_util_Cache.GetCacheData();
    }
    
    @AuraEnabled
    public static Boolean disbaleSelfCoverage(){
        return wmp_util_Cache.PortalConfiguration.DisableSelfCoverage__c;
    }
}