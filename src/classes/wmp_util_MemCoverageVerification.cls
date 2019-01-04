/**********************************************************************************************************************
Name                        : 	wmp_util_MemCoverageVerification
Purpose                     : 	The utility that will retrieve/create the contact/account and the user verification record
Created on                  : 	08/15/2017
Developed by				: 	Todd Tompkins
History
Version#    Sprint#     Date            by                   Comments
1.0			1.0      	09/15/2017		Todd Tompkins	

**********************************************************************************************************************/
public without sharing class wmp_util_MemCoverageVerification {
    
    /*
    	Look to see if the contact exists by searching the user plan verification table; if it does not exist the create the account
    	and the contact and return the contact id
    */
    public static String getContactRec(String fName, String lName, String portalName, String routeId, String memberId, String planId){
    	return getContactRec(fname, lname, portalName,routeId,memberId,planId,null);
    }
    public static String getContactRec(String fName, String lName, String portalName, String routeId, String memberId, String planId, Date birthdate){
    	//initialize the variables
    	Contact con = new Contact();
    	Account acc = new Account();
    	RecordType memAccount = null;// = [SELECT ID from RecordType WHERE DeveloperName='Member_Account'];
    	
    	//set the savepoint
    	Savepoint sp;
    	
    	try{
    		//query for the user plan verification for an existing contact
    		for(User_Plan_Verification__c upv : wmp_util_DAL.getUserPlanVerifications(memberId, planId, routeId) ){
    			if(upv.Member_Contact__c != null){//make sure the member contact is populated
	    			return upv.Member_Contact__c;//return the member contact id
    			}
    		}
            String SharingaccountId = null;
            try{
            	Global_Configuration__c accountId = Global_Configuration__c.getInstance('SharingAccountId');
            	SharingAccountId = accountId.value__c;
            }catch (exception ex){
                system.debug('----------------------------------------------');
                system.debug('Default sharing Account Setting Not Set');
                system.debug(ex.getMessage());
                system.debug('----------------------------------------------');
            }
    		sp = Database.setSavePoint();
    		/********member contact does not exist at this point; need to create the account and contact ***/
    		//get the record type for the member account
    		memAccount = [SELECT ID from RecordType WHERE DeveloperName='Member_Account'];
            String sysOwner = routeId + ' System Owner';
            system.debug('Sys Owner: ' + sysOwner);
    		User owner = [SELECT Id FROM USER WHERE Name = :sysOwner];
    		//create the account for the member contact
    		acc.Name = fName +'_'+lName+'@gdp_'+ portalName+'.com';
    		acc.RecordTypeId = memAccount.Id;
    		acc.First_name__c = fName;
    		acc.Last_name__c = lName;
    		acc.route_id__c = routeId;
    		acc.Site = portalName;
    		acc.ownerID = owner.Id;
            acc.SharingAccount__c = SharingAccountId;
    		//insert the account
    		insert acc;
    		
    		//create the contact
    		con.RecordTypeId = [SELECT Id from RecordType WHERE DeveloperName = 'Guardian_Contact'].Id;
    		con.FirstName = fName;
    		con.LastName = lName;
    		con.Portal_Name__c = portalName;
    		con.AccountId = acc.Id;
    		con.birthdate = birthdate;
            con.SharingAccount__c = SharingAccountId;
    		//insert the contact
    		insert con;
    		
    		//return the contact id
    		return con.Id;
    	} catch(Exception ex){
    		System.debug('message::'+ex.getMessage());
    		System.debug('ln::'+ex.getLineNumber());
            system.debug(ex.getStackTraceString());
    		Database.rollback(sp);
    		return 'Error';
    	}
    	return 'Error';
    }
    
    public static String createUserPlanVerification(String fName, String lName, String planGuid, String memCovGuid, 
    												String subscriberId, Id contactId, Id guardianId ){
    	//initialize the variable
    	User_Plan_Verification__c upv = new User_Plan_Verification__c();
    	Savepoint sp;
    	
    	try{
    		//check to see if the verification record already exists
    		if([SELECT id FROM User_Plan_Verification__c WHERE 
    			Member_Contact__c =: contactId AND Subscriber_ID__c =: subscriberId AND 
    			guardian_Contact__c =: guardianId AND Plan_ID__c =: planGuid].size() > 0){
    			return 'Exists';
    		}
    		
    		sp = Database.setSavePoint();
    		//set the first name
    		upv.Name = fName + ' ' + lName + ' - '+ planGuid;
			//if name is greater than 80 characters, then trim to only 80 characters (limit to 80 characters)
			if(upv.name.length() > 80){
				upv.name = upv.Name.substring(0, 80);
			}
			//set the fields
			upv.Member_Contact__c = contactId;
			upv.MemberCoverageGuid__c = memCovGuid;
			upv.Subscriber_ID__c = subscriberId;
			upv.Plan_ID__c = planGuid;
			upv.guardian_Contact__c = guardianId;
			//insert the upv
			insert upv;	
			return fName;
    	}catch(Exception ex){
    		System.debug('errorMessage::'+ex.getMessage());
    		System.debug('lineNumber::'+ex.getLineNumber());
    		Database.rollback(sp);
    		return 'Error';
    	}
    	return 'Error';
    }
}