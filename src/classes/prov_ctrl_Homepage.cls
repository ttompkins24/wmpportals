public with sharing class prov_ctrl_Homepage {
    
    @AuraEnabled
	public static prov_ctrl_Homepage.BannerWrapper retrieveBannerApex(String bizAcctId){
		prov_ctrl_Homepage.BannerWrapper wrapper = new prov_ctrl_Homepage.BannerWrapper();
		if(bizAcctId == null || bizAcctId == ''){
			bizAcctId = prov_util_Cache.DefaultBusinessId;
		}
	    //List<String> VisibleLOB = prov_util_Cache.VisibleLOB;
	    List<String> locAcctIDList = prov_util_Cache.retrieveServiceLocationIdsByBusinessId(bizAcctId);
	    List<String> provAcctIDList = prov_util_Cache.retrieveProviderIdsByBusinessId(bizAcctId);
	    bizAcctId = bizAcctId.substring(0,15);
		List<String> networkIds = prov_util_Cache.retrieveNetworkIds(bizAcctId);
		System.debug('newtworkIds::'+networkIds);
		prov_util_Permissions permission = prov_util_Cache.cobj.businessId2PermissionsMap.get(bizAcctId);
		List<String> permissionList = permission.permissionList_Notification();
		Set<String> provNotifIdSet = new Set<String>();
		
		/*
		//query for the provider notificiation network to see any notifications related to a network that this business is connected too
		for(Provider_Notification_Network__c network : [SELECT id, Provider_Notification__c FROM Provider_Notification_Network__c WHERE Network__c IN:networkIds AND Provider_Notification__r.Effective_Date__c <= TODAY AND (Provider_Notification__r.Expiration_Date__c >= TODAY OR Provider_Notification__r.Expiration_Date__c =null)]){
			provNotifIdSet.add(network.Provider_Notification__c);
		}
		*/
		//query for the provider notificiation network to see any notifications related to a network that this business is connected too
		for(AggregateResult aggRes : [SELECT Count(id) ct, Provider_Notification__c provNotif, MAX(Provider_Notification__r.Effective_Date__c) effDate 
									FROM Provider_Notification_Network__c 
									WHERE  Network__c IN:networkIds AND Provider_Notification__r.Effective_Date__c <= TODAY AND 
									(Provider_Notification__r.Expiration_Date__c >= TODAY OR Provider_Notification__r.Expiration_Date__c =null)
									 
									 GROUP BY Provider_Notification__c
									  HAVING Count(Id) > 0 
									 ]){
			provNotifIdSet.add((String)aggRes.get('provNotif'));
		} 
		String notifWhereClause = ' WHERE Show_in_Hero_Banner__c = true AND ((Business__c = \'' + bizAcctId + '\' '+
            ' AND (Provider__c =null OR Provider__c IN (\'' + String.join(provAcctIDList, '\',\'') + '\') )'+
            ' AND (Service_Location__c =null OR Service_Location__c IN (\'' + String.join(locAcctIDList, '\',\'') + '\') ) ) OR (Business__c = null AND Id IN:provNotifIdSet) OR (Portal_Wide_Notification__c =true AND Related_Provider_Portal__c =\'' + prov_util_Cache.ConfigurationName + '\')) '+
            'AND Effective_Date__c <= TODAY AND (Expiration_Date__c >= TODAY OR Expiration_Date__c =null) ' +
            //' (Network__c =null OR Network__c IN (\'' + String.join(networkIds, '\',\'') + '\')) )'+
            ' AND (Related_Functionality__c = null OR Related_Functionality__c IN:permissionList) ' +
            ' ORDER BY Effective_Date__c DESC limit 1';
            
        //List<Provider_Notification__c> messages = new List<Provider_Notification__c>();
        String query = 'SELECT id, Business__c, Portal_Wide_Notification__c, Show_in_Hero_Banner__c, Message__c, Message_Header__c, Effective_Date__c '+ 
            'FROM Provider_Notification__c ' + notifWhereClause ;
            //'ORDER BY ' + sortField + ' ' + sortDirection + ' LIMIT ' + pageSizeInt + ' OFFSET ' + total_offset;

        System.debug('### query: ' + query);
        List<Provider_Notification__c> notificationList =(List<Provider_Notification__c>)Database.query(query);
        //for(Provider_Notification__c notif : (List<Provider_Notification__c>)Database.query(query)){
        	//if(notif.Business__c != null || notif.Portal_Wide_Notification__c  || notif.Provider_Notification_Networks__r.size() > 0 ){
        	//	notificationList.add(notif);
        	//	break;
        	//}
       // }
        if(notificationList.size() == 0){//no notification to show in the hero banner

			String whereClause = 'SELECT count() ';
			whereClause += 				' FROM Member_Intervention__c'; 
	    	whereClause += ' WHERE Business__c = :bizAcctId' ;
	    	whereClause += ' AND Service_Location__c IN :locAcctIDList';    
	        whereClause += ' AND Provider__c IN :provAcctIDList AND Intervention_Action__c = \'New Notice\'';
	
	        system.debug(whereClause);
	
	        Integer memInt = Database.countquery(whereClause);
	        
	        if(memInt == 0){//there is no memeber interventions and no notifications
	        	wrapper.bannerType = 'NONE';
	        	
	        } else {
	        	wrapper.bannerType = 'Intervention';
	        	wrapper.bannerMessage = String.valueOf(memInt);
	        	
	        }
        } else { //there is a portal notification
        	wrapper.bannerType = 'Notification';
        	wrapper.bannerMessage = notificationList[0].Message__c;
        }

        return wrapper;
	} 
	
	public class BannerWrapper{
		@AuraEnabled
		public String bannerType {get;set;}
		@AuraEnabled
		public String bannerMessage {get;set;}
	}
	
	@AuraEnabled
    public static List<NotificationWrapper> recentMessagesApex(String currentBusinessId){
        Date today = Date.today();
        if(currentBusinessId == null || currentBusinessId == ''){
			currentBusinessId = prov_util_Cache.DefaultBusinessId;
		}
        currentBusinessId = currentBusinessId.substring(0,15);
        String companyName = prov_util_Cache.PortalConfiguration.Company_Name__c;
        //String dateStr = DateTime.newInstance(today.year(),today.month(),today.day()).format('yyyy-MM-dd');
		List<NotificationWrapper> recentMessages = new List<NotificationWrapper>();
		List<String> providerIds = prov_util_Cache.retrieveProviderIdsByBusinessId(currentBusinessId);
		List<String> serviceLocationIds = prov_util_Cache.retrieveServiceLocationIdsByBusinessId(currentBusinessId);
		List<String> networkIds = prov_util_Cache.retrieveNetworkIds(currentBusinessId);
		System.debug('newtworkIds::'+networkIds);
		prov_util_Permissions permission = prov_util_Cache.cobj.businessId2PermissionsMap.get(currentBusinessId);
		List<String> permissionList = permission.permissionList_Notification();
		Set<String> provNotifIdSet = new Set<String>();
        Integer maxSize = 3;
		 
		/*
		//query for the provider notificiation network to see any notifications related to a network that this business is connected too
		for(Provider_Notification_Network__c network : [SELECT id, Provider_Notification__c FROM Provider_Notification_Network__c WHERE Network__c IN:networkIds AND Provider_Notification__r.Effective_Date__c <= TODAY AND (Provider_Notification__r.Expiration_Date__c >= TODAY OR Provider_Notification__r.Expiration_Date__c =null)]){
			provNotifIdSet.add(network.Provider_Notification__c);
		}
		*/
		//query for the provider notificiation network to see any notifications related to a network that this business is connected too
		for(AggregateResult aggRes : [SELECT Count(id) ct, Provider_Notification__c provNotif FROM Provider_Notification_Network__c WHERE  Network__c IN:networkIds AND Provider_Notification__r.Effective_Date__c <= TODAY AND (Provider_Notification__r.Expiration_Date__c >= TODAY OR Provider_Notification__r.Expiration_Date__c =null) GROUP BY Provider_Notification__c HAVING Count(Id) > 0 ]){
			provNotifIdSet.add((String)aggRes.get('provNotif'));
		}
		String whereClause = ' WHERE ((Business__c = \'' + currentBusinessId + '\' '+
            ' AND (Provider__c =null OR Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\') )'+
            ' AND (Service_Location__c =null OR Service_Location__c IN (\'' + String.join(serviceLocationIds, '\',\'') + '\') ) ) OR (Business__c = null AND Id IN:provNotifIdSet) OR (Portal_Wide_Notification__c =true AND Related_Provider_Portal__c =\'' + prov_util_Cache.ConfigurationName + '\')) '+
            //' (Network__c =null OR Network__c IN (\'' + String.join(networkIds, '\',\'') + '\')) )'+
            ' AND Effective_Date__c <= TODAY AND (Expiration_Date__c >= TODAY OR Expiration_Date__c =null)' +
            ' AND (Related_Functionality__c = null OR Related_Functionality__c IN:permissionList) ' +
            '  ORDER BY Effective_Date__c DESC limit '+(maxSize+1);
            
        //List<Provider_Notification__c> messages = new List<Provider_Notification__c>();
        String query = 'SELECT id, Business__c, Business__r.Name, Service_Location__r.Name, Provider__r.Name, Portal_Wide_Notification__c, '+
        				'Show_in_Hero_Banner__c, Message__c, Message_Header__c, Effective_Date__c,Redirect_Page__c, Related_Case__c ' +
            			'FROM Provider_Notification__c ' + whereClause ;
            			//'ORDER BY ' + sortField + ' ' + sortDirection + ' LIMIT ' + pageSizeInt + ' OFFSET ' + total_offset;

        System.debug('### query: ' + query);
        Boolean foundOne = false;
        for(Provider_Notification__c notif : (List<Provider_Notification__c>)Database.query(query)){
        	if(notif.Show_in_Hero_Banner__c && foundOne == false ){
					foundOne = true; 
					continue;       			
        	}else {
        		recentMessages.add(new NotificationWrapper(notif, companyName));
        	}
        	
        	//break out of loop if you have the correct amount of messages
        	if(recentMessages.size() == maxSize)break;
        }
        
        return recentMessages;
    }
    
    public class NotificationWrapper{
    	@AuraEnabled
    	public Provider_Notification__c notif {get;set;}
    	@AuraEnabled
    	public String targetAudience {get;set;}
    	@AuraEnabled
    	public String redirectUrl {get;set;}
    	public NotificationWrapper(Provider_Notification__c newNotif, string companyName){
    		notif = newNotif;
    		redirectUrl = '';
    		targetAudience = 'DentaQuest';
    		//see if there is a redirect url
    		if(notif.Redirect_Page__c != null && notif.Redirect_Page__c != ''){
    			redirectUrl = notif.Redirect_Page__c;
    		}else if(notif.Related_Case__c != null ){
    			redirectUrl = 'help-request-detail?id='+notif.Related_Case__c;
    		}
    		
    		//see who the targeted group is
    		if(notif.Provider__c != null)
    			targetAudience = notif.Provider__r.Name;
    		else if(notif.Service_Location__c != null)
    			targetAudience = notif.Service_Location__r.Name;
    		else if(notif.Business__c != null)
    			targetAudience = notif.Business__r.Name;
    		else
    			targetAudience = companyName;
    	}
    }
    
    @AuraEnabled
    public static List<EventWrapper> recentEventsApex(String currentBusinessId){
        Date today = Date.today();
        if(currentBusinessId == null || currentBusinessId == ''){
			currentBusinessId = prov_util_Cache.DefaultBusinessId;
		}
        currentBusinessId = currentBusinessId.substring(0,15);
        //String dateStr = DateTime.newInstance(today.year(),today.month(),today.day()).format('yyyy-MM-dd');
		List<EventWrapper> recentEvents = new List<EventWrapper>();
		List<String> networkIds = prov_util_Cache.retrieveNetworkIds(currentBusinessId);
		prov_util_Permissions permission = prov_util_Cache.cobj.businessId2PermissionsMap.get(currentBusinessId);
		List<String> permissionList = permission.permissionList_Notification();
		System.debug('newtworkIds::'+networkIds);
		
		Set<String> provNotifIdSet = new Set<String>();
		/*
		for(Provider_Event_Network__c network : [SELECT id, Provider_Event__c FROM Provider_Event_Network__c WHERE Network__c IN:networkIds AND Provider_Event__r.Event_Date__c >= TODAY AND Provider_Event__r.Show_in_Provider_Portal__c = true]){
			provNotifIdSet.add(network.Provider_Event__c);
		}
		*/
		//query for the provider notificiation network to see any notifications related to a network that this business is connected too
		for(AggregateResult aggRes : [SELECT Count(id) ct, Provider_Event__c provEve FROM Provider_Event_Network__c WHERE  Network__c IN:networkIds AND Provider_Event__r.Event_Date__c >= TODAY AND Provider_Event__r.Show_in_Provider_Portal__c = true GROUP BY Provider_Event__c HAVING Count(Id) > 0  ]){
			provNotifIdSet.add((String)aggRes.get('provEve'));
		}
        //List<Provider_Notification__c> messages = new List<Provider_Notification__c>();
        String query = 'SELECT id, Event_Date__c, Event_Start_Time__c, Event_End_Time__c, Event_Timezone__c, Event_Title__c, Event_Content__c, Event_Content_Header__c ' + 
            'FROM Provider_Event__c ' ;
            //'ORDER BY ' + sortField + ' ' + sortDirection + ' LIMIT ' + pageSizeInt + ' OFFSET ' + total_offset;
            

		String whereClause = ' WHERE Id IN:provNotifIdSet '+
            //' (Network__c =null OR Network__c IN (\'' + String.join(networkIds, '\',\'') + '\')) )'+
             ' AND (Related_Functionality__c = null OR Related_Functionality__c IN:permissionList) ' +
            ' ORDER BY Event_Date__c ASC limit 3';

		query += whereClause;
		
 	    for(Provider_Event__c event : (List<Provider_Event__c>)Database.query(query)){
        	//EventWrapper wrapper = new EventWrapper(event);
        	recentEvents.add(new EventWrapper(event));
 	    	
        }
        
        return recentEvents;
    }
    
    public class EventWrapper{
    	@AuraEnabled
    	public String monthStr {get;set;}
    	@AuraEnabled
    	public Date eventDate {get;set;}
    	@AuraEnabled
    	public String dayStr {get;set;}
    	@AuraEnabled
    	public String startTime {get;set;}
    	@AuraEnabled
    	public String endTime {get;set;}
    	@AuraEnabled
    	public String timezone {get;set;}
    	@AuraEnabled
    	public String messageHeader {get;set;}
    	@AuraEnabled
    	public String messageContent {get;set;}
    	@AuraEnabled
    	public String messageContentHeader {get;set;}
    	@AuraEnabled
    	public String eventId {get;set;}
    	
    	public EventWrapper(Provider_Event__c event){
    		messageContent = '';
    		messageContentHeader='';
    		eventId = event.Id;
			dayStr = String.valueOf( event.Event_Date__c.day() );
			System.debug('startTime::'+event.Event_Start_Time__c);
			System.debug('startTime::'+event.Event_End_Time__c);
			eventDate = event.Event_Date__c;
			timezone = event.Event_Timezone__c;
			
			//set the content if not null
			if(event.Event_Content__c != null)
				messageContent = event.Event_Content__c;
			if(event.Event_Content_Header__c != null)
				messageContentHeader = event.Event_Content_Header__c;
			
			if(event.Event_Start_Time__c != null){
				Integer startHour = event.Event_Start_Time__c.hour();
				String amOrPMS = 'AM';
				if(startHour > 11){
					amOrPMS = 'PM';
					startHour -= 12;
					startHour = startHour == 0 ? 12 : startHour;
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
					endHour = endHour == 0 ? 12 : endHour;
				}
				endHour = endHour == 0 ? 12 : endHour;
				
				String endMin = String.valueOf(event.Event_End_Time__c.minute());
                if (endMin.length() ==1){
                    endMin = '0'+ endMin;
                }
	    		endTime = endHour + ':'+endMin + ' '+amOrPME;
			}
    		messageHeader = event.Event_Title__c;
    		
    		//generate string for month
    		/*Map<Integer, String> month2FriendlyMonthMap = new Map<Integer, String>{ 1=> 'Jan',
    																				2=> 'Feb',
    																				3=> 'Mar',
    																				4=> 'Apr',
    																				5=> 'May',
    																				6=> 'June',
    																				7=> 'July',
    																				8=> 'Aug',
    																				9=> 'Oct',
    																				10=> 'Oct',
    																				11=> 'Nov',
    																				12=> 'Dec'
    																				
    																				
    																				};*/
    	}
    }
    
     @AuraEnabled
    public static Boolean returnNothing(){
    	return true;
    }
}