/*
/*******************************************************************************************************
Name 						: prov_ctrl_Billed_amount_detail
Purpose						: Controller for the prov_comp_Billed_Amount_Detail  
							  Displays billed amount record and the related records (billed amount association and billed amount detai1)
Created on					: 13rd February 2018
Developed by				: West Monroe Partners
History
Version#		Sprint#		Date					by  							Comments
1.0				1.0			13rd February 2018		West Monroe Partners			See header - purpose
 
*******************************************************************************************************
*/
public without sharing class prov_ctrl_Billed_Amount_Detail {

	/* RETRIEVE THE BILLED AMOUNT, BILLED AMOUNT DETAILS, AND BILLED AMOUNT ASSOCIATIONS */
	@AuraEnabled
	public static BilledAmountWrapper getBilledAmountApex(String billedAmountId, String businessId){
		BilledAmountWrapper wrapper = new BilledAmountWrapper();
		System.debug('billedAmountId::'+billedAmountId);
		System.debug('businessId::'+businessId);
		//Id businessId = prov_util_Cache.CurrentBusinessId;
		Account business = [SELECT Name, Id FROM Account WHERE Id =: businessId];

		prov_util_CacheObject cacheObj = prov_util_Cache.cobj;
		
		try{
		wrapper.business = business;
		wrapper.billed_amount = null;
		List<Billed_Amount__c> tempList;
		if(billedAmountId != NULL) {
			if(!true ){
	            List<Id> providerIds = prov_util_Cache.BusinessIdToProviderIds.get(businessId);
	            List<String> servLocationIds = prov_util_Cache.BusinessIdToLocationIds.get(businessId);
	            Set<Id> businessAmountIds = new Set<Id>();
	            for(Billed_Amount_Association__c baa :[SELECT Id, Billed_Amount__c
	                                                    FROM Billed_Amount_Association__c
	                                                    WHERE Provider__c IN:providerIds AND Service_Location__c IN: servLocationIds AND Billed_Amount__r.Business__c =:businessId]){
	                //collect the info needed
	                businessAmountIds.add(baa.Billed_Amount__c);                                                
	            }
	            //query for the billed amount list
	            tempList =  (List<Billed_Amount__c>) Database.query('SELECT Id, Name, Created_By_Contact__r.Name, '+
								'Created_By_Contact__r.LastName, Business__c, '+
								'(SELECT Id, Name, Provider__r.Name, Service_Location__r.Name, Provider__c, Service_Location__c FROM Billed_Amount_Associations__r), '+
								'(SELECT Id, Procedure_Code__r.Name, Procedure_Code__r.Description__c, Billed_Value__c FROM Billed_Amount_Details__r) '+
								' FROM Billed_Amount__c '+
								' WHERE Id =\''+ billedAmountId + '\' AND (Id IN (\''+String.join(new List<Id>(businessAmountIds),'\',\'')+'\') OR (Business__c =\''+businessId +'\' AND Created_By_Contact__c =\''+cacheObj.ContactRec.Id+'\') ) AND RouteId__c includes (\''+String.join(new List<String>(cacheObj.VisibleLOB),'\',\'')+'\')');
	           //if list finds item, add it to the wrapper
	 			if(tempList.size() > 0){
	 				 wrapper.billed_amount = tempList[0];
	 			}
	        } else{ 
	        	//query for the billed amount list
	           tempList = (List<Billed_Amount__c>) Database.query('SELECT Id, Name, Created_By_Contact__r.Name, '+
								'Created_By_Contact__r.LastName, Business__c,'+
								'(SELECT Id, Name, Provider__r.Name, Service_Location__r.Name, Provider__c, Service_Location__c FROM Billed_Amount_Associations__r), '+
								'(SELECT Id, Procedure_Code__r.Name, Procedure_Code__r.Description__c, Billed_Value__c FROM Billed_Amount_Details__r) '+
								' FROM Billed_Amount__c '+
								' WHERE Id =\''+ billedAmountId + '\' AND Business__c =\''+businessId +'\' '); //AND RouteId__c includes (\''+String.join(new List<String>(cacheObj.VisibleLOB),'\',\'')+'\')
				System.debug('tempList::'+tempList);
				//if list finds item, add it to the wrapper
				if(tempList.size() > 0){
	 				 wrapper.billed_amount = tempList[0];
	 			}
	        }
			
		} 
		} catch(Exception ex){
			System.debug('message::' + ex.getMessage());
			System.debug('stackTrace::' + ex.getStackTraceString());
			System.debug('lineNumber::' + ex.getLineNumber());
		}
		return wrapper;
    }

	/* DELETE THE BILLED AMOUNT ASSOCIATION RECORD*/
    @AuraEnabled
	public static BilledAmountWrapper deleteAssociationApex(Billed_Amount__c billed_amount, String associationId){
		Billed_Amount_Association__c association = [SELECT Id FROM Billed_Amount_Association__c WHERE Id =: associationId];
		delete association;
		return getBilledAmountApex(billed_amount.Id, billed_amount.Business__c);
	}

	/* DELETE THE BILLED AMOUNT DETAIL RECORD*/
	@AuraEnabled
	public static BilledAmountWrapper deleteAmountApex(Billed_Amount__c billed_amount, String amountId){
		Billed_Amount_Detail__c amount = [SELECT Id FROM Billed_Amount_Detail__c WHERE Id =: amountId];
		delete amount;
		return getBilledAmountApex(billed_amount.Id, billed_amount.Business__c);
	}

	/* SAVE THE BILLED AMOUNT, BILLED AMOUNT DETAILS, BILLED AMOUNT ASSOCIATIONS*/
    @AuraEnabled
	public static BilledAmountWrapper saveBilledAmountDetailsApex(Billed_Amount__c billed_amount, String billed_details, String billed_associations){
		upsert billed_amount;

		String businessId = billed_amount.Business__c;
		businessId = businessId.substring(0,15);

		// Deserealize billed details
		System.debug('billed_details::'+billed_details);
		System.debug('billed_associations::'+billed_associations);
		List<Object> details = billed_details != null ? (List<Object>)JSON.deserializeUntyped(billed_details) : new List<object>();
		List<Billed_Amount_Detail__c> new_billed_details = new List<Billed_Amount_Detail__c>();
		for(Object detail : details) {
			Map<String, Object> detailToProperty = (Map<String, Object>) detail;

				System.debug('code::'+(String) detailToProperty.get('Procedure_Code__c')+ '### billedValue::'+detailToProperty.get('Billed_Value__c'));
			if(detailToProperty != NULL && (String) detailToProperty.get('Procedure_Code__c') != NULL  && (String) detailToProperty.get('Procedure_Code__c') != ''
				 && detailToProperty.get('Billed_Value__c') != null && String.valueOf(detailToProperty.get('Billed_Value__c')) != '') {
				if( Decimal.valueOf(''+detailToProperty.get('Billed_Value__c')) > 0){
					Billed_Amount_Detail__c new_detail = new Billed_Amount_Detail__c();
	
					// if the id exists, write it else create the new master-detail relationship
					if((String)detailToProperty.get('Id') != NULL && (String)detailToProperty.get('Id') != '') {
						new_detail.Id = (String) detailToProperty.get('Id');
					} else {
						new_detail.Billed_Amount__c = billed_amount.Id;
					}
					new_detail.Procedure_Code__c = (String) detailToProperty.get('Procedure_Code__c');
					new_detail.Billed_Value__c = Decimal.valueOf(''+detailToProperty.get('Billed_Value__c'));
					new_billed_details.add(new_detail);
				}
			}
		}

		if(new_billed_details != NULL && new_billed_details.size() > 0) {
			upsert new_billed_details;
		}

		// Deserealize billed associations
		List<Object> associations = billed_associations != null ? (List<Object>)JSON.deserializeUntyped(billed_associations) : new List<object>();
		Map<String, Billed_Amount_Association__c> billedAmountAssMap = new Map<String, Billed_Amount_Association__c>();
		for(Billed_Amount_Association__c ba : [SELECT id, Service_Location__c, Provider__c FROM Billed_Amount_Association__c WHERE Billed_Amount__c =:billed_amount.Id]){
			String key = string.valueOf(ba.Service_Location__c).substring(0,15) + '' + String.valueOf(ba.Provider__c).substring(0,15);
			billedAmountAssMap.put(key, ba);
		}
		System.debug('billedAmountAssMap::'+billedAmountAssMap.keyset());
		List<Billed_Amount_Association__c> new_billed_associations = new List<Billed_Amount_Association__c>();
		for(Object association : associations) {
			Map<String, Object> associationToProperty = (Map<String, Object>) association;
			System.debug('associationToProperty::'+associationToProperty);
			// ensure all the properties exist
			if(associationToProperty != NULL  ) {
				Billed_Amount_Association__c new_association = new Billed_Amount_Association__c();

				// if the id exists, write it else create the new master-detail relationship
				if((String)associationToProperty.get('Id') != NULL && (String)associationToProperty.get('Id') != '') {
					new_association.Id = (String) associationToProperty.get('Id');
				} else {
					new_association.Billed_Amount__c = billed_amount.Id;
				}
				//set the provider
				if((String)associationToProperty.get('Provider__c') != NULL && (String)associationToProperty.get('Provider__c') != '' && (String)associationToProperty.get('Provider__c') != 'ALL'){//
					new_association.Provider__c = (String) associationToProperty.get('Provider__c');
				} 
				//set the location
				if((String) associationToProperty.get('Service_Location__c') != NULL && (String) associationToProperty.get('Service_Location__c') != '' && (String)associationToProperty.get('Service_Location__c') != 'ALL'){//
					new_association.Service_Location__c = (String)associationToProperty.get('Service_Location__c');
				}
				
				if( (String)associationToProperty.get('Provider__c') == 'ALL' && (String)associationToProperty.get('Service_Location__c') == 'ALL'){
					//all all is selected
					for(String serviceLocationId : prov_util_Cache.BusinessId2Location2ProvidersMap.get(businessId).keyset()){
						for(String providerId : prov_util_Cache.BusinessId2Location2ProvidersMap.get(businessId).get(serviceLocationId)){
							Billed_Amount_Association__c tempnew_association = new Billed_Amount_Association__c();
							tempnew_association.Billed_Amount__c = billed_amount.Id;
							tempnew_association.Provider__c = providerId;
							tempnew_association.Service_Location__c = serviceLocationId;
							
							String key = serviceLocationId.substring(0,15) + '' +providerId.substring(0,15);
							if( !billedAmountAssMap.containsKey(key))
								new_billed_associations.add(tempnew_association);
						}
					}
				} else if( (String)associationToProperty.get('Provider__c') == 'ALL'){
					//apply to all providers
					for(Account provider : prov_util_Cache.retrieveProviders(businessId)){
						Billed_Amount_Association__c tempnew_association = new Billed_Amount_Association__c();
						tempnew_association.Billed_Amount__c = billed_amount.Id;
						tempnew_association.Provider__c = provider.Id;
						tempnew_association.Service_Location__c = (String) associationToProperty.get('Service_Location__c');
						
						String key = tempnew_association.Service_Location__c + '' +tempnew_association.Provider__c;
						if( !billedAmountAssMap.containsKey(key)){
							new_billed_associations.add(tempnew_association);
						}
					}
				} else if( (String)associationToProperty.get('Service_Location__c') == 'ALL'){
					//apply to all service locations
					for(Account servicelocation : prov_util_Cache.retrieveServiceLocation(prov_util_Cache.CurrentBusinessId)){
						Billed_Amount_Association__c tempnew_association = new Billed_Amount_Association__c();
						tempnew_association.Billed_Amount__c = billed_amount.Id;
						tempnew_association.Provider__c = (String) associationToProperty.get('Provider__c');
						tempnew_association.Service_Location__c = servicelocation.Id;
						
						String key = tempnew_association.Service_Location__c + '' + tempnew_association.Provider__c;
						if( !billedAmountAssMap.containsKey(key))
							new_billed_associations.add(tempnew_association);
					}
				} else{
					new_billed_associations.add(new_association);
				}
			}
		}

		// upsert 
		System.debug('new_billed_associations::'+new_billed_associations);
		if(new_billed_associations != NULL && new_billed_associations.size() > 0) {
			upsert new_billed_associations;
		}
		return getBilledAmountApex(billed_amount.Id, billed_amount.Business__c);
	} 

	
	/*RETRIEVE THE PROCEDURE CODES*/
	@AuraEnabled
	public static List<Procedure_Code__c> getProcedureCodeApex(String procedureCode){
		procedureCode = String.escapeSingleQuotes(procedureCode);  
		procedureCode = procedureCode.toUpperCase();  
				
		List<Procedure_Code__c> codes = [SELECT Id, Name, Description__c 
			FROM Procedure_Code__c
			WHERE Name =: procedureCode LIMIT 1];
		return codes;
	}
	
	/*RETRIEVE THE service locations based on provider*/
	@AuraEnabled
	public static List<Account> getServiceLocationsApex(String providerId){
		return prov_util_Cache.retrieveServiceLocation(prov_util_Cache.CurrentBusinessId);
	}

	/*RETRIEVE THE providers based on service location*/
	@AuraEnabled
	public static List<Account> getProvidersApex(String serviceLocationId){
		return prov_util_Cache.retrieveProviders(prov_util_Cache.CurrentBusinessId, serviceLocationId);
	}

	/* Save the billed amount record */
	@AuraEnabled
    public static BilledAmountWrapper saveBilledAmountApex(String billedAmountName, String businessId) {
    	Billed_Amount__c newBilledAmountGroup = new Billed_Amount__c();

    	Contact currentContact = prov_util_Cache.getContactRec();
    	newBilledAmountGroup.Created_By_Contact__c = currentContact.Id;
    	newBilledAmountGroup.Name = billedAmountName;
    	if(businessId == null)
    		businessId = prov_util_Cache.CurrentBusinessId;
    	newBilledAmountGroup.Business__c = businessId;
    	newBilledAmountGroup.RouteId__c = String.join(new List<String>(prov_util_Cache.VisibleLOB),';');

    	insert newBilledAmountGroup;

    	return getBilledAmountApex(newBilledAmountGroup.Id, businessId);
    }

	/*RETRIEVE THE Locations and providers for initial list*/
    @AuraEnabled 
    public static LocationsAndProviders getLocationsAndProvidersApex() {
    	//BusinessId2Location2ProvidersMap
    	LocationsAndProviders locationsAndProviders = new LocationsAndProviders();
    	System.debug('businessId::'+prov_util_Cache.CurrentBusinessId);
    	locationsAndProviders.providers = prov_util_Cache.retrieveProviders(prov_util_Cache.CurrentBusinessId);
    	System.debug('providers::'+locationsAndProviders.providers);
    	locationsAndProviders.locations = prov_util_Cache.retrieveServiceLocation(prov_util_Cache.CurrentBusinessId);
    	System.debug('locations::'+locationsAndProviders.locations);
   		return locationsAndProviders;
    }

	
	/* WRAPPER CLASS FOR THE BILLED AMOUNT AND THE BILLED AMOUNT DETAILS AND ASSOCIATIONS	*/
    public class BilledAmountWrapper {
        @AuraEnabled public Account business;
        @AuraEnabled public Billed_Amount__c billed_amount;
    }

	/* WRAPPER CLASS THE LOCATION AND PROVIDER DROPDOWNS*/
    public class LocationsAndProviders {
        @AuraEnabled public List<Account> providers;
        @AuraEnabled public List<Account> locations;
    }
}