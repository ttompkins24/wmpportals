/*
		TRIGGER HANDLER FOR CLAIM__C
		This class contains the helper methods called by the trigger on the claim object
*/

public with sharing class prov_logic_Claim {
    
    /*
    	BY: West Monroe Partners
    	4.30.2018
    	AFTER UPDATE TRIGGER
    	
    	If claim draft status changes, make the updates to claim child objects attached to those claims. This allows for child validation rules
    	to run on those records
    */
    public static void passDraftStatus(Map<Id,Claim__c> newMap, Map<Id, Claim__c> oldMap){
    	//initialize the variables
    	Set<Id> claimIds = new Set<Id>();
    	List<COB_Payer_Claim__c> updateCOBPayer = new List<COB_Payer_Claim__c>();
    	List<Claim_Service_Line__c> updateClaimSL = new List<Claim_Service_Line__c>();
    	List<COB_Payer_Detail__c> updateCOBDetail = new List<COB_Payer_Detail__c>();
    	
    	//loop through the records and see if the draft status has changed
    	for(Claim__c claim : newMap.values()){
    		if(claim.Claim_Draft_Status__c != oldMap.get(claim.Id).Claim_Draft_Status__c){
    			claimIds.add( claim.Id );
    		}
    	}
    	
    	//check to see if any records met the criteria
    	if(claimIds.size() > 0){
    		//query for cob payer claim 
    		for(COB_Payer_Claim__c payer : [SELECT id, Claim_Draft_Status__c, Claim__c FROM COB_Payer_Claim__c WHERE Claim__c IN:claimIds]){
    			//update the status to what is on the claim
    			payer.Claim_Draft_Status__c = newMap.get(payer.Claim__c).Claim_Draft_Status__c;
    			updateCOBPayer.add( payer );
    		}
    		//update the cob payer
    		update updateCOBPayer;
    		
    		//query for the claim service line and its child cob payer details
    		for(Claim_Service_Line__c servLine : [SELECT id, Claim_Draft_Status__c, Claim__c, (Select Id, Claim_Draft_Status__c From COB_Payer_Details__r) FROM Claim_Service_Line__c WHERE Claim__c IN:claimIds]){
    			//update the status to what is on the claim
    			servLine.Claim_Draft_Status__c = newMap.get(servLine.Claim__c).Claim_Draft_Status__c;
				
				//add record to list to later update    			
    			updateClaimSL.add( servLine );
    			for(COB_Payer_Detail__c detail : servLine.COB_Payer_Details__r){
	    			//update the status to what is on the claim
	    			detail.Claim_Draft_Status__c = newMap.get(servLine.Claim__c).Claim_Draft_Status__c;

					//add record to list to later update    			
	    			updateCOBDetail.add( detail );
    				
    			}
    		}
    		
    		//update the claim service line items
    		update updateClaimSL;
    		
    		//update the cob payer details
    		update updateCOBDetail;
    	}
    }
}