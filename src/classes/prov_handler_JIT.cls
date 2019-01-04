/**********************************************************************************************************************
Name                        :   prov_handler_JIT
Purpose                     :   handles just-in-time user provisioning from the IDM SSO to the provider portal
Created on                  :   03/01/201
Developed by                :   Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.0         3           03/01/2018      Patrick Stephens
        

**********************************************************************************************************************/
 
//This class provides logic for inbound just-in-time provisioning of single sign-on users to the provider portal.
global class prov_handler_JIT implements Auth.SamlJitHandler {
    
    //custom exception class used to generate custom error messages
    private class JitException extends Exception{}
    
    //static variables used in the handler
    global static String SharingAccountId {get{
        try{
            Global_Configuration__c accountId = Global_Configuration__c.getInstance('SharingAccountId');
            return accountId.value__c;
        }catch (exception ex){
            throw new JitException('No master account defined.');
        }
    }}
    
    global static String providerProfile {get{
        try{
            Global_Configuration__c accountId = Global_Configuration__c.getInstance('Provider Portal Profile Name');
            return accountId.value__c;
        } catch (Exception ex){
            throw new JitException('No master account defined.');
        }
    }}
    
    global static String ownerName {get{
        try{
            Global_Configuration__c accountId = Global_Configuration__c.getInstance('System Owner Name');
            return accountId.value__c;
        } catch (Exception ex){
            throw new JitException('No master account defined.');
        }
    }}
    
    //method to create the user 
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
        handleJit(true, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        system.debug('User: ' + u);
        return u;
    }
    
    //method to update a user, used if the user currently exists
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id, FirstName, ContactId FROM User WHERE FederationIdentifier = :federationIdentifier];
        handleJit(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }
    
    //utility method to process the SAML assertion
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        //setup a debug log 
        system.debug('----ssossossossossossossossossossossossossossossossossossossossossossossossossossossossossosso-----');
        System.debug('Create? ' + create);
        System.debug('provId: ' + samlSsoProviderId);
        System.debug('commID: ' + communityId);
        System.debug('portalId: ' + portalId);
        System.debug('fedId: ' + federationIdentifier);
        system.debug('Attributes: ');
        for(String s : attributes.keyset()){
            system.debug(s + ' : ' + attributes.get(s));
        }
        
        //get the global system owner
        String sysOwner = ownerName;
        User owner = [SELECT Id FROM User WHERE Name = :sysOwner];
       
        if(communityId != null || portalId != null) {
            Account tempAccount = handleAccount(create, u, federationIdentifier, attributes, owner.Id);
            handleContact(create, tempAccount, u, attributes, owner.Id, federationIdentifier);
            handleUser(create, u, attributes, federationIdentifier, false);
        } else {
            handleUser(create, u, attributes, federationIdentifier, true);
        }
        
        system.debug('----ssossossossossossossossossossossossossossossossossossossossossossossossossossossossossosso-----');
    }
    
    //utility method to instantiate the user record
    private void handleUser(boolean create, User u, Map<String, String> attributes, String federationIdentifier, boolean isStandard) {
        if(create) {
            if(attributes.containsKey('FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('FederationIdentifier');
                u.Username = attributes.get('FederationIdentifier') + '@provider.gdp.com';
            } else {
                u.FederationIdentifier = federationIdentifier;
                u.Username = federationIdentifier + '@provider.gdp.com';
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
        if(attributes.containsKey('TimeZone')){
            u.TimeZoneSidKey = attributes.get('TimeZone');
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
        String pName = providerProfile;
        Profile p = [SELECT Id FROM Profile WHERE Name = :pName];
        u.ProfileId = p.Id;

        if(!create) {
            update(u);
        }
    }

    //utility method to instantiate the contact record
    private void handleContact(boolean create, account tempAccount, User u, Map<String, String> attributes, String ownerID, String federationIdentifier) {
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
        if(attributes.containsKey('ProviderRecordAccess')) {
            c.Provider_Portal_Permissions__c = attributes.get('ProviderRecordAccess');
        }
        if(c.Provider_Portal_Permissions__c.indexOf(':') != -1){
        	String businessGuid = c.Provider_Portal_Permissions__c.split(':')[0];
        	
        	List<Account> businessAccs = [SELECT id FROM Account WHERE guid__c =:businessGuid];
        	if(businessAccs.size() > 0)
        		c.Provider_Portal_Business__c = businessAccs[0].Id;
        }
        //if(attributes.containsKey('ProviderRoleAccess')) {
        //    c.Provider_Role_Access__c = attributes.get('ProviderRoleAccess');
        //}
        if(federationIdentifier != null){
            c.federationIdentifier__c = federationIdentifier;
        }

        c.Portal_Name__c = 'ProviderPortal';
        if(newContact) {
            //see if the contact exists but the user does not
            Map<Id,Contact> existingContacts = new Map<Id,Contact>([SELECT ID, FirstName, LastName, OwnerId, AccountID, Phone, Birthdate, Email
                                                FROM Contact WHERE Email = :c.Email AND FirstName = :c.FirstName 
                                                AND LastName = :c.LastName AND Portal_Name__c = 'ProviderPortal' AND federationIdentifier__c = :c.federationIdentifier__c ORDER BY CreatedDate Desc]);
            system.debug('ExistingCons: ' + existingContacts);
            if(existingContacts.size()>0){
                c = existingContacts.values()[0];
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
        
    }
 
    //instantiate the account record
    private Account handleAccount(boolean create, User u, String federationIdentifier, Map<String, String> attributes, String ownerId) {
        String accountName = federationIdentifier;
        if(attributes.containsKey('UserName')){
            accountName = attributes.get('UserName');
        }
        accountName = accountName + '@provider.gdp.com';
        if(create) {
            //create the account
            RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Provider_Portal_Account'];
            Account a = new Account();
                a.Name = accountName ;
                a.RecordTypeId = rt.Id;
                a.First_Name__c = attributes.get('UserFirstName');
                a.Last_Name__c = attributes.get('UserLastName');
                a.ownerId = ownerid;
                a.SharingAccount__c = sharingAccountId;
                a.Site = 'ProviderPortal';
            return a;
        } else {
            //we might need to update account owner
            List<Account> accs = [SELECT Id, OwnerId FROM Account WHERE Name = :accountName];
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