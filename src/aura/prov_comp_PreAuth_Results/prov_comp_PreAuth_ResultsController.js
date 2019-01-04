({
	doInit : function(component, event, helper) {
        helper.initializeOptions(component);
        //console.log('authSearchHeader results init: '+JSON.stringify(component.get('v.authSearchHeader')));
        // helper.searchAuths(component);

        var labelName = component.get('v.portalConfig.PreAuthorization_Label__c');
 		labelValue = $A.getReference('$Label.c.' + labelName);
 		
 		//console.log('pre auth label: ' + labelValue);

 		component.set('v.preAuthLabel', labelValue);
        window.scrollTo(0,0);

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
                helper.searchAuthsRemote(component);

            // check to see if error is returned
            //console.log('error in page' + event.data.hasOwnProperty('error'));
            } else if(event.data.hasOwnProperty('error')){
                //console.log('error occurred');
                component.set('v.isError', true);
                component.set('v.showSpinner', false);
                component.set('v.str_errorMsg','Search unavailable at this time. Please try again later.');

            //pre auth response
            } else {
                //console.log('pre auths returned');
                //Handle the message

                var result = event.data.result;

                if(result != undefined || result != ''){
                    //console.log('result not blank');
                    //console.log('result ' + result);
                    //console.log('result ' + JSON.stringify(result));
                    
                    //display results here
                    var returnValue = [];
                    var errorMsg = 'External system is currently unavailable; please try again later. Displaying submitted ' + component.get('v.preAuthLabel') + 's only.';
                    if(result['calloutSuccess']) {
                        returnValue = result['calloutSuccess'];
                    } else {
                        returnValue = result['calloutError'];
                        component.set('v.isError', true);
                        component.set('v.str_errorMsg',errorMsg);
                    }               
                    //console.log('returnValue: '+JSON.stringify(returnValue));
                    if(returnValue.length == 0) {
                        component.set('v.noResults', true);
                        component.set('v.paginationList', null);
                        component.set('v.authSearchResults', null);
                        component.set('v.startPage',0);
                        component.set('v.endPage',1);
                        component.set('v.currentPage', 1);
                    } else {
                        var pageSize = component.get('v.pageSize');
                        // hold all the records into an attribute named "authSearchResults"
                        var authSearchResults = returnValue;
                        authSearchResults.sort(dynamicSort('ClaimNumber','desc'));
                        
                        component.set('v.authSearchResults', authSearchResults);
                        // get size of all the records and then hold into an attribute "totalRecords"
                        component.set('v.totalRecords', component.get('v.authSearchResults').length);
                        //console.log('totalRecords: '+component.get('v.totalRecords'));
                        
                        component.set('v.totalPages', Math.ceil(authSearchResults.length / pageSize));
                        helper.repaginate(component);
                        // //console.log('authSearchResults: '+JSON.stringify(response.getReturnValue()));
                    }
                    component.set('v.showSpinner', false);
                    //console.log('searchAuths end');

                } else {

                    //setting the error flag    and the message
                    component.set('v.showSpinner', false);

                    component.set("v.isError",true);
                    component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
                    //console.log('Error');
                }
            }
        }, false);
    },
    
    filterSearch : function(component, event, helper) {
        //console.log('filterSearch start');
        component.set('v.isError', false);

        helper.updateAuthRequestHeader(component);
        helper.searchAuthsRemote(component);    
        //console.log('filterSearch end');
    },
	
    backToSearch : function(component, event, helper) {
        var showResults = component.get('v.showResults');
        var defaultOptions = component.get('v.authStatusOptionsDefault');
        //add back in the All option because Javascript sucks
        if(defaultOptions.indexOf('All') == -1) {
            defaultOptions.unshift('All');
        }

        if(component.get('v.selectedAuthStatusFromSearch') == 'All') {
            component.set('v.selectedAuthStatus', 'All'); 
        }
        //console.log('defaultOptions: '+defaultOptions);
        component.set('v.authStatusOptions', defaultOptions);

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
        helper.updateAuthRequestHeader(component);
        helper.searchAuths(component);
    },
    
    draftDetail : function(component,event,helper){
        //redirects to the pre-auth detail page
        //gets claimNumber for particular pre-auth
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
    

    //pagination methods
    firstPage : function(component, event, helper){
        var pageSize = component.get('v.pageSize');
        var authSearchResults = component.get('v.authSearchResults');
        // set start as 0
        component.set('v.startPage',0);
        component.set('v.endPage',pageSize-1);
        component.set('v.currentPage', 1);
        var paginationList = [];
        for(var i=0; i< pageSize; i++){
            if(authSearchResults.length > i) {
                paginationList.push(authSearchResults[i]);
            }
        }
        component.set('v.paginationList', paginationList);
				
    },

    previousPage: function(component, event, helper) {
        var fullAuthList = component.get('v.authSearchResults');
        var end = component.get('v.endPage');
        var start = component.get('v.startPage');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                paginationList.push(fullAuthList[i]);
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
        var fullAuthList = component.get('v.authSearchResults');
        var end = component.get('v.endPage');
        var start = component.get('v.startPage');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(fullAuthList.length > i){
                paginationList.push(fullAuthList[i]);
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
        var authSearchResults = component.get('v.authSearchResults');
       
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

        authSearchResults.sort(dynamicSort(fieldName,sortDirection));
        component.set('v.authSearchResults', authSearchResults);

        // call repaginate function to re-do the pagniation
        helper.repaginate(component);
        
        //console.log('end of sort method');
    }
    //end column sort methods
})