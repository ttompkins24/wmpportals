/**********************************************************************************************************************
Name                        : 	wmp_util_MockData
Purpose                     : 	utility class to deal with mock data
Created on                  : 	08/17/2017
Developed by				: 	Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.0			1.0      	08/17/2017		Patrick Stephens	

**********************************************************************************************************************/

global without sharing class wmp_util_MockData {
    //method to see if the mockdata value has been set    
    global static 	boolean													useMockData	{
    	get{
    		try{
    			Global_Configuration__c configUseMockData = Global_Configuration__c.getInstance('UseMockData');
    			if(configUseMockData==null){
    				//Global Configuration settings have not been populated
    				//run the method to populate the settings
    				populateSettingRecords();
    				configUseMockData = Global_Configuration__c.getInstance('UseMockData');
    			}
    			return Boolean.valueOf(configUseMockData.Value__c);
    		} catch (exception ex){
    			return null;
    		}
    	}
    }	
    
    //method to create a sharing account for unit test purposes, returns the account Id
    @TestVisible
    global static string createSharingAccount(){
        //create sharing account 
        Account a = new Account();
        a.name = 'SharingAccount';
		a.BillingStreet = '1 Main';
		a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
		a.BillingPostalCode = '60606';
		a.Phone = '8454301234';
        insert a;
        //set global config
        Global_Configuration__c newSetting6 = Global_Configuration__c.getInstance('SharingAccountId');
        if(newSetting6==null){
            newSetting6 = new Global_Configuration__c();
            newSetting6.Name = 'SharingAccountId';
        }
	    newSetting6.Value__c = a.Id;
	    upsert newSetting6;
        return a.Id;
    }
    
    //method to instantiate custom setting values if they are not populated
    global static void														populateSettingRecords(){
    	List<Global_Configuration__c> settings	= new List<Global_Configuration__c>();
    	//this set contains the orgIds of those orgs that should use MockData by default
    	Set<String> orgsThatUseMockDataByDefault = new Set<String>{'00Dg0000001qRGKEA2','00DV0000007zGJy'};
    	//get the org and check to see if it should use MockData by default
    	List<Organization> orgs = [Select Name, IsSandbox FROM Organization];
    	Boolean useMD = (orgsThatUseMockDataByDefault.contains(orgs[0].Id));
    	
    	//UseMockData setting
    	Global_Configuration__c newSetting = new Global_Configuration__c();
	    	newSetting.Name = 'UseMockData';
	    	newSetting.Value__c = String.valueOf(useMD);
	           settings.add(newSetting);
        Global_Configuration__c newSetting1 = new Global_Configuration__c();
	    	newSetting1.Name = 'CaseSyncOrigins';
	    	newSetting1.Value__c = 'Member Portal';
	           settings.add(newSetting1);
        Global_Configuration__c newSetting2 = new Global_Configuration__c();
	    	newSetting2.Name = 'CaseSyncRecordTypeNames';
	    	newSetting2.Value__c = 'Appeals/Reconsideration;Complaint;Grievance';
	    	      settings.add(newSetting2);
        Global_Configuration__c newSetting3 = new Global_Configuration__c();
	    	newSetting3.Name = 'CaseSyncRoutingRT';
	    	newSetting3.Value__c = 'General Case';
	    	      settings.add(newSetting3);
        Global_Configuration__c newSetting4 = new Global_Configuration__c();
	    	newSetting4.Name = 'CaseSyncActive';
	    	newSetting4.Value__c = 'false';
	    	      settings.add(newSetting4);
        Global_Configuration__c newSetting5 = new Global_Configuration__c();
	    	newSetting5.Name = 'PCDRequestEndpoint';
	    	newSetting5.Value__c = 'null';
	    	      settings.add(newSetting5);
        Global_Configuration__c newSetting6 = new Global_Configuration__c();
	    	newSetting6.Name = 'SharingAccountId';
	    	newSetting6.Value__c = '';
	    	      settings.add(newSetting6);
  			
  			
  		//add other setting setup here
    	List<Database.UpsertResult> srs = Database.upsert(settings,false);
    }
    
    
    
}