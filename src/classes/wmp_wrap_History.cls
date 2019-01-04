/**********************************************************************************************************************
Purpose						: A wrapper class that helps display the History info to the end user
Created on					: 9th Oct 2017
Developed by				: Todd Tompkins
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th Oct 2017					Todd Tompkins					See header - purpose
  

**********************************************************************************************************************/
public without sharing class wmp_wrap_History {
        
    @AuraEnabled
    public Date appDate {get;set;}
    
    @AuraEnabled
    public String description {get;set;}
    
    @AuraEnabled
    public String provider {get;set;}
    
    @AuraEnabled
    public String procedureCode {get;set;}
    
    @AuraEnabled
    public String partOfMouth {get;set;}
    
    @AuraEnabled
    public String claimNumber {get;set;}
    
    @AuraEnabled
    public String claimStatus {get;set;}
    
    @AuraEnabled
    public String planGuid {get;set;}
    @AuraEnabled
    public String planName {get;set;}
    
    @AuraEnabled
    public Decimal totalCost {get;set;}
    
    @AuraEnabled
    public Decimal planPay {get;set;}
    
    @AuraEnabled
    public Decimal youPay {get;set;}
    
    @AuraEnabled
    public String eobName {get;set;}
    
    @AuraEnabled
    public String eobUrl {get;set;}
    
    public wmp_wrap_History(){
    	
    }
    
    public wmp_wrap_History(mock_MembersServiceHistory__c history){
    	//set the fields
    	this.appDate = history.ProcedureDate__c;
    	this.description = history.ProcedureCodeDescription__c;
    	this.provider = history.ProviderName__c;
    	this.procedureCode = history.ProcedureCode__c + '-'+history.ProcedureCodeDescription__c;
    	this.claimNumber = history.ClaimNumber__c;
    	this.claimStatus = history.ServiceLineStatus__c;
    	this.planGuid = history.PlanGuid__c;
    	this.totalCost = history.SubmittedFee__c;
    	this.planPay = history.AmountPaid__c;
    	this.youPay = history.AmountPatientPaid__c;
    	
    	this.partOfMouth = '';
    	//construct the string for part of mouth
    	if(history.ToothCode__c != '' && history.ToothCode__c != null)
    		this.partOfMouth += 'Tooth ' + history.ToothCode__c + ', ';
    	if(history.ToothSurfaces__c != '' && history.ToothSurfaces__c != null)
    		this.partOfMouth += 'Surface(s) ' + history.ToothSurfaces__c + ', ';
    	if(history.OralCavityQuadDescription__c != '' && history.OralCavityQuadDescription__c != null)
    		this.partOfMouth +=  history.OralCavityQuadDescription__c + ', ';
    	if(history.OralCavityArchDescription__c != '' && history.OralCavityArchDescription__c != null)
    		this.partOfMouth +=  history.OralCavityArchDescription__c + ', ';
    	
    	if(this.partOfMouth != '')
    		this.partOfMouth = this.partOfMouth.substring(0, this.partOfMouth.length()-2);
    }
}