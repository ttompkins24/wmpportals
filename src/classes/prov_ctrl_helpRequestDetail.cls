/**********************************************************************************************************************
Name 						: prov_ctrl_helpRequestDetail
Purpose						: The controller for the component that displays the case detail page
Created on					: February 2018
Developed by				: West Monroe Partners	
History
Version#		Sprint#		Date							By  						Comments
1.0				1.0			February 2018				West Monroe Partners		See header - purpose
  

**********************************************************************************************************************/
public without sharing class prov_ctrl_helpRequestDetail {
    
    /***********************************************************
    Method Name : fetch_relatedCaseInfo
    Purpose		: send the case with detail information
    ************************************************************/
    @AuraEnabled
    public static Case fetch_relatedCaseInfo(String str_caseId){
    	
    	List<Case> list_relatedCase = [SELECT Id, Account.Name, Provider__r.Name, Service_Location__r.Name, Subject, CaseNumber,
                Status, Claim_Auth__c, Meeting_Logistics_Contact_Date__c, Requested_Contact_Time__c, Requested_Contact_Time_Zone__c, Meeting_Logistics_Phone__c, Description, ClosedDate, IsClosed, Business_lkup__r.Name, Claim_Void_Reason__c, Claim_Void_Reason_Other__c, Desired_Resolution__c, Resolution_Description__c, Member_First_Name__c, 
                Member_Last_Name__c, Member_ID__c, Provider_Portal_Member_Last_Name__c, Provider_Portal_Member_First_Name__c,
                Provider_NPI__c, Amount__c, Practice_Management_Updates__c, Desired_Start_Date__c, Notes__c, Member_Name__c	
            FROM Case
            WHERE Id =: str_caseId];
    	return list_relatedCase[0];
    }

    /***********************************************************
    Method Name : fetch_relatedCaseComments
    Purpose		: send the case comments
    ************************************************************/
    @AuraEnabled
    public static List<CaseComment> fetch_relatedCaseComments(String str_caseId){
    	List<CaseComment> list_relatedCaseComments = new List<CaseComment>();
    	
   		//iterating through the list of attachments
    	for(CaseComment iterating_comment : [ SELECT Id,
    													CreatedById,
    													CreatedBy.name,
    													CommentBody,
    													CreatedDate
    											 FROM 	CaseComment
    											 WHERE  ParentId =:str_caseId
    											 AND IsPublished = true
    											 ORDER BY CreatedDate DESC
    											]){
    		//adding to the list
    		list_relatedCaseComments.add(iterating_comment);
    	}
    	
    	//if not present, an exception is thrown and sent back to the lightning controller as an error in the callback function
    	return list_relatedCaseComments;
    }
    
    /***********************************************************
    Method Name : fetch_RunningUser
    Purpose		: send the running user
    ************************************************************/
    @AuraEnabled
    public static User fetch_RunningUser(){
    	//returning from cache class
    	return prov_util_Cache.getUserRec();
    }

    /***********************************************************
    Method Name : saveCaseComment
    Purpose		: saving case comment
    ************************************************************/
    @AuraEnabled
    public static void saveCaseComment(String caseCommentDescription, Id caseId){
    	CaseComment inst_CaseComment = new CaseComment(ParentId=caseId, CommentBody = caseCommentDescription);
    	insert inst_CaseComment;
    }
}