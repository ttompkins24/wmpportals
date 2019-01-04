/**********************************************************************************************************************
Purpose						: The controller for the file case. This involves submitting a case and possibly uploading an attachment. Also retrieve the addresses,
							the case types, the members with their member plans
Created on					: 9th Oct 2017
Developed by				: Todd Tompkins
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th Oct 2017					Todd Tompkins					See header - purpose
  

**********************************************************************************************************************/
public without sharing class wmp_ctrl_FileCase {
    
    @AuraEnabled 
    //retrieve the case types that are applicable for this portal
    public static List<Map<String, String>> retrieveCaseTypeInfo (){
		System.debug('starting retrieveCaseTypeInfo...');
    	//initialize the vars
    	String language = UserInfo.getLanguage();
    	Map<String, String> lang2langCodeMap = new Map<String, String>{'en_US'=>'English', 'es' =>'Spanish'};
    	
    	return wmp_util_Cache.util_retrievePicklistValues('Case Type', lang2langCodeMap.get(language) );
    }
    
    @AuraEnabled
    //return the map for the member addresses
    public static Map<String, mock_MemberAddress__c > retrieveMemberAddress(String memCovGuid){
    	//get the member profile guid from the mem coverage record
    	String memProfileGuid = wmp_util_Cache.MemberPlans.get(memCovGuid.toLowerCase()).MemberProfileGUID__c;
    	System.debug('memProfileGuid ::'+memProfileGuid );
    	//return the result
    	return wmp_util_Cache.getMemberAddresses(memProfileGuid);
    }
    
    @AuraEnabled
    //return the member plans that are all the members that the user is able to manage
	public static Map<String,String> retrieveMemberPlans(){
		System.debug('starting retrieveMemberPlans...');
		//initialize variables
		Map<String, String> memCoverageGuid2MemNamePlanMap = new Map<String, String>();
		Map<String, String> planGuid2PlanNameMap = new Map<String, String>();
		
		for(mock_MemberCoverage__c mc : wmp_util_Cache.MemberPlans.values()){
			planGuid2PlanNameMap.put(mc.PlanGuid__c, null);
		}
		System.debug('planGuid2PlanNameMap::'+planGuid2PlanNameMap.keyset());
		
		//query for the plan names
		for(Account acc : [SELECT id, Name, guid__c FROM Account WHERE guid__c IN:planGuid2PlanNameMap.keyset()]){
			planGuid2PlanNameMap.put(acc.guid__c, acc.Name);
		}
		System.debug('planGuid2PlanNameMap::'+planGuid2PlanNameMap);
		
		//loop through the member coverage and map the mem coverage guid to the member name and plan name
		for(mock_MemberCoverage__c mc : wmp_util_Cache.MemberPlans.values()){
			//initialize the fields
			String labelName = '';
			
			//get the member
			mock_Member__c member = wmp_util_Cache.getMember(mc.SubscriberId__c.toLowerCase(), mc.PlanGuid__c.toLowerCase());
			
			//construct the label
			labelName += member.FirstName__c + ' (' + planGuid2PlanNameMap.get(mc.PlanGuid__c)  + ')';
			System.debug('lableName::'+labelName);
			//map the mem coverage guid to the generated label
			memCoverageGuid2MemNamePlanMap.put(mc.MemberCoverageGuid__c, labelName);
		}
		
		return memCoverageGuid2MemNamePlanMap;
	}
    
    @AuraEnabled
    //create the case with the info that is passed to the method
    public static Case createCase(Map<String, String> paramMap){
    	//initialize the var
    	String memberCovGuid = paramMap.get('memberchosen');
    	String caseType = paramMap.get('casetype');
    	String caseDescription = paramMap.containsKey('description') ? paramMap.get('description') : '';
    	String caseResolution = paramMap.containsKey('resolved') ? paramMap.get('resolved') : '';
    	String addressGuid = paramMap.containsKey('addressChosen') ? paramMap.get('addressChosen') : '';
    	Case newCase = new Case();
    	mock_MemberAddress__c memAddress = null;
    	Contact memberContact = null;
    	Contact signedInContact = wmp_util_Cache.ContactRec;
    	Group defaultQueue = [SELECT id FROM Group WHERE DeveloperName='Member_Portal_Cases'];
    	
    	try{
    		//retrieve the member coverage record
    		System.debug('paramMap :: ' + paramMap);
    		System.debug('memberCovGuid :: ' + memberCovGuid);
    		mock_MemberCoverage__c mc = wmp_util_Cache.MemberPlans.get(memberCovGuid.toLowerCase());
    		
    		System.debug('subscriberId::'+mc.SubscriberId__c );
    		System.debug('planGuId::'+mc.PlanGuid__c );
    		//retrieve the member
    		mock_Member__c member = wmp_util_Cache.getMember(mc.SubscriberId__c.toLowerCase(), mc.PlanGuid__c.toLowerCase());
    		System.debug('member::'+member);
    		//retrieve the address
    		system.debug('paramMap: ' + paramMap);
    		system.debug('addressguid: ' + addressGuid);
            system.debug('profileGuid: ' + mc.MemberProfileGUID__c.toLowerCase());
            /*if(String.IsNotBlank(addressGUID)){
    		memAddress = wmp_util_Cache.MemberAddresses.get(mc.MemberProfileGUID__c.toLowerCase()).containsKey(addressGuid) ? 
    										wmp_util_Cache.getMemberAddresses(mc.MemberProfileGUID__c.toLowerCase()).get(addressGuid) : null;
            }	*/
    		//get the selected member contact
    		/*for(User_Plan_Verification__c upv : wmp_util_Cache.getUserPlanVerifications(mc.SubscriberId__c, mc.PlanGuid__c) ){
    			if(upv.Member_Contact__c != null){//make sure the member contact is populated
	    			//query for the contact
	    			memberContact = [SELECT id, FirstName, LastName, AccountId, Name FROM Contact WHERE Id =:upv.Member_Contact__c];
	    			break;
    			}
    		}*/
    		Id upvId = wmp_util_Cache.MemberGuidToPlanVerification.containsKey(mc.MemberCoverageGuid__c.toLowerCase()) ? wmp_util_Cache.MemberGuidToPlanVerification.get(mc.MemberCoverageGuid__c.toLowerCase()) : null;
    		
    		if(upvId != null){
	    		User_Plan_Verification__c upv = wmp_util_Cache.VerifiedPlans.get(upvId);
	    		memberContact = [SELECT id, FirstName, LastName, AccountId, Name FROM Contact WHERE Id =:upv.Member_Contact__c];
	    		
	    		//get the plan
	    		Account plan = [SELECT id FROM Account WHERE guid__c=:mc.PlanGuid__c];
	    		
	    		//create the case
	    		newCase.Subject = caseType;
	    		newCase.Portal_Name_Text__c = wmp_util_Cache.PortalConfiguration.Label;
	    		newCase.Origin = 'Member Portal'; 
	    		newCase.Plan__c = plan.Id;
	    		newCase.Subscriber_ID__c = mc.SubscriberId__c;
	    		newCase.Member_Profile_Guid__c = mc.MemberProfileGuid__c;
	    		newCase.AccountId = memberContact.AccountId;
	    		newCase.ContactId = memberContact.Id;
	    		newCase.Member_DOB__c = member.Birthdate__c;
	    		newCase.Primary_Contact__c = signedInContact.Id;
				newCase.Desired_Resolution__c = caseResolution;
				newCase.Description = caseDescription;
				
				if(defaultQueue != null)
					newCase.OwnerId = defaultQueue.Id;
				
				//set the member address info on the case if populated
				/*if(memAddress != null){
		    		newCase.Member_Address__c = memAddress.AddressLine1__c;
		    		newCase.Member_Address_2__c=  memAddress.AddressLine2__c;
		    		newCase.Member_City__c = memAddress.City__c;
		    		newCase.Member_State__c = memAddress.State__c;
		    		newCase.Member_Zip__c = memAddress.Zip__c;
				}*/
				
				//insert the case
				insert newCase;
				    	
				//query for the case to get the case number
				newCase = [SELECT id, CaseNumber FROM Case where Id=:newCase.id];
		        return newCase;
    		}
    	} catch(Exception ex){
    		System.debug('Error::'+ex.getMessage());
            system.debug(ex.getStackTraceString());
    		System.debug('Error Line Number::'+ex.getLineNumber());
    	} 
    	
    	return null;
    }
    
    @AuraEnabled
    //upload the attachment to the case
    public static void uploadFileAttachment(Id caseId, String fileName, String base64Data, String contentType){
    	//create the attachment on the case
    	base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
    
        Attachment a = new Attachment();
        a.parentId = caseId;
 
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        
        insert a;
    }
}