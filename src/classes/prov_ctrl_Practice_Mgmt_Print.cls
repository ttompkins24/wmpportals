public without sharing class prov_ctrl_Practice_Mgmt_Print {
	public String PDFData {get; set;}
    public String errorMessageString {
        get {
            return errorMessageStringInternal;
        } private set;
    }
    public Boolean hasError {
        get{
            return hasErrorInternal;
        } private set;
    }

    public Account bizacctrec {get; set;}
    public List<Account> locaccts {get; set;}
    public List<Providers_Service_Locations__c> provaccts {get; set;}

    public Account bizAcctRecId {get;set;}
    public Account locAcctRecId {get;set;}
    public Account provAcctRecId {get;set;}

    public String locationId {get;set;}
    public String providerId {get;set;}
    public String businessId {get;set;}
    public String bizId {get;set;}
    public String pageNumber {get;set;}
    public String sortFieldLoc {get;set;}
    public String sortDirectionLoc {get;set;}
    public String sortFieldProv {get;set;}
    public String sortDirectionProv {get;set;}
    public String errorMessageStringInternal {get;set;}
    public Boolean hasErrorInternal {get;set;}


    public prov_ctrl_Practice_Mgmt_Print() {
        PDFData = '';
        errorMessageStringInternal = '';
        locationId = ApexPages.currentPage().getParameters().get('locId');
        providerId = ApexPages.currentPage().getParameters().get('provId');
        businessId = ApexPages.currentPage().getParameters().get('busId');
        if(businessId != null && businessId.length() > 15)
        	businessId = businessId.subString(0,15);
        bizId = businessId;
        sortFieldLoc = ApexPages.currentPage().getParameters().get('locSort');
        sortDirectionLoc = ApexPages.currentPage().getParameters().get('locDir');
        sortFieldProv = ApexPages.currentPage().getParameters().get('provSort');
        sortDirectionProv = ApexPages.currentPage().getParameters().get('provDir');

        system.debug('locationId :'+locationId);
        system.debug('providerId :'+providerId);
        system.debug('businessId : '+ businessId);


        //call get methods
        set1Bizacctrec();
        set1Locaccts();
        set1Provaccts();


    }


    public void set1Bizacctrec() {
    
    Account results = [SELECT Id, Name, Phone, tax_id_number__c FROM Account Where Id = :businessId];
	system.debug(results.tax_id_number__c);


    bizacctrec = results;
	
    }

    public void set1Locaccts() {
        hasErrorInternal = false;
        List<String> locAcctIDList = new List<String>();
        List<String> provAcctIDList = new List<String>();

        if(locationId == null){
            locAcctIDList = prov_util_Cache.retrieveActiveServiceLocationIds(businessId);
        }
        
        if(providerId == null || providerId == 'Any'){
            provAcctIDList = prov_util_Cache.retrieveProviderIdsByBusinessId(businessId);
        } else {
        	provAcctIDList.add(providerId);
        }

        if(locationId != null){
            if(!prov_util_Cache.retrieveServiceLocationIdsByBusinessId(businessId).contains(locationId)) {
                errorMessageStringInternal += 'Service Location supplied is not available for the current Business. ';
                hasErrorInternal = true;
            }
        }

        if(sortFieldLoc == null || sortFieldLoc == '')        sortFieldLoc = 'Name';
        if(sortDirectionLoc == null || sortDirectionLoc == '')   sortDirectionLoc = 'ASC';
        system.debug(locationId);
        String whereClause = 'SELECT id, Service_Location__c';
        whereClause +=              ' FROM Providers_Service_Locations__c '; 
        if(locationId == null){
            whereClause += ' WHERE Service_Location__c IN :locAcctIDList';
        }else{
        whereClause += ' WHERE Service_Location__c = :locationId'; 
        }

		whereClause += ' AND Provider__c IN:provAcctIDList';
		
		whereClause += ' AND Effective_Date__c <= TODAY ' ;
        whereClause += ' AND (termination_date__c >= TODAY OR termination_date__c = null)';
		
        String order = '';
        if(sortFieldLoc != null || sortDirectionLoc != null){
            order = ' ORDER BY '+sortFieldLoc+' '+sortDirectionLoc;
        }

        whereClause += order;
        
        Set<String> locIdSet = new Set<String>();
        for(Providers_Service_Locations__c psl : (List<Providers_Service_Locations__c>)Database.query(whereClause)){
        	locIdSet.add(psl.Service_Location__c);
        }
        
        List<Account> results = new List<Account>();

        if(!hasErrorInternal) {
            results = Database.query('SELECT id, Name, BillingStreet, Service_Location_Name__c, BillingCity, BillingState, BillingPostalCode, Phone FROM Account WHERE Id IN:locIdSet' );
        }
		    
        locaccts = results;
        
    }

    public void set1Provaccts(){
        System.debug('Starting getProvaccts...');
        System.debug('locationId ' + locationId);
        System.debug('providerId ' + providerId);
        System.debug('businessId ' + businessId);

        hasErrorInternal = false;
        List<String> locAcctIDList = new List<String>();
        List<String> provAcctIDList = new List<String>();

        if(locationId == null){
        locAcctIDList = prov_util_Cache.retrieveServiceLocationIdsByBusinessId(businessId);
        }

        if(providerId == null || providerId == 'Any'){
            provAcctIDList = prov_util_Cache.retrieveProviderIdsByBusinessId(businessId);
        }

        /*if(locationId != null ){
            if(!prov_util_Cache.retrieveServiceLocationIdsByBusinessId(businessId).contains(locationId)) {
                errorMessageStringInternal += 'Service Location supplied is not available for the current Business. ';
                hasErrorInternal = true;
            }
        }
        if(providerId != null && providerId != 'Any') {
            if(!prov_util_Cache.retrieveProviderIdsByBusinessId(businessId).contains(providerId)) {
                errorMessageStringInternal += 'Provider supplied is not available for the current Business. ';
                hasErrorInternal = true;
            }
        }*/

        if(sortFieldProv == null || sortFieldProv == '')        sortFieldProv = 'Provider__r.Name';
        if(sortDirectionProv == null || sortDirectionProv == '')   sortDirectionProv = 'ASC';

        String whereClause = 'SELECT id, Name, Provider__c, Provider__r.Id, Provider__r.Name, Service_Location__c, Service_Location__r.BillingStreet, Service_Location__r.BillingCity, Service_Location__r.BillingState, Service_Location__r.BillingPostalCode, Service_Location__r.Phone, Provider__r.npi__c, Business__c';
        whereClause +=              ' FROM Providers_Service_Locations__c'; 
        whereClause += ' WHERE Business__c = :businessId AND Effective_Date__c <= TODAY ' ;
        whereClause += ' AND (termination_date__c >= TODAY OR termination_date__c = null)';
        if(locationId == null){
            whereClause += ' AND Service_Location__c IN :locAcctIDList';
        }else{
        whereClause += ' AND Service_Location__c = :locationId';    
        }


        if(providerId == null || providerId == '' || providerId == 'Any'){
            whereClause += ' AND Provider__c IN :provAcctIDList';
        } else {
           whereClause += ' AND Provider__c = :providerId';
        }

        //build query ordering based on field and direction
        String order = '';
        if(sortFieldProv != null || sortDirectionProv != null){
            order = ' ORDER BY '+sortFieldProv+' '+sortDirectionProv;
        }
        



        whereClause += order;
        system.debug(whereClause);
        List<Providers_Service_Locations__c> psl = new List<Providers_Service_Locations__c>();
        
        if(!hasErrorInternal) {
            psl = Database.query(whereClause);
            system.debug(psl);
        }

        provaccts = psl;
    }

}