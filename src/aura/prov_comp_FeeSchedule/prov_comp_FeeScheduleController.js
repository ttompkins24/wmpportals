({
    //page utility methods
       doInit : function(component, event, helper) {
        helper.defaultDOS(component);
 
        helper.createFeeSearchHeader(component);
 
        helper.getNetworkList(component, event, helper);
       
        //var tempDate = new Date();
        // USED FOR TESTING PURPOSES
        //component.set('v.serviceDate', tempDate);
       
        
        var listener = function(event) {
              var origin = $A.get('$Label.c.Member_Eligibility_VF_URL');
                     //var providerId = component.get("v.provAcctRec");
                     //console.log('providerId ' + providerId);
//            console.log('return listener');
//            console.log('event.origin ' + event.origin);
              if(event.origin !== origin) {
                     //not the expected origin. reject results
                     console.log('origins did not match');
                     return;
              }
 
              //Handle the message
              var results = event.data;
             
              if(results == 'pageLoaded'){
                     console.log('vf page loaded...');
              component.set('v.checkButtonDisabled', false);
              return;
            }
 
              console.log('results ' + results);
              console.log('results ' + JSON.stringify(results));
//            console.log('results ' + typeof results);
//                   console.log('time out in search page' + results.hasOwnProperty('timeout'));
 
                     if(results.hasOwnProperty('timeout')){
                           //console.log('timeout');
                           component.set('v.isError', true);
                component.set('v.str_errorMsg','Search is currently unavailable. Please try again later.');
                           component.set('v.showSpinner', false);
 
                     } else {
                           //success - update list and push results
                component.set('v.searchMade', true);
                    
                console.log('result: '+JSON.stringify(results));
                if(results == null || results.length == 0 ) {
                    component.set('v.noResults', true);
                    component.set('v.paginationList', null);
                    component.set('v.feeScheduleResults', null);
                    component.set('v.startPage',0);
                    component.set('v.endPage',1);
                    component.set('v.currentPage', 1);
                } else {
                   
                    var pageSize = component.get('v.pageSize');
                    // hold all the records into an attribute named "feeScheduleSearchResults"
                    var feeScheduleResults = results;
                    var pCode = component.get('v.pCode');
                    var pDesc = component.get('v.pDesc');
                    console.log('pCode::'+pCode+'***** pDesc::'+pDesc);
 
                    // sort based on code and description (if entered)
                    if(pCode) {
                        feeScheduleResults = feeScheduleResults.filter(function(element) {
                            var elementCode = element.ProcedureCode.toLowerCase();
                            return elementCode.indexOf(pCode.toLowerCase()) > -1;
                        });
                    }
 
                    if(pDesc) {
                        feeScheduleResults = feeScheduleResults.filter(function(element) {
                            var elementDesc = element.ProcedureDescription.toLowerCase();
                            return elementDesc.indexOf(pDesc.toLowerCase()) > -1;
                        });
                    }
 
                    feeScheduleResults.sort(dynamicSort('ProcedureCode','asc'));
                   
                    component.set('v.feeScheduleResults', feeScheduleResults);
                    // get size of all the records and then hold into an attribute "totalRecords"
                    component.set('v.totalRecords', feeScheduleResults.length);
                    console.log('totalRecords: '+component.get('v.totalRecords'));
                   
                    component.set('v.totalPages', Math.ceil(feeScheduleResults.length / pageSize));
                    //paginate
                    helper.repaginate(component);
                    // console.log('feeScheduleResults: '+JSON.stringify(response.getReturnValue()));
                }
                //hide spinner
                component.set('v.showSpinner', false);
                          
                     }
              }
             
              if(window.addEventListener !== undefined) {
                     console.log('adding listener');
                     window.addEventListener("message", listener, false);
              } else {
                     console.log('attaching event');
                     attachEvent("onmessage", listener);
              }     
              component.set('v.showSpinner', false);
        console.log('init Finish - hide spinner');
    },
 
    feeScheduleSearch: function(component, event, helper) {
        console.log('search for those records!');
        helper.validateEntry(component, event, helper);
    },
 
    clearSearchFields : function(component, event, helper) {
        var pageName = "fee-schedule";
 
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({
            'pageName' : pageName,
            'memberProfileGuid' : null
        });
        redirectEvent.fire();
    },
    //end page utility methods
 
    //pagination methods
    firstPage : function(component, event, helper){
        var pageSize = component.get('v.pageSize');
        var feeScheduleResults = component.get('v.feeScheduleResults');
        // set start as 0
        component.set('v.startPage',0);
        component.set('v.endPage',pageSize-1);
        component.set('v.currentPage', 1);
        var paginationList = [];
        for(var i=0; i< pageSize; i++){
            if(feeScheduleResults.length > i) {
                paginationList.push(feeScheduleResults[i]);
            }
        }
        component.set('v.paginationList', paginationList);
                          
    },
 
    previousPage: function(component, event, helper) {
        var fullFeeList = component.get('v.feeScheduleResults');
        var end = component.get('v.endPage');
        var start = component.get('v.startPage');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                paginationList.push(fullFeeList[i]);
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
        var fullFeeList = component.get('v.feeScheduleResults');
        var end = component.get('v.endPage');
        var start = component.get('v.startPage');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(fullFeeList.length > i){
                paginationList.push(fullFeeList[i]);
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
   
    //column sort methods
    //sorts the column selected
    updateColumnSorting: function(component, event, helper){
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        var fieldName = tar.dataset.fieldname;
        console.log('target and column found');
 
        // sort direction for dynamicSort
        // if null, dynamicSort will sort ascending
        var sortDirection = '';
 
        // resort the table
        var feeScheduleResults = component.get('v.feeScheduleResults');
      
        if($A.util.hasClass(tar, 'notSorted')){
            console.log('not sorted');
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
            console.log('asc');
            //column is currently sorted by ascending order, switch it
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            sortDirection = 'desc';
            console.log('end of sort asc');
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            console.log('dsc');
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
        }  
 
        feeScheduleResults.sort(dynamicSort(fieldName,sortDirection));
        component.set('v.feeScheduleResults', feeScheduleResults);
 
        // call repaginate function to re-do the pagniation
        helper.repaginate(component);
       
        console.log('end of sort method');
    },
    //end column sort methods
   
    //utility methods
    fixDate : function(component, event, helper) {
        helper.fixDate(component, event, helper);
    },
 
    cleanUpInput: function(component, event) {
        var selectItem = event.getSource();
        var stringEntered = selectItem.get('v.value');
        selectItem.set('v.value',stringEntered.trim());
    }
    //end utility methods
})