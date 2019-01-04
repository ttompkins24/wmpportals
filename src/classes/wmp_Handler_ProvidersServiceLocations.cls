/**********************************************************************************************************************
Name                        : 	wmp_trigger_ProvidersServiceLocations
Purpose                     : 	Trigger on Providers_Service_Locations__c business logic is located in the 
								wmp_Handler_ProvidersServiceLocations
Created on                  : 	11/22/2017
Developed by				: 	Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.0			8.0      	11/22/2017		Patrick Stephens	

**********************************************************************************************************************/
public class wmp_Handler_ProvidersServiceLocations {
	

	//check to see if both the provider and service locations are populated
	//if they are, we want to combine the provider languages and service location languagues into the PSL 
    //public static Boolean isUpdate = true;
	public static void handleAfterUpdate(Map<Id, Providers_Service_Locations__c> newMap, Map<Id, Providers_Service_Locations__c> oldMap){
		//if(isUpdate){
		//isUpdate = false;	
		List<Providers_Service_Locations__c> updatedPSL = new List<Providers_Service_Locations__c>();
		for(Providers_Service_Locations__c psl  : newMap.values() ){
			Providers_Service_Locations__c oldPsl = oldMap.get(psl.id); 
			//check to make sure Provider and Service Location are both populated and dont match the old vales
			if((psl.Provider__c != null && psl.Service_Location__c != null) && (psl.Provider__c != oldPsl.Provider__c || psl.Service_Location__c != oldPsl.Service_Location__c)){
			//if((psl.Provider__c != null && psl.Service_Location__c != null) ){
				updatedPSL.add(psl);
			}
		}
		System.debug('updatedPSL: ' + updatedPSL);
		if(updatedPSL.size() > 0){
			combineLanguagesSpoken(updatedPSL);
		}
		//}

	}

	public static void handleAfterInsert(List<Providers_Service_Locations__c> newList){
		List<Providers_Service_Locations__c> pslList = new List<Providers_Service_Locations__c>();
		for(Providers_Service_Locations__c psl : newList){
			if(psl.Provider__c != null && psl.Service_Location__c != null){
				pslList.add(psl);
			}
		}
		System.debug('pslList: ' + pslList);
		if(pslList.size() > 0){
			combineLanguagesSpoken(pslList);
		}
	}
	
    //method that actually combines the lists
	public static void combineLanguagesSpoken(List<Providers_Service_Locations__c> pslList){
		System.debug('pslList: ' + pslList);
		List<Providers_Service_Locations__c>newPSLList = [select id, Languages_Spoken__c, Provider__c, Service_Location__c, Provider__r.Supported_Languages__c, service_Location__r.Supported_Languages__c from Providers_Service_Locations__c where id in :pslList ];
		System.debug('newPSLList: ' + newPSLList);
		for(Providers_Service_Locations__c psl : newPSLList){
			System.debug('psl: ' + psl);
			Set<String> languageSet = new Set<String>();
			if(psl.Provider__r.Supported_Languages__c != null && psl.Provider__r.Supported_Languages__c != ''){
				String pLanguages = psl.Provider__r.Supported_Languages__c;
				System.debug('provider languages: ' + pLanguages);
				List<string> pLanguage = pLanguages.split(';');
				for(String s : pLanguage){
					languageSet.add(s);
				}				
			}
			if(psl.Service_Location__r.Supported_Languages__c != null && psl.Service_Location__r.Supported_Languages__c != '' ){
				String slLanguages = psl.Service_Location__r.Supported_Languages__c;
				System.debug('SL languages: ' + slLanguages);
				//combine all languages into a set
				List<string> slLanguage = slLanguages.split(';');
				for(String s : slLanguage){
					languageSet.add(s);
				}
			}

			if(languageSet.size() > 0){
				//put languages back in list
			    List<String> strList = new List<String>(languageSet);
			    strList.sort();
			    psl.Languages_Spoken__c = String.join(strList, ';');
				System.debug('psl.Languages_Spoken__c: ' + psl.Languages_Spoken__c);
			}
		}
		update newPSLList;
	}

}