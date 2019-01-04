@isTest
private class prov_batch_MemberInterventionDeleteTest {

	@testSetup
	static void testSetup(){
		//set the custom setting to turn on mock data
		Global_Configuration__c	 inst_Global_Configuration = new Global_Configuration__c();
		inst_Global_Configuration.Name = 'ClaimDeleteDelayDays';
		inst_Global_Configuration.Value__c = '3'; 
		insert inst_Global_Configuration;
		
		//this is just to initialize the cache to get the mock data
		Contact con = prov_util_Cache.getContactRec();
		
    	Providers_Service_Locations__c psl = [SELECT Id, Provider__c, Service_Location__c, Business__c FROM Providers_Service_Locations__c limit 1];
		//create member intervention
		List<Member_Intervention__c> updateList = new List<Member_Intervention__c>();
		for(integer i = 0; i < 200; i++){
			updateList.add( new Member_Intervention__c(
								Business__c = psl.Business__c,
								provider__c = psl.provider__c,
								Service_Location__c = psl.Service_Location__c,
								Intervention_Action__c = 'Dismissed Notice',
								Intervention_Measure__c = 'Routine Cleaning',
								Intervention_Steps__c = 'clean those teeth'
							)
						);
		} 
		insert updateList;
	}
	
    static testMethod void myUnitTest() {
 
 
        // TO DO: implement unit test
        prov_batch_MemberInterventionDelete bc = new prov_batch_MemberInterventionDelete();
		Test.startTest();
		Database.executeBatch(bc, 200);
		Test.stopTest();
		
    }
    static testMethod void scheduleTest() {
		Test.startTest();
		prov_batch_MemberInterventionDelete sh1 = new prov_batch_MemberInterventionDelete();

		String sch = '0 0 23 * * ?'; system.schedule('Test Member Intervention delete', sch, sh1); 
		Test.stopTest();
		
    }
}