/**********************************************************************************************************************
Name                        : wmp_UnitTestFactory
Purpose                     : Factory for creating different objects required for test classes, 
							  no records are inserted in factory
Created on                  : November 2017
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                            By                      Comments
1.0             8           November 2017               	West Monroe Partners    See header - purpose
 
**********************************************************************************************************************/
@isTest
public with sharing class wmp_UnitTestFactory {
	
	public static Account buildTestPlan(){
        RecordType rts = [SELECT Id FROM RecordType WHERE DeveloperName = :'Plan_Account' limit 1];

        Account a = new Account();
        a.RecordTypeId = rts.id;
        a.name = 'The Best and Original Plan';
        a.guid__c = 'planTest1';

		return a;
	}

	public static Account buildTestMemberAccount(String memberName, String street, String city, String state, String postalCode, String phone){
        RecordType rts = [SELECT Id FROM RecordType WHERE DeveloperName = :'Member_Account' limit 1];

        Account a = new Account();
        a.RecordTypeId = rts.id;
        a.name = memberName;
		a.BillingStreet = street;
		a.BillingCity = city;
		a.BillingState = state;
		a.BillingPostalCode = postalCode;
		a.Phone = phone;

		return a;
	}	

	public static Account buildTestProvider(String providerName, String street, String city, String state, String postalCode, String phone){
        RecordType rts = [SELECT Id FROM RecordType WHERE DeveloperName = :'Provider' limit 1];

        Account a = new Account();
        a.RecordTypeId = rts.id;
        a.name = providerName;
        a.npi__c = '11111';
		a.tax_id_number__c = '22222';
		a.BillingStreet = street;
		a.BillingCity = city;
		a.BillingState = state;
		a.BillingPostalCode = postalCode;
		a.Phone = phone;

		return a;
	}	

	public static Providers_Service_Locations__c buildTestPSL(Id providerId, Id serviceLocationId){

		Providers_Service_Locations__c psl = new Providers_Service_Locations__c();
		psl.Provider__c = providerId;
		psl.Service_Location__c	= serviceLocationId;

		return psl;

	}

	public static Account buildTestServiceLocation(String serviceLocationName, String street, String city, String state, String postalCode, String phone){
        RecordType rts = [SELECT Id FROM RecordType WHERE DeveloperName = :'Service_Location' limit 1];

        Account a = new Account();
        a.RecordTypeId = rts.id;
        a.name = serviceLocationName;
		a.BillingStreet = street;
		a.BillingCity = city;
		a.BillingState = state;
		a.BillingPostalCode = postalCode;
		a.Phone = phone;

		return a;
	}

	public static Case buildTestCase(){
		return buildTestCase(null);
	}
	

	public static Case buildTestCase(Id AccountId){
        RecordType rts = [SELECT Id FROM RecordType WHERE DeveloperName = :'General_Case' limit 1];


		Case c = new Case();
		c.AccountId = accountId;
		c.subject = 'Unit Tests';
		c.Type = 'Other';
		c.SubType__c = 'Other';
		c.Status = 'New';
		c.RecordTypeId = rts.id;
		c.Subscriber_ID__c = '1234567';
		return c;
	}

	public static Contact buildTestMemberContact(String firstName, String lastName){
		return buildTestMemberContact(firstName, lastName, null);
	}

	public static Contact buildTestMemberContact(String firstName, String lastName, Id accountId){
        RecordType rts = [SELECT Id FROM RecordType WHERE DeveloperName = :'General_Contact' limit 1];

        Contact c = new Contact();
        c.accountId = accountId;
        c.RecordTypeId = rts.Id;
		c.firstName = firstName; 
		c.lastName = lastName;
		c.mailingStreet = '11100 Liberty Drive';
		c.mailingCity = 'Milwaukee';
		c.mailingState = 'WI';
		c.MailingPostalCode = '53154';
		c.phone = '847-827-1821';
		c.Birthdate = Date.newInstance(2010, 1, 31);
		return c;

	}

	public static Contact buildTestGuardianContact(String firstName, String lastName){
        RecordType rts = [SELECT Id FROM RecordType WHERE DeveloperName = :'Guardian_Contact' limit 1];
		
        Contact c = new Contact();
        c.RecordTypeId = rts.Id;
		c.firstName = firstName; 
		c.lastName = lastName;
		c.mailingStreet = '5200 W Brown Deer Rd';
		c.mailingCity = 'Brown Deer';
		c.mailingState = 'WI';
		c.MailingPostalCode = '53202';
		c.phone = '847-454-9121';
		c.Birthdate = Date.newInstance(1987, 6, 29);
		return c;
	}

	public static mock_Member__c buildTestMember(String memberProfileGUID, String universalMemberGuid){
		mock_Member__c mem = new mock_Member__c();
		mem.MemberProfileGUID__c = memberProfileGUID;
		mem.UniversalMemberGuid__c = universalMemberGuid;
		return mem;
	}

	public static mock_MemberCoverage__c buildTestMemberCoverage(String subscriberId, Id planId, String memCovGUID, Id mockMemId, Id mocksSubId){
		mock_MemberCoverage__c mc = new mock_MemberCoverage__c();
		mc.name = 'Member Coverage';
		mc.Plan__c = planId;
		mc.SubscriberId__c = subscriberId;
		mc.Member__c = mockMemId;
		mc.MemberCoverageGuid__c = memCovGUID;
		mc.Subscriber__c = mocksSubId;
		return mc;
	}

	public static User_Plan_Verification__c buildTestUPV(Id memberContactId, Id guardianContactId, String memCovGUID, String subscriberId, String planId){
		
		User_Plan_Verification__c upv = new User_Plan_Verification__c();
		upv.Member_Contact__c = memberContactId;
		upv.Subscriber_ID__c = subscriberId;
		upv.Plan_ID__c = planId;
		upv.MemberCoverageGuid__c = memCovGUID;
		
		if(guardianContactId != null){
			upv.Guardian_Contact__c = guardianContactId;
		}

		return upv;

	}

}