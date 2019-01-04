global without sharing class prov_handler_ProviderPermissions {
	
	
	public static void checkBusinessPermissionExistence(List<String> businessWWIds){
		Map<String, Provider_Business_Permission__c> busId2PermissionMap = new Map<String, Provider_Business_Permission__c>();
		List<String> businessIdsMissingPermission = new List<String>();
		for(Provider_Business_Permission__c permission : [SELECT id, Business__c, Business__r.guid__c 
														FROM Provider_Business_Permission__c 
														WHERE Business__r.guid__c IN:businessWWIds ] ){
			busId2PermissionMap.put(permission.Business__r.guid__c.toLowercase(), permission);
		}
		
		for(String wwId : businessWWIds){
			if(!busId2PermissionMap.containsKey(wwId.toLowercase())){
				businessIdsMissingPermission.add(wwId);
			}
		}
		
		if(businessIdsMissingPermission.size() > 0){
			prov_handler_ProviderPermissions.updateBusinessPermission( businessIdsMissingPermission );
		}
	}
	
	/*webservice static String updateBusinessPermission2(List<String> businessWWIds){
		if(businessWWIds.size() == 0)return 'SUCCESS';
		//initialize the variables
		List<String> businessIds = new List<String> ();
		Map<string, String> pslId2BusinessIdMap = new Map<String, String>();
		Map<String, Set<Id>> businessId2NetworkIds = new Map<String, Set<Id>>();
		Set<String> networkIds = new Set<String>();
		
		try{
			//get the psls for that business that are active witin the last year
			for(Providers_Service_Locations__c psl : prov_util_DAL.retrievePSL_ProvPermission(new Set<String>( businessWWIds)) ){
				pslId2BusinessIdMap.put(psl.Id, String.valueOf(psl.Business__c).substring(0,15));
				businessIds.add(String.valueOf(psl.Business__c).substring(0,15));
			}
			System.debug('pslId2BusinessIdMap.size::'+pslId2BusinessIdMap.keyset().size());
			//query for the psln
			for(Providers_Service_Locations_Networks__c psln :  prov_util_DAL.retrievePSLN_ProvPermission(pslId2BusinessIdMap.keyset() ) ){
				//add network to set to later retrieve
				networkIds.add( psln.Network__c );
				
				//get the business id
				String businessId = pslId2BusinessIdMap.get(psln.Provider_Service_Location__c);
				
				//map the network to the business
				if(businessId2NetworkIds.containsKey(businessId)){
					businessId2NetworkIds.get(businessId.substring(0,15)).add(psln.network__c);
				} else {
					businessId2NetworkIds.put(businessId.substring(0,15), new Set<Id>{psln.network__c});
				}
			}
			System.debug('businessId2NetworkIds::'+businessId2NetworkIds);
	
			//query for the networks
			Map<id, Networks__c> id2NetworkMap = new Map<Id, Networks__c>([SELECT id, Enable_Accumulator__c, Enable_Broken_Appointments__c, Enable_FAD_OON__c, Enable_Fee_Schedule__c,
											Enable_Member_Intervention__c, Enable_Panel_Roster__c, Enable_Referrals__c, Enable_Reports__c,
											route_id__c
											FROM Networks__c where Id IN:networkIds ]);
			System.debug('id2NetworkMap::'+id2NetworkMap);
														
			//query for the provider business permission object
			Map<String, Provider_Business_Permission__c> busId2PermissionMap = new Map<String, Provider_Business_Permission__c>();
			String provBusinessFields = wmp_util_Helper.getSelectStarSOQL('Provider_Business_Permission__c', true);
			System.debug('provBusinessFields::'+provBusinessFields);
			for(Provider_Business_Permission__c permission : (List<Provider_Business_Permission__c>) Database.query(
											provBusinessFields + 
											' WHERE Business__c IN:businessIds ') ){
				busId2PermissionMap.put(String.valueOf(permission.Business__c).substring(0,15), permission);
			}
			
			//loop through the business ids
			for(String busId : businessIds){
				busId = busId.substring(0,15);
				System.debug('busId::'+busId);
				System.debug('businessId2NetworkIds::'+businessId2NetworkIds);
				if(businessId2NetworkIds.containsKey(busId)){
					Provider_Business_Permission__c permission = new Provider_Business_Permission__c(Business__c = busId);
					
					if(busId2PermissionMap.containsKey(busId))
						permission = busId2PermissionMap.get(busId);
					
					//reset the network fields on the permission object
					permission = clearNetworkFields(permission);
					
					//loop through the networks and set the settings
					for(Id networkId : businessId2NetworkIds.get(busId)){
						Networks__c network = id2NetworkMap.get(networkId);
						
						permission.Network_Broken_Appointment__c = network.Enable_Broken_Appointments__c || permission.Network_Broken_Appointment__c; 
						permission.Network_FAD_OON__c = network.Enable_FAD_OON__c || permission.Network_FAD_OON__c; 
						permission.Network_Fee_Schedule__c = network.Enable_Fee_Schedule__c || permission.Network_Fee_Schedule__c; 
						permission.Network_Member_Intervention__c = network.Enable_Member_Intervention__c || permission.Network_Member_Intervention__c; 
						permission.Network_Panel_Roster__c = network.Enable_Panel_Roster__c || permission.Network_Panel_Roster__c; 
						permission.Network_Referral__c = network.Enable_Referrals__c || permission.Network_Referral__c; 
						permission.Network_Report__c = network.Enable_Reports__c || permission.Network_Report__c; 
					}
					busId2PermissionMap.put(busId, permission);
					//upsertList.add( permission );
				}
			}
			
			System.debug('upsertList::'+busId2PermissionMap.values());
			upsert busId2PermissionMap.values();
			return 'SUCCESS';
		} catch(Exception ex){
			System.debug('************************************');
    		System.debug('Error::'+ex.getMessage());
    		System.debug('LN::'+ex.getLineNumber());
    		System.debug('stackTrace::'+ex.getStackTraceString());
    		System.debug('***********************************');
		}
		return 'ERROR';
		
	}*/
	
	
	webservice static String updateBusinessPermission(List<String> businessWWIds){
		if(businessWWIds.size() == 0)return 'SUCCESS';
		//initialize the variables
		Set<String> businessIds = new Set<String>();
		Map<string, String> pslId2BusinessIdMap = new Map<String, String>();
		Map<String, Set<Id>> businessId2NetworkIds = new Map<String, Set<Id>>();
		Set<String> networkIds = new Set<String>();
		
		try{
			for(Account bus : [SELECT id FROM Account WHERE guid__c IN:businessWWIds]){ 
				businessIds.add(bus.Id);
			}
			//get the psls for that business that are active witin the last year
			//System.debug('pslId2BusinessIdMap.size::'+pslId2BusinessIdMap.keyset().size());
			//query for the psln
			for(AggregateResult agg :  prov_util_DAL.retrievePSLN_Cache2(new Set<String>(), new Set<String>(), businessIds, false) ){
				if(agg.get('Business__c') == null || agg.get('Business__c') == '') continue;
				//add network to set to later retrieve
				String networkId = (String) agg.get('Network__c');
				networkIds.add( networkId );
				
				//get the business id
				String businessId = (String) agg.get('Business__c');
				businessId = businessId.substring(0,15);
				
				//map the network to the business
				if(businessId2NetworkIds.containsKey(businessId)){
					businessId2NetworkIds.get(businessId).add(networkId);
				} else {
					businessId2NetworkIds.put(businessId, new Set<Id>{networkId});
				}
			}
			System.debug('businessId2NetworkIds::'+businessId2NetworkIds);
	
			//query for the networks
			Map<id, Networks__c> id2NetworkMap = new Map<Id, Networks__c>([SELECT id, Enable_Accumulator__c, Enable_Broken_Appointments__c, Enable_FAD_OON__c, Enable_Fee_Schedule__c,
											Enable_Member_Intervention__c, Enable_Panel_Roster__c, Enable_Referrals__c, Enable_Reports__c,
											route_id__c
											FROM Networks__c where Id IN:networkIds ]);
			System.debug('id2NetworkMap::'+id2NetworkMap);
														
			//query for the provider business permission object
			Map<String, Provider_Business_Permission__c> busId2PermissionMap = new Map<String, Provider_Business_Permission__c>();
			String provBusinessFields = wmp_util_Helper.getSelectStarSOQL('Provider_Business_Permission__c', true);
			System.debug('provBusinessFields::'+provBusinessFields);
			for(Provider_Business_Permission__c permission : (List<Provider_Business_Permission__c>) Database.query(
											provBusinessFields + 
											' WHERE Business__c IN:businessIds ') ){
				busId2PermissionMap.put(String.valueOf(permission.Business__c).substring(0,15), permission);
			}
			
			//loop through the business ids
			for(String busId : businessIds){
				busId = busId.substring(0,15);
				System.debug('busId::'+busId);
				System.debug('businessId2NetworkIds::'+businessId2NetworkIds);
				if(businessId2NetworkIds.containsKey(busId)){
					Provider_Business_Permission__c permission = new Provider_Business_Permission__c(Business__c = busId);
					
					if(busId2PermissionMap.containsKey(busId))
						permission = busId2PermissionMap.get(busId);
					
					//reset the network fields on the permission object
					permission = clearNetworkFields(permission);
					
					//loop through the networks and set the settings
					for(Id networkId : businessId2NetworkIds.get(busId)){
						Networks__c network = id2NetworkMap.get(networkId);
						
						permission.Network_Broken_Appointment__c = network.Enable_Broken_Appointments__c || permission.Network_Broken_Appointment__c; 
						permission.Network_FAD_OON__c = network.Enable_FAD_OON__c || permission.Network_FAD_OON__c; 
						permission.Network_Fee_Schedule__c = network.Enable_Fee_Schedule__c || permission.Network_Fee_Schedule__c; 
						permission.Network_Member_Intervention__c = network.Enable_Member_Intervention__c || permission.Network_Member_Intervention__c; 
						permission.Network_Panel_Roster__c = network.Enable_Panel_Roster__c || permission.Network_Panel_Roster__c; 
						permission.Network_Referral__c = network.Enable_Referrals__c || permission.Network_Referral__c; 
						permission.Network_Report__c = network.Enable_Reports__c || permission.Network_Report__c; 
					}
					busId2PermissionMap.put(busId, permission);
					//upsertList.add( permission );
				}
			}
			
			System.debug('upsertList::'+busId2PermissionMap.values());
			upsert busId2PermissionMap.values();
			return 'SUCCESS';
		} catch(Exception ex){
			System.debug('************************************');
    		System.debug('Error::'+ex.getMessage());
    		System.debug('LN::'+ex.getLineNumber());
    		System.debug('stackTrace::'+ex.getStackTraceString());
    		System.debug('***********************************');
		}
		return 'ERROR';
		
	}
	
	/*webservice static String updateBusinessPermission_Network2(List<String> networkIds){
		//initialize the variables
		Set<String> businessWWIds = new Set<String> ();
		Set<String> businessWWIdsNeedUpdate = new Set<String> ();
		String response;
		try{
			//query for the PSLNs attached to the network
			for(Providers_Service_Locations_Networks__c psln :  [SELECT id, Provider_Service_Location__c, Provider_Service_Location__r.Business__c, Provider_Service_Location__r.Business__r.guid__c
													FROM Providers_Service_Locations_Networks__c
													WHERE Network__c IN:networkIds AND Effective_Date__c <= TODAY AND (Termination_Date__c = null OR Termination_Date__c >= LAST_N_DAYS:365) ]){
				if(psln.Provider_Service_Location__c != null)
					businessWWIds.add(psln.Provider_Service_Location__r.Business__r.guid__c);
			}
			
			String provBusinessFields = wmp_util_Helper.getSelectStarSOQL('Provider_Business_Permission__c', true);
			//System.debug('provBusinessFields::'+provBusinessFields);
			for(Provider_Business_Permission__c permission : (List<Provider_Business_Permission__c>) Database.query(
											provBusinessFields + 
											' WHERE Business__r.guid__c IN:businessWWIds') ){
				businessWWIdsNeedUpdate.add(permission.Business_guid__c);
			}
			
			if(businessWWIdsNeedUpdate.size() > 0){
				response = prov_handler_ProviderPermissions.updateBusinessPermission( new List<String> (businessWWIdsNeedUpdate) );
			} else {
				response = 'SUCCESS';
			}
			return response;
		} catch(Exception ex){
			System.debug('************************************');
    		System.debug('Error::'+ex.getMessage());
    		System.debug('LN::'+ex.getLineNumber());
    		System.debug('stackTrace::'+ex.getStackTraceString());
    		System.debug('***********************************');
		}
		return 'ERROR';
	}*/
	
	webservice static String updateBusinessPermission_Network(List<String> networkIds){
		//initialize the variables
		Set<String> businessWWIds = new Set<String> ();
		Set<String> businessIds = new Set<String> ();
		Set<String> businessWWIdsNeedUpdate = new Set<String> ();
		String response;
		try{
			//query for the PSLNs attached to the network
			for(AggregateResult agg : [SELECT Business__c, Network__c 
										FROM Providers_Service_Locations_Networks__c
										WHERE Network__c IN:networkIds  
												AND Effective_Date__c <= TODAY AND (Termination_Date__c = null OR Termination_Date__c >= LAST_N_DAYS:365) 
										GROUP BY Business__c, Network__c]){
				if(agg.get('Business__c') == null || agg.get('Business__c') == '') continue;
				businessIds.add((String) agg.get('Business__c'));
			}
			/*for(Providers_Service_Locations_Networks__c psln :  [SELECT id, Provider_Service_Location__c, Provider_Service_Location__r.Business__c, Provider_Service_Location__r.Business__r.guid__c
													FROM Providers_Service_Locations_Networks__c
													WHERE Network__c IN:networkIds AND Effective_Date__c <= TODAY AND (Termination_Date__c = null OR Termination_Date__c >= LAST_N_DAYS:365) ]){
				if(psln.Provider_Service_Location__c != null)
					businessWWIds.add(psln.Provider_Service_Location__r.Business__r.guid__c);
			}*/
			
			//System.debug('provBusinessFields::'+provBusinessFields);
			for(Provider_Business_Permission__c permission : [SELECT id, Business__c, Business_guid__c 
															  FROM Provider_Business_Permission__c
											 				  WHERE Business__c IN:businessIds] ){
				businessWWIdsNeedUpdate.add(permission.Business_guid__c);
			}
			
			if(businessWWIdsNeedUpdate.size() > 0){
				response = prov_handler_ProviderPermissions.updateBusinessPermission( new List<String> (businessWWIdsNeedUpdate) );
			} else {
				response = 'SUCCESS';
			}
			return response;
		} catch(Exception ex){
			System.debug('************************************');
    		System.debug('Error::'+ex.getMessage());
    		System.debug('LN::'+ex.getLineNumber());
    		System.debug('stackTrace::'+ex.getStackTraceString());
    		System.debug('***********************************');
		}
		return 'ERROR';
	}
	
	private static Provider_Business_Permission__c clearNetworkFields(Provider_Business_Permission__c permission){
		//clear the fields
		permission.Network_Broken_Appointment__c = false;
		permission.Network_FAD_OON__c = false;
		permission.Network_Fee_Schedule__c = false;
		permission.Network_Member_Intervention__c = false;
		permission.Network_Panel_Roster__c = false;
		permission.Network_Referral__c = false;
		permission.Network_Report__c = false;
		
		return permission;
	}
}