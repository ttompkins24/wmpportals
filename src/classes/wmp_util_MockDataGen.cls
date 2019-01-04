/**********************************************************************************************************************
Name                        : 	wmp_util_MockDataGen
Purpose                     : 	The utility that will generate mock data for external and other objects
Created on                  : 	09/14/2017
Developed by				: 	Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.0			1.0      	09/14/2017		Patrick Stephens	

**********************************************************************************************************************/

global without sharing class wmp_util_MockDataGen {
	 
	//method to generate base data for Portal functionality
	@TestVisible
	global static 	String												genBaseData()											{
		String result = 'MockData Not Generated';
		//check to see if the data exists before we create it
		List<Contact> existingContactData = [SELECT Id FROM Contact WHERE FirstName = 'Bruce' AND LastName = 'Wayne' AND Email = 'iluvbats@test.com'];
		if(existingContactData==null || existingContactData.size()==0){
			Savepoint sp = Database.setSavepoint();
			try{
				//get recordTypes
				List<RecordType> rts = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = true];
				Map<String, RecordType> mrts = new Map<String, RecordType>();
				for(RecordType rt : rts){
					mrts.put(rt.DeveloperName,rt);
				}
				
				
				
				//set static values
					//routeIds 	
					List<String> routeIds = new List<String>{'GOV','GOV_MH'}; 
				
				//generate Accounts
					//Texas and Colorado Client
					List<Account> clients = new List<Account>();
						Account txClt = new Account();
							txClt.route_id__c 				= 			'GOV';
							txClt.Name 							= 			'The State of Texas';
							//txClt.RecordTypeId 					= 			mrts.get('Client_Account').Id;
							txClt.ParentId						=			null;
							txClt.GUID__c				=			'Client 1';
						clients.add(txClt);
						Account coClt = new Account();
							coClt.route_id__c 				= 			'GOV';
							coClt.Name 							= 			'The State of Colorado';
							//coClt.RecordTypeId 					= 			mrts.get('Client_Account').Id;
							coClt.ParentId						=			null;
							coClt.GUID__c				=			'Client 2';
						clients.add(coClt);
					//insert clients;
					
					//Texas and Colorado Group
					List<Account> groups = new List<Account>();
						Account txGrp = new Account();
							txGrp.route_id__c 				= 			'GOV';
							txGrp.Name 							= 			'TX Health and Human Services Commission';
							txGrp.RecordTypeId 					= 			mrts.get('Group_Account').Id;
							//txGrp.ParentId					=			txClt.Id;
							txGrp.GUID__c				=			'Group 1';
						groups.add(txGrp);
						Account coGrp = new Account();
							coGrp.route_id__c 				= 			'GOV';
							coGrp.Name 							= 			'CO GOV Health Group';
							coGrp.RecordTypeId 					= 			mrts.get('Group_Account').Id;
							//coGrp.ParentId					=			coClt.Id;
							coGrp.GUID__c				=			'Group 2';
						groups.add(coGrp);
					insert groups;
					
					//Texas Medicaid and Chip, Colorado Gov plan
					List<Account> plans = new List<Account>();
						Account txP1 = new Account();
							txP1.route_id__c 				= 			'GOV';
							txP1.Name 							= 			'TX HHSC Medicaid Dental Services';
							txP1.RecordTypeId 					= 			mrts.get('Plan_Account').Id;
							txP1.ParentId						=			txGrp.Id;
							txP1.Plan_Group_Name__c				=			'TX Medicaid';
							txP1.Provider_Portal_Requires_Referral__c		=			true;
							txP1.GUID__c				=			'Plan 1';
						plans.add(txP1);
						Account txP2 = new Account();
							txP2.route_id__c 				= 			'GOV';
							txP2.Name 							= 			'TX HHSC CHIP Dental Services';
							txP2.RecordTypeId 					= 			mrts.get('Plan_Account').Id;
							txP2.Plan_Group_Name__c				=			'TX Chip';
							txP2.Provider_Portal_Requires_Referral__c		=			true;
							txP2.ParentId						=			txGrp.Id;
							txP2.GUID__c				=			'Plan 2';
						plans.add(txP2);
						Account coP1 = new Account();
							coP1.route_id__c 				= 			'GOV';
							coP1.Name 							= 			'CO GOV Health Plan';
							coP1.RecordTypeId 					= 			mrts.get('Plan_Account').Id;
							coP1.ParentId						=			coGrp.Id;
							coP1.Plan_Group_Name__c				=			'Health Plan';
							coP1.Provider_Portal_Requires_Referral__c		=			false;
							coP1.GUID__c				=			'Plan 3';
						plans.add(coP1);
					insert plans;
				
					//generate MemberPortal Accounts
					//Two Accounts for each Texas and Colorado Clients
					List<Account> memAccounts = new List<Account>();
						Account txMemAcc1 = new Account();
							txMemAcc1.route_id__c 				= 			'GOV';
							txMemAcc1.Name 							= 			'iluvbats@test.com';
							txMemAcc1.RecordTypeId 					= 			mrts.get('Member_Account').Id;
							txMemAcc1.Site							=			'TXMEMBER';
						memAccounts.add(txMemAcc1);
						Account txMemAcc2 = new Account();
							txMemAcc2.route_id__c 				= 			'GOV';
							txMemAcc2.Name 							= 			'txtest2@test.com';
							txMemAcc2.RecordTypeId 					= 			mrts.get('Member_Account').Id;
							txMemAcc2.Site							=			'TXMEMBER';
						memAccounts.add(txMemAcc2);
						Account txMemAcc3 = new Account();
							txMemAcc3.route_id__c 				= 			'GOV';
							txMemAcc3.Name 							= 			'ihatebats@test.com';
							txMemAcc3.RecordTypeId 					= 			mrts.get('Member_Account').Id;
							txMemAcc3.Site							=			'TXMEMBER';
						memAccounts.add(txMemAcc3);
						Account txMemAcc4 = new Account();
							txMemAcc4.route_id__c 				= 			'GOV';
							txMemAcc4.Name 							= 			'txtest3@test.com';
							txMemAcc4.RecordTypeId 					= 			mrts.get('Member_Account').Id;
							txMemAcc4.Site							=			'TXMEMBER';
						memAccounts.add(txMemAcc4);
						Account txMemAcc5 = new Account();
							txMemAcc5.route_id__c 				= 			'GOV';
							txMemAcc5.Name 							= 			'txtest4@test.com';
							txMemAcc5.RecordTypeId 					= 			mrts.get('Member_Account').Id;
							txMemAcc5.Site							=			'TXMEMBER';
						memAccounts.add(txMemAcc5);
						
						Account coMemAcc1 = new Account();
							coMemAcc1.route_id__c 				= 			'GOV';
							coMemAcc1.Name 							= 			'cotest1@test.com';
							coMemAcc1.RecordTypeId 					= 			mrts.get('Member_Account').Id;
							coMemAcc1.Site							=			'COMEMBER';
						memAccounts.add(coMemAcc1);
						Account coMemAcc2 = new Account();
							coMemAcc2.route_id__c 				= 			'GOV';
							coMemAcc2.Name 							= 			'cotest2@test.com';
							coMemAcc2.RecordTypeId 					= 			mrts.get('Member_Account').Id;
							coMemAcc2.Site							=			'COMEMBER';
						memAccounts.add(coMemAcc2);
					insert memAccounts;
					
				//generate MemberPortalContacts
					//Contacts for Texas and Colorado (portal)
					List<Contact> contacts = new List<Contact>();
					Contact batman = new Contact();
						batman.FirstName 							= 			'Bruce';
						batman.LastName 							=			'Wayne';
						batman.Email								=			'iluvbats@test.com';
						batman.Portal_Name__c						=			'TXMEMBER';
						batman.AccountId							=			txMemAcc1.Id;
						batman.UseAsMockDataRecord__c				= 			true;
						batman.Birthdate							=			Date.newInstance(1939,3,1);
					contacts.add(batman);		
					
					Contact robin = new Contact();
						robin.FirstName 							= 			'Dick';
						robin.LastName 								=			'Grayson';
						robin.Email									=			'ihatebats@test.com';
						robin.Portal_Name__c						=			'TXMEMBER';
						robin.AccountId								=			txMemAcc3.Id;
					contacts.add(robin);	
								
					Contact jim = new Contact();
						jim.FirstName 							= 			'James';
						jim.LastName 							=			'Bowie';
						jim.Email								=			'bigKnife@test.com';
						jim.Portal_Name__c						=			'TXMEMBER';
						jim.AccountId							=			txMemAcc2.Id;
					contacts.add(jim);
					Contact davy = new Contact();
						davy.FirstName 							= 			'Davy';
						davy.LastName 							=			'Crocket';
						davy.Email								=			'kingofthewildfrontier@test.com';
						davy.Portal_Name__c						=			'TXMEMBER';
						davy.AccountId							=			txMemAcc4.Id;
					contacts.add(davy);
					Contact george = new Contact();
						george.FirstName 							= 			'George';
						george.LastName 							=			'Cottle';
						george.Email								=			'alamowho@test.com';
						george.Portal_Name__c						=			'TXMEMBER';
						george.AccountId							=			txMemAcc5.Id;
					contacts.add(george);
					
					Contact liane = new Contact();
						liane.FirstName 						= 			'Liane';
						liane.LastName 							=			'Cartman';
						liane.Email								=			'lc@test.com';
						liane.Portal_Name__c					=			'COMEMBER';
						liane.AccountId							=			coMemAcc1.Id;
					contacts.add(liane);
					
					Contact eric = new Contact();
						eric.FirstName 							= 			'Eric';
						eric.LastName 							=			'Cartman';
						eric.Email								=			'ec@test.com';
						eric.Portal_Name__c						=			'COMEMBER';
						eric.AccountId							=			coMemAcc2.Id;
					contacts.add(eric);
					
				insert contacts;
				
				//generate MemberExternalData
					//generate Member
					List<mock_Member__c> members = new List<mock_Member__c>();
					mock_Member__c mem1 = new mock_Member__c();
						mem1.Birthdate__c						=			Date.newInstance(1939,3,1);
						mem1.FirstName__c						=			'Bruce';
						mem1.Gender__c							=			'M';
						mem1.IsConfidential__c					=			false;
						mem1.LastName__c						=			'Wayne';
						mem1.MemberProfileGUID__c				=			'Profile 1';
						mem1.MiddleName__c						=			null;
						mem1.NamePrefix__c						=			'';
						mem1.NameSuffix__c						=			null;
						mem1.RouteId__c							=			'GOV';
						mem1.UniversalMemberGuid__c				=			'UID 1';
					members.add(mem1);
					mock_Member__c mem2 = new mock_Member__c();
						mem2.Birthdate__c						=			Date.newInstance(1940,4,1);
						mem2.FirstName__c						=			'Richard';
						mem2.Gender__c							=			'M';
						mem2.IsConfidential__c					=			false;
						mem2.LastName__c						=			'Grayson';
						mem2.MemberProfileGUID__c				=			'Profile 2';
						mem2.MiddleName__c						=			'John';
						mem2.NamePrefix__c						=			'';
						mem2.NameSuffix__c						=			null;
						mem2.RouteId__c							=			'GOV';
						mem2.UniversalMemberGuid__c				=			'UID 2';
					members.add(mem2);
					mock_Member__c mem3 = new mock_Member__c();
						mem3.Birthdate__c						=			Date.newInstance(1796,3,10);
						mem3.FirstName__c						=			'James';
						mem3.Gender__c							=			'M';
						mem3.IsConfidential__c					=			false;
						mem3.LastName__c						=			'Bowie';
						mem3.MemberProfileGUID__c				=			'Profile 3';
						mem3.MiddleName__c						=			null;
						mem3.NamePrefix__c						=			'';
						mem3.NameSuffix__c						=			null;
						mem3.RouteId__c							=			'GOV';
						mem3.UniversalMemberGuid__c				=			'UID 3';
					members.add(mem3);
					mock_Member__c mem4 = new mock_Member__c();
						mem4.Birthdate__c						=			Date.newInstance(2011,8,17);
						mem4.FirstName__c						=			'Davy';
						mem4.Gender__c							=			'M';
						mem4.IsConfidential__c					=			false;
						mem4.LastName__c						=			'Crocket';
						mem4.MemberProfileGUID__c				=			'Profile 4';
						mem4.MiddleName__c						=			null;
						mem4.NamePrefix__c						=			'';
						mem4.NameSuffix__c						=			'Esq.';
						mem4.RouteId__c							=			'GOV';
						mem4.UniversalMemberGuid__c				=			'UID 4';
					members.add(mem4);
					mock_Member__c mem5 = new mock_Member__c();
						mem5.Birthdate__c						=			Date.newInstance(2012,5,13);
						mem5.FirstName__c						=			'George';
						mem5.Gender__c							=			'M';
						mem5.IsConfidential__c					=			false;
						mem5.LastName__c						=			'Cottle';
						mem5.MemberProfileGUID__c				=			'Profile 5';
						mem5.MiddleName__c						=			'Washington';
						mem5.NamePrefix__c						=			'';
						mem5.NameSuffix__c						=			null;
						mem5.RouteId__c							=			'GOV';
						mem5.UniversalMemberGuid__c				=			'UID 5';
					members.add(mem5);
					mock_Member__c mem6 = new mock_Member__c();
						mem6.Birthdate__c						=			Date.newInstance(2013,11,1);
						mem6.FirstName__c						=			'Susanna';
						mem6.Gender__c							=			'F';
						mem6.IsConfidential__c					=			false;
						mem6.LastName__c						=			'Dickinson';
						mem6.MemberProfileGUID__c				=			'Profile 6';
						mem6.MiddleName__c						=			null;
						mem3.NamePrefix__c						=			'';
						mem6.NameSuffix__c						=			null;
						mem6.RouteId__c							=			'GOV';
						mem6.UniversalMemberGuid__c				=			'UID 6';
					members.add(mem6);
					mock_Member__c mem7 = new mock_Member__c();
						mem7.Birthdate__c						=			Date.newInstance(1796,09,27);
						mem7.FirstName__c						=			'Juana';
						mem7.Gender__c							=			'M';
						mem7.IsConfidential__c					=			false;
						mem7.LastName__c						=			'Alsbury';
						mem7.MemberProfileGUID__c				=			'Profile 7';
						mem7.MiddleName__c						=			'Navarro';
						mem7.NamePrefix__c						=			'Mrs.';
						mem7.NameSuffix__c						=			null;
						mem7.RouteId__c							=			'GOV';
						mem7.UniversalMemberGuid__c				=			'UID 7';
					members.add(mem7);
					
					mock_Member__c mem8 = new mock_Member__c();
						mem8.Birthdate__c						=			Date.newInstance(1796,09,27);
						mem8.FirstName__c						=			'Liane';
						mem8.Gender__c							=			'F';
						mem8.IsConfidential__c					=			false;
						mem8.LastName__c						=			'Cartman';
						mem8.MemberProfileGUID__c				=			'Profile 8';
						mem8.MiddleName__c						=			'';
						mem8.NamePrefix__c						=			'Ms.';
						mem8.NameSuffix__c						=			null;
						mem8.RouteId__c							=			'GOV';
						mem8.UniversalMemberGuid__c				=			'UID 8';
					members.add(mem8);
					mock_Member__c mem9 = new mock_Member__c();
						mem9.Birthdate__c						=			Date.newInstance(1796,09,27);
						mem9.FirstName__c						=			'Eric';
						mem9.Gender__c							=			'M';
						mem9.IsConfidential__c					=			false;
						mem9.LastName__c						=			'Cartman';
						mem9.MemberProfileGUID__c				=			'Profile 9';
						mem9.MiddleName__c						=			'';
						mem9.NamePrefix__c						=			'';
						mem9.NameSuffix__c						=			null;
						mem9.RouteId__c							=			'GOV';
						mem9.UniversalMemberGuid__c				=			'UID 9';
					members.add(mem9);
					
					insert members;
					
					//generate MemberAddress
					List<mock_MemberAddress__c> memAdds = new List<mock_MemberAddress__c>();
					mock_MemberAddress__c mAdd1 = new mock_MemberAddress__c();
						mAdd1.AddressLine1__c					=			'2424 Swiss Ave';
						mAdd1.AddressLine2__c					=			'Gotham';
						mAdd1.City__c							=			'Dallas';
						mAdd1.Country__c						=			'';
						mAdd1.CountyName__c						=			'';
						mAdd1.Latitude__c						=			32.784775;
						mAdd1.Longitude__c						=			-96.790142;
						mAdd1.MemberAddressGUID__c				=			'Address 1';
						mAdd1.Member__c							=			mem1.Id;	
						mAdd1.RouteId__c						=			'GOV';
						mAdd1.State__c							=			'TX';
						mAdd1.Type__c							=			'';
						mAdd1.Zip__c							=			'75204';
						mAdd1.ZipFour__c						=			null;
					memAdds.add(mAdd1);
					mock_MemberAddress__c mAdd2 = new mock_MemberAddress__c();
						mAdd2.AddressLine1__c					=			'2424 Swiss Ave';
						mAdd2.AddressLine2__c					=			'Gotham';
						mAdd2.City__c							=			'Dallas';
						mAdd2.Country__c						=			'';
						mAdd2.CountyName__c						=			'';
						mAdd2.Latitude__c						=			32.784775;
						mAdd2.Longitude__c						=			-96.790142;
						mAdd2.MemberAddressGUID__c				=			'Address 2';
						mAdd2.Member__c							=			mem2.Id;
						mAdd2.RouteId__c						=			'GOV';
						mAdd2.State__c							=			'TX';
						mAdd2.Type__c							=			'';
						mAdd2.Zip__c							=			'75204';
						mAdd2.ZipFour__c						=			null;
					memAdds.add(mAdd2);
					mock_MemberAddress__c mAdd3 = new mock_MemberAddress__c();
						mAdd3.AddressLine1__c					=			'300 Alamo Plaza, San Antonio';
						mAdd3.AddressLine2__c					=			'';
						mAdd3.City__c							=			'San Antonio';
						mAdd3.Country__c						=			'';
						mAdd3.CountyName__c						=			'';
						mAdd3.Latitude__c						=			29.425607;
						mAdd3.Longitude__c						=			-98.486155;
						mAdd3.MemberAddressGUID__c				=			'Address 3';
						mAdd3.Member__c							=			mem3.Id;
						mAdd3.RouteId__c						=			'GOV';
						mAdd3.State__c							=			'TX';
						mAdd3.Type__c							=			'';
						mAdd3.Zip__c							=			'78205';
						mAdd3.ZipFour__c						=			null;
					memAdds.add(mAdd3);
					mock_MemberAddress__c mAdd4 = new mock_MemberAddress__c();
						mAdd4.AddressLine1__c					=			'300 Alamo Plaza, San Antonio';
						mAdd4.AddressLine2__c					=			'';
						mAdd4.City__c							=			'San Antonio';
						mAdd4.Country__c						=			'';
						mAdd4.CountyName__c						=			'';
						mAdd4.Latitude__c						=			29.425607;
						mAdd4.Longitude__c						=			-98.486155;
						mAdd4.MemberAddressGUID__c				=			'Address 4';
						mAdd4.Member__c							=			mem4.Id;	
						mAdd4.RouteId__c						=			'GOV';
						mAdd4.State__c							=			'TX';
						mAdd4.Type__c							=			'';
						mAdd4.Zip__c							=			'78205';
						mAdd4.ZipFour__c						=			null;
					memAdds.add(mAdd4);
					mock_MemberAddress__c mAdd5 = new mock_MemberAddress__c();
						mAdd5.AddressLine1__c					=			'210 W Market St';
						mAdd5.AddressLine2__c					=			'';
						mAdd5.City__c							=			'San Antonio';
						mAdd5.Country__c						=			'';
						mAdd5.CountyName__c						=			'';
						mAdd5.Latitude__c						=			29.425607;
						mAdd5.Longitude__c						=			-98.486155;
						mAdd5.MemberAddressGUID__c				=			'Address 5';
						mAdd5.Member__c							=			mem5.Id;
						mAdd5.RouteId__c						=			'GOV';
						mAdd5.State__c							=			'TX';
						mAdd5.Type__c							=			'';
						mAdd5.Zip__c							=			'78205';
						mAdd5.ZipFour__c						=			null;
					memAdds.add(mAdd5);
					//no six or seven
					
					mock_MemberAddress__c mAdd8 = new mock_MemberAddress__c();
						mAdd8.AddressLine1__c					=			'639 Hathaway St';
						mAdd8.AddressLine2__c					=			'';
						mAdd8.City__c							=			'Fairplay';
						mAdd8.Country__c						=			'';
						mAdd8.CountyName__c						=			'';
						mAdd8.Latitude__c						=			39.223678;
						mAdd8.Longitude__c						=			-105.999906;
						mAdd8.MemberAddressGUID__c				=			'Address 8';
						mAdd8.Member__c							=			mem8.Id;	
						mAdd8.RouteId__c						=			'GOV';
						mAdd8.State__c							=			'CO';
						mAdd8.Type__c							=			'';
						mAdd8.Zip__c							=			'80440';
						mAdd8.ZipFour__c						=			null;
					memAdds.add(mAdd8);
					mock_MemberAddress__c mAdd9 = new mock_MemberAddress__c();
						mAdd9.AddressLine1__c					=			'639 Hathaway St';
						mAdd9.AddressLine2__c					=			'';
						mAdd9.City__c							=			'Fairplay';
						mAdd9.Country__c						=			'';
						mAdd9.CountyName__c						=			'';
						mAdd9.Latitude__c						=			29.425607;
						mAdd9.Longitude__c						=			-98.486155;
						mAdd9.MemberAddressGUID__c				=			'Address 9';
						mAdd9.Member__c							=			mem9.Id;	
						mAdd9.RouteId__c						=			'GOV';
						mAdd9.State__c							=			'CO';
						mAdd9.Type__c							=			'';
						mAdd9.Zip__c							=			'80440';
						mAdd9.ZipFour__c						=			null;
					memAdds.add(mAdd9);
					insert memAdds;
					 
					//generate MemberPhone
					List<mock_MemberPhone__c> memPhones = new List<mock_MemberPhone__c>();
					for(integer i=1;i<=9;i++){
						mock_MemberPhone__c mPh1 = new mock_MemberPhone__c();
							mPh1.Extension__c 						= 			'';
							mPh1.MemberPhoneGuid__c					=			'Phone ' + string.valueOf(i);
							mPh1.Member__c							=			members[(i-1)].Id;
							mPh1.Number__c							=			string.valueOf(i) + '23456789' + string.valueOf(i);
							mPh1.RouteId__c							=			'GOV';
							mPh1.Type__c							=			'Home';
						memPhones.add(mPh1);
					}
					
					insert memPhones;
					
					//generate MemberUniversalID
					List<mock_MemberUniversalID__c> memUIDs = new List<mock_MemberUniversalID__c>();
					for(integer i=1;i<=9;i++){
						mock_MemberUniversalID__c mUID = new mock_MemberUniversalID__c();
							mUID.UniversalMemberGuid__c				=			'UID ' + string.valueOf(i);
							mUID.Member__c							=			members[(i-1)].Id;
							mUID.RouteId__c							=			'GOV';
							muID.MemberUniversalIDGUID__c			=			'UIDX ' + string.valueOf(i);
						memUIDs.add(mUID);
					}
					
					insert memUIDs;
					
					//generate MemberCoverage
					List<mock_MemberCoverage__c> memCovs = new List<mock_MemberCoverage__c>();
					//generate User Plan Verification records at the same time
					List<User_Plan_Verification__c> upvs = new List<User_Plan_Verification__c>();
					
					//generate 1 active coverage for Bruce and 2 active for Dick Grayson
					//generate 1 UPVR for Bruce and Dick under Bruce's record
					mock_MemberCoverage__c mcBat = new mock_MemberCoverage__c();
						mcBat.TerminationDate__c 				= 			date.newInstance(date.today().year(),12,31);
						mcBat.MemberCoverageGuid__c				=			'MC 1';
						mcBat.Member__c							=			mem1.Id;
						mcBat.EffectiveDate__c					=			date.newInstance(date.today().year(),1,1);
						mcBat.RouteId__c						=			'GOV';
						mcBat.AidCategory__c					=			'';
						mcBat.CoverageLevelCode__c				=			'';
						mcBat.MedicaidId__c						=			'';
						mcBat.Plan__c							=			txP1.Id;
						mcBat.Subscriber__c						=			mem1.Id;
						mcBat.SubscriberId__c					=			'SUB 1';
					memCovs.add(mcBat);
					User_Plan_Verification__c upvBat = new User_Plan_Verification__c();
						upvBat.Guardian_Contact__c				=			null;
						upvBat.Member_Contact__c				=			batman.id;
						upvBat.MemberCoverageGuid__c			=			'MC 1';
						upvBat.Plan_ID__c						= 			txP1.GUID__c;
						upvBat.Subscriber_ID__c					=			'SUB 1';
					upvs.add(upvBat);
					
					mock_MemberCoverage__c mcRobin1 = new mock_MemberCoverage__c();
						mcRobin1.TerminationDate__c 				= 			date.newInstance(date.today().year(),12,31);
						mcRobin1.MemberCoverageGuid__c				=			'MC 2';
						mcRobin1.Member__c							=			mem2.Id;
						mcRobin1.EffectiveDate__c					=			date.newInstance(date.today().year(),1,1);
						mcRobin1.RouteId__c							=			'GOV';
						mcRobin1.AidCategory__c						=			'';
						mcRobin1.CoverageLevelCode__c				=			'';
						mcRobin1.MedicaidId__c						=			'';
						mcRobin1.Plan__c							=			txP1.Id;
						mcRobin1.Subscriber__c						=			mem2.Id;
						mcRobin1.SubscriberId__c					=			'SUB 2';
					memCovs.add(mcRobin1);
					mock_MemberCoverage__c mcRobin2 = new mock_MemberCoverage__c();
						mcRobin2.TerminationDate__c 				= 			date.newInstance(date.today().year(),12,31);
						mcRobin2.MemberCoverageGuid__c				=			'MC 3';
						mcRobin2.Member__c							=			mem2.Id;
						mcRobin2.EffectiveDate__c					=			date.newInstance(date.today().year(),1,1);
						mcRobin2.RouteId__c							=			'GOV';
						mcRobin2.AidCategory__c						=			'';
						mcRobin2.CoverageLevelCode__c				=			'';
						mcRobin2.MedicaidId__c						=			'';
						mcRobin2.Plan__c							=			txP2.Id;
						mcRobin2.Subscriber__c						=			mem2.Id;
						mcRobin2.SubscriberId__c					=			'SUB 3';
					memCovs.add(mcRobin2);
					User_Plan_Verification__c upvRobin1 = new User_Plan_Verification__c();
						upvRobin1.Guardian_Contact__c				=			batman.id;
						upvRobin1.Member_Contact__c					=			robin.id;
						upvRobin1.MemberCoverageGuid__c				=			'MC 2';
						upvRobin1.Plan_ID__c						= 			txP1.GUID__c;
						upvRobin1.Subscriber_ID__c					=			'SUB 2';
					upvs.add(upvRobin1);
					User_Plan_Verification__c upvRobin2 = new User_Plan_Verification__c();
						upvRobin2.Guardian_Contact__c				=			batman.id;
						upvRobin2.Member_Contact__c					=			robin.id;
						upvRobin2.MemberCoverageGuid__c				=			'MC 3';
						upvRobin2.Plan_ID__c						= 			txP2.GUID__c;
						upvRobin2.Subscriber_ID__c					=			'SUB 3';

					upvs.add(upvRobin2);
					
					//generate 1 active coverage for jim Bowie
					//generate 1 UPVR for all alamo dependents under Jim's record
					mock_MemberCoverage__c mcJim = new mock_MemberCoverage__c();
						mcJim.TerminationDate__c 				= 			date.newInstance(date.today().year(),12,31);
						mcJim.MemberCoverageGuid__c				=			'MC 4';
						mcJim.Member__c							=			mem3.Id;
						mcJim.EffectiveDate__c					=			date.newInstance(date.today().year(),1,1);
						mcJim.RouteId__c						=			'GOV';
						mcJim.AidCategory__c					=			'';
						mcJim.CoverageLevelCode__c				=			'';
						mcJim.MedicaidId__c						=			'';
						mcJim.Plan__c						=			txP1.Id;
						mcJim.Subscriber__c						=			mem3.Id;
						mcJim.SubscriberId__c					=			'SUB 4';
					memCovs.add(mcJim);
					
					//generate 1 active coverage for the first twoof the alamo dependents and 1 inactive coverage
					integer counter = 5;
					for(integer i=4;i<=7;i++){
						mock_MemberCoverage__c mACov = new mock_MemberCoverage__c();
							mACov.TerminationDate__c 				= 			date.newInstance(date.today().year(),12,31);
							mACov.MemberCoverageGuid__c				=			'MC ' + string.valueOf(counter);
							mACov.Member__c							=			members[(i-1)].Id;
							mACov.EffectiveDate__c					=			date.newInstance(date.today().year(),1,1);
							mACov.RouteId__c						=			'GOV';
							mACov.AidCategory__c					=			'';
							mACov.CoverageLevelCode__c				=			'';
							mACov.MedicaidId__c						=			'';
							mACov.Plan__c							=			txP2.Id;
							mACov.Subscriber__c						=			members[(i-1)].Id;
							mACov.SubscriberId__c					=			'SUB '+ string.valueOf(counter);
						memCovs.add(mACov);
						if(i==4){
							User_Plan_Verification__c upvAlamo = new User_Plan_Verification__c();
								upvAlamo.Guardian_Contact__c			=			jim.id;
								upvAlamo.Member_Contact__c				=			davy.id;
								upvAlamo.MemberCoverageGuid__c			=			'MC ' + string.valueOf(counter);
								upvAlamo.Plan_ID__c						= 			txP2.GUID__c;
								upvAlamo.Subscriber_ID__c				=			'SUB '+ string.valueOf(counter);
							upvs.add(upvAlamo);
						} else if(i==5){
							User_Plan_Verification__c upvAlamo = new User_Plan_Verification__c();
								upvAlamo.Guardian_Contact__c			=			jim.id;
								upvAlamo.Member_Contact__c				=			george.id;
								upvAlamo.MemberCoverageGuid__c			=			'MC ' + string.valueOf(counter);
								upvAlamo.Plan_ID__c						= 			txP2.GUID__c;
								upvAlamo.Subscriber_ID__c				=			'SUB '+ string.valueOf(counter);
							upvs.add(upvAlamo);
						}
						counter++;
						mock_MemberCoverage__c mICov = new mock_MemberCoverage__c();
							mICov.TerminationDate__c 				= 			date.newInstance(date.today().year()-1,1,31);
							mICov.MemberCoverageGuid__c				=			'MC ' + string.valueOf(counter);
							mICov.Member__c							=			members[(i-1)].Id;
							mICov.EffectiveDate__c					=			date.newInstance(date.today().year()-1,1,1);
							mICov.RouteId__c						=			'GOV';
							mICov.AidCategory__c					=			'';
							mICov.CoverageLevelCode__c				=			'';
							mICov.MedicaidId__c						=			'';
							mICov.Plan__c							=			txP2.Id;
							mICov.Subscriber__c						=			members[(i-1)].Id;
							mICov.SubscriberId__c					=			'SUB '+ string.valueOf(counter-1);
						memCovs.add(mICov);
						counter++;
					}
					
					//generate two active coverages for all Colorado members
					//generate 1 UPVR for Eric under Liane's record
					for(integer i=8;i<=9;i++){
						mock_MemberCoverage__c mACov = new mock_MemberCoverage__c();
							mACov.TerminationDate__c 				= 			date.newInstance(date.today().year(),12,31);
							mACov.MemberCoverageGuid__c				=			'MC ' + string.valueOf(counter);
							mACov.Member__c							=			members[(i-1)].Id;
							mACov.EffectiveDate__c					=			date.newInstance(date.today().year(),1,1);
							mACov.RouteId__c						=			'GOV';
							mACov.AidCategory__c					=			'';
							mACov.CoverageLevelCode__c				=			'';
							mACov.MedicaidId__c						=			'';
							mACov.Plan__c							=			coP1.Id;
							mACov.Subscriber__c						=			members[(i-1)].Id;
							mACov.SubscriberId__c					=			'SUB ' + string.valueOf(counter);
						memCovs.add(mACov);
						counter++;
						mock_MemberCoverage__c mICov = new mock_MemberCoverage__c();
							mICov.TerminationDate__c 				= 			date.newInstance(date.today().year()-1,1,31);
							mICov.MemberCoverageGuid__c				=			'MC ' + string.valueOf(counter);
							mICov.Member__c							=			members[(i-1)].Id;
							mICov.EffectiveDate__c					=			date.newInstance(date.today().year()-1,1,1);
							mICov.RouteId__c						=			'GOV';
							mICov.AidCategory__c					=			'';
							mICov.CoverageLevelCode__c				=			'';
							mICov.MedicaidId__c						=			'';
							mICov.Plan__c							=			coP1.Id;
							mICov.Subscriber__c						=			members[(i-1)].Id;
							mICov.SubscriberId__c					=			'SUB ' + string.valueOf(counter-1);
						memCovs.add(mICov);
						counter++;
					}
					User_Plan_Verification__c upvEric = new User_Plan_Verification__c();
						upvEric.Guardian_Contact__c				=			liane.id;
						upvEric.Member_Contact__c				=			eric.id;
						upvEric.MemberCoverageGuid__c			=			'MC ' + string.valueOf(counter-1);
						upvEric.Plan_ID__c						= 			coP1.GUID__c;
						upvEric.Subscriber_ID__c				=			'SUB '+ string.valueOf(counter-1);
					upvs.add(upvEric);
					
					insert memCovs;
					insert upvs;
					 
					counter = 1;
					//generate MemberPrimaryCareDentist
					List<mock_MemberPrimaryCareDentist__c> mPCDs = new List<mock_MemberPrimaryCareDentist__c>();
					for(mock_MemberCoverage__c mc : memCovs){
						mock_MemberPrimaryCareDentist__c mPCD = new mock_MemberPrimaryCareDentist__c();
							mPCD.EffectiveDate__c 					= 			date.newInstance(date.today().year(),1,1);
							mPCD.MemberPcdGuid__c					=			'MPCD ' + string.valueOf(counter);
							mPCD.MemberCoverage__c					=			mc.Id;
							mPCD.TerminationDate__c					=			date.newInstance(date.today().year(),12,31);
							mPCD.RouteId__c							=			'GOV';
							mPCD.ProviderGUID__c					=			'Provider 1';
							mPCD.ServiceLocationGUID__c				=			'SLOC 1';
							mPCD.TerminationReason__c				=			null;
							mPCD.PlanGUID__c						= 			'plan 1';

						mPCDs.add(mPCD);
						counter++;
						mock_MemberPrimaryCareDentist__c mPCDI = new mock_MemberPrimaryCareDentist__c();
							mPCDI.EffectiveDate__c 					= 			date.newInstance(date.today().year()-1,1,1);
							mPCDI.MemberPcdGuid__c					=			'UID ' + string.valueOf(counter);
							mPCDI.MemberCoverage__c					=			mc.Id;
							mPCDI.TerminationDate__c				=			date.newInstance(date.today().year()-1,1,31);
							mPCDI.RouteId__c						=			'GOV';
							mPCDI.ProviderGUID__c					=			'Provider 2';
							mPCDI.ServiceLocationGUID__c			=			'SLOC 2';
							mPCDI.TerminationReason__c				=			null;
							mPCDI.PlanGUID__c						= 			'plan 2';

						mPCDs.add(mPCDI);
						counter++;
					}
					
					insert mPCDs;
					
					//generate MemberServiceHistory
					//generate MemberGuardian
					List<mock_MemberGuardian__c> memGs = new List<mock_MemberGuardian__c>();
					counter = 1;
					//Dick is a ward of Bruce
					mock_MemberGuardian__c mgd = new mock_MemberGuardian__c();
						mgd.MemberGuardianGuid__c 			= 			'MG ' + String.valueOf(counter);
						mgd.GuardianType__c					=			'GaurdianType';
						mgd.Member__c						=			mem2.Id;
						mgd.GuardianId__c					=			null;
						mgd.RouteId__c						=			'GOV';
						mgd.Birthdate__c					=			mem2.BirthDate__c;
						mgd.FirstName__c					=			'Bruce';
						mgd.LastName__c						=			'Wayne';
						mgd.MiddleName__c					=			null;
						mgd.NamePrefix__c					=			null;
						mgd.NameSuffix__c					=			null;
					memGs.add(mgd);
					counter++;
					//alamo dependents
					
					for(integer i=4;i<=7;i++){
						mock_MemberGuardian__c mg = new mock_MemberGuardian__c();
							mg.MemberGuardianGuid__c 			= 			'MG ' + String.valueOf(counter);
							mg.GuardianType__c					=			'GaurdianType';
							mg.Member__c						=			members[(i-1)].Id;
							mg.GuardianId__c					=			null;
							mg.RouteId__c						=			'GOV';
							mg.Birthdate__c						=			members[(i-1)].BirthDate__c;
							mg.FirstName__c						=			'Jim';
							mg.LastName__c						=			'Bowie';
							mg.MiddleName__c					=			null;
							mg.NamePrefix__c					=			null;
							mg.NameSuffix__c					=			null;
						memGs.add(mg);
						counter++;
					}
					
					//eric is a dependent
					mock_MemberGuardian__c mge = new mock_MemberGuardian__c();
						mge.MemberGuardianGuid__c 			= 			'MG ' + String.valueOf(counter);
						mge.GuardianType__c					=			'GaurdianType';
						mge.Member__c						=			mem9.Id;
						mge.GuardianId__c					=			null;
						mge.RouteId__c						=			'GOV';
						mge.Birthdate__c					=			mem9.BirthDate__c;
						mge.FirstName__c					=			'Liane';
						mge.LastName__c						=			'Cartman';
						mge.MiddleName__c					=			null;
						mge.NamePrefix__c					=			null;
						mge.NameSuffix__c					=			null;
					memGs.add(mge);
					
					insert memGs;
					counter = 0;
					//generate MemberAccumulator
					//generate two accumulators for each membercoverage
					List<mock_MemberAccumulator__c> memAccs = new List<mock_MemberAccumulator__c>();
					for(mock_MemberCoverage__c mc : memCovs){
							mock_MemberAccumulator__c macc = new mock_MemberAccumulator__c();
								macc.Applied__c = 100.00;
								macc.BenefitPeriod__c = 'Annual';
								macc.EffectiveDate__c = date.newInstance(date.today().year(),1,1);
								macc.EntityTypeName__c = 'Deductible';
								macc.Level__c = 'Level';
								macc.Limit__c = 2000.00;
								macc.member__c = mc.Member__c;
								macc.MemberAccumulatorGUID__c = 'Acc ' + counter;
								macc.MemberCoverage__c = mc.Id;
								macc.NetworkGroup__c = 'Network Group 1';
								macc.Plan__c = mc.plan__c;
								macc.Remaining__c = 1900.00;
								macc.routeId__c = 'GOV';
								macc.TerminationDate__c = date.newInstance(date.today().year(),12,31);
								macc.TreatmentClass__c = 'TreatmentClass';
							memAccs.add(macc);
							counter++;
							mock_MemberAccumulator__c macc1 = new mock_MemberAccumulator__c();
								macc1.Applied__c = 555.00;
								macc1.BenefitPeriod__c = 'Monthly';
								macc1.EffectiveDate__c = date.newInstance(date.today().year(),1,1);
								macc1.EntityTypeName__c = 'Type2';
								macc1.Level__c = 'Level';
								macc1.Limit__c = 1000.00;
								macc1.member__c = mc.Member__c;
								macc1.MemberAccumulatorGUID__c = 'Acc ' + counter;
								macc1.MemberCoverage__c = mc.Id;
								macc1.NetworkGroup__c = 'Network Group 1';
								macc1.Plan__c = mc.plan__c;
								macc1.Remaining__c = 445.00;
								macc1.routeId__c = 'GOV';
								macc1.TerminationDate__c = date.newInstance(date.today().year(),12,31);
								macc1.TreatmentClass__c = 'TreatmentClass2';
							memAccs.add(macc1);
	
					}
					insert memAccs;
					//generate MemberCOB
					//generate MemberServiceHistory
	
				result = batman.id;
			} catch(exception ex){
				Database.rollback(sp);
				system.debug('--MockDataGen Error------------------------------------------------------------');
				system.debug(ex.getMessage());
				system.debug(ex.getStackTraceString());
				system.debug('-------------------------------------------------------------------------------');
			}
		} else {
			//data exists
			result = existingContactData[0].Id;
		}	
		return result;
	}
    
}