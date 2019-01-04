({
    MAX_FILE_SIZE: 4500000,    //Max file size 4.5 MB 
    CHUNK_SIZE: 600000,        //Chunk Max size 750Kb 

    /**
     * File upload helper
     */
    uploadHelper: function(component, event) {
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        var self = this;
        component.set('v.hasAttachmentError', false);

        var attachments = component.get('v.attachments');
        
        if(fileInput && fileInput.length > 0) {
            var totalFiles = fileInput.length + attachments.length;

            if(totalFiles > 10) {
                component.set('v.hasAttachmentError', true);
                component.set('v.attachmentErrorMessage',  $A.get('$Label.c.X10_Maximum_Attachments'));
                return;
            }

            for(var i = 0; i < fileInput.length; i++) {
                // Since we're doing multiple uploads, we need to put the file upload within
                // a closure to avoid callback confusion
                (function(file) {
                    // check the selected file size, if select file size greater then MAX_FILE_SIZE,
                    // then show a alert msg to user,hide the loading spinner and return from function  
                    //console.log('fs: ' + file.size);
                    if (file.size > self.MAX_FILE_SIZE) {
                        component.set('v.hasAttachmentError', true);
                        component.set('v.attachmentErrorMessage', $A.get('$Label.c.File_size_too_large'));
                        return;
                    }
            
                    // create a FileReader object 
                    var objFileReader = new FileReader();
                    // set onload function of FileReader object   
                    objFileReader.onload = $A.getCallback(function() {
                        var fileContents = objFileReader.result;
                        var base64 = 'base64,';
                        ////console.log(fileContents);
                        var dataStart = fileContents.indexOf(base64) + base64.length;
             
                        fileContents = fileContents.substring(dataStart);
                        // call the uploadProcess method 
                        //console.log('start upload');
                        self.uploadProcess(component, file, fileContents, self);
                    });
             
                    objFileReader.readAsDataURL(file);
                })(fileInput[i]);
            }
        }
    },


    /**
     * File upload helper
     */ 
    uploadProcess: function(component, file, fileContents, helper) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + helper.CHUNK_SIZE);
        //console.log('### start upload process....');

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        helper.uploadInChunk(component, file, fileContents, startPosition, endPosition, '', helper);
    },
 
 
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId, helper, claimAttachmentId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        var parentId = component.get('v.parentId');

        var body = {
            claimAttachmentId : claimAttachmentId,
            parentId: parentId,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        };
        //console.log('Chunk: ' + attachId);

        /*
        Wod document (.doc) 
        PowerPoint files (.ppt) 
        Excel files (.xls) 
        Comma-separated values files (.csv) 
        Text file (.txt and .rtf) 
        Images (.gif, .jpg, .png, and .bmp) 
        Zipped files (.zip) 
        HTML files (.htm) 
        PDF files (.pdf) 
        XML files (.xml) 
        Orthocad files (.3dm)
        */
        var ext = file.name.split('.').pop().toLowerCase();
        ////console.log('### ext: ' + ext);

        var type = component.get('v.type');

        if(type == 'Claim') {
            if(ext != "doc" && ext != "ppt" && ext != "xls" && ext != "csv" && ext != "rtf" && ext != "txt" && ext != "gif" && ext != "jpg" && ext != "png" && ext != "bmp"
                 && ext != "zip" && ext != "htm" && ext != "pdf" && ext != "xml" && ext != "3dm"){
                component.set('v.hasAttachmentError', true);
                component.set('v.attachmentErrorMessage', $A.get('$Label.c.File_type_not_accepted'));
                return;
            }
        } else if(type == 'Case') {
            if(ext != "doc" && ext != "ppt" && ext != "xls" && ext != "csv" && ext != "rtf" && ext != "txt" && ext != "gif" && ext != "jpg" && ext != "png" && ext != "bmp"
                 && ext != "zip" && ext != "htm" && ext != "pdf" && ext != "xml" && ext != "3dm" && ext != "pdf"){
                component.set('v.hasAttachmentError', true);
                component.set('v.attachmentErrorMessage', $A.get('$Label.c.File_type_not_accepted'));
                return;
            }
        }
        

        action.setParams(body);



        // set call back 
        action.setCallback(helper, function(response) {
            ////console.log('### got file response: ' + JSON.stringify(response.getReturnValue()));


            // store the response / Attachment Id   
            attachId = response.getReturnValue().attachmentId;
            //console.log('attachId: ' + attachId);
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + helper.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    //console.log('sned another chunk');
                    var obj_type = component.get('v.type');
                    if(obj_type == 'Claim') {
                        //console.log('### uploading chunk');
                        helper.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, helper, response.getReturnValue().claimAttachmentId);
                    } else  {
                        helper.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, helper);
                    }
                } else {
                    helper.getAttachments(component);
                }
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                ////console.log('### error');
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        ////console.log("Error message: " + errors[0].message);
                    }
                } else {
                    ////console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },

    // setClaimAttachment : function(component, attachId) {
    //     var action = component.get("c.getAttachmentsApex");
    //     var parentId = component.get('v.parentId');
    //     var params = { parentId : parentId };  
    //     var helper = this;  

  
    //     action.setParams(params);  
    //     action.setCallback(this, function(response) {

    //     });
    // }
    
    getAttachments : function(component) {
        var action = component.get("c.getAttachmentsApex");
        var parentId = component.get('v.parentId');
        var params = { parentId : parentId };  
        var helper = this;  

        $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-show");

        ////console.log('### getting attachments...');

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue(); 
                ////console.log('### attachments data: ' + JSON.stringify(data));
                if(data) {
                    ////console.log('### attachments data: ' + JSON.stringify(data));
                    var obj_type = component.get('v.type');

                    if(obj_type == 'Claim') {
                        data.claim_attachments.forEach(function(attachment, index) {
                            attachment.Name = attachment.Original_File_Name__c;
                            attachment.index = index;
                            attachment.attachType = attachment.Id + '---' + attachment.Attachment_Type__c;
                        }); 
                        component.set('v.attachments', data.claim_attachments);
                    } else {
                        component.set('v.attachments', data.attachments);
                    }
                }
            } else {  
                ////console.log('error');
            } 
        });

        $A.enqueueAction(action);
    },

    deleteAttachment : function(component, attachmentId) {
        var action = component.get("c.deleteAttachmentApex");
        var params = { attachmentId : attachmentId, parentId : component.get('v.parentId') };  
        var helper = this;  

        $A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
  
        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue(); 
                helper.getAttachments(component);
            } else {  
                ////console.log('error');
            } 
        });

        $A.enqueueAction(action);
    },

    updateAttachmentType : function(component, attachmentId, attachmentType) {
        var action = component.get("c.updateAttachmentTypeApex");
        var params = { attachmentId : attachmentId, attachmentType : attachmentType };  
        //console.log('### upading attachment type: ' + JSON.stringify(params));
        var helper = this;  

        $A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
  
        ////console.log('### params: ' + JSON.stringify(params));

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue(); 
                helper.getAttachments(component);
            } else {  
                ////console.log('error');
            } 
        });

        $A.enqueueAction(action);
    },


    fetchAttachment : function(component, docId, docName) {

        var action = component.get("c.getAttachmentData");
        var helper = this;

        ////console.log('### fetching attachment...');

        var params = {
            docId: docId,
            parentId : component.get('v.parentId')
        };  

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                helper.saveBlobAttachment(component, data.body, data.contentType, docName);   
            } else {  
                ////console.log('error');
            } 
            $A.util.addClass(component.find("loadingSpinner"), "slds-hide");
        }); 
        $A.enqueueAction(action);
    },    

    saveBlobAttachment: function(component, body, contentType, filename) {
        var helper = this;
        var blob = new Blob([helper.base64toBlob(body, contentType)], {type: contentType});
        var filename =  filename;
        if(window.navigator.msSaveBlob) {
            window.navigator.msSaveBlob(blob, filename);
        } else {
            var elem = window.document.createElement('a');
            elem.href = window.URL.createObjectURL(blob);
            elem.download = filename;
            document.body.appendChild(elem);
            elem.click();
            document.body.removeChild(elem);
        }
    },

    base64toBlob: function(base64Data, contentType) {
        contentType = contentType || '';
        var sliceSize = 1024;
        var byteCharacters = atob(base64Data);
        var bytesLength = byteCharacters.length;
        var slicesCount = Math.ceil(bytesLength / sliceSize);
        var byteArrays = new Array(slicesCount);
    
        for (var sliceIndex = 0; sliceIndex < slicesCount; ++sliceIndex) {
            var begin = sliceIndex * sliceSize;
            var end = Math.min(begin + sliceSize, bytesLength);
    
            var bytes = new Array(end - begin);
            for (var offset = begin, i = 0 ; offset < end; ++i, ++offset) {
                bytes[i] = byteCharacters[offset].charCodeAt(0);
            }
            byteArrays[sliceIndex] = new Uint8Array(bytes);
        }
        return new Blob(byteArrays, { type: contentType });
    }
})