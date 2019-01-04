/**********************************************************************************************************************
Purpose						: A wrapper class that helps display the FAD info to the end user
Created on					: 9th Oct 2017
Developed by				: Todd Tompkins
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th Oct 2017					Todd Tompkins					See header - purpose
  

**********************************************************************************************************************/
public without sharing class prov_wrap_FAD {
    
    @AuraEnabled 
    public String name {get;set;}//both dentist and office
    
    @AuraEnabled
    public String id {get;set;}//both dentist and office
    
    //@AuraEnabled
    //public String specialty {get;set;}//dentist
    
    @AuraEnabled
    public String languages {get;set;}//dentist
    
    @AuraEnabled
    public String distance {get;set;}//office
    
    @AuraEnabled
    public String phone {get;set;}//office
    
    @AuraEnabled
    public String address {get;set;}//office
    
    @AuraEnabled
    public Boolean acceptingNewPatients {get;set;}//accepting new patients for that plan at that location/provider/or both
    
    @AuraEnabled
    public List<Map<String, String>> children {get;set;}//both dentist and office
    
    @AuraEnabled
    public List<Map<String, String>> moreChildren {get;set;}//both dentist and office
    
    public prov_wrap_FAD(){
    	children = new List<Map<String, String>>();
    	moreChildren = new List<Map<String, String>>();
    }
    
    public void main_dentist(Providers_Service_Locations__c psl){
    	//make the languages be separated by commas
		String languageSemiColon = psl.Provider__r.Supported_Languages__c;
		if(languageSemiColon != null){
			String[] languageList = languageSemiColon.split(';');
			languages =String.join(languageList, ', ');
		} else {
			languages ='';
		}
    	//set the fields
		name =  psl.Provider__r.Name;
		//specialty = psl.Provider__r.Specialties__c;
		id = psl.Provider__r.Id;
    }
    
    public void main_office(Providers_Service_Locations__c psl, Location sGeo){
    	//initialize variables
    	Location serviceGEO = Location.newInstance(psl.Service_Location__r.BillingLatitude,
															psl.Service_Location__r.BillingLongitude);//get the service location for the current record
		System.debug('serviceGEO::'+serviceGEO);
    	String sDistance =  serviceGEO.getLatitude() != null ? String.valueOf( Decimal.valueOf(serviceGeo.getDistance( sGeo, 'mi') ).setScale(1) ) : '1';//get the distance between the two geos
		String sAddress = formatAddress(psl.Service_Location__r.BillingStreet,  psl.Service_Location__r.BillingCity, 
									psl.Service_Location__r.BillingState, psl.Service_Location__r.BillingPostalCode);//format the billing address
				
		//map the info for the location
		name = psl.Service_Location__r.Name;
		address = sAddress;
		distance = sDistance ;
		phone = psl.Service_Location__r.Phone ;
		id = psl.Service_Location__r.id ;
    }
    
    public Map<String, String> child_dentist(Providers_Service_Locations__c psl, Boolean pslAcceptingNewPatients, String specialties){
    	//initialize the var
    	Map<String, String> dentistObj = new Map<String, String>();
		
		//make the languages be separated by commas
		String languageSemiColon = psl.Provider__r.Supported_Languages__c;
		if(languageSemiColon != null){
			String[] languageList = languageSemiColon.split(';');
			dentistObj.put('languages', String.join(languageList, ', '));
		} else {
			dentistObj.put('languages', '');
		}
		
		//set the fields
		dentistObj.put('name', psl.Provider__r.Name);
		dentistObj.put('acceptingNewPatients', pslAcceptingNewPatients ? 'true' :'false');
		dentistObj.put('specialty', specialties);
		dentistObj.put('providerId', psl.Provider__r.Id);
		dentistObj.put('serviceLocationId', psl.Service_Location__r.Id);
		dentistObj.put('pslId', psl.Id);
		dentistObj.put('phone', psl.Service_Location__r.Phone );
		dentistObj.put('providerName', psl.Provider__r.Name );
		dentistObj.put('provWindGuid', psl.Provider__r.guid__c);
		dentistObj.put('slWindGuid', psl.Service_Location__r.guid__c);
		dentistObj.put('routeId', psl.route_Id__c);
		dentistObj.put('npi', psl.Provider__r.NPI__c);
		dentistObj.put('streetAddress', psl.Service_Location__r.BillingStreet);
		dentistObj.put('city', psl.Service_Location__r.BillingCity);
		dentistObj.put('state', psl.Service_Location__r.BillingState);
		dentistObj.put('zipcode', psl.Service_Location__r.BillingPostalCode);
		dentistObj.put('country', psl.Service_Location__r.BillingCountry);
		
		return dentistObj;
    }
    
    public Map<String, String> child_office(Providers_Service_Locations__c psl, Location sGeo, Boolean pslAcceptingNewPatients, String specialties){//, Boolean pslAcceptingNewPatients
    	//initialize the var
    	Map<String, String> officeObj = new Map<String, String>();
    	Location serviceGEO = Location.newInstance(psl.Service_Location__r.BillingLatitude,
															psl.Service_Location__r.BillingLongitude);//get the service location for the current record
    	String sDistance =  serviceGEO.getLatitude() != null ? String.valueOf( Decimal.valueOf(serviceGeo.getDistance( sGeo, 'mi') ).setScale(1) ) : '1';//get the distance between the two geos
		String sAddress = formatAddress(psl.Service_Location__r.BillingStreet,  psl.Service_Location__r.BillingCity, 
									psl.Service_Location__r.BillingState, psl.Service_Location__r.BillingPostalCode);//format the billing address
				
		//map the info for the location
		officeObj.put('name', psl.Service_Location__r.Name);
		officeObj.put('pslId', psl.Id);
		officeObj.put('acceptingNewPatients', pslAcceptingNewPatients ? 'true' :'false');
		officeObj.put('address', sAddress);
		officeObj.put('specialty', specialties);
		officeObj.put('distance', sDistance );
		officeObj.put('phone', psl.Service_Location__r.Phone );
		officeObj.put('providerName', psl.Provider__r.Name );
		officeObj.put('providerId', psl.Provider__r.id );
		officeObj.put('serviceLocationId', psl.Service_Location__r.Id);
		officeObj.put('provWindGuid', psl.Provider__r.guid__c);
		officeObj.put('slWindGuid', psl.Service_Location__r.guid__c);
		officeObj.put('npi', psl.Provider__r.NPI__c);
		officeObj.put('routeId', psl.route_Id__c);
		officeObj.put('streetAddress', psl.Service_Location__r.BillingStreet);
		officeObj.put('city', psl.Service_Location__r.BillingCity);
		officeObj.put('state', psl.Service_Location__r.BillingState);
		officeObj.put('zipcode', psl.Service_Location__r.BillingPostalCode);
		officeObj.put('country', psl.Service_Location__r.BillingCountry);
						
		return officeObj;
    }
    
    public String formatAddress(String streetAddress, String city, string state, String zipcode){
    	if(streetAddress != null)
    		return streetAddress  + ', '+ city + ', ' +state +' ' + zipcode;
    	else
    		return '';
    }
}