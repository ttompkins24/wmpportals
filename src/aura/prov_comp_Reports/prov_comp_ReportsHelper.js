({    
    getNotifications : function(component, pageNum, sortField, sortDirection) {
        var currentBusinessId = component.get('v.currentBusinessId');
        var action = component.get("c.getNotificationsApex");

        var params = {
            currentBusinessId : currentBusinessId,
            pageNum : ''+pageNum,
            sortField : sortField,
            sortDirection : sortDirection,
            pageSize : ''+component.get('v.pageSize')
        };  
        var helper = this;  

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                //console.log('### got messages: ' + JSON.stringify(data));
                component.set('v.messages', data.messages);
                component.set('v.totalPages', Math.ceil(data.totalPages / component.get('v.pageSize')));
                localStorage['message_read'] = true;
            } else {  
                //console.log('error');
            } 
            $A.util.addClass(component.find("loadingSpinner"), "slds-hide");
        });

        $A.enqueueAction(action);
    }, 

    fetchAttachment : function(component, docId, docName) {

        var action = component.get("c.getAttachmentData");
        var helper = this;

        //console.log('### fetching attachment...');

        var params = {
            docId: docId
        };  

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                helper.saveBlobAttachment(component, data.body, data.contentType, docName);   
            } else {  
                //console.log('error');
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