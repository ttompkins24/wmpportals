public without sharing class prov_ctrl_Claim_Drafts {
	@AuraEnabled
	public static List<Claim__c> getClaimDrafts(Integer limitNum, String businessId){

        List<Claim__c> claimDraftResult = new List<Claim__c>();

        claimDraftResult = queryClaimDrafts(limitNum, businessId);
        system.debug('claimDraftResult apex: '+claimDraftResult);
        return claimDraftResult;
    }

    @AuraEnabled
	public static Map<String, Integer> submitDraftsApex(List<Claim__c> claimDrafts){
        List<Claim__c> claimDraftsToSubmit = new List<Claim__c>();
        Map<String, Integer> submissionResultsMap = new Map<String, Integer>{'success' => 0, 'error' => 0};
        for(Claim__c tempClaim : claimDrafts) {
            tempClaim.Is_Submitted__c = true;
            tempClaim.Submitted_DateTime__c = DateTime.now();
            tempClaim.Claim_Draft_Status__c = 'Submitted';
            claimDraftsToSubmit.add(tempClaim);
        }
        system.debug('got here');
        List<Database.SaveResult> srList = Database.update(claimDraftsToSubmit, false);
        List<Claim__c> submitSuccessList = new List<Claim__c>();
        List<Claim__c> submitFailedList = new List<Claim__c>();
        system.debug('srList: '+srList);
        for(Integer i=0;i<srList.size();i++) {
            if(srList.get(i).isSuccess()) {
                // up the count of the successful submissions
                submissionResultsMap.put('success', submissionResultsMap.get('success') + 1);
                // send successful updates to get a claim number
                Claim__c submitSuccessClaim = claimDraftsToSubmit.get(i);
                submitSuccessList.add(submitSuccessClaim);
            } else {
                for(Database.Error err : srList.get(i).getErrors()) {
                    system.debug('draft submission error: '+ err.getStatusCode() + ': ' + err.getMessage());
                    system.debug('on line: '+i);
                    system.debug('on fields: '+ err.getFields());
                }
                // up the count of the failed submissions
                submissionResultsMap.put('error', submissionResultsMap.get('error') + 1);
                Claim__c submitFailedClaim = claimDraftsToSubmit.get(i);
                submitFailedList.add(submitFailedClaim);
            }
        }
        // create claim numbers for successfully submitted claims only, or we will waste claim numbers
        if(!submitSuccessList.isEmpty()) {
            try {
                List<Claim__c> updateClaimNumberList = new List<Claim__c>();                
                List<String> claimNumbers = prov_util_Claims.buildnumber(submitSuccessList.size());
                for(integer i=0; i<submitSuccessList.size(); i++) {
                    Claim__c tempClaim = submitSuccessList[i];
                    tempClaim.Claim_Number__c = claimNumbers[i];
                    updateClaimNumberList.add(tempClaim);
                }
                Update updateClaimNumberList;
            } catch(System.DmlException e) {
                system.debug('submitSuccessList failed to update: '+ e.getMessage());
            }
        }
        system.debug('submitFailedList: '+submitFailedList);
        system.debug('update submissionResultsMap: '+submissionResultsMap);
        return submissionResultsMap;
    }

    @AuraEnabled
	public static String deleteDraftsApex(List<Claim__c> claimDrafts, Claim__c claimDraft){
        String errorMessage = 'Success';
        try {
            if(claimDraft != null) {
                delete claimDraft;
            }
            if(claimDrafts != null) {
                delete claimdrafts;
            }
        } catch(System.DmlException e) {
            errorMessage = e.getMessage();
        }
        return errorMessage;
    }

	private static List<Claim__c> queryClaimDrafts(Integer limitNum, String businessId) {
        String whereClause = ' WHERE Business__c = \'' + businessId + '\'';
        whereClause += ' AND Claim_Draft_Status__c != \'Submitted\''; 
        whereClause += ' AND Claim_Type__c = \'CLAIM\'';
        whereClause += ' ORDER BY LastModifiedDate DESC';
		if(limitNum != null) {
        	whereClause += ' LIMIT ' + limitNum;
		}
        return (List<Claim__c>)prov_util_DAL.dalQuery('Claim__c', whereClause);
    }
}