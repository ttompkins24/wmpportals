global without sharing class wmp_class_PrimaryDentistInfo {
    
    @AuraEnabled
    public 	String											Name									{get;set;}
     
    @AuraEnabled
    public 	String											Phone									{get;set;}
    
    @AuraEnabled
    public 	String											streetAddress							{get;set;}
    
    @AuraEnabled
    public 	Account											Provider								{get;private set;}
    
    @AuraEnabled
    public	Providers_Service_Locations__c					ServiceLocation							{get;private set;}
    
    @AuraEnabled
    public	mock_MemberPrimaryCareDentist__c						PrimaryRecord							{get;private set;}
    
    public wmp_class_PrimaryDentistInfo(mock_MemberPrimaryCareDentist__c mpcdx, Account thisProvider, Providers_Service_Locations__c thisLocation){
    	System.debug('thisProvider::'+thisProvider);
    	System.debug('SPL::'+thisLocation);
 		Provider = thisProvider;
 		ServiceLocation = thisLocation;
 		PrimaryRecord = mpcdx;
 		if(thisProvider != null){
	 		Name= thisProvider.Name;
	 		Phone = thisProvider.Phone;
	 		
 		}
 		if(thisLocation != null){
 			streetAddress = thisLocation.Address__c;
 		}
    }

}