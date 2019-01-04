({
	doInit : function(component, event, helper) {
		console.log('eobSearchParamMap results init: '+JSON.stringify(component.get('v.eobSearchParamMap')));

        //holds the origin of the message originating from the Visual Force page
        var origin = $A.get('$Label.c.Member_Eligibility_VF_URL');
        component.set('v.vfHost', origin);


        helper.initialzeFilterFields(component);
        helper.initializeQuickActions(component);
        window.scrollTo(0,0);

        //Listener for responses from VF page
        window.addEventListener("message", function(event) {
            console.log('return listener');
            console.log('event.origin ' + event.origin);
            var origin = component.get('v.vfHost');
            if(event.origin !== origin) {
                //not the expected origin. reject results
                console.log('origins did not match');
                return;
            }

            //call search method once visualforce page loads
            if(event.data.type == "load"){
                helper.searchEOBs(component);

            // check to see if error is returned
            console.log('error in page' + event.data.hasOwnProperty('error'));
            } else if(event.data.hasOwnProperty('error')){
                console.log('error occurred');
                console.log('data ' + JSON.stringify(event.data));
                component.set("v.isError",true);
                component.set("v.showSpinner",false);
                if(event.data.error == 404){
                    component.set("v.str_errorMsg",$A.get("$Label.c.EOB_Not_Available"));
                } else {
                    component.set("v.str_errorMsg",$A.get("$Label.c.General_Error_Provider"));
                }

            //check to see if its a single EOB response
            } else if(event.data.type == "eob"){
                console.log('eob returned');
                //Handle the message

                var doc = event.data.result;
                var name = event.data.name;

                if(doc != undefined || doc != ''){
                    console.log('doc not blank');
                    console.log('doc ' + doc);

                    // IE doesn't allow using a blob object directly as link href
                    // instead it is necessary to use msSaveOrOpenBlob

                    if (window.navigator && window.navigator.msSaveOrOpenBlob) { // IE workaround
                        var byteCharacters = atob(doc);
                        var byteNumbers = new Array(byteCharacters.length);
                        
                        for (var i = 0; i < byteCharacters.length; i++) {
                            byteNumbers[i] = byteCharacters.charCodeAt(i);
                        }
                        
                        var byteArray = new Uint8Array(byteNumbers);
                        var blob = new Blob([byteArray], {type: 'application/pdf'});
                        window.navigator.msSaveOrOpenBlob(blob, name+".pdf");
                        component.set('v.showSpinner', false);

                    } else {
                        var element = document.createElement('a');

                        element.setAttribute('href', 'data:make-me-download;base64,' + doc);

                        element.setAttribute('download', name+".pdf");

                        element.style.display = 'none';
                        document.body.appendChild(element);

                        element.click();

                        document.body.removeChild(element);

                        console.log('end of download');
                        component.set('v.showSpinner', false);
                    }

                } else {

                    //setting the error flag    and the message

                    component.set("v.isError",true);
                    component.set("v.str_errorMsg",$A.get("$Label.c.General_Error_Provider"));
                    console.log('Error');
                    component.set('v.showSpinner', false);
                }
            //check to see if its an EOBlist response
            } else if (event.data.type = "eobList"){
                console.log('eobList returns to init listener');
                
                var result = event.data.result;
                console.log('results in listener ' + result);
                                
                var returnValue = [];
                if(result.hasOwnProperty('calloutSuccess')) {
                    console.log('in here');
                    returnValue = result.calloutSuccess;
                }
                console.log('returnValue: '+JSON.stringify(returnValue));
                if(!returnValue || returnValue.length == 0) {
                    component.set('v.noResults', true);
                    component.set('v.eobSearchResults', null);
                    component.set('v.totalPages', 0);
                    component.set('v.totalRecords', 0);
                    component.set('v.currentPage', 0);
                } else {
                console.log('returnValue: '+JSON.stringify(returnValue));
                    component.set('v.eobSearchResults', returnValue.Eobs);

                    // get size of all the records and then hold into an attribute "totalRecords"
                    component.set('v.totalRecords', returnValue.Total);
                    console.log('totalRecords: '+component.get('v.totalRecords'));
                    
                    component.set('v.totalPages', returnValue.TotalPages);

                    component.set('v.currentPage', returnValue.PageNumber);
                }
                component.set('v.showSpinner', false);
                console.log('searchEOBs end');
            }
        }, false);
    },

    handleQuickAction : function(component, event, helper) {
        if(event.getParam('value') == 'download') {
            console.log('download original PDF');
            // helper.downloadPDF(component, event, helper);
            helper.downloadPDFRemote(component, event, helper);
        }
    },
    
    filterSearch : function(component, event, helper) {
        console.log('filterSearch start');
        component.set('v.isError', false);
        
        helper.updateEOBSearchParamMap(component);
        helper.searchEOBs(component);  
        console.log('filterSearch end');
    },
	
    backToSearch : function(component, event, helper) {
        var showResults = component.get('v.showResults');

        console.log('showResults before: '+showResults);
        component.set('v.showResults', !showResults);     
	},

	showHideFilter : function(component, event, helper) {
        var expandFilter = component.get('v.expandFilter');
        console.log('expandFilter before: '+expandFilter);
        component.set('v.expandFilter', !expandFilter);
    },

    clearFilters : function(component, event, helper) {
        component.set('v.isError', false);
        helper.clearFilterFields(component);
        helper.updateEOBSearchParamMap(component);
        helper.searchEOBs(component);
    },    

	printList:function(component, event, helper){
		console.log("printing...");
		window.print();
	},

    //pagination methods
    firstPage : function(component, event, helper){
        var eobSearchParamMap = component.get('v.eobSearchParamMap');

        eobSearchParamMap.Page = '1';
        console.log('paramMap: '+JSON.stringify(eobSearchParamMap));

        component.set('v.eobSearchParamMap', eobSearchParamMap);

        helper.searchEOBs(component);
        console.log('firstPage end');				
    },

    previousPage: function(component, event, helper) {
        var eobSearchParamMap = component.get('v.eobSearchParamMap');
        var currentPage = component.get('v.currentPage') - 1;

        eobSearchParamMap.Page = currentPage.toString();
        console.log('paramMap: '+JSON.stringify(eobSearchParamMap));

        component.set('v.eobSearchParamMap', eobSearchParamMap);

        helper.searchEOBs(component);
        console.log('previousPage end');
    },
 
    nextPage: function(component, event, helper) {
        var eobSearchParamMap = component.get('v.eobSearchParamMap');
        var currentPage = component.get('v.currentPage') + 1;

        eobSearchParamMap.Page = currentPage.toString();
        console.log('paramMap: '+JSON.stringify(eobSearchParamMap));

        component.set('v.eobSearchParamMap', eobSearchParamMap);

        helper.searchEOBs(component);
        console.log('nextPage end');
    },
    //end pagination methods

    fixDate : function(component, event, helper) {
        helper.fixDate(component, event, helper);
	},
	
    cleanUpInput: function(component, event) {
        var selectItem = event.getSource();
        var stringEntered = selectItem.get('v.value');
        selectItem.set('v.value',stringEntered.trim());
    },

    //column sort methods
    //sorts the column selected
    updateColumnSorting: function(component, event, helper){
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        var fieldName = tar.dataset.fieldname;
        console.log('target and column found');
        console.log('target: '+tar);
        console.log('column: '+col);
        console.log('fieldName: '+fieldName);

        // sort direction for dynamicSort
        // if null, dynamicSort will sort ascending
        var sortDirection = 'Ascending';

        // resort the table
        var eobSearchParamMap = component.get('v.eobSearchParamMap');
       
        if($A.util.hasClass(tar, 'notSorted')){
            console.log('not sorted');
            $A.util.removeClass(tar, 'notSorted');
            if(col == 0){
                //default last updated to descend. newest first
                $A.util.addClass(tar, 'sortDescend');
                sortDirection = 'Descending';
            } else {
                $A.util.addClass(tar, 'sortAscend');
            }
            $('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

        } else if($A.util.hasClass(tar, 'sortAscend')) {
            console.log('asc');
            //column is currently sorted by ascending order, switch it
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            sortDirection = 'Descending';
            console.log('end of sort asc');
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            console.log('dsc');
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
        }   

        eobSearchParamMap.SortBy = fieldName;
        eobSearchParamMap.SortDirection = sortDirection;
        eobSearchParamMap.Page = '1';
        component.set('v.currentPage',1);
        console.log('after sort eobSearchParamMap: '+ JSON.stringify(eobSearchParamMap));
        component.set('v.eobSearchParamMap', eobSearchParamMap);

        // search again
        helper.searchEOBs(component);
        
        console.log('end of sort method');
    }
    //end column sort methods
})