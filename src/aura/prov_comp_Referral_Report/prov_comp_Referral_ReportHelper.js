({


     helperPopulateDateFilter : function(component,event,helper) {
        var numDays = '';
        var intDays;

        var action = component.get("c.getNumberOfDays");
        //pass in todays date to apex method to use on SOQL query
        
        action.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
            //assign result to list of claims
            var numDays = res.getReturnValue();
            intDays = parseInt(numDays, 10);

            var today = new Date();
            var options = [];     
            var dd = today.getDate();
                var mm = today.getMonth()+1; //January is 0!
                var yyyy = today.getFullYear();

            var dd = today.getDate();
                var mm = today.getMonth()+1; //January is 0!
                var yyyy = today.getFullYear();


                today = mm + '/' + dd + '/' + yyyy;
            options.push(today); 
            //populates picklist values

            var dateset = new Date();
            for(var i=0;i < intDays;i++){
                var newDate = new Date(dateset.setDate(dateset.getDate()-1));
                var formatDate = newDate.getMonth( ) + 1 +'/'+ newDate.getDate( ) + '/' +newDate.getFullYear();


                options.push(formatDate);
            }
            component.set("v.dateFilterList", options);
            
            }
        });



        $A.enqueueAction(action);
    },

    helperPopulateReport :function (component,event,helper, filterDate) {
        component.set('v.noResults', false);
        //get todays date
        var today = new Date();
        var options = [];     

        var dd = today.getDate();
            var mm = today.getMonth()+1; //January is 0!
            var yyyy = today.getFullYear();


            today = mm + '/' + dd + '/' + yyyy;
                component.set("v.filterDate", today);
        if (filterDate != null){
            today = filterDate;
        }    
        var action = component.get("c.retreiveReferralsReport");

        //pass in todays date to apex method to use on SOQL query
        action.setParams({
            'filterDate' : today,
            'businessId' : sessionStorage['businessid']
        });

        action.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
            var results = res.getReturnValue();
            if(results.length > 0 ){
            component.set('v.referralDetails', res.getReturnValue());
                //console.log(res.getReturnValue());
            }else{
                component.set('v.referralDetails', null);
               component.set('v.noResults', true);
            }
            }
        });

        $A.enqueueAction(action);
    },

    helperFilterByDate :function (component,event,helper,date) {
    	//console.log("filtering by date");
        component.set('v.noResults', false);
        var action = component.get("c.retreiveReferralsReport");
        action.setParams({
            'filterDate' : date,
            'businessId' : sessionStorage['businessid']
        });

        action.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
            var results = res.getReturnValue();
            //console.log(results);
            if(results.length > 0 ){
            component.set('v.referralDetails', res.getReturnValue());
                
            }else{
            component.set('v.referralDetails', null);
            component.set('v.noResults', true);
            }
            }
        });
        $A.enqueueAction(action);
    },


    helperExpandServiceLine : function(component,event,helper){
        //expand html block on click
        var tar = event.currentTarget;
        var lineNumber = tar.dataset.linenumber;
        $(".moreSection_" + lineNumber).toggleClass("slds-hide");
    }
})