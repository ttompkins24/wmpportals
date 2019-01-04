public without sharing class prov_ctrl_PreAuth_Drafts {
	@AuraEnabled
	public static List<Claim__c> getAuthDrafts(Integer limitNum, String businessId){

        List<Claim__c> authDraftResult = new List<Claim__c>();

        authDraftResult = queryAuthDrafts(limitNum, businessId);
        system.debug('authDraftResult apex: '+authDraftResult);
        return authDraftResult;
    }

    @AuraEnabled
	public static String deleteDraftsApex(List<Claim__c> authDrafts, Claim__c authDraft){
        String errorMessage = 'Success';
        try {
            if(authDraft != null) {
                delete authDraft;
            }
            if(authDrafts != null) {
                delete authDrafts;
            }
        } catch(System.DmlException e) {
            errorMessage = e.getMessage();
        }
        return errorMessage;
    }

	private static List<Claim__c> queryAuthDrafts(Integer limitNum, String businessId) {
        String whereClause = ' WHERE Business__c = \'' + businessId + '\'';
        whereClause += ' AND Claim_Draft_Status__c != \'Submitted\''; 
        whereClause += ' AND Claim_Type__c = \'AUTH\'';
        whereClause += ' ORDER BY LastModifiedDate DESC';
		if(limitNum != null) {
        	whereClause += ' LIMIT ' + limitNum;
		}
        return (List<Claim__c>)prov_util_DAL.dalQuery('Claim__c', whereClause);
    }
}