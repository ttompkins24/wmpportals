({
    createFeeSearchHeader : function(component) {
        var feeSearchHeader = component.get('v.feeSearchHeader') || {};
        component.set('v.feeSearchHeader', feeSearchHeader);
        console.log('feeSearchHeader: '+JSON.stringify(component.get('v.feeSearchHeader')));
    },
 
    updateFeeSearchHeader : function(component) {
        console.log('updateFeeSearchHeader start');
        var feeSearchHeader = component.get('v.feeSearchHeader');
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        var businessid = component.get('v.currentBusinessId');// gets current business id  
        var businessGuid = providercache.businessMap[businessid].guid__c;//gets the guid
        var routeId = sessionStorage['portalconfig_lob'];
 
        feeSearchHeader.IsSpecialDeal = (component.get('v.feeScheduleType') == 'Provider');
        feeSearchHeader.BusinessGuid = businessGuid;
        feeSearchHeader.ProviderGuid = component.get('v.providerRecord').guid__c;
        feeSearchHeader.ServiceOfficeGuid = component.get('v.locationRecord').guid__c;
        feeSearchHeader.NetworkGuid = component.get('v.networkRecId');
        feeSearchHeader.ServiceDate = component.get('v.serviceDate');
        feeSearchHeader.RouteId = routeId;
 
        component.set('v.feeSearchHeader', feeSearchHeader);
        console.log('feeSearchHeader after update: '+JSON.stringify(component.get('v.feeSearchHeader')));
       
        console.log('updateFeeSearchHeader end');
    },
    getNetworkList : function (component, event, helper){
        var getNetworks = component.get('c.getAllNetworksFeeSchedule');
 
        getNetworks.setParams({
            "businessId" : component.get('v.currentBusinessId')                  
        });
       
        getNetworks.setCallback(this,function(response){
            var state = response.getState();
            var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' +
                                 errors[0].message);
                    }
                } else {
                    console.log('Unknown error');
                }
 
            console.log('state: '+state);
            if(state === 'SUCCESS'){
                component.set('v.networkList', response.getReturnValue());
 
                // if(response.getReturnValue().length === 1){
                // component.find('locAccts').set('v.value', response.getReturnValue()[0]);
                //         helper.getLocId(component, event, helper);
                   
                // }
                 //console.log('networkListyo: '+component.get('v.networkList');
            }
        });
        $A.enqueueAction(getNetworks);
    },
 
    validateEntry : function(component, event, helper) {
        component.set('v.isError', false);
        component.set('v.str_errorMsg','');
        var serviceDate = component.get('v.serviceDate');
        var networkRecId = component.get('v.networkRecId');
        var providerRecord = component.get('v.providerRecord');
        var locationRecord = component.get('v.locationRecord');
 
        console.log('serviceDate: '+ serviceDate);
        console.log('networkRecId: '+ networkRecId);
        console.log('providerRecord: ' + providerRecord);
        console.log('locationRecord: ' + locationRecord);
 
        if(!serviceDate) {
            component.set('v.str_errorMsg','Please enter a Service Date.');
            component.set('v.showSpinner', false);
            component.set('v.isError', true);
            console.log('validateEntry error');
        }
        else if(!locationRecord) {
            component.set('v.str_errorMsg','Please select a Location.');
            component.set('v.isError', true);
            component.set('v.showSpinner', false);
            console.log('validateEntry error');
        }
        else if(!providerRecord) {
            component.set('v.str_errorMsg','Please select a Provider.');
            component.set('v.isError', true);
            component.set('v.showSpinner', false);
            console.log('validateEntry error');
        }
        else if(networkRecId == '' ) {
            component.set('v.str_errorMsg','Please select a Network.');
            component.set('v.isError', true);
            component.set('v.showSpinner', false);
            console.log('validateEntry error');
        }
        else {
            helper.updateFeeSearchHeader(component, event, helper);
            helper.searchFeeSchedules2(component);
            console.log('validateEntry success');
        }
 
    },
 
    searchFeeSchedules2 : function(component) {
        console.log('searchFeeSchedules2 start');
 
        component.set('v.noResults', false);
        component.set('v.showSpinner', true);
        component.set('v.isError', false);
 
        var feeScheduleType = component.get('v.feeScheduleType');
        var networkRecId = component.get('v.networkRecId');
        var providerRecId = component.get('v.providerRecId');
        var pCode = component.get('v.pCode');
        var pDesc = component.get('v.pDesc');
        var serviceDate = component.get('v.serviceDate');
        var feeSearchHeader = component.get('v.feeSearchHeader');
 
        var jsonStr = JSON.stringify(feeSearchHeader);
   
        console.log('searchFeeSchedules early: '+jsonStr);
        //holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
 
       // var vfOrigin = "https://dev1-greatdentalplans-community.cs13.force.com/Provider/";
              window.scrollTo(0,0);                   
 
       var vfWindow = component.find("vfFrame").getElement().contentWindow;
       vfWindow.postMessage(jsonStr, vfOrigin);
        console.log('searchFeeSchedules end');
    },
   
    searchFeeSchedules : function(component) {
        console.log('searchFeeSchedules start');
 
        component.set('v.noResults', false);
        component.set('v.showSpinner', true);
        component.set('v.isError', false);
 
        var feeScheduleType = component.get('v.feeScheduleType');
        var networkRecId = component.get('v.networkRecId');
        var providerRecId = component.get('v.providerRecId');
        var pCode = component.get('v.pCode');
        var pDesc = component.get('v.pDesc');
        var serviceDate = component.get('v.serviceDate');
        var feeSearchHeader = component.get('v.feeSearchHeader');
 
        var getSchedules = component.get('c.getFeeSchedulesApex');
   
        console.log('searchFeeSchedules early');
        getSchedules.setParams({
            "json" : JSON.stringify(feeSearchHeader),
            "businessId" : component.get('v.currentBusinessId')                  
        });
           
        console.log('searchFeeSchedules middle: '+JSON.stringify(feeSearchHeader));
        getSchedules.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
 
            if(state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result['calloutSuccess']) {
                    result = result['calloutSuccess'];
                    component.set('v.searchMade', true);
                } else {
                    component.set('v.isError', true);
                    component.set('v.str_errorMsg','Search is currently unavailable. Please try again later.');
                }   
                   
                console.log('result: '+JSON.stringify(result));
               if(result == null || result.length == 0 ) {
                    component.set('v.noResults', true);
                    component.set('v.paginationList', null);
                    component.set('v.feeScheduleResults', null);
                    component.set('v.startPage',0);
                    component.set('v.endPage',1);
                    component.set('v.currentPage', 1);
                } else {
                    var pageSize = component.get('v.pageSize');
                    // hold all the records into an attribute named "feeScheduleSearchResults"
                    var feeScheduleResults = result;
                   
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
                    this.repaginate(component);
                    // console.log('feeScheduleResults: '+JSON.stringify(response.getReturnValue()));
                }
            }
            component.set('v.showSpinner', false);
            console.log('searchFeeSchedules end');
        });
        $A.enqueueAction(getSchedules);        
    },
 
    repaginate : function(component) {
              var feeScheduleResults = component.get('v.feeScheduleResults');
              var pageSize = component.get('v.pageSize');
        var paginationList = [];
              // set start as 0
              component.set('v.startPage',0);
              component.set('v.endPage',pageSize-1);
        component.set('v.currentPage', 1);
 
        for(var i=0; i< pageSize; i++){
            if(feeScheduleResults.length > i) {
                paginationList.push(feeScheduleResults[i]);
            }
        }
        component.set('v.paginationList', paginationList);
       },
 
    defaultDOS : function(component) {
        var today = new Date();
        var mm = today.getMonth()+1;
        var dd = today.getDate();
 
        if (mm <= 9) {
            mm = '0' + mm;
        }
        if (dd <= 9) {
            dd = '0' + dd;
        }
        component.set('v.serviceDate', today.getFullYear() + '-' + mm + '-' + dd);
        console.log('serviceDate init: '+component.get('v.serviceDate'));
    }
})