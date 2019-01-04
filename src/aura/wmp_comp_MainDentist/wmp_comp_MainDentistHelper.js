({
	loadConfig : function(component) {
		var action = component.get('c.retrievePortalConfig');
		
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var portalConfig = response.getReturnValue();
				
				//retrieve the fields for each of the labels
				var allowSetMember = portalConfig.Allow_Setting_Main_Dentist__c;
				var setMem_title = portalConfig.PCD_SETMEM_Title_Label__c;
				var setMem_info = portalConfig.PCD_SetMem_Info_Label__c;
				var setMem_oneMem = portalConfig.PCD_SETMEM_One_Member_Label__c;
				var setMem_allMem = portalConfig.PCD_All_Member_Label__c;
				var val_errorTitle = portalConfig.PCD_VAL_Error_Title_Label__c;
				var val_approveTitle = portalConfig.PCD_VAL_Approve_Title_Label__c;
				var val_continue = portalConfig.PCD_VAL_Continue_Label__c;
				var val_goBack = portalConfig.PCD_VAL_Go_back_Label__c;
				var success_title = portalConfig.PCD_Success_Title_Label__c;
				var success_info = portalConfig.PCD_Success_Info_Label__c;
				
				if(allowSetMember ){
					var setMem_titleL = $A.getReference('$Label.c.'+ setMem_title);
					component.set('v.setMem_title', setMem_titleL);
					
					var setMem_infoL = $A.getReference('$Label.c.'+ setMem_info);
					component.set('v.setMem_info', setMem_infoL);
					
					var setMem_oneMemL = $A.getReference('$Label.c.'+ setMem_oneMem);
					component.set('v.setMem_oneMem', setMem_oneMemL);
					
					var setMem_allMemL = $A.getReference('$Label.c.'+ setMem_allMem);
					component.set('v.setMem_allMem', setMem_allMemL);
					
					var val_errorTitleL = $A.getReference('$Label.c.'+ val_errorTitle);
					component.set('v.val_errorTitle', val_errorTitleL);
					
					var val_approveTitleL = $A.getReference('$Label.c.'+ val_approveTitle);
					component.set('v.val_approveTitle', val_approveTitleL);
					
					var val_continueL = $A.getReference('$Label.c.'+ val_continue);
					component.set('v.val_continue', val_continueL);
					
					var val_goBackL = $A.getReference('$Label.c.'+ val_goBack);
					component.set('v.val_goBack', val_goBackL);
					
					var success_titleL = $A.getReference('$Label.c.'+ success_title);
					component.set('v.success_title', success_titleL);

					var success_infoL = $A.getReference('$Label.c.'+ success_info);
					component.set('v.success_info', success_infoL);
				}
			}
		});
		
		$A.enqueueAction(action);
	},
	
	loadMember : function(component){
		var memCovIds = component.get('v.memCovIds');
		console.log('memCovLength::'+memCovIds.length );
		console.log('memCovIds::'+memCovIds);
		if(memCovIds.length == 1 ){
			console.log('memCovId::'+memCovIds[0]);
			var action = component.get('c.retrieveMemberName');
			action.setParams({
				'memCovGuid' : memCovIds[0]
			});
			action.setCallback(this, function(response){
				if(response.getState() == 'SUCCESS'){
					var result = response.getReturnValue();
					console.log('result::'+result);
					component.set('v.memName', result);
				}
			});
			$A.enqueueAction(action);
		}
	},
})