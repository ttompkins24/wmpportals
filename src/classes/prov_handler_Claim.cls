/*
		TRIGGER HANDLER FOR CLAIM__C
		This class contains the helper methods called by the trigger on the claim object
*/

public with sharing class prov_handler_Claim {
    
    /*
    	BY: West Monroe Partners
    	4.30.2018
    	AFTER UPDATE TRIGGER
    	
    	If claim draft status changes, make the updates to claim child objects attached to those claims. This allows for child validation rules
    	to run on those records
    */
    public static void passDraftStatus(Map<Id,Claim__c> newMap, Map<Id, Claim__c> oldMap){
    	System.debug('START passDraftStatus.....');
    	//initialize the variables
    	Set<Id> claimIds = new Set<Id>();
    	List<COB_Payer_Claim__c> updateCOBPayer = new List<COB_Payer_Claim__c>();
    	List<Claim_Service_Line__c> updateClaimSL = new List<Claim_Service_Line__c>();
    	List<COB_Payer_Detail__c> updateCOBDetail = new List<COB_Payer_Detail__c>();
    	
    	Map<Id, Id> detailId2ClaimIdMap = new Map<Id, Id>();
    	
    	//loop through the records and see if the draft status has changed
    	for(Claim__c claim : newMap.values()){
    		if(claim.Claim_Draft_Status__c != oldMap.get(claim.Id).Claim_Draft_Status__c){
    			claimIds.add( claim.Id );
    		}
    	}
    	
    	//check to see if any records met the criteria
    	if(claimIds.size() > 0){
    		String objectName ;
			//Savepoint sp = Database.setSavepoint();
    		String tempClaimId = '';
	    		//query for cob payer claim 
	    		for(COB_Payer_Claim__c payer : [SELECT id, Claim_Draft_Status__c, Claim__c FROM COB_Payer_Claim__c WHERE Claim__c IN:claimIds]){
	    			String detailId = String.valueOf(payer.Id).substring(0,15);
	    			tempClaimId = String.valueOf(payer.Claim__c).substring(0,15);
	    			//update the status to what is on the claim
	    			payer.Claim_Draft_Status__c = newMap.get(payer.Claim__c).Claim_Draft_Status__c;
	    			detailId2ClaimIdMap.put(detailId, tempClaimId);
	    			updateCOBPayer.add( payer );
	    		}
	    		
	    		//query for the claim service line and its child cob payer details
	    		for(Claim_Service_Line__c servLine : [SELECT id, Claim_Draft_Status__c, Claim__c, (Select Id, Claim_Draft_Status__c From COB_Payer_Details__r) FROM Claim_Service_Line__c WHERE Claim__c IN:claimIds]){
	    			String detailId = String.valueOf(servLine.Id).substring(0,15);
	    			tempClaimId = String.valueOf(servLine.Claim__c).substring(0,15);
	    			//update the status to what is on the claim
	    			servLine.Claim_Draft_Status__c = newMap.get(servLine.Claim__c).Claim_Draft_Status__c;
	    			detailId2ClaimIdMap.put(detailId, tempClaimId);
					
					//add record to list to later update    			
	    			updateClaimSL.add( servLine );
	    			for(COB_Payer_Detail__c detail : servLine.COB_Payer_Details__r){
		    			detailId = String.valueOf(detail.Id).substring(0,15);
		    			//update the status to what is on the claim
		    			detail.Claim_Draft_Status__c = newMap.get(servLine.Claim__c).Claim_Draft_Status__c;
	
		    			detailId2ClaimIdMap.put(detailId, tempClaimId);
		    			
						//add record to list to later update    			
		    			updateCOBDetail.add( detail );
	    				
	    			}
	    		}
	    		//update the cob payer
	    		Database.SaveResult[] cobPayerResult = Database.update(updateCOBPayer, false);
	    		
	    		for(INteger i = 0; i < cobPayerResult.size(); i++){
	    			Database.SaveResult result =cobPayerResult[i];
	    			if(!result.isSuccess()){
	    				System.debug('result::'+result);
	    				String detailId = updateCOBPayer[i].Id;
	    				detailId = detailId.substring(0,15);
	    				String claimId = detailId2ClaimIdMap.get(detailId);
	    				Database.Error errorObj = result.getErrors()[0];
	    				objectName = 'COB_Payer_Claim__c';
	    				
	    				//String errorMessage = claimId + '####'+ detailId + '####'+ objectName + '####'+ errorObj.getMessage();
	    				//throw new ClaimException(errorObj, detailId, claimid, objectName);
	    				//System.debug('claimOBJ::'+newMap.get(claimId));
	    				newMap.get(claimId).addError(new ClaimException(errorObj, detailId, claimid, objectName));
	    				//newMap.get(claimId).addError( errorMessage );
	    			}
	    		} 
	    		//objectName = 'COB_Payer_Claim__c';
	    		//update updateCOBPayer;
	    		//update the claim service line items
	    		//objectName = 'Claim_Service_Line__c';
	    		Database.SaveResult[] claimSLResult = Database.update(updateClaimSL, false);
	    		for(INteger i = 0; i < claimSLResult.size(); i++){
	    			Database.SaveResult result =claimSLResult[i];
	    			if(!result.isSuccess()){
	    				System.debug('result::'+result);
	    				String detailId = updateClaimSL[i].Id;
	    				detailId = detailId.substring(0,15);
	    				String claimId = detailId2ClaimIdMap.get(detailId);
	    				Database.Error errorObj = result.getErrors()[0];
	    				objectName = 'Claim_Service_Line__c';
	    				
	    				//String errorMessage = claimId + '####'+ detailId + '####'+ objectName + '####'+ errorObj.getMessage();
	    				//throw new ClaimException(errorObj, detailId, claimid, objectName);
	    				//System.debug('claimOBJ::'+newMap.get(claimId));
	    				newMap.get(claimId).addError(new ClaimException(errorObj, detailId, claimid, objectName));
	    				//newMap.get(claimId).addError( errorMessage );
	    			}
	    		}
	    		//update updateClaimSL; 
	    		System.debug('end with claim service line');
	    		//update the cob payer details
	    		//objectName = 'COB_Payer_Detail__c';
	    		Database.SaveResult[] cobDetailResult = Database.update(updateCOBDetail, false);
	    		for(INteger i = 0; i < cobDetailResult.size(); i++){
	    			Database.SaveResult result =cobDetailResult[i];
	    			if(!result.isSuccess()){
	    				System.debug('result::'+result);
	    				String detailId = updateCOBDetail[i].Id;
	    				detailId = detailId.substring(0,15);
	    				String claimId = detailId2ClaimIdMap.get(detailId);
	    				Database.Error errorObj = result.getErrors()[0];
	    				objectName = 'COB_Payer_Detail__c';
	    				
	    				
	    				//throw new ClaimException(errorObj, detailId, claimid, objectName);
	    				//System.debug('claimOBJ::'+newMap.get(claimId));
	    				newMap.get(claimId).addError(new ClaimException(errorObj, detailId, claimid, objectName));
	    				//newMap.get(claimId).addError( errorMessage );
	    			}
	    		}
	    		//update updateCOBDetail;
    		
    	}
    	System.debug('END passDraftStatus.....');
    }
}