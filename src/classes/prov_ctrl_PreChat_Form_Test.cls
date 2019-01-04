/**********************************************************************************************************************
Name                        : prov_ctrl_PreChat_Form_Test
Purpose                     : Test class for prov_ctrl_PreChat_Form
Created on                  : June 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                            By                      Comments
1.0             9           June 2018                West Monroe Partners    See header - purpose
 
**********************************************************************************************************************/
@isTest
private class prov_ctrl_PreChat_Form_Test {
	
	@testSetup
	static void testSetup(){
		//set the custom setting to turn on mock data
		Global_Configuration__c	 inst_Global_Configuration = new Global_Configuration__c();
		inst_Global_Configuration.Name = 'UseMockData';
		inst_Global_Configuration.Value__c = 'true'; 
		insert inst_Global_Configuration;
		
		//this is just to initialize the cache to get the mock data
		Contact con = prov_util_Cache.getContactRec();
	}

	@isTest
	static void test_caseRecordType() {
		PageReference myVfPage = Page.prov_vf_PreChat_Form;
		Test.setCurrentPage(myVfPage);

		prov_ctrl_PreChat_Form controller = new prov_ctrl_PreChat_Form();

		String returnedRecordType = controller.caseRecordType;

		System.assertNotEquals(null, returnedRecordType);
	}
	
	@isTest
	static void test_caseOwner() {
		PageReference myVfPage = Page.prov_vf_PreChat_Form;
		Test.setCurrentPage(myVfPage);

		prov_ctrl_PreChat_Form controller = new prov_ctrl_PreChat_Form();

		String returnedOwner = controller.caseOwner;

		System.assertNotEquals(null, returnedOwner);
	}

	@isTest
	static void test_serviceLocationOptions() {
		Account business = [select Id, Name from Account WHERE Name = 'Daily Planet'];
		String bizId = String.valueOf(business.Id);

		List<Account> locationOptions = prov_ctrl_PreChat_Form.serviceLocationOptions(bizId);

		System.assertEquals(1, locationOptions.size());
		System.assertEquals('Daily Planet on Wacker', locationOptions[0].Name);
	}

	@isTest
	static void test_providerOptions() {
		Account business = [select Id, Name from Account WHERE Name = 'Daily Planet'];
		Account location = [select Id, Name from Account WHERE Name = 'Daily Planet on Wacker'];
		String bizId = String.valueOf(business.Id);
		String locId = String.valueOf(location.Id);

		List<Account> providerOptions = prov_ctrl_PreChat_Form.providerOptions(bizId,locId);

		System.assertEquals(2, providerOptions.size());
	}

	@isTest
	static void test_URL() {
		PageReference myVfPage = Page.prov_vf_PreChat_Form;
		Test.setCurrentPage(myVfPage);

		prov_ctrl_PreChat_Form controller = new prov_ctrl_PreChat_Form();

		String str = controller.chatUrl;
		System.debug('url ' + str);

		System.assertNotEquals(null, str);
	}	
	@isTest
	static void test_JsURL() {
		PageReference myVfPage = Page.prov_vf_PreChat_Form;
		Test.setCurrentPage(myVfPage);

		prov_ctrl_PreChat_Form controller = new prov_ctrl_PreChat_Form();

		String str = controller.chatJsUrl;
		System.debug('jsURL ' + str);
		System.assertNotEquals(null, str);
	}
}