public without sharing class prov_ctrl_File_Upload {

    @AuraEnabled
    public static AttachmentSaveWrapper saveChunk(String parentId, String fileName, String base64Data, String contentType, String fileId, String claimAttachmentId) {
        AttachmentSaveWrapper wrapper = new AttachmentSaveWrapper();

        System.debug('### id: ' + parentId.substring(0, 3));
        if(parentId.substring(0, 3) != '500') {
			//claimAttachmentId == NULL
            if(fileId == '') {
                Claim_Attachment__c claim_attachment = new Claim_Attachment__c();
                claim_attachment.Attachment_Type__c = 'DA';
                claim_attachment.Original_File_Name__c = fileName;
                claim_attachment.Claim__c = parentId;
                System.debug('### submitting claim: ' + claim_attachment);
                insert claim_attachment; 
                 
                wrapper.claimAttachmentId = claim_attachment.Id;
                fileId = saveTheFile(claim_attachment.Id, fileName, base64Data, contentType);
            } else {
                appendToFile(fileId, base64Data);
            }
        } else {
            if (fileId == '') {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            } else {
                appendToFile(fileId, base64Data);
            }
        }
        
        wrapper.attachmentId = Id.valueOf(fileId);
        return wrapper;
    }

    @AuraEnabled
    public static AttachmentWrapper getAttachmentsApex(String parentId) {

        AttachmentWrapper wrapper = new AttachmentWrapper();
        if(parentId.substring(0, 3) != '500') {
            List<Claim_Attachment__c> claim_attachments = [SELECT Id, Attachment_Type__c, CreatedDate, Original_File_Name__c,
                (SELECT Id, Name, Description, ContentType, CreatedDate FROM Attachments)
                FROM Claim_Attachment__c WHERE Claim__c =: parentId];
            wrapper.claim_attachments = claim_attachments;
        } else {
            List<Attachment> attachments = [SELECT Id, Name, Description, ContentType, CreatedDate FROM Attachment WHERE ParentId =: parentId];
            wrapper.attachments = attachments;
        }
    
        return wrapper;
    }


    @AuraEnabled
    public static BlobAttachment getAttachmentData(String docId, String parentId) {
        List<Attachment> attachments;
        if(parentId.substring(0, 3) != '500') {
            attachments = [SELECT ContentType, Body FROM Attachment WHERE ParentId =: docId LIMIT 1];
        } else {
            attachments = [SELECT ContentType, Body FROM Attachment WHERE Id =: docId LIMIT 1];
        }

        BlobAttachment ba = new BlobAttachment();
        
        if(attachments!= null && attachments.size()==1){
            ba.body = EncodingUtil.base64Encode(attachments[0].Body);
            ba.contentType = attachments[0].ContentType;
        }
        return ba;
    }   
    public class BlobAttachment {
        @AuraEnabled public String contentType;
        @AuraEnabled public String body;
    }  

    
    @AuraEnabled
    public static void deleteAttachmentApex(Id attachmentId, String parentId) {

        if(parentId.substring(0, 3) != '500') {

            List<Claim_Attachment__c> claim_attachments = [SELECT Id From Claim_Attachment__c WHERE Id =: attachmentId];
            List<Attachment> attachments = [SELECT Id From Attachment WHERE ParentId =: claim_attachments[0].Id];
            delete attachments;
            delete claim_attachments;
        } else {
            List<Attachment> attachments = [SELECT Id From Attachment WHERE Id =: attachmentId];
            delete attachments;
        }

        return;
    }

    @AuraEnabled
    public static void updateAttachmentTypeApex(Id attachmentId, String attachmentType) {
        Claim_Attachment__c claim_attachment = [SELECT Id, Attachment_Type__c, Original_File_Name__c
            FROM Claim_Attachment__c WHERE Id =: attachmentId];
        claim_attachment.Attachment_Type__c = attachmentType;
        update claim_attachment;
    }

    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 		system.debug('sz: ' + oAttachment.Body.size());
        insert oAttachment;
        return oAttachment.Id;
    }
 
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment a = [SELECT Id, Body FROM Attachment WHERE Id =: fileId];
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        system.debug('sza: ' + a.Body.size());
        update a;
    }

    public class AttachmentWrapper{
        @AuraEnabled public List<Attachment> attachments {get;set;}
        @AuraEnabled public List<Claim_Attachment__c> claim_attachments {get;set;}
    }

    public class AttachmentSaveWrapper{
        @AuraEnabled public Id attachmentId { get; set; }
        @AuraEnabled public Id claimAttachmentId { get; set; }
    }
}