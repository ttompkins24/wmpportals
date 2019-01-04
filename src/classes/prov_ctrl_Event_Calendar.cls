public without sharing class prov_ctrl_Event_Calendar {

    public static final Integer PAGE_SIZE = 20;


    @AuraEnabled
    public static EventsWrapper getEventsApex(String businessId, String pageNumS) {

        Integer pageNum = 1;
        if(pageNumS != null && pageNumS != '') pageNum = Integer.valueOf(pageNumS);
        Integer offset = (pageNum - 1) * PAGE_SIZE;


        Id bizId = Id.valueOf(businessId);
        List<String> networkIds = prov_util_Cache.retrieveNetworkIds(businessId);
        List<Provider_Event_Network__c> prov_networks = [SELECT Provider_Event__c FROM Provider_Event_Network__c WHERE Network__c IN: networkIds];
        Set<Id> eventIds = new Set<Id>();

        for(Provider_Event_Network__c prov_net : prov_networks) {
            eventIds.add(prov_net.Provider_Event__c);
        }

        Date today = Date.today();

        List<Provider_Event__c> prov_events = [SELECT Id, Name, Event_Title__c, Event_Timezone__c, Event_Content__c, Event_Date__c, Related_Functionality__c, Event_End_Time__c, Event_Start_Time__c, Event_Content_Header__c 
                FROM Provider_Event__c 
                WHERE Id IN: eventIds AND Show_in_Provider_Portal__c =: true AND Event_Date__c >= today 
                ORDER BY Event_Date__c, Event_Start_Time__c
                LIMIT :PAGE_SIZE
                OFFSET :offset];

        EventsWrapper wrapper = new EventsWrapper();

        List<EventWrapper> events = new List<EventWrapper>();
        for(Provider_Event__c event : prov_events) {
            events.add(new EventWrapper(event));
        }
        wrapper.events = events; 

        wrapper.totalSize = [SELECT Count() 
                FROM Provider_Event__c 
                WHERE Id IN: eventIds AND Show_in_Provider_Portal__c =: true AND Event_Date__c >= today];
        return wrapper;
    } 

    public class EventsWrapper {
        @AuraEnabled public List<EventWrapper> events;
        @AuraEnabled public Integer pageSize = PAGE_SIZE;
        @AuraEnabled public Integer totalSize;
    }

    public class EventWrapper {
        @AuraEnabled public String Event_Title {get;set;}
        @AuraEnabled public Date Event_Date {get;set;}
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String Event_Timezone {get;set;}
        @AuraEnabled public String Event_Content {get;set;}
        @AuraEnabled public String Event_Content_Header {get;set;}
        @AuraEnabled public String startTime {get;set;}
        @AuraEnabled public String endTime {get;set;}
        @AuraEnabled public String Id {get;set;}
        
        public EventWrapper(Provider_Event__c event){
            Id                   = event.Id;
            Event_Date           = event.Event_Date__c;
            Event_Timezone       = event.Event_Timezone__c;
            Name                 = event.Name;
            Event_Content        = event.Event_Content__c;
            Event_Content_Header = event.Event_Content_Header__c;
            Event_Title          = event.Event_Title__c;
                

            if(event.Event_Start_Time__c != null){
                Integer startHour = event.Event_Start_Time__c.hour();
                String amOrPMS = 'AM';
                if(startHour > 11){
                    amOrPMS = 'PM';
                    startHour -= 12;
                    startHour = startHour == 0 ? 1 : startHour;
                }
                startHour = startHour == 0 ? 12 : startHour;
                String startMin = String.valueOf(event.Event_Start_Time__c.minute());
                if (startMin.length() ==1){
                    startMin = '0'+ startMin;
                }
                startTime = startHour + ':'+startMin + ' '+amOrPMS;
            }
            
            if(event.Event_End_Time__c != null){
                Integer endHour = event.Event_End_Time__c.hour();
                String amOrPME = 'AM';
                if(endHour > 11){
                    amOrPME = 'PM';
                    endHour -= 12;
                    endHour = endHour == 0 ? 1 : endHour;
                }
                endHour = endHour == 0 ? 12 : endHour;
                String endMin = String.valueOf(event.Event_End_Time__c.minute());
                if (endMin.length() ==1){
                    endMin = '0'+ endMin;
                }
                endTime = endHour + ':'+endMin + ' '+amOrPME;
            }
        }
    }
}