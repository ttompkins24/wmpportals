({
    /**************************************************************************************************************
     * Method Name							: getCurrentMember
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current member from cache class
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			30th August 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
    getCurrentMember: function(component) {
        //calling an action to the server side controller to fetch the current member
        var action = component.get("c.fetchCurrentMember");

        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response) {
            var response_state = response.getState();

            //checking if the response is success
            if (response_state === 'SUCCESS') {
                //set the attribute with the value
                console.log('currentMember::'+JSON.stringify(response.getReturnValue()));
                component.set("v.currentMember", response.getReturnValue());
            } else {
                //toast to display
                //console.log in case we need to track
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    /**************************************************************************************************************
     * Method Name							: getCurrentMemberPlans
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current member plans from cache class
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			30th August 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
    getCurrentMemberPlans: function(component, helper) {
        //console.log('init');
        //calling an action to the server side controller to fetch the current member plan
        var action = component.get("c.fetchCurrentMemberPlans");

        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response) {
            var response_state = response.getState();

            //checking if the response is success
            if (response_state === 'SUCCESS') {
                //set the attribute with the value
                var memberplans = response.getReturnValue();
                component.set("v.currentMemberPlans", memberplans);
                component.set("v.chosen_MemberPlan", memberplans[0]);
                //component.set("v.chosen_MemberPlan",memberplans[0]);
                //console.log('memberPlans::'+JSON.stringify(memberplans));

                //get the related member plan accounts
                helper.getRelatedPlanAccountsFromMemberPlans(component, helper);
                //get the plan name
                helper.getPlanName(component, helper);
                console.log(memberplans);
            } else {
                //toast to display
                //console.log in case we need to track
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    /**************************************************************************************************************
     * Method Name							: getRelatedKnowledgeArticle
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# knowledge article of type my Benefits to display the information
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			31th August 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
    getRelatedKnowledgeArticle: function(component) {
        //calling an action to the server side controller to fetch the current knowledge article
        var action = component.get("c.getRelatedKnowledgeArticle");
		
        //getting theplanguid
        //var allmemberplans =  component.get("v.currentMemberPlans")[0].PlanGuid__c;
        //var planguid       = '506c616e-3153-616e-7320-74656574682c';
        var planguid = component.get("v.chosen_MemberPlan").PlanGUID__c;

        //setting the member plan planGUid as the parameter to the server side action
        action.setParams({
            subgroupID: planguid
        });
        console.log('getRelatedKnowledgeArticle::'+planguid);
        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response) {
            var response_state = response.getState();

            //checking if the response is success
            if (response_state === 'SUCCESS') {
                //set the attribute with the value
                component.set("v.knowledgeArticle_myBenefits", response.getReturnValue());
                var knwArticle = response.getReturnValue();
                console.log('knwArticle::'+JSON.stringify(knwArticle));
                /***********************************
                 * The following lines of code will populate the downloadable links for the 4 files that are displayed on the screen
                 * 1. Benefits Summary - English
                 * 2. Benefits Summary - Spanish
                 * 3. Member Handbook - English
                 * 4. Member Handbook - Spanish
                 */
                 
                component.set("v.benefits_summary_eng", '/member/servlet/fileField?entityId=' + knwArticle.Id + '&field=Benefits_Summary_English__Body__s');
                if(knwArticle.Benefits_Summary_Spanish__Name__s != null)
                	component.set("v.benefits_summary_esp", '/member/servlet/fileField?entityId=' + knwArticle.Id + '&field=Benefits_Summary_Spanish__Body__s');
                component.set("v.member_handbook_eng", '/member/servlet/fileField?entityId=' + knwArticle.Id + '&field=Member_Handbook_English__Body__s');
                if(knwArticle.Member_Handbook_Spanish__Name__s != null)
                	component.set("v.member_handbook_esp", '/member/servlet/fileField?entityId=' + knwArticle.Id + '&field=Member_Handbook_Spanish__Body__s');
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        var showAccums = component.get("c.showAccumulators");
        showAccums.setParams({
            subgroupId: planguid
        });
        console.log('pg ' + planguid + ' ' + JSON.stringify(showAccums));
        showAccums.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
            console.log('accum resp: ' + JSON.stringify(response.getReturnValue()));
            component.set("v.showAccum", response.getReturnValue());
            }
        });
        $A.enqueueAction(showAccums);
        
    },
    /**************************************************************************************************************
     * Method Name							: getRelatedPlanAccountsFromMemberPlans
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# verified account plans from the member plans
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			6th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
    getRelatedPlanAccountsFromMemberPlans: function(component, helper) {
    console.log('getRelatedPlanAccountsFromMemberPlans...');
        //calling an action to the server side controller to fetch the current account plans
        var action = component.get("c.fetchVerifiedMemberPlansAccounts");

        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response) {
            var response_state = response.getState();

            //checking if the response is success
            if (response_state === 'SUCCESS') {
                //check for the number of verified plan returned
                if (response.getReturnValue().length > 0) {
                    //set the attribute with the value and set the error boolean to false

                    component.set("v.currentMemberPlansFromAccount", response.getReturnValue());
                    console.log(response.getReturnValue());
                    //get the related knowledge article
                    helper.getRelatedKnowledgeArticle(component);
                } else {
                    //set the error message and the condition
                    component.set("v.bln_isError", true);
                    component.set("v.str_errorMsg", $A.get("$Label.c.FAD_LandingError"));
                }

            } else {
                //toast to display
                //console.log in case we need to track
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    /**************************************************************************************************************
     * Method Name							: changeInPlanId
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current memberplan information
     * 											# current knowledge article related to the member plan
     *										 
     History
     Version#		Sprint#		Date				by  						Comments
	 1.0			1.0			8th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
    changeInPlanId: function(component, event, helper) {
        console.log('in changeinplanid');
    	//new planguid
    	var planId = event.currentTarget.dataset.planid;
        
        helper.changeInPlan_settingNewPlan(component, event, helper, planId);
        
    },
    changeInPlanIdMob: function(component, event, helper) {
        console.log('in changeinplanidMob');
    	//new planguid
        var planId = event.getSource().get("v.value");        
        helper.changeInPlan_settingNewPlan(component, event, helper, planId);
    },
    //The common function that updates the change  in plan
    changeInPlan_settingNewPlan : function (component, event, helper, planId){
    	console.log('in common');
    	var subscriberId = '';
        //fetch the list of memberplans
        var memberPlans = component.get("v.currentMemberPlans");
        for (var iterating_int = 0; iterating_int < memberPlans.length; iterating_int++) {
            if (memberPlans[iterating_int].PlanGUID__c === planId) {
                subscriberId = memberPlans[iterating_int].SubscriberID__c;
            }
        }
        
        //calling an action to the server side controller to set the new plan Id and then fetch the current member plan
        var action = component.get("c.fetchNewCurrentMemberPlan");
        //setting the member plan planGUid as the parameter to the server side action
        action.setParams({
            planId: planId,
            subscriberId: subscriberId
        });
        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response) {
            var response_state = response.getState();
            //checking if the response is success
            if (response_state === 'SUCCESS') {
                component.set("v.chosen_MemberPlan", response.getReturnValue());
                //console.log('test >> ' + memberPlans[0].PlanGuid__c + ' - ' + memberPlans[1].PlanGuid__c);
                //get the related knowledge article
                helper.getRelatedKnowledgeArticle(component);
                helper.getPlanName(component, helper);
            } else {
                console.log('Error >>' + response.getReturnValue());
                //set the error message and the condition
                component.set("v.bln_isError", true);
                component.set("v.str_errorMsg", $A.get("$Label.c.FAD_LandingError"));
            }
        });
        $A.enqueueAction(action);
    },
    /**************************************************************************************************************
     * Method Name							: getPlanName
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# get the plan Name
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			8th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
    getPlanName: function(component, helper) {
        //get the plan guid
        var planId = component.get("v.chosen_MemberPlan").PlanGUID__c;
		component.find("dynamicPlanPicklist").set("v.value",planId);
        //calling an action to the server side controller to get the plan name
        var action = component.get("c.fetchPlanName");
        //setting the member plan planGUid as the parameter to the server side action
        action.setParams({
            planId: planId
        });
        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response) {
            var response_state = response.getState();
            //checking if the response is success
            if (response_state === 'SUCCESS') {
                console.log('Plan name >> ' + response.getReturnValue());
                component.set("v.planName", response.getReturnValue());
            } else {
                console.log('Error in plan name');
            }
        });
        $A.enqueueAction(action);
    }
})