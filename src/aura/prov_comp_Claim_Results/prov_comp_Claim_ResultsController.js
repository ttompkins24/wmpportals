({
    doInit : function(component, event, helper) {
        helper.initializeOptions(component);
        //console.log('claimSearchHeader results init: '+JSON.stringify(component.get('v.claimSearchHeader')));
        // helper.searchClaims(component);
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
                helper.searchClaimsRemote(component);

            // check to see if error is returned
            //console.log('error in page' + event.data.hasOwnProperty('error'));
            } else if(event.data.hasOwnProperty('error')){
                //console.log('error occurred');
                component.set('v.isError', true);
                component.set('v.showSpinner', false);
                component.set('v.str_errorMsg','Search unavailable at this time. Please try again later.');

            //claim response
            } else {
                //console.log('claims returned');
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
                        component.set('v.claimSearchResults', null);
                        component.set('v.startPage',0);
                        component.set('v.endPage',1);
                        component.set('v.currentPage', 1);
                    } else {
                        var pageSize = component.get('v.pageSize');
                        // hold all the records into an attribute named "claimSearchResults"
                        var claimSearchResults = returnValue;
                        claimSearchResults.sort(dynamicSort('ClaimNumber','desc'));
                        
                        component.set('v.claimSearchResults', claimSearchResults);
                        // get size of all the records and then hold into an attribute "totalRecords"
                        component.set('v.totalRecords', component.get('v.claimSearchResults').length);
                        //console.log('totalRecords: '+component.get('v.totalRecords'));
                        
                        component.set('v.totalPages', Math.ceil(claimSearchResults.length / pageSize));
                        helper.repaginate(component);
                        // //console.log('claimSearchResults: '+JSON.stringify(response.getReturnValue()));
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
        
        helper.updateClaimRequestHeader(component);
        helper.searchClaimsRemote(component);  
        //console.log('filterSearch end');
    },
    
    backToSearch : function(component, event, helper) {
        var showResults = component.get('v.showResults');
        var defaultOptions = component.get('v.claimStatusOptionsDefault');
        //add back in the All option because Javascript sucks
        if(defaultOptions.indexOf('All') == -1) {
            defaultOptions.unshift('All');
        }

        if(component.get('v.selectedClaimStatusFromSearch') == 'All') {
            component.set('v.selectedClaimStatus', 'All'); 
        }
        //console.log('defaultOptions: '+defaultOptions);
        component.set('v.claimStatusOptions', defaultOptions);

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
        helper.updateClaimRequestHeader(component);
        helper.searchClaims(component);
    },
    
    draftDetail : function(component,event,helper){
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
    

    //pagination methods
    firstPage : function(component, event, helper){
        var pageSize = component.get('v.pageSize');
        var claimSearchResults = component.get('v.claimSearchResults');
        // set start as 0
        component.set('v.startPage',0);
        component.set('v.endPage',pageSize-1);
        component.set('v.currentPage', 1);
        var paginationList = [];
        for(var i=0; i< pageSize; i++){
            if(claimSearchResults.length > i) {
                paginationList.push(claimSearchResults[i]);
            }
        }
        component.set('v.paginationList', paginationList);
                
    },

    previousPage: function(component, event, helper) {
        var fullClaimList = component.get('v.claimSearchResults');
        var end = component.get('v.endPage');
        var start = component.get('v.startPage');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                paginationList.push(fullClaimList[i]);
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
        var fullClaimList = component.get('v.claimSearchResults');
        var end = component.get('v.endPage');
        var start = component.get('v.startPage');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(fullClaimList.length > i){
                paginationList.push(fullClaimList[i]);
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
        var claimSearchResults = component.get('v.claimSearchResults');
       
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

        claimSearchResults.sort(dynamicSort(fieldName,sortDirection));
        component.set('v.claimSearchResults', claimSearchResults);

        // call repaginate function to re-do the pagniation
        helper.repaginate(component);
        
        //console.log('end of sort method');
    }
    //end column sort methods
})