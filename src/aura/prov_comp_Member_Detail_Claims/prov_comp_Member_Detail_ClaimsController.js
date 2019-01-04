({
	/**
     * Get the claims based on the profile id parameter
     */
	init : function(component, event, helper) {
		//console.log('init start: '+ component.get('v.params.id'));

        var labelName = component.get('v.portalConfig.PreAuthorization_Label__c');
 		labelValue = $A.getReference('$Label.c.' + labelName);
 		
 		//console.log('pre auth label: ' + labelValue);

 		component.set('v.preAuthLabel', labelValue);

        //Listener for responses from VF page
        window.addEventListener("message", function(event) {
            var origin = $A.get('$Label.c.Member_Eligibility_VF_URL');
            //console.log('return listener');
            //console.log('event.origin ' + event.origin);
            if(event.origin !== origin) {
                //not the expected origin. reject results
                //console.log('origins did not match');
                return;
            }

            //call search method once visualforce page loads
            if(event.data.type == "load"){
                helper.searchClaimsRemote(component, component.get('v.params.id'));
                helper.searchAuthsRemote(component, component.get('v.params.id'));

            // check to see if error is returned
            //console.log('error in page' + event.data.hasOwnProperty('error'));
            } else if(event.data.hasOwnProperty('error')){
                //console.log('error occurred');
                component.set('v.isError', true);
                component.set('v.str_errorMsg','Search unavailable at this time. Please try again later.');

            //claim response
            } else if(event.data.type == "claims"){
                //console.log('claims returned');
                //Handle the message

                var result = event.data.result;
                var returnValue = [];

                if(result['calloutSuccess']) {
                    returnValue = result['calloutSuccess'];
                } else {
                    returnValue = result['calloutError'];
                    component.set('v.isError', true);
                    component.set('v.str_errorMsg','External system is currently unavailable. Please try again later.');
                }
                if(!returnValue || returnValue.length == 0) {
                    component.set('v.claimPaginationList', null);
                    component.set('v.claims', null);
                    component.set('v.claimStartPage',0);
                    component.set('v.claimEndPage',1);
                    component.set('v.claimCurrentPage', 1);
                } else {
                    var pageSize = component.get('v.pageSize');
                    // hold all the records into an attribute named "claims
                    returnValue.sort(dynamicSort('ClaimNumber','desc'));
                    
                    component.set('v.claims', returnValue);
                    // get size of all the records and then hold into an attribute "totalRecords"
                    component.set('v.claimTotalRecords', returnValue.length);
                    //console.log('totalRecords: '+returnValue.length);
                    
                    component.set('v.claimTotalPages', Math.ceil(returnValue.length / pageSize));
                    helper.repaginateClaims(component);
                }
                //console.log('end');            
                $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
                $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
                component.set('v.isLoading', false);
                //console.log('returnValue: '+JSON.stringify(returnValue));
            } else if(event.data.type == "preAuth"){
                //console.log('preAuth returned');
                //Handle the message

                var result = event.data.result;
                            var returnValue = [];
                if(result['calloutSuccess']) {
                    returnValue = result['calloutSuccess'];
                } else {
                    returnValue = result['calloutError'];
                    component.set('v.isError', true);
                    component.set('v.str_errorMsg','External system is currently unavailable. Please try again later.');
                }
                if(!returnValue || returnValue.length == 0) {
                    component.set('v.authPaginationList', null);
                    component.set('v.auths', null);
                    component.set('v.authStartPage',0);
                    component.set('v.authEndPage',1);
                    component.set('v.authCurrentPage', 1);
                } else {
                    var pageSize = component.get('v.pageSize');
                    // hold all the records into an attribute named "claims
                    returnValue.sort(dynamicSort('ClaimNumber','desc'));
                    
                    component.set('v.auths', returnValue);
                    // get size of all the records and then hold into an attribute "totalRecords"
                    component.set('v.authTotalRecords', returnValue.length);
                    //console.log('totalRecords: '+returnValue.length);
                    
                    component.set('v.authTotalPages', Math.ceil(returnValue.length / pageSize));
                    helper.repaginateAuths(component);
                }
                //console.log('end');            
                $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
                $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
                component.set('v.isLoading', false);
                //console.log('returnValue: '+JSON.stringify(returnValue));
            }
            

        }, false);


    },

    draftDetailClaims : function(component,event,helper){
        //redirects to the claim detail page
        //gets claimNumber for particular claim
        var detailRedirectId = event.currentTarget.dataset.detailredirectid;
        //console.log('detailRedirectId: '+detailRedirectId);
        //sets page name to route to
        var pageName = "claim-detail";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			"pageName" : pageName,
			"memberProfileGuid" : detailRedirectId,
			"newTab" : true

		});
		redirectEvent.fire();
	},
	
	draftDetailAuths : function(component,event,helper){
        //redirects to the claim detail page
        //gets claimNumber for particular claim
        var detailRedirectId = event.currentTarget.dataset.detailredirectid;
        //console.log('detailRedirectId: '+detailRedirectId);
        //sets page name to route to
        var pageName = "pre-auth-detail";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			"pageName" : pageName,
			"memberProfileGuid" : detailRedirectId,
			"newTab" : true

		});
		redirectEvent.fire();
    },    

	//column sort methods
    //sorts the column selected
    updateColumnSortingClaims: function(component, event, helper){
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        var fieldName = tar.dataset.fieldname;
        //console.log('target and column found');

        // sort direction for dynamicSort
        // if null, dynamicSort will sort ascending
        var sortDirection = '';

        // resort the table
        var claimSearchResults = component.get('v.claims');
       
        if($A.util.hasClass(tar, 'notSorted')){
            //console.log('not sorted');
            $A.util.removeClass(tar, 'notSorted');
            if(col == 0){
                //default last updated to descend. newest first
                $A.util.addClass(tar, 'sortDescend');
                sortDirection = 'desc';
            } else {
                $A.util.addClass(tar, 'sortAscend');
            }
            $('#claimTable').find('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

        } else if($A.util.hasClass(tar, 'sortAscend')) {
            //console.log('asc');
            //column is currently sorted by ascending order, switch it
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            sortDirection = 'desc';
            //console.log('end of sort asc');
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            //console.log('dsc');
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
        }   

        claimSearchResults.sort(dynamicSort(fieldName,sortDirection));
		component.set('v.claims', claimSearchResults);
        helper.repaginateClaims(component);		
        
        //console.log('end of sort method');
	},
	
	updateColumnSortingAuths: function(component, event, helper){
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        var fieldName = tar.dataset.fieldname;
        //console.log('target and column found');

        // sort direction for dynamicSort
        // if null, dynamicSort will sort ascending
        var sortDirection = '';

        // resort the table
        var authSearchResults = component.get('v.auths');
       
        if($A.util.hasClass(tar, 'notSorted')){
            //console.log('not sorted');
            $A.util.removeClass(tar, 'notSorted');
            if(col == 0){
                //default last updated to descend. newest first
                $A.util.addClass(tar, 'sortDescend');
                sortDirection = 'desc';
            } else {
                $A.util.addClass(tar, 'sortAscend');
            }
            $('#authTable').find('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

        } else if($A.util.hasClass(tar, 'sortAscend')) {
            //console.log('asc');
            //column is currently sorted by ascending order, switch it
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            sortDirection = 'desc';
            //console.log('end of sort asc');
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            //console.log('dsc');
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
        }   

        authSearchResults.sort(dynamicSort(fieldName,sortDirection));
        component.set('v.auths', authSearchResults);
        helper.repaginateAuths(component);		
        
        //console.log('end of sort method');
    },

    //end column sort methods

    //claim pagination
    claimFirstPage: function(component, event, helper){

        var allClaims = component.get('v.claims');
        var pageSize = component.get('v.pageSize');
        // //console.log('allClaims ' + allClaims);
        // //console.log('pageSize ' + pageSize);

        var startClaim = 0;
        var endClaim = startClaim + pageSize;
        // //console.log('startClaim ' + startClaim);
        // //console.log('endClaim ' + endClaim);
        var currentClaims; 
        
        if(endClaim > allClaims.lenth){
            currentClaims = allClaims.slice(startClaim);
        } else {
            currentClaims = allClaims.slice(startClaim, endClaim);
        }
        // //console.log('currentClaims ' + JSON.stringify(currentClaims));

        component.set('v.claimPaginationList', currentClaims);
        component.set('v.claimCurrentPage', 1);


    },

    claimPreviousPage: function(component, event, helper){
        var currentPage = component.get('v.claimCurrentPage');
        var allClaims = component.get('v.claims');
        var pageSize = component.get('v.pageSize');
        // //console.log('currentPage ' + currentPage);
        // //console.log('pageSize ' + pageSize);

        var startClaim = pageSize * (currentPage-2);
        var endClaim = startClaim + pageSize;
        // //console.log('startClaim ' + startClaim);
        // //console.log('endClaim ' + endClaim);
        var currentClaims; 
        
        if(endClaim > allClaims.lenth){
            currentClaims = allClaims.slice(startClaim);
        } else {
            currentClaims = allClaims.slice(startClaim, endClaim);
        }

        component.set('v.claimPaginationList', currentClaims);
        component.set('v.claimCurrentPage', currentPage-1);
    },

    claimNextPage: function(component, event, helper){
        var currentPage = component.get('v.claimCurrentPage');
        var allClaims = component.get('v.claims');
        var pageSize = component.get('v.pageSize');
        // //console.log('currentPage ' + currentPage);
        // //console.log('pageSize ' + pageSize);

        var startClaim = pageSize * currentPage;
        var endClaim = startClaim + pageSize;
        // //console.log('startClaim ' + startClaim);
        // //console.log('endClaim ' + endClaim);
        var currentClaims; 
        
        if(endClaim > allClaims.lenth){
            currentClaims = allClaims.slice(startClaim);
        } else {
            currentClaims = allClaims.slice(startClaim, endClaim);
        }

        component.set('v.claimPaginationList', currentClaims);
        component.set('v.claimCurrentPage', currentPage+1);

    },
    //end claim pagination

    //pre auth pagination
    authFirstPage: function(component, event, helper){

        var allAuths = component.get('v.auths');
        var pageSize = component.get('v.pageSize');
        // //console.log('pageSize ' + pageSize);

        var startAuth = 0;
        var endAuth = startAuth + pageSize;
        // //console.log('startAuth ' + startAuth);
        // //console.log('endAuth ' + endAuth);
        var currentClaims; 
        
        if(endAuth > allAuths.lenth){
            currentClaims = allAuths.slice(startAuth);
        } else {
            currentClaims = allAuths.slice(startAuth, endAuth);
        }

        component.set('v.authPaginationList', currentClaims);
        component.set('v.authCurrentPage', 1);
    },

    authPreviousPage: function(component, event, helper){
        var currentPage = component.get('v.authCurrentPage');
        var allAuths = component.get('v.auths');
        var pageSize = component.get('v.pageSize');
        // //console.log('currentPage ' + currentPage);
        // //console.log('pageSize ' + pageSize);

        var startAuth = pageSize * (currentPage-2);
        var endAuth = startAuth + pageSize;
        // //console.log('startAuth ' + startAuth);
        // //console.log('endAuth ' + endAuth);
        var currentAuths; 
        
        if(endAuth > allAuths.lenth){
            currentAuths = allAuths.slice(startAuth);
        } else {
            currentAuths = allAuths.slice(startAuth, endAuth);
        }

        component.set('v.authPaginationList', currentAuths);
        component.set('v.authCurrentPage', currentPage-1);
    },

    authNextPage: function(component, event, helper){
       var currentPage = component.get('v.authCurrentPage');
        var allAuths = component.get('v.auths');
        var pageSize = component.get('v.pageSize');
        // //console.log('currentPage ' + currentPage);
        // //console.log('pageSize ' + pageSize);

        var startAuth = pageSize * currentPage;
        var endAuth = startAuth + pageSize;
        // //console.log('startAuth ' + startAuth);
        // //console.log('endAuth ' + endAuth);
        var currentClaims; 
        
        if(endAuth > allAuths.lenth){
            currentClaims = allAuths.slice(startAuth);
        } else {
            currentClaims = allAuths.slice(startAuth, endAuth);
        }
        component.set('v.authPaginationList', currentClaims);
        component.set('v.authCurrentPage', currentPage+1);
    },
    //end pre auth pagination




})