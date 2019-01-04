public with sharing class prov_wrap_DentistList_Provider {
	
    public provObj 																			Provider {get;set;}
	public locObj 																			ServiceLocation {get;set;}
	public List<Map<String, String>> 														Affiliations {get;set;}
	public List<Map<String, String>>														Specialties {get;set;}
	public List<PSLNObj>																	PSLN {get;set;}
	public List<PSLObj>																		PSL {get;set;}
	
	public prov_wrap_DentistList_Provider(){
		//random reinit
		//Provider = new provObj([SELECT id, Name, Phone, guid__c FROM Account WHERE Id='001W000000cqhhQ']);
		//ServiceLocation= new locObj([SELECT id, Name, BillingStreet,guid__c FROM Account WHERE Id='001W000000cqhhT']);
		//PSLN = new List<prov_wrap_DentistList_Provider.PSLNObj>();
		//PSL = new List<prov_wrap_DentistList_Provider.PSLObj>();
		//for(Providers_Service_Locations_Networks__c pslnT :  [SELECT id, Name, participation_status__c, guid__c, ww_route_id__c FROM Providers_Service_Locations_Networks__c limit 5]){
		//	PSLNObj obj = new PSLNObj(pslnT);
		//	PSLN.add(obj );
		//} 
		//for(Providers_Service_Locations__c pslT: [SELECT id, Name, Provider__r.Name, guid__c FROM Providers_Service_Locations__c limit 5]){
		//	PSLObj obj = new PSLObj(pslT);
		//	PSL.add(obj);
		//}
		//Specialties = new List<Map<String, String>>();
		//Map<String, String> tempMap = new Map<String,String>();
		//for(integer i = 0; i < 5; i++){
		//	tempMap = new Map<String,String>();
			
		//	tempMap.put('Name', 'tempSpecialty'+i);
		//	tempMap.put('BoardName', 'DentaDeny');
		//	tempMap.put('BoardCertified', 'Full');
		//	tempMap.put('Status', 'Denied');
			
		//	Specialties.add(tempMap);
		//}
		
		//Affiliations = new List<Map<String, String>>();
		//for(integer i = 0; i < 5; i++){
		//	tempMap = new Map<String,String>();
			
		//	tempMap.put('Name', 'tempLoc'+i);
		//	tempMap.put('AffiliatedLoc', 'DentaSmiles ' + i);
			
		//	Affiliations.add(tempMap);
		//}
	}
	
	public class PSLNObj{
		public String name {get;set;}
		public String windwardGuid {get;set;}
		public String parStatus {get;set;}
		public PSLNObj(Providers_Service_Locations_Networks__c acc){
			name = acc.Name;
			windwardGuid = acc.guid__c;
			parStatus = acc.participation_status__c;
		}
	}
	
	public class PSLObj{
		public String name {get;set;}
		public String providerName {get;set;}
		public String windwardGuid {get;set;}
		public PSLObj(Providers_Service_Locations__c acc){
			name = acc.Name;
			windwardGuid = acc.guid__c;
			providerName = acc.Provider__r.Name;
		}
	}
	
	public class provObj{
		public String name {get;set;}
		public String windwardGuid {get;set;}
		public String phone {get;set;}
		public provObj(Account acc){
			name = acc.Name;
			windwardGuid = acc.guid__c;
			phone = acc.Phone;
		}
	}
	
	public class locObj{
		public String name {get;set;}
		public String windwardGuid {get;set;}
		public String streetaddress {get;set;}
		public locObj(Account acc){
			name = acc.Name;
			windwardGuid = acc.guid__c;
			streetaddress = acc.BillingStreet;
		}
	}
}