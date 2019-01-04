({
    init : function(component, event, helper) {
        if(!component.get('v.attachmentTypes')) {
        }
        var attachmentTypes = [];
        	attachmentTypes.push({label:'Dental Models', value:'DA' });
        	attachmentTypes.push({label:'Diagnostic Report', value:'DG' });
        	attachmentTypes.push({label:'Explanation of Benefits', value:'EB' });
        	attachmentTypes.push({label:'Periodontal Charts', value:'P6' });
        	attachmentTypes.push({label:'Radiology Films', value:'RB' });
        	attachmentTypes.push({label:'Radiology Reports', value:'RR' });
        	attachmentTypes.push({label:'Referral Form', value:'B4' });
            attachmentTypes.push({label:'Support Data for Claim', value:'OZ'});
        if(component.get('v.isReferral') == true) {
            attachmentTypes = [
            	{label:'Dental Models', value:'DA' },
            	{label:'Diagnostic Report', value:'DG' },
            	{label:'Periodontal Charts', value:'P6' },
            	{label:'Radiology Films', value:'RB' },
            	{label:'Radiology Reports', value:'RR' }
            ];
        }
        component.set('v.attachmentTypes', attachmentTypes);
        helper.getAttachments(component);        
    },

    handleFilesChange : function(component, event, helper) {
        if(component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } 
    },

    deleteAttachment : function(component, event, helper) {
        var eventSource = event.target || event.srcElement;
        var targetId = $(eventSource).closest("div").attr('data-value');
        var index = $(eventSource).closest("div").attr('data-index');

        var attachments = component.get('v.attachments');

        helper.deleteAttachment(component, targetId);
    },
    updateAttachmentType : function(component, event, helper) {
        var eventSource = event.target || event.srcElement;
        var value = event.getSource().get('v.value');

        // split value to arr
        var splitValue = value.split('---');
        var attachmentId = splitValue[0];
        var attachType = splitValue[1];
        //console.log("### type: " + JSON.stringify(attachType));
    
        helper.updateAttachmentType(component, attachmentId, attachType);
    },

    downloadAttachment : function(component, event, helper) {
        var attachmentId = event.currentTarget.dataset.value;
        //console.log('### attachmentId: ' + attachmentId);
        var attachments = component.get('v.attachments');
        var attachmentName;

        for(var i = 0; i < attachments.length; i++) {
            var entry = attachments[i];
            if(entry.Id == attachmentId) {
                
                if(component.get('v.type') == 'Claim') {
                    attachmentName = entry.Original_File_Name__c;
                } else {
                    attachmentName = entry.Name;
                }
                //console.log('### entry: ' + JSON.stringify(entry));
            } 
        } 
        
            
        helper.fetchAttachment(component, attachmentId, attachmentName);
    }

})