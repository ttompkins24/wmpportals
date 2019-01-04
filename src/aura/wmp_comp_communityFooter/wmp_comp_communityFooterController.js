({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information from 
     * 											# footer links and label from the cache class
     *										 To display the links on the footer of the page
     History
     Version#		Sprint#		Date				by  						Comments
	 1.0			1.0			7th August 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
		//helper method for server side controller call
		//This methods helps in populating the list of links on the footer
		helper.getFooterLinks(component, helper);

        //getting the portal config information
		helper.getPortalConfig(component, event, helper);
	},
	
	loadLiveAgentJS : function(component, event, helper){
		//get the record type id for the general case
		helper.getGeneralRecordTypeId(component, helper);

		//retrieve the info about the member
		var action = component.get('c.retrieveMemberInfoLiveAgent');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){

				var resultMap = response.getReturnValue();

				//set the values for the live agent console
				liveagent.addCustomDetail('First Name', resultMap['FirstName'], true);
				liveagent.addCustomDetail('Last Name', resultMap['LastName'], true);
				liveagent.addCustomDetail('Last Name', resultMap['LastName'], true);
				liveagent.addCustomDetail('Contact Id', resultMap['ContactId'], true);
				liveagent.addCustomDetail('Account Id', resultMap['AccountId'], true);
				liveagent.addCustomDetail('Portal', resultMap['PortalName'], true);
				liveagent.addCustomDetail('RouteId', resultMap['RouteId'], true);

				//find the contact based on the contact id
				liveagent.findOrCreate('Contact').map('Id','Contact Id',true,true,false).saveToTranscript('ContactId').showOnCreate().linkToEntity('Case','Primary_Contact__c');
				liveagent.findOrCreate('Account').map('Id','Account Id',true,true,false).saveToTranscript('AccountId').showOnCreate();
				
				 /* Sets the display name of the visitor in the agent console when engaged in a chat */
				liveagent.setName(resultMap['FirstName'] + ' ' + resultMap['LastName'] );
				
				//set case field values 
				liveagent.addCustomDetail('Case Status','New', false);
				liveagent.addCustomDetail('Case Subject','Live Agent', false);
				liveagent.addCustomDetail('Record Type Id', component.get("v.generalRecordTypeId"), false);
				liveagent.addCustomDetail('Type Text','Other', false);
                liveagent.addCustomDetail('Portal Case', 'DentaQuest Portal Cases', false);
                liveagent.addCustomDetail('OriginLabel', 'Live Chat', false);
				//create a case for the contact, populate: Recordtype, subject, status, Primary contact, and Contact
				liveagent.findOrCreate('Case')
					.map('RecordTypeId', 'Record Type Id', false, false, true)
					.map('Subject','Case Subject',false,false,true)
					.map('Status','Case Status',false,false,true)
					.map('ContactId','Contact Id',false,false,true)
					.map('Primary_Contact__c','Contact Id',false,false,true)
	                .map('Type', 'Type Text',false,false,true)	
                	.map('SubType__c', 'Type Text',false,false,true)
                	.map('Route_To__c', 'Portal Case',false,false,true)
                	.map('Origin', 'OriginLabel',false,false,true)
					.saveToTranscript('CaseId').showOnCreate();

				var chatId = resultMap['LiveChatId'];
				var orgId = resultMap['OrgId'].substring(0,15);
				var liveInitId = resultMap['LiveAgentInitId'];
				var liveURL = resultMap['LiveAgentURL'];
				component.set('v.chatId', chatId);
				if(window.liveagent){
					liveagent.init(liveURL, liveInitId, orgId);
					if (!window._laq) { window._laq = []; }
					window._laq.push(function(){
						liveagent.showWhenOnline(chatId, document.getElementById('liveagent_button_online'));
						liveagent.showWhenOffline(chatId, document.getElementById('liveagent_button_offline'));
					});
				}
			}
		});
		$A.enqueueAction(action);
	
	},
	
	launchLiveAgent : function(component, event, helper){
		liveagent.enableLogging();
		
		liveagent.startChat(component.get('v.chatId'));
		
	},
	
	redirectUrl : function(component, event, helper){
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.loc;
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
						'pageName' : pageName
		});
		redirectEvent.fire();
	},
})