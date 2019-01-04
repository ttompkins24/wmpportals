({
	doInit : function(component, event, helper) {
		component.set('v.showSpinner', true);
        helper.initializeOptions(component);
        
        var listener = function(event) {
			//var providerId = component.get("v.provAcctRec");
			////console.log('providerId ' + providerId);
//    		//console.log('return listener');
//    		//console.log('event.origin ' + event.origin);
        	var origin = $A.get('$Label.c.Member_Eligibility_VF_URL');
    		if(event.origin !== origin) {
    			//not the expected origin. reject results
    			//console.log('origins did not match');
    			return;
    		}

    		//Handle the message
    		var results = event.data;
    		
    		if(results == 'pageLoaded'){
//    			//console.log('vf page loaded...');
            	//component.set('v.checkButtonDisabled', false);
            	helper.searchReferrals(component);
            	return;
            }

//    		//console.log('results ' + results);
//    		//console.log('results ' + JSON.stringify(results));
//    		//console.log('results ' + typeof results);
//			//console.log('time out in search page' + results.hasOwnProperty('timeout'));

    		var returnValue = [];
			if(results.hasOwnProperty('timeout')){
				//console.log('timeout');
				component.set("v.isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Server_No_Response_Error"));
				component.set('v.showSpinner', false);
				//returnValue = result['calloutError'];

			} else {
				//success - update list and push results
				//console.log('returnValue: '+JSON.stringify(results));
				if(results.calloutError != undefined){
					component.set('v.isError', true);
					component.set('v.str_errorMsg','External system is currently unavailable; please try again later. Displaying submitted referrals only.');
				} else {
					var referralSearchResults = results.calloutSuccess;
					if(referralSearchResults.length == 0) {
						component.set('v.noResults', true);
						component.set('v.paginationList', null);
						component.set('v.referralSearchResults', null);
						component.set('v.startPage',0);
						component.set('v.endPage',1);
						component.set('v.currentPage', 1);
					} else {
						var pageSize = component.get('v.pageSize');
						// hold all the records into an attribute named "referralSearchResults"
//						JSON.stringify('results in LC :: ' + referralSearchResults);
						referralSearchResults.sort(dynamicSort('ClaimNumber','desc'));
						
						component.set('v.referralSearchResults', referralSearchResults);
						// get size of all the records and then hold into an attribute "totalRecords"
						component.set('v.totalRecords', component.get('v.referralSearchResults').length);
						//console.log('totalRecords: '+component.get('v.totalRecords'));
						
						component.set('v.totalPages', Math.ceil(referralSearchResults.length / pageSize));
						helper.repaginate(component);
						// //console.log('referralSearchResults: '+JSON.stringify(response.getReturnValue()));
					}
				}
            
				component.set('v.showSpinner', false);
				
			}
		}
		
		if(window.addEventListener !== undefined) {
			//console.log('adding listener');
			window.addEventListener("message", listener, false);
		} else {
			//console.log('attaching event');
			attachEvent("onmessage", listener);
		}
       // //console.log('referralSearchHeader results init: '+JSON.stringify(component.get('v.referralSearchHeader')));
        
        window.scrollTo(0,0);
    },
    
    filterSearch : function(component, event, helper) {
        //console.log('filterSearch start');
        component.set('v.isError', false);
        
        helper.updateReferralRequestHeader(component);
        helper.searchReferrals(component);
        //console.log('filterSearch end');
    },
	
    backToSearch : function(component, event, helper) {
        var showResults = component.get('v.showResults');
        var defaultOptions = component.get('v.referralStatusOptionsDefault');
        //add back in the All option because Javascript sucks
        if(defaultOptions.indexOf('All') == -1) {
            defaultOptions.unshift('All');
        }

        if(component.get('v.selectedReferralStatusFromSearch') == 'All') {
            component.set('v.selectedReferralStatus', 'All'); 
        }
        //console.log('defaultOptions: '+defaultOptions);
        component.set('v.referralStatusOptions', defaultOptions);

        //console.log('showResults before: '+showResults);
        component.set('v.showResults', !showResults);
	},

	showHideFilter : function(component, event, helper) {
        var expandFilter = component.get('v.expandFilter');
        //console.log('expandFilter before: '+expandFilter);
        component.set('v.expandFilter', !expandFilter);
    },

    clearFilters : function(component, event, helper) {
        component.set('v.isError', false);
        helper.clearMultiPicklists(component);
        helper.initializeOptions(component);
        helper.updateReferralRequestHeader(component);
        helper.searchReferrals(component);
    },
    
    draftDetail : function(component,event,helper){
        //redirects to the referral detail page
        //gets claimNumber for particular referral
        var detailRedirectId = event.currentTarget.dataset.detailredirectid;
        //console.log('detailRedirectId: '+detailRedirectId);
        //sets page name to route to
        var pageName = "referral-detail";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "memberProfileGuid" : detailRedirectId,
                "newTab" : true
            });
            redirectEvent.fire();
    },
    

    //pagination methods
    firstPage : function(component, event, helper){
        var pageSize = component.get('v.pageSize');
        var referralSearchResults = component.get('v.referralSearchResults');
        // set start as 0
        component.set('v.startPage',0);
        component.set('v.endPage',pageSize-1);
        component.set('v.currentPage', 1);
        var paginationList = [];
        for(var i=0; i< pageSize; i++){
            if(referralSearchResults.length > i) {
                paginationList.push(referralSearchResults[i]);
            }
        }
        component.set('v.paginationList', paginationList);
				
    },

    previousPage: function(component, event, helper) {
        var fullReferralList = component.get('v.referralSearchResults');
        var end = component.get('v.endPage');
        var start = component.get('v.startPage');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                paginationList.push(fullReferralList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set('v.startPage',start);
        component.set('v.endPage',end);
        component.set('v.currentPage', component.get('v.currentPage')-1)
        component.set('v.paginationList', paginationList);
    },
 
    nextPage: function(component, event, helper) {
        var fullReferralList = component.get('v.referralSearchResults');
        var end = component.get('v.endPage');
        var start = component.get('v.startPage');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(fullReferralList.length > i){
                paginationList.push(fullReferralList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set('v.startPage',start);
        component.set('v.endPage',end);
        component.set('v.currentPage', component.get('v.currentPage')+1)
        component.set('v.paginationList', paginationList);
    },
    //end pagination methods

    fixDate : function(component, event, helper) {
        helper.fixDate(component, event, helper);
    },

    //column sort methods
    //sorts the column selected
    updateColumnSorting: function(component, event, helper){
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        var fieldName = tar.dataset.fieldname;
        //console.log('target and column found');

        // sort direction for dynamicSort
        // if null, dynamicSort will sort ascending
        var sortDirection = '';

        // resort the table
        var referralSearchResults = component.get('v.referralSearchResults');
       
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
            $('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

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

        referralSearchResults.sort(dynamicSort(fieldName,sortDirection));
        component.set('v.referralSearchResults', referralSearchResults);

        // call repaginate function to re-do the pagniation
        helper.repaginate(component);
        
        //console.log('end of sort method');
    }
    //end column sort methods
})