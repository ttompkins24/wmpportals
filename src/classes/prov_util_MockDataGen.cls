/**********************************************************************************************************************
Name                        : 	prov_util_MockDataGen
Purpose                     : 	The class that stores the fetches and sets values in the session cache
Created on                  : 	1/01/2018
Developed by				: 	Todd Tompkins
History
Version#    Sprint#     Date            by                   Comments
1.1			5.0      	01/01/2018		Todd Tompkins	 	

**********************************************************************************************************************/

/* Description	**********************************************************


The actual class stored in the session cache is an instantiation of the prov_util_CacheObject class. However, we do
not intend consuming components or classes to interact directly with the cacheObject, but rather through this cache class.


**************************************************************************/
global without sharing class prov_util_MockDataGen {
    
    //method to generate base data for Portal functionality
	@TestVisible
	global static 	String												genBaseData()											{
		String result = 'MockData Not Generated';
		//check to see if the data exists before we create it
		List<Contact> existingContactData = [SELECT Id FROM Contact WHERE FirstName = 'Clark' AND LastName = 'Kent' AND Email = 'iluvcapes@test.com'];
		if(existingContactData==null || existingContactData.size()==0){
			Savepoint sp = Database.setSavepoint();
			try{
				//get recordTypes
				List<RecordType> rts = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = true];
				Map<String, RecordType> mrts = new Map<String, RecordType>();
				for(RecordType rt : rts){
					mrts.put(rt.DeveloperName,rt);
				}
				
				
				Global_Configuration__c sharingAccount = Global_Configuration__c.getInstance('SharingAccountId');
				if(sharingAccount == null || sharingAccount.Value__c == null || [SELECT id FROM Account WHERE Id=:sharingAccount.Value__c ].size() == 0){
					//System.debug('sharing record being created...');					
					prov_util_MockData.createSharingAccount();
				}
				//System.debug('sharing record set...');
				//set static values
					//routeIds 	
					List<String> routeIds = new List<String>{'GOV','GOV_MH'}; 
					
					//generate Networks for each plan
					List<Networks__c> networkList = new List<Networks__c>();
					Networks__c network1 = new Networks__c();
						network1.route_id__c = 'GOV';
						network1.effective_date__c = Date.today().addDays(-30);
						network1.Name = 'test Network 1(DG)';
						network1.guid__c = 'networkAA11';
						network1.Enable_Accumulator__c = true;
						network1.Enable_Broken_Appointments__c = true;
						network1.Enable_FAD_OON__c = true;
						network1.Enable_Fee_Schedule__c = true;
						network1.Enable_Member_Intervention__c = true;
						network1.Enable_Panel_Roster__c = true;
						network1.Enable_Referrals__c = true;
						network1.Enable_Reports__c = true;
					networkList.add(network1);
					Networks__c network2 = new Networks__c();
						network2.route_id__c = 'GOV';
						network2.effective_date__c = Date.today().addDays(-30);
						network2.Name = 'test Network 2(DG)';
						network2.guid__c = 'networkBB22';
						network2.Enable_Accumulator__c = true;
						network2.Enable_Broken_Appointments__c = true;
						network2.Enable_FAD_OON__c = true;
						network2.Enable_Fee_Schedule__c = true;
						network2.Enable_Member_Intervention__c = true;
						network2.Enable_Panel_Roster__c = true;
						network2.Enable_Referrals__c = true;
						network2.Enable_Reports__c = true;
					networkList.add(network2);
					Networks__c network3 = new Networks__c();
						network3.route_id__c = 'GOV';
						network3.effective_date__c = Date.today().addDays(-30);
						network3.Name = 'test Network 3(DG)';
						network3.guid__c = 'networkCC##';
						network3.Enable_Accumulator__c = true;
						network3.Enable_Broken_Appointments__c = true;
						network3.Enable_FAD_OON__c = true;
						network3.Enable_Fee_Schedule__c = true;
						network3.Enable_Member_Intervention__c = true;
						network3.Enable_Panel_Roster__c = true;
						network3.Enable_Referrals__c = true;
						network3.Enable_Reports__c = true;
					networkList.add(network3);
					insert networkList;
					List<Contact> existingMemberData = [SELECT Id FROM Contact WHERE FirstName = 'Bruce' AND LastName = 'Wayne' AND Email = 'iluvbats@test.com'];
					wmp_util_MockDataGen.genBaseData();

					//get accounts					
					List<Account> plans = [SELECT id FROM Account WHERE guid__c IN ('Plan 1','Plan 2','Plan 3') Order By guid__c ASC];
					Account txP1 = plans[0];
					Account txP2 = plans[1];
					Account coP1 = plans[2];
					
					List<Account> businesses = new List<Account>();
					//generate Businesses
					Account metroBusiness = new Account();
						metroBusiness.route_id__c = 'GOV';
						metroBusiness.Name = 'Metropolis Dental';
						metroBusiness.RecordTypeId = mrts.get('Business_Account').Id;
						metroBusiness.guid__c = 'Metropolis1';
						metroBusiness.Tax_Id_Number__c = 'Metropoli';
					businesses.add(metroBusiness);
					Account dailyP = new Account();
						dailyP.route_id__c = 'GOV';
						dailyP.Name = 'Daily Planet';
						dailyP.Tax_Id_Number__c = 'bus2IndyT';
						dailyP.RecordTypeId = mrts.get('Business_Account').Id;
						dailyP.guid__c = 'bus2Indy';
					businesses.add(dailyP);
					
					//generate providers
					List<Account> providerList = new List<Account>();
					Account clarkKent = new Account();
						clarkKent.Name = 'Clark Kent';
						clarkKent.RecordTypeId = mrts.get('Provider').Id;
						clarkKent.guid__c = 'clarkkent1';
						clarkKent.route_id__c = 'GOV';
					providerList.add(clarkKent);
					Account lois = new Account();
						lois.Name = 'Lois Lane';
						lois.RecordTypeId = mrts.get('Provider').Id;
						lois.guid__c = 'loislane1';
						lois.route_id__c = 'GOV';
					providerList.add(lois);
					Account lex = new Account();
						lex.Name = 'Lex Luther';
						lex.RecordTypeId = mrts.get('Provider').Id;
						lex.guid__c = 'lexluther1';
						lex.route_id__c = 'GOV';
					providerList.add(lex);
					
					//generate service locations
					List<Account> serviceLocationList = new List<Account>();
					Account dailyPlanet = new Account();
						dailyPlanet.Name = 'Daily Planet on Wacker';
						dailyPlanet.RecordTypeId = mrts.get('Service_Location').Id;
						dailyPlanet.guid__c = 'dailyPlanetA1';
						dailyPlanet.route_id__c = 'GOV';
						
						dailyPlanet.BillingStreet = '233 S Wacker Dr';
						dailyPlanet.BillingCity = 'Chicago';
						dailyPlanet.BillingState = 'IL';
						dailyPlanet.BillingPostalCode = '60606';
						dailyPlanet.BillingCountry = 'US';
					serviceLocationList.add(dailyPlanet);
					Account krypton = new Account();
						krypton.Name = 'Krypton Dental';
						krypton.RecordTypeId = mrts.get('Service_Location').Id;
						krypton.guid__c = 'krypton1';
						krypton.route_id__c = 'GOV';
						
						krypton.BillingStreet = '1060 W Addison St';
						krypton.BillingCity = 'Chicago';
						krypton.BillingState = 'IL';
						krypton.BillingPostalCode = '60613';
						krypton.BillingCountry = 'US';
					serviceLocationList.add(krypton);
					Account smallville = new Account();
						smallville.Name = 'Smallville Smile';
						smallville.RecordTypeId = mrts.get('Service_Location').Id;
						smallville.guid__c = 'smallville1';
						smallville.route_id__c = 'GOV';
						
						smallville.BillingStreet = '600 E Grand Ave';
						smallville.BillingCity = 'Chicago';
						smallville.BillingState = 'IL';
						smallville.BillingPostalCode = '60611';
						smallville.BillingCountry = 'US';
					serviceLocationList.add(smallville);
					
					
					//add all the account type lists into the same list for one dml statement
					businesses.addAll(providerList);
					businesses.addAll(serviceLocationList);
					insert businesses;
				
				//generate ProvideServiceLocations
				List<Providers_Service_Locations__c> pslList = new List<Providers_Service_Locations__c>();
				Providers_Service_Locations__c clarkDaily = new Providers_Service_Locations__c();
					clarkDaily.Effective_Date__c = Date.today().addYears(-1);
					clarkDaily.is_accepting_new_patients__c = true;
					clarkDaily.Languages_Spoken__c = 'English';
					clarkDaily.Provider__c = clarkKent.id;
					clarkDaily.Business__c = dailyP.id;
					clarkDaily.Service_Location__c = dailyPlanet.Id;
					clarkDaily.Specialties__c = 'General Practitioner';
					clarkDaily.route_id__c = 'GOV';
					clarkDaily.guid__c = 'PSLBB11';
				pslList.add(clarkDaily);
				Providers_Service_Locations__c loisDaily = new Providers_Service_Locations__c();
					loisDaily.Effective_Date__c = Date.today().addYears(-1);
					loisDaily.is_accepting_new_patients__c = true;
					loisDaily.Languages_Spoken__c = 'English';
					loisDaily.Provider__c = lois.id;
					loisDaily.Business__c = dailyP.id;
					loisDaily.Service_Location__c = dailyPlanet.Id;
					loisDaily.Specialties__c = 'General Practitioner';
					loisDaily.route_id__c = 'GOV';
					loisDaily.guid__c = 'PSLCC11';
				pslList.add(loisDaily);
				Providers_Service_Locations__c lexKrypton = new Providers_Service_Locations__c();
					lexKrypton.Effective_Date__c = Date.today().addYears(-1);
					lexKrypton.is_accepting_new_patients__c = true;
					lexKrypton.Languages_Spoken__c = 'English';
					lexKrypton.Provider__c = lex.id;
					lexKrypton.Business__c = metroBusiness.id;
					lexKrypton.Service_Location__c = krypton.Id;
					lexKrypton.Specialties__c = 'General Practitioner';
					lexKrypton.route_id__c = 'GOV';
					lexKrypton.guid__c = 'PSLDD11';
				pslList.add(lexKrypton);
				Providers_Service_Locations__c lexSmall = new Providers_Service_Locations__c();
					lexSmall.Effective_Date__c = Date.today().addYears(-1);
					lexSmall.is_accepting_new_patients__c = true;
					lexSmall.Languages_Spoken__c = 'English';
					lexSmall.Provider__c = lex.id;
					lexSmall.Business__c = metroBusiness.id;
					lexSmall.Service_Location__c = smallville.Id;
					lexSmall.Specialties__c = 'General Practitioner';
					lexSmall.route_id__c = 'GOV';
					lexSmall.guid__c = 'PSLEE11';
				pslList.add(lexSmall);
				Providers_Service_Locations__c clarkSmall = new Providers_Service_Locations__c();
					clarkSmall.Effective_Date__c = Date.today().addYears(-1);
					clarkSmall.is_accepting_new_patients__c = true;
					clarkSmall.Languages_Spoken__c = 'English';
					clarkSmall.Provider__c = clarkKent.id;
					clarkSmall.Business__c = metroBusiness.id;
					clarkSmall.Service_Location__c = smallville.Id;
					clarkSmall.Specialties__c = 'General Practitioner';
					clarkSmall.route_id__c = 'GOV';
					clarkSmall.guid__c = 'PSLFF11';
				pslList.add(clarkSmall);
				//insert the providers service locations
				insert pslList;
				
				//generate plan networks
				List<Plans_Networks__c> planNetworkList = new List<Plans_Networks__c>();
				Plans_Networks__c planNetwork1 = new Plans_Networks__c();
					planNetwork1.Network__c = network1.Id;
					planNetwork1.Plan__c = txP1.Id;
				planNetworkList.add(planNetwork1);
				/*Plans_Networks__c planNetwork2 = new Plans_Networks__c();
					planNetwork2.Network__c = network2.Id;
					planNetwork2.Plan__c = txP1.Id;
				planNetworkList.add(planNetwork2);*/
				Plans_Networks__c planNetwork3 = new Plans_Networks__c();
					planNetwork3.Network__c = network1.Id;
					planNetwork3.Plan__c = txP2.Id;
				planNetworkList.add(planNetwork3);
				Plans_Networks__c planNetwork4 = new Plans_Networks__c();
					planNetwork4.Network__c = network2.Id;
					planNetwork4.Plan__c = coP1.Id;
				planNetworkList.add(planNetwork4);
				insert planNetworkList;
				
				//generate PSL Networks
				List<Providers_Service_Locations_Networks__c> pslnList = new List<Providers_Service_Locations_Networks__c>();
				Providers_Service_Locations_Networks__c clarkNet1 = new Providers_Service_Locations_Networks__c();
					clarkNet1.network__c = network1.Id;
					clarkNet1.Provider_Service_Location__c = clarkDaily.Id;
					clarkNet1.Business__c = dailyP.id;
					clarkNet1.effective_date__c = Date.today().addYears(-1);
					clarkNet1.guid__c = 'pslnAA1';
					clarkNet1.route_id__c = 'GOV';
					clarkNet1.is_provider_active__c = true;
					clarkNet1.is_accepting_new_patients__c = true;
				pslnList.add(clarkNet1);
				Providers_Service_Locations_Networks__c loisNet1 = new Providers_Service_Locations_Networks__c();
					loisNet1.network__c = network1.Id;
					loisNet1.Provider_Service_Location__c = loisDaily.Id;
					loisNet1.Business__c = dailyP.id;
					loisNet1.effective_date__c = Date.today().addYears(-1);
					loisNet1.guid__c = 'pslnBB1';
					loisNet1.route_id__c = 'GOV';
					loisNet1.is_provider_active__c = true;
					loisNet1.is_accepting_new_patients__c = true;
				pslnList.add(loisNet1);
				Providers_Service_Locations_Networks__c clarkNet2 = new Providers_Service_Locations_Networks__c();
					clarkNet2.network__c = network2.Id;
					clarkNet2.Provider_Service_Location__c = clarkSmall.Id;
					clarkNet2.Business__c = dailyP.id;
					clarkNet2.effective_date__c = Date.today().addYears(-1);
					clarkNet2.guid__c = 'pslnCC1';
					clarkNet2.route_id__c = 'GOV';
					clarkNet2.is_provider_active__c = true;
					clarkNet2.is_accepting_new_patients__c = true;
				pslnList.add(clarkNet2);
				Providers_Service_Locations_Networks__c lexNet2 = new Providers_Service_Locations_Networks__c();
					lexNet2.network__c = network2.Id;
					lexNet2.Provider_Service_Location__c = lexKrypton.Id;
					lexNet2.effective_date__c = Date.today().addYears(-1);
					lexNet2.Business__c = metroBusiness.id;
					lexNet2.guid__c = 'pslnDD1';
					lexNet2.route_id__c = 'GOV';
					lexNet2.is_provider_active__c = true;
					lexNet2.is_accepting_new_patients__c = true;
				pslnList.add(lexNet2);
				Providers_Service_Locations_Networks__c lexSmallNet2 = new Providers_Service_Locations_Networks__c();
					lexSmallNet2.network__c = network2.Id;
					lexSmallNet2.Provider_Service_Location__c = lexSmall.Id;
					lexSmallNet2.Business__c = metroBusiness.id;
					lexSmallNet2.effective_date__c = Date.today().addYears(-1);
					lexSmallNet2.guid__c = 'pslnEE1';
					lexSmallNet2.route_id__c = 'GOV';
					lexSmallNet2.is_provider_active__c = true;
					lexSmallNet2.is_accepting_new_patients__c = true;
				pslnList.add(lexSmallNet2);
				insert pslnList;
					
				//generate MemberPortal Accounts
					//Two Accounts for each Texas and Colorado Clients
					List<Account> memAccounts = new List<Account>();
						Account dailyAcc = new Account();
							dailyAcc.route_id__c 				= 			'GOV';
							dailyAcc.Name 							= 			'iluvcapes@test.com';
							dailyAcc.RecordTypeId 					= 			mrts.get('Member_Account').Id;
							dailyAcc.Site							=			'GOVProvider';
						memAccounts.add(dailyAcc);
						Account metroAcc = new Account();
							metroAcc.route_id__c 				= 			'GOV';
							metroAcc.Name 							= 			'metroAdmin@test.com';
							metroAcc.RecordTypeId 					= 			mrts.get('Member_Account').Id;
							metroAcc.Site							=			'GOVProvider';
						memAccounts.add(metroAcc);
						if(existingMemberData.size()== 0){
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
						}
					insert memAccounts;
					
				//generate MemberPortalContacts
					//Contacts for Texas and Colorado (portal)
					List<Contact> contacts = new List<Contact>();
					Contact daily = new Contact();
						daily.FirstName 							= 		'Daily';
						daily.LastName 							=			'DAdmin';
						daily.Email								=			'iluvcapes@test.com';
						daily.Portal_Name__c						=		'GOVProvider';
						daily.AccountId							=			dailyAcc.Id;
						daily.Provider_Portal_Permissions__c        =		dailyP.guid__c+':ALL;ALL$ALL';
						daily.UseAsMockDataRecord__c				= 		true;
					contacts.add(daily);		
					
					Contact metro = new Contact();
						metro.FirstName 							= 		'Metro';
						metro.LastName 								=		'MAdmin';
						metro.Email									=		'metroAdmin@test.com';
						metro.Portal_Name__c						=		'GOVProvider';
						metro.Provider_Portal_Permissions__c        =		metroBusiness.guid__c+':ALL;ALL$ALL';
						metro.AccountId								=		metroAcc.Id;
					contacts.add(metro);
					
				insert contacts;
				
				Datetime todayDT = Datetime.now();
				Date today = Date.today();
				//create provider notifications
				List<Provider_Notification__c> provNotifList = new List<Provider_Notification__c>();
				Provider_Notification__c profNotif = new Provider_Notification__c();
					profNotif.Business__c = dailyP.Id;
					profNotif.Effective_Date__c = todayDT.addDays(-1);
					profNotif.Expiration_Date__c = todayDT.addDays(-30);
					profNotif.Message__c = 'this is a test message';
					profNotif.Message_Header__c = 'Header of the message';
				provNotifList.add(profNotif);
				
				Provider_Notification__c profNotif2 = new Provider_Notification__c();
					profNotif2.Business__c = dailyP.Id;
					profNotif2.Effective_Date__c = todayDT.addDays(-5);
					profNotif2.Expiration_Date__c = todayDT.addDays(-30);
					profNotif2.Message__c = 'this is a test message 2';
					profNotif2.Message_Header__c = 'Header of the message';
					profNotif2.Show_in_Hero_Banner__c = true;
				provNotifList.add(profNotif2);

				Provider_Notification__c profNotif3 = new Provider_Notification__c();
					profNotif3.Business__c = dailyP.Id;
					profNotif3.Service_Location__c = dailyPlanet.Id;
					profNotif3.Effective_Date__c = todayDT.addDays(-10);
					profNotif3.Expiration_Date__c = todayDT.addDays(-30);
					profNotif3.Message__c = 'this is a test message 3';
					profNotif3.Message_Header__c = 'Header of the message';
					profNotif3.Redirect_page__c = 'www.test.salesforce.com';
				provNotifList.add(profNotif3);
				
				Provider_Notification__c profNotif4 = new Provider_Notification__c();
					profNotif4.Business__c = dailyP.Id;
					profNotif4.Provider__c = clarkKent.Id;
					profNotif4.Service_Location__c = dailyPlanet.Id;
					profNotif4.Effective_Date__c = todayDT.addDays(-11);
					profNotif4.Expiration_Date__c = todayDT.addDays(-30);
					profNotif4.Message__c = 'this is a test message 4';
					profNotif4.Message_Header__c = 'Header of the message';
				provNotifList.add(profNotif4);
				
				Provider_Notification__c profNotif5 = new Provider_Notification__c();
					profNotif5.Effective_Date__c = todayDT.addDays(-9);
					profNotif5.Expiration_Date__c = todayDT.addDays(-30);
					profNotif5.Message__c = 'this is a test message 5';
					profNotif5.Message_Header__c = 'Header of the message';
				provNotifList.add(profNotif5);
				
				insert provNotifList;
				
				//insert provider notification network
				insert new Provider_Notification_Network__c(Provider_Notification__c = profNotif5.Id, Network__c = network1.Id);
				
				//create time varibales for the provider events
				//create provider events
				List<Provider_Event__c> eventList = new List<Provider_Event__c>();
				Provider_Event__c event = new Provider_Event__c();
					event.Event_Date__c = today.addDays(10);
					event.Event_Content__c = 'some content for the body to render';
					event.Event_Content_Header__c	 = 'some content for the header';
					event.Event_End_Time__c	 =  Time.newInstance(9,30,0,0);
					event.Event_Start_Time__c	 = Time.newInstance(17,0,0,0);
					event.Event_Timezone__c	 = 'CST';
					event.Event_Title__c	 = 'some content for the header';
					event.Show_in_Provider_Portal__c	 = true;
				eventList.add(event);	
				
				Provider_Event__c event2 = new Provider_Event__c();
					event2.Event_Date__c = today.addDays(15);
					event2.Event_Content__c = 'some content for the body to render';
					event2.Event_Content_Header__c	 = 'some content for the header';
					event2.Event_End_Time__c	 =  Time.newInstance(11,30,0,0);
					event2.Event_Start_Time__c	 = Time.newInstance(14,0,0,0);
					event2.Event_Timezone__c	 = 'CST';
					event2.Event_Title__c	 = 'some content for the header';
					event2.Show_in_Provider_Portal__c	 = true;
				eventList.add(event2);	
				
				Provider_Event__c event3 = new Provider_Event__c();
					event3.Event_Date__c = today.addDays(20);
					event3.Event_Content__c = 'some content for the body to render';
					event3.Event_Content_Header__c	 = 'some content for the header';
					event3.Event_End_Time__c	 =  Time.newInstance(15,30,0,0);
					event3.Event_Start_Time__c	 = Time.newInstance(23,0,0,0);
					event3.Event_Timezone__c	 = 'CST';
					event3.Event_Title__c	 = 'some content for the header';
					event3.Show_in_Provider_Portal__c	 = true;
				eventList.add(event3);	
				
				insert eventList;


				//specify global config for days for confirmation reports

				if(Global_Configuration__c.getInstance('ClaimDeleteDelayDays') == null){
					Global_Configuration__c csobj=new Global_Configuration__c ();
					csobj.Value__c = '3';
					csobj.name='ClaimDeleteDelayDays';
					insert csobj;

				}

				

				
				//create provider event notification
				List<Provider_Event_Network__c> eventNetworkList = new List<Provider_Event_Network__c>();
				Provider_Event_Network__c eventNetwork = new Provider_Event_Network__c();
					eventNetwork.Provider_Event__c = event.Id;
					eventNetwork.Network__c = network1.Id;
				eventNetworkList.add(eventNetwork);
				
				Provider_Event_Network__c eventNetwork2 = new Provider_Event_Network__c();
					eventNetwork2.Provider_Event__c = event2.Id;
					eventNetwork2.Network__c = network1.Id;
				eventNetworkList.add(eventNetwork2);
				
				Provider_Event_Network__c eventNetwork3 = new Provider_Event_Network__c();
					eventNetwork3.Provider_Event__c = event3.Id;
					eventNetwork3.Network__c = network1.Id;
				eventNetworkList.add(eventNetwork3);
				
				insert eventNetworkList;

				Sequence_Number__c seqNumber = new Sequence_Number__c();
				SeqNumber.Name = 'Claim Number';
				insert seqNumber;
				
				result = daily.id;
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