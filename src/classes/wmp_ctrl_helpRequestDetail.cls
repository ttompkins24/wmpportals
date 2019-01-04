/**********************************************************************************************************************
Name 						: wmp_ctrl_helpRequestDetail
Purpose						: The controller for the component that displays the case detail page
Created on					: 12th October 2017
Developed by				: Santosh Kumar Sriram
History
Version#		Sprint#		Date							By  						Comments
1.0				1.0			12th October 2017				Santosh Kumar Sriram		See header - purpose
  

**********************************************************************************************************************/
public without sharing class wmp_ctrl_helpRequestDetail {
    
    /***********************************************************
    Method Name : fetch_relatedCaseInfo
    Purpose		: send the case with detail information
    ************************************************************/
    @AuraEnabled
    public static Case fetch_relatedCaseInfo(String str_caseId){
    	
    	list<Case> list_relatedCase = new list<Case>();
    	
    	//Constructing the where clause
    	String whereClause = ' WHERE Id=\'' + str_caseId + '\'';
    	
    	
    	Set<String> subIdSet = new Set<String>();
    	Set<String> planIdGuidSet = new Set<String>();
    	List<String> planIdList = new List<String>();
    	for(mock_MemberCoverage__c memCov : wmp_util_Cache.MemberPlans.values()){
    		subIdSet.add(memCov.SubscriberId__c);
    		planIdGuidSet.add(memCov.PlanGuid__c);
    	}
    	//query for the plan ids
    	for(Account plan : [SELECT id FROM Account WHERE guid__c IN:planIdGuidSet]){
    		planIdList.add(plan.Id);
    	}
    	
    	whereClause += ' AND Subscriber_ID__c IN (\'' + String.join(new List<String>(subIdSet), '\', \'') + '\') ' + 
    					' AND Plan__c IN (\'' + String.join(planIdList, '\', \'') + '\')';
    	System.debug('Case Query:: ' + whereClause);    	
    	
    	//Using the util helper to query for the case
    	list_relatedCase = wmp_util_Helper.getObjects('Case',whereClause, false);
    	System.debug('CaseList:: ' + list_relatedCase);

    	//returning the first element of the  list
    	//if not present, an exception is thrown and sent back to the lightning controller as an error in the callback function
    	return list_relatedCase[0];
    }
    
    /***********************************************************
    Method Name : fetch_relatedCaseAttachments
    Purpose		: send the case attachments
    ************************************************************/
    @AuraEnabled
    public static list<Attachment> fetch_relatedCaseAttachments(String str_caseId){
    	if(str_caseId == null || str_caseId == '') return new List<Attachment>();
    	
    	list<Attachment> list_relatedCaseAttachments = new list<Attachment>();
    	
    	//iterating through the list of attachments
    	for(Attachment iterating_attachement : [ SELECT Id,
    													Name,
    													LastModifiedDate
    											 FROM 	Attachment
    											 WHERE  ParentId =:str_caseId
    											 ORDER BY LastModifiedDate DESC
    											]){
    		//adding to the list
    		list_relatedCaseAttachments.add(iterating_attachement);
    	}
    	return list_relatedCaseAttachments;
    }
    /***********************************************************
    Method Name : fetch_relatedCaseComments
    Purpose		: send the case comments
    ************************************************************/
    @AuraEnabled
    public static list<CaseComment> fetch_relatedCaseComments(String str_caseId){
    	list<CaseComment> list_relatedCaseComments = new list<CaseComment>();
    	
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
    	return wmp_util_Cache.getUserRec();
    }
    /***********************************************************
    Method Name : uploadFileAttachment
    Purpose		: attach file to case
    ************************************************************/
    @AuraEnabled
    public static void uploadFileAttachment(Id caseId, String fileName, String base64Data, String contentType){
    	//create the attachment on the case
    	base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
    
        Attachment a = new Attachment();
        a.parentId = caseId;
 
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        
        insert a;
    }
    /***********************************************************
    Method Name : saveCaseComment
    Purpose		: saving case comment
    ************************************************************/
    @AuraEnabled
    public static void saveCaseComment(String caseCommentDescription, Id caseId){
    	CaseComment inst_CaseComment = new CaseComment( ParentId=caseId,
    													CommentBody = caseCommentDescription
    													);
    	
    	insert inst_CaseComment;
    }
}