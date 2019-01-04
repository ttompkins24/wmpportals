({
	init : function(component, event, helper) {
        helper.getEvents(component, event, helper);
	},

    nextPageClick : function(component, event, helper){
        var pageNum = component.get('v.pageNum');
        component.set('v.pageNum', pageNum + 1);
        helper.getEvents(component, event, helper);
        window.scrollTo(0,0);
        
    },
    
    previousPageClick : function(component, event, helper){
        var pageNum = component.get('v.pageNum');
        component.set('v.pageNum', pageNum - 1);
        helper.getEvents(component);
        window.scrollTo(0,0);
    },
    
    firstPageClick : function(component, event, helper){
        var pageNum = component.get('v.pageNum');
        component.set('v.pageNum',  1);
        helper.getEvents(component, event, helper);
        window.scrollTo(0,0);
    },
    launchEventModal : function(component, event, helper){
        var target = event.currentTarget;
        var recid = target.dataset.value;
        
        var eventList = component.get('v.events');
        //console.log('### events: ' + JSON.stringify(eventList));


        for(var i = 0; i < eventList.length; i++){
            if(eventList[i].Id == recid && eventList[i].Event_Content){
                //console.log('### got event: ' + JSON.stringify(eventList[i]));
                $A.createComponent(
                        'c:prov_common_Modal',
                        {
                            'value' : eventList[i].Event_Content,
                            'typeName' : 'TEXT',
                            'headerText' : eventList[i].Event_Content_Header
                        },
                        function(newModal, status, errorMessage){
                            //Add the new button to the body array
                            if (status === "SUCCESS") {
                                //push the modal onto the page for it to be displayed
                                var body = component.get("v.body");
                                body.push(newModal);
                                component.set('v.body', body);
                            }
                        }
                );
            }
        }
    }
})