global without sharing class prov_wrap_PanelRoster {

	@AuraEnabled 
    public String memberNumber {get;set;}//member Number

    @AuraEnabled
    public String mempcdGuid {get;set;}
    
@AuraEnabled
    public String universalMemberGuid{get;set;}
    
    @AuraEnabled
    public String firstName {get;set;}//First Name

    @AuraEnabled
    public String lastName {get;set;}//Last Name
    @AuraEnabled
    public String phone {get;set;}//Last Name
    @AuraEnabled
    public String address {get;set;}//Last Name
    @AuraEnabled
    public String language {get;set;}//Last Name
    
    @AuraEnabled
    public String planGuid {get;set;}//planGuid to hold for Apex controller

    @AuraEnabled
    public String planName {get;set;}//Plan Name from planGuid

    @AuraEnabled
    public String memberProfileGuid {get;set;}

    @AuraEnabled
    public Date birthDate {get;set;}//string of Birthdate

    @AuraEnabled
    public String pcdGuid {get;set;}//string of service Location or provider guid

    @AuraEnabled
    public String pcdName {get;set;}//name of the PCD based on pcd Guid

    @AuraEnabled
    public String RouteId {get;set;}//name of the PCD based on pcd Guid
    
    @AuraEnabled
    public Date effectiveDate {get;set;}
    
    @AuraEnabled 
    public List<mock_Member__c> members {get;set;}

    @AuraEnabled
    public mock_MemberCoverage__c memCov {get;set;}

    @AuraEnabled
    public String ProviderName {get;set;}
   
    @AuraEnabled
    public String ServiceOfficeAddress {get; set;} 

    global prov_wrap_PanelRoster(){

    }

}