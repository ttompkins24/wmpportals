({
	retrieveCaseTypes : function(component) {
		var action = component.get('c.retrieveCaseTypeInfo');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resMap = response.getReturnValue();
				var caseList = [];
				
				for( var key in resMap){
					if(resMap[key].Value != undefined){
						var obj = {'Value':resMap[key].Value, 'Label':resMap[key].Label, 'Description' : resMap[key].Description};
						
						caseList.push(obj);
					}
				}
				
				component.set('v.typeDescriptionList', caseList);
			}
		});
		$A.enqueueAction(action);
	},
	
	retrieveMembers : function(component){
		var action = component.get('c.retrieveMemberPlans');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resMap = response.getReturnValue();
				var memList = [];
				for( var key in resMap){
					var obj = {'Value':key	, 'Label':resMap[key]};
					
					memList.push(obj);
				}
				
				component.set('v.memberList', memList);
			}
		});
		$A.enqueueAction(action);
		
	},
	
	readFile : function(component, caseId, file){
		var fr = new FileReader();
        var self = this;
       	fr.onload = $A.getCallback(function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
 
            fileContents = fileContents.substring(dataStart);
            var upAttachment = component.get('c.uploadFileAttachment');
            upAttachment.setParams({
            		'caseId' : caseId,
            		'fileName': file.name,
			        'base64Data' : encodeURIComponent(fileContents), 
			        'contentType': file.type
            });
            upAttachment.setCallback(this, function(response){
            	if(response.getState() == 'SUCCESS'){
            		//var result = response.getReturnValue();
            		
            		
            	}
            });
            $A.enqueueAction(upAttachment);
        });
 
        fr.readAsDataURL(file);
	},
	
	createCase : function(component, paramMap, file){
		var action = component.get("c.createCase"); 
	    action.setParams({
	    				'paramMap' : paramMap
	    });
	    action.setCallback(this, function(response){
	    	if(response.getState() == 'SUCCESS'){
	    		var result = response.getReturnValue();
	    		if(result != null){
                    try{
	    			$A.createComponent(
							'c:WMP_comp_Modal',
							{
								'value' : $A.get('$Label.c.Case_Submission_Success_Body') + ' ' + result.CaseNumber,
								'typeName' : 'TEXT',
								'headerText' : $A.get('$Label.c.Case_Submission_Success_Header'),
								'footerDisplay' : 'Overview'
							},
							function(newModal, status, errorMessage){
								//Add the new button to the body array
								if (status === "SUCCESS") {
									var body = component.get("v.body");
									body.push(newModal);
									component.set('v.body', body);
									
									//reset the attributes on the field
									component.set('v.typeChosen', '');
									component.set('v.memberChosen', '');
									component.set('v.addressChosen', '');
									component.find('casedescription').set('v.value', undefined);
									component.find('casedesired').set('v.value', undefined);
									
								}
							}
	    			);
                    } catch (ex){
                        //console.log(JSON.stringify(ex));
                    }
                } else{
	    			window.scrollTo(0,0);
		    		component.set('v.str_errorMsg', $A.get("$Label.c.CreateCase_General_Error") );
		    		component.set('v.bln_isError', true);
	    		}
	    		var spinner = component.find('uploadSpinner');
	    		$A.util.toggleClass(spinner, 'slds-hide');
	    		if(file != null && result != null){
	    			this.readFile(component, result.Id, file);
	    		}
	    	} 
	    	
	    });
	    $A.enqueueAction(action);
	},
})