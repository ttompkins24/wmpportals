/**********************************************************************************************************************
Name                        : 	wmp_handler_JIT
Purpose                     : 	handles just-in-time user provisioning from the IDM SSO
Created on                  : 	10/05/2017
Developed by				: 	Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.0			6.0      	10/05/2017		Patrick Stephens
		

**********************************************************************************************************************/

//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class wmp_handler_JIT implements Auth.SamlJitHandler {
	
    //custom exception class used to generate custom error messages
	private class JitException extends Exception{}
    
    //static variables used in the handler
    global static Map<String,mock_MemberCoverage__c> memberPlans {get;set;}
    global static Map<String,mock_Member__c> membersMap {get;set;}
    global static Map<String,String> mpToProfileGUIDs {get;set;}
    global static String SharingAccountId {get;set;}
    global static boolean isGuardian {get;set;}
    
    //method to retrieve the portal configuration object
	private Portal_Configuration__mdt getPortalConfig(String federationIdentifier){
		//get portal identifier the federationId should be the users email address appended with the memberidentifier
		//eg test@user.com.TX
		//get sharing account id
        try{
            Global_Configuration__c accountId = Global_Configuration__c.getInstance('SharingAccountId');
            SharingAccountId = accountId.value__c;
        }catch (exception ex){
            throw new JitException('No master account defined.');
        }
		Portal_Configuration__mdt portalConfig = null;
        //Set a default value for the portal name
		String PortalName = 'Internal';
        isGuardian = false;
        //incoming federation ids should follow the following pattern
        //sample: 714037998@mailinator.com.gdp-TXmember.GOV.[guardian/member]
        
        //read the federation identifier and parse it for the associate values
		if(federationIdentifier.contains('@')){
			List<String> idDomain = federationIdentifier.split('@')[1].split('-');
            system.debug('fedId: ' + federationIdentifier);
			PortalName = idDomain[1];
            if(PortalName.split('\\.').size()>2){
                string memtype = PortalName.split('\\.')[2].toLowerCase();
                PortalName = PortalName.split('\\.')[0];
                if(memtype=='member' || memtype=='guardian'){
                    isGuardian = (memtype == 'guardian');
                } else {
                    //member-guardian not valid
					throw new JitException('No valid member or guardian indicated.');
                }
            	
            } else {
                //member-guardian not specified
				throw new JitException('No member or guardian indicated.');
            }

		}
        system.debug('PortalConfig Name: ' + portalName);
		List<Portal_Configuration__mdt> configs = (List<Portal_Configuration__mdt>)wmp_util_DAL.dalQuery('Portal_Configuration__mdt',
					'WHERE DeveloperName = \'' + PortalName.toUppercase() + '\'');
		if(configs.size()>0)
			portalConfig = configs[0];
		return portalConfig;	
	}
	
    //method to create the user 
	global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
		User u = new User();
		handleJit(true, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion, getPortalConfig(federationIdentifier));
		system.debug('User: ' + u);
		return u;
	}
	
    //method to update a user, used if the user currently exists
	global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
		User u = [SELECT Id, FirstName, ContactId FROM User WHERE FederationIdentifier = :federationIdentifier];
		handleJit(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion, getPortalConfig(federationIdentifier));
	}
	
    //utility method to process the SAML assertion
	private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion, Portal_Configuration__mdt portalConfig) {
		//setup a debug log 
		system.debug('----ssossossossossossossossossossossossossossossossossossossossossossossossossossossossossosso-----');
		System.debug('Create? ' + create);
		System.debug('provId: ' + samlSsoProviderId);
		System.debug('commID: ' + communityId);
		System.debug('portalId: ' + portalId);
		System.debug('fedId: ' + federationIdentifier);
		System.debug('config: ' + portalConfig);
		system.debug('Attributes: ');
		for(String s : attributes.keyset()){
			system.debug(s + ' : ' + attributes.get(s));
		}
        
		//get the global system owner
		String sysOwner = portalConfig.routeId__c + ' System Owner';
		User owner = [SELECT Id FROM User WHERE Name = :sysOwner];
        
        //find the memberPlan records with the subscriber ID
		memberPlans = wmp_util_DAL.getMembersPlansBySubscriberID(attributes.get('SubscriberID'),portalConfig.RouteID__c);
        system.debug('memberPlan: ' + memberPlans.size());
        //loop through to get memberProfileGUIDs
        mpToProfileGUIDs = new Map<String,String>();
        for(mock_MemberCoverage__c mp : memberPlans.values()){
            system.debug('MP: ' + mp);
            mpToProfileGUIDs.put(mp.MemberCoverageGUID__c.toLowerCase(),mp.MemberProfileGUID__c.toLowerCase());
        } 
		membersMap = wmp_util_DAL.getMembersMap(mpToProfileGUIDs.values(), 
												attributes.get('SubscriberFirstName'), attributes.get('SubscriberLastName'), 
												Date.valueOf(attributes.get('SubscriberBirthDate')),portalConfig.RouteID__c);
        system.debug('membersMap: ' + membersMap);
		if(communityId != null || portalId != null) {
			Account tempAccount = handleAccount(create, u, federationIdentifier, attributes, portalConfig, owner.Id);
			handleContact(create, tempAccount, u, attributes, portalConfig, owner.Id);
			handleUser(create, u, attributes, federationIdentifier, false, portalConfig);
		} else {
			handleUser(create, u, attributes, federationIdentifier, true, portalConfig);
		}
		
		system.debug('----ssossossossossossossossossossossossossossossossossossossossossossossossossossossossossosso-----');
	}
	
    //utility method to instantiate the user record
	private void handleUser(boolean create, User u, Map<String, String> attributes, String federationIdentifier, boolean isStandard, Portal_Configuration__mdt portalConfig) {
		if(create) {
			if(attributes.containsKey('FederationIdentifier')) {
				u.FederationIdentifier = attributes.get('FederationIdentifier');
				u.Username = attributes.get('FederationIdentifier');
			} else {
				u.FederationIdentifier = federationIdentifier;
				u.Username = federationIdentifier;
			}
		}
		
		if(attributes.containsKey('ContactPhone')) {
			u.Phone = attributes.get('ContactPhone');
		}
		if(attributes.containsKey('Email')) {
			u.Email = attributes.get('Email');
		}
		if(attributes.containsKey('UserFirstName')) {
			u.FirstName = attributes.get('UserFirstName');
		}
		if(attributes.containsKey('UserLastName')) {
			u.LastName = attributes.get('UserLastName');
		}

		
		//set defaults
		
		u.ReceivesAdminInfoEmails = false;
		u.ReceivesInfoEmails = false;
		String languageKey = 'en_US';
		if(attributes.containsKey('LanguageID')) {
			if(attributes.get('LanguageID').toLowerCase().trim()=='esp'){
				languageKey = 'es';
            } 
		}

		u.LocaleSidKey = languageKey;
		u.LanguageLocaleKey = languageKey;
		u.EmailEncodingKey = 'ISO-8859-1';
		if(portalConfig!=null && String.isNotBlank(PortalConfig.TimeZoneSidKey__c)){
			u.TimeZoneSidKey = PortalConfig.TimeZoneSidKey__c;
		} else {
			u.TimeZoneSidKey = 'America/New_York';
		}
		if(attributes.containsKey('Alias')) {
			u.Alias = attributes.get('Alias');
		} else if(create) {
			String alias = '';
			if(u.FirstName == null) {
				alias = u.LastName;
			} else {
				alias = u.FirstName.charAt(0) + u.LastName;
			}
			if(alias.length() > 5) {
				alias = alias.substring(0, 5);
			}
			u.Alias = alias;
		}
		
		u.IsActive = true;
		String pName = 'Member Portal ' + portalConfig.routeId__c;
		Profile p = [SELECT Id FROM Profile WHERE Name = :pName];
		u.ProfileId = p.Id;

		if(!create) {
			update(u);
		}
	}

    //utility method to instantiate the contact record
	private void handleContact(boolean create, account tempAccount, User u, Map<String, String> attributes, Portal_Configuration__mdt portalConfig, String ownerID) {
		Contact c;
		boolean newContact = false;
        //create new record or retrieve the existing record
		if(create) {
			c = new Contact();
			newContact = true;
			RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Portal_Contact'];
			c.recordTypeId = rt.Id;
		} else {
			String contactId = u.ContactId;
			c = [SELECT Id, AccountId FROM Contact WHERE Id=:contactId];
		}
        
		system.debug('ContactId: ' + u.contactId);
		system.debug('TempAccount: ' + tempAccount);
		system.debug('Contact: ' + c);
        
        
		if(!newContact && tempAccount != null && c.AccountId != tempAccount.Id) {
			throw new JitException('Mismatched account: ' + c.AccountId + ', ' + tempAccount.Id);
		}
		c.SharingAccount__c = SharingAccountId;
		if(attributes.containsKey('Email')) {
			c.Email = attributes.get('Email');
		}
		if(attributes.containsKey('UserFirstName')) {
			c.FirstName = attributes.get('UserFirstName');
		}
		if(attributes.containsKey('UserLastName')) {
			c.LastName = attributes.get('UserLastName');
		}
		if(attributes.containsKey('ContactPhone')) {
			c.Phone = attributes.get('ContactPhone');
		}
		c.Portal_Name__c = portalConfig.DeveloperName;
		if(newContact) {
			//see if the contact exists but the user does not
			Map<Id,Contact> existingContacts = new Map<Id,Contact>([SELECT ID, FirstName, LastName, OwnerId, AccountID, Phone, Birthdate, Email
												FROM Contact WHERE Email = :c.Email AND FirstName = :c.FirstName 
												AND LastName = :c.LastName AND routeId__c = :portalConfig.routeId__c]);
			system.debug('ExistingCons: ' + existingContacts);
			if(existingContacts.size()>0){
				//check subscriberId
				List<User_Plan_Verification__c> upvs = [SELECT Id, Member_Contact__c, Guardian_Contact__c, routeID__c, Subscriber_Id__c FROM User_Plan_Verification__c 
															WHERE (Member_Contact__c in :existingContacts.keySet() OR Guardian_Contact__c in :existingContacts.keySet()) 
															AND Subscriber_Id__c = :attributes.get('SubscriberID') AND routeId__c = :portalConfig.routeId__c 
															ORDER BY CreatedDate ASC];
				if(upvs.size()>0){
					for(User_Plan_Verification__c upv : upvs){
						if(upv.Guardian_Contact__c != null && existingContacts.containsKey(upv.Guardian_Contact__c)){
							c = existingcontacts.get(upv.Guardian_Contact__c);
						}
						if(upv.Member_Contact__c != null && existingContacts.containsKey(upv.Member_Contact__c)){
							c = existingcontacts.get(upv.Member_Contact__c);
						}
					}
				}
			}
			if(c.Id == null){
				insert tempAccount;
				c.AccountId = tempAccount.id;
				insert c;
			} else {
				//check the account owner
				if(c.accountId!=null){
					List<Account> accs = [SELECT Id, OwnerId FROM Account WHERE Id = :c.AccountId and ownerId != :ownerid];
					if(accs.size()>0){
						if(accs[0].OwnerId!=ownerid){
							accs[0].ownerId = ownerid;
							update accs[0];
						}
					}
				}
			}
			
		} else {
			update(c);
		}
		if(u.contactId==null)
			u.ContactId = c.Id;
		system.debug('Set ContactId: ' + u.contactId);
		//handle User_Plan_Verification__c record
		if(attributes.containsKey('SubscriberID')) {
			Set<String> subPlanComboAdded = new Set<String>();
			if(!newContact){
				//search for existing plan verifications
				List<User_Plan_Verification__c> upvs = (List<User_Plan_Verification__c>)wmp_util_DAL.dalQuery('User_Plan_Verification__c',
								'WHERE Member_Contact__c = \'' + c.Id + '\' OR Guardian_Contact__c = \'' + c.Id + '\'');
				for(User_Plan_Verification__c upv : upvs){
					subPlanComboAdded.add(upv.subscriber_Id__c + upv.plan_Id__c);
				}
			}
			if(membersMap.size()>0){
                //map of subscriber to contact to be sure we don't create multiple member contacts
                Map<String,String> subToMember = new Map<String,String>();
				//get the correct mapping
				List<User_Plan_Verification__c> newUPVs = new List<User_Plan_Verification__c>();
                system.debug('mpGuids: ' + mpToProfileGUIDs);
				for(string mpg : mpToProfileGUIDs.keySet()){
					if(membersMap.containsKey(mpToProfileGUIDs.get(mpg)) 
					&& !subPlanComboAdded.contains(attributes.get('SubscriberID') + memberPlans.get(mpg).planGUID__c)){
						subPlanComboAdded.add(attributes.get('SubscriberID') + memberPlans.get(mpg).planGUID__c);
						User_Plan_Verification__c upv = new User_Plan_Verification__c();
							upv.Subscriber_ID__c = attributes.get('SubscriberID');
							upv.plan_Id__c = memberPlans.get(mpg).planGUID__c;
							upv.memberCoverageGUID__c = mpg;
							//check to see if this is a member or guardian
							if(!isGuardian){
							   	//this is a member
							   	if(c.Birthdate==null){
							   		c.birthdate = date.valueOf(attributes.get('SubscriberBirthDate'));
							   	}
								upv.Member_Contact__c = c.Id;
							} else {
								//this is a guardian -- also create the member
								upv.Guardian_Contact__c = c.Id;
                                if(!subToMember.containsKey(attributes.get('SubscriberID'))){
                                    //we have not added this member yet
                                    upv.Member_Contact__c = wmp_util_MemCoverageVerification.getContactRec(attributes.get('SubscriberFirstName'), attributes.get('SubscriberLastName'),
																										portalConfig.DeveloperName, portalConfig.RouteID__c,
																										attributes.get('SubscriberID'), memberPlans.get(mpg).planGUID__c,
																										date.valueOf(attributes.get('SubscriberBirthDate')));
                                    subToMember.put(attributes.get('SubscriberID'),upv.Member_Contact__c);
                                } else {
                                    //we've created the member, just use the reference 
                                    upv.Member_Contact__c = subToMember.get(attributes.get('SubscriberID'));
                                }
							}
						newUPVS.add(upv);
					}
				}
				if(newUPVs.size()>0 ){
					insert newUpvs;
					update c;
				} else if(subPlanComboAdded.size()<1) {
					//no member match!!!
					throw new JitException('No verified member found.');
				}
			} else {
				//no member match!!!
				//no match on Name and birthdate
				throw new JitException('No valid member found.');
			}	
		}
	}
 
    //instantiate the account record
	private Account handleAccount(boolean create, User u, String federationIdentifier, Map<String, String> attributes, Portal_Configuration__mdt portalConfig, String ownerId) {
		if(create) {
			//create the account
			RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Member_Account'];
			
			Account a = new Account();
				a.Name = federationIdentifier;
				a.RecordTypeId = rt.Id;
				a.First_Name__c = attributes.get('UserFirstName');
				a.Last_Name__c = attributes.get('UserLastName');
				a.route_Id__c = portalConfig.routeId__c;
				a.ownerId = ownerid;
            	a.SharingAccount__c = sharingAccountId;
				a.Site = portalConfig.DeveloperName;
			return a;
		} else {
			//we might need to update account owner
			List<Account> accs = [SELECT Id, OwnerId FROM Account WHERE Name = :federationIdentifier];
			if(accs.size()>0){
				if(accs[0].OwnerId!=ownerid){
					accs[0].ownerId = ownerid;
					update accs[0];
				}
				return accs[0];
			}
			return null;
		}
	}
}