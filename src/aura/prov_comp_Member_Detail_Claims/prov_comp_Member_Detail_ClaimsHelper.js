({

	/**
     * Get the claims and format the number amounts into readable dollar amounts
     */
	searchClaimsRemote : function(component, memberGuid) {
		//console.log('searchClaims start');
		component.set('v.isError', false);

		var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        var businessid = component.get('v.currentBusinessId');// gets current business id   
		var businessGuid = providercache.businessMap[businessid].windward_guid__c;//gets the guid 
		var universalMemberGuid = component.get('v.member.UniversalMemberGUID__c'); 
		//console.log('searchClaims early');
		//console.log('universalMemberGuid ' + universalMemberGuid);

		//create message to send to vf page
		if(universalMemberGuid != null){
			var message = {BusinessGuid: businessGuid, UniversalMemberGuid: universalMemberGuid, ClaimType: 'CLAIM'};
		} else {
			var message = {MemberProfileGuid: memberGuid, BusinessGuid: businessGuid, ClaimType: 'CLAIM'};
		}
		//console.log('message ' + JSON.stringify(message));

		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
        //console.log('vfOrigin ' + vfOrigin);

		//get vf page		
        var vfWindow = component.find('vfFrame').getElement().contentWindow;

        //post message to vf page
    	vfWindow.postMessage(JSON.stringify(message), vfOrigin);
    	//console.log('finished post message searchClaimsRemote');			
   	},

	/**
     * Get the auths and format the number amounts into readable dollar amounts
     */
	searchAuthsRemote : function(component, memberGuid) {
		//console.log('searchAuths start');
		component.set('v.isError', false);

		var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        var businessid = component.get('v.currentBusinessId');// gets current business id   
		var businessGuid = providercache.businessMap[businessid].windward_guid__c;//gets the guid 
		var universalMemberGuid = component.get('v.member.UniversalMemberGUID__c'); 

		//console.log('searchAuths early');

		//create message to send to vf page
		if(universalMemberGuid != null){
			var message = {BusinessGuid: businessGuid, UniversalMemberGuid: universalMemberGuid, ClaimType: 'AUTH'};
		} else {
			var message = {MemberProfileGuid: memberGuid, BusinessGuid: businessGuid, ClaimType: 'AUTH'};
		}
		//console.log('message ' + JSON.stringify(message));

		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
        //console.log('vfOrigin ' + vfOrigin);

		//get vf page		
        var vfWindow = component.find('vfFrame').getElement().contentWindow;

        //post message to vf page
    	vfWindow.postMessage(JSON.stringify(message), vfOrigin);
    	//console.log('finished post message searchAuthsRemote');			
	},

	repaginateClaims : function(component) {
		var claimSearchResults = component.get('v.claims');
		var pageSize = component.get('v.pageSize');
        var paginationList = [];
		// set start as 0
		component.set('v.claimStartPage',0);
		component.set('v.claimEndPage',pageSize-1);
        component.set('v.claimCurrentPage', 1);

        for(var i=0; i< pageSize; i++){
            if(claimSearchResults.length > i) {
                paginationList.push(claimSearchResults[i]);
            }
        }
        component.set('v.claimPaginationList', paginationList);
	},

	repaginateAuths : function(component) {
		//console.log('repaginateAuths');
		var authSearchResults = component.get('v.auths');
		var pageSize = component.get('v.pageSize');
        var paginationList = [];
        //console.log('authSearchResults: ' + JSON.stringify(authSearchResults) );
        //console.log('pageSize: ' + pageSize);

		// set start as 0
		component.set('v.authStartPage',0);
		component.set('v.authEndPage',pageSize-1);
        component.set('v.authCurrentPage', 1);

		//console.log('repaginateAuths 2');
        for(var i=0; i< pageSize; i++){
            if(authSearchResults.length > i) {
                paginationList.push(authSearchResults[i]);
            }
        }
		//console.log('repaginateAuths 3');
        component.set('v.authPaginationList', paginationList);
		//console.log('repaginateAuths 4');
	}
})