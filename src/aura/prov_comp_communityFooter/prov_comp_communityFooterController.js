({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: WMP
     * Purpose								: To fetch the necessary information from 
     * 											# footer links and label from the cache class
     *										 To display the links on the footer of the page
     History
     Version#		Sprint#		Date				by  						Comments
	 1.0			1.0			1 Feb 2017			WMP					See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
		//helper method for server side controller call
		//This methods helps in populating the list of links on the footer
		helper.getFooterLinks(component, helper);
	},
	
	loadLiveAgentJS : function(component, event, helper){
		//get the record type id for the general case
		//helper.getGeneralRecordTypeId(component, helper);
		
		var action = component.get('c.retrieveMemberInfoLiveAgent');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){

				var resultMap = response.getReturnValue();
				//console.log('live agent mid');
				
				//set the values for the live agent console
				liveagent.addCustomDetail('First Name', resultMap['FirstName'], true);
				liveagent.addCustomDetail('Last Name', resultMap['LastName'], true);
				liveagent.addCustomDetail('Last Name', resultMap['LastName'], true);
				liveagent.addCustomDetail('Contact Id', resultMap['ContactId'], true);
				liveagent.addCustomDetail('Account Id', resultMap['AccountId'], true);
				liveagent.addCustomDetail('Portal', resultMap['PortalName'], true);
				liveagent.addCustomDetail('RouteId', resultMap['RouteId'], true);

				//find the contact based on the contact id
				//console.log('live agent mid2');
				liveagent.addCustomDetail('BusinessId', component.get('v.currentBusinessId'), true);
//				liveagent.findOrCreate('Contact').map('Id','Contact Id',true,true,false).saveToTranscript('ContactId').showOnCreate().linkToEntity('Case','Primary_Contact__c');
//				liveagent.findOrCreate('Account').map('Id','Account Id',true,true,false).saveToTranscript('AccountId').showOnCreate();
				
				//  Sets the display name of the visitor in the agent console when engaged in a chat 
				liveagent.setName(resultMap['FirstName'] + ' ' + resultMap['LastName'] );
				
				//set case field values 
				liveagent.addCustomDetail('Case Status','New', false);
                liveagent.addCustomDetail('Portal Case', 'DentaQuest Portal Cases', false);
                liveagent.addCustomDetail('PortalLabel', 'Provider Portal', false);
				//create a case for the contact, populate: Recordtype, subject, status, Primary contact, and Contact
				

                //console.log('live agent mid3');
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
				//console.log('live agent complete');
			}
		});
		$A.enqueueAction(action);
	
	},
	
	launchLiveAgent : function(component, event, helper){
		liveagent.enableLogging();
		 
		//console.log('chat started...');
		liveagent.startChat(component.get('v.chatId'));
		//console.log('chat ended...');
		
	},
	
	openNewWindow : function(component, event, helper){
		 event.preventDefault();
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.loc;
		
		window.open(pageName);
	},
})