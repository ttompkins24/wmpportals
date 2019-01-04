public without sharing class prov_ctrl_Reports {

    @AuraEnabled
    public static MessagesWrapper getNotificationsApex(String currentBusinessId, String pageNum, String sortField, String sortDirection, String pageSize){
        Integer pageSizeInt = (Integer.valueOf(pageSize));
        Integer total_offset = pageSizeInt * (Integer.valueOf(pageNum) - 1);

        Date today = Date.today();
        String dateStr = DateTime.newInstance(today.year(),today.month(),today.day()).format('yyyy-MM-dd');

        List<String> providerIds = prov_util_Cache.retrieveProviderIdsByBusinessId(currentBusinessId);
        List<String> serviceLocationIds = prov_util_Cache.retrieveServiceLocationIdsByBusinessId(currentBusinessId);
        List<String> networkIds = prov_util_Cache.retrieveNetworkIds(currentBusinessId);
        prov_util_Permissions permission = prov_util_Cache.cobj.businessId2PermissionsMap.get(currentBusinessId);
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
        //generate the where clause
        String whereClause = ' WHERE ((Business__c = \'' + currentBusinessId + '\' '+
            ' AND (Provider__c =null OR Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\') )'+
            ' AND (Service_Location__c =null OR Service_Location__c IN (\'' + String.join(serviceLocationIds, '\',\'') + '\') ) ) OR (Business__c = null AND Id IN:provNotifIdSet) OR (Portal_Wide_Notification__c =true AND Related_Provider_Portal__c =\'' + prov_util_Cache.ConfigurationName + '\')) '+
            ' AND (Related_Functionality__c = null OR Related_Functionality__c IN:permissionList) ' +
            ' AND Effective_Date__c <= TODAY AND (Expiration_Date__c >= TODAY OR Expiration_Date__c =null) ' +
            ' AND Has_Document__c = true';
            
        List<Provider_Notification__c> messages = new List<Provider_Notification__c>();
        String query = 'SELECT Id, Effective_Date__c, Related_Case__c, Has_Document__c, Redirect_page__c, Expiration_Date__c, Message__c, Message_Header__c ' + 
            ', (SELECT Id, Name FROM Attachments)' +
            ' FROM Provider_Notification__c ' + whereClause +  
            ' ORDER BY ' + sortField + ' ' + sortDirection + ' LIMIT ' + pageSizeInt + ' OFFSET ' + total_offset; 

        System.debug('### query: ' + query);
        messages = Database.query(query);
 
        String count_query = 'SELECT Count() FROM Provider_Notification__c ' + whereClause;
        Integer count = Database.countQuery(count_query);
        MessagesWrapper wrapper = new MessagesWrapper();
        wrapper.messages = messages;
        wrapper.totalPages = count;
        return wrapper;
    }


    @AuraEnabled
    public static BlobAttachment getAttachmentData(String docId) {
        BlobAttachment ba = new BlobAttachment();
        if(docId != null) {
            List<Attachment> attachments = [SELECT ContentType, Body FROM Attachment 
                                            WHERE ParentId =: docId 
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];

            if(attachments!= null && attachments.size()==1){
                ba.body = EncodingUtil.base64Encode(attachments[0].Body);
                ba.contentType = attachments[0].ContentType;
            }
        }
        return ba;
    }   
    public class BlobAttachment {
       @AuraEnabled public String contentType;
       @AuraEnabled public String body;
    }   

    public class MessagesWrapper {
        @AuraEnabled public List<Provider_Notification__c> messages;
        @AuraEnabled public Integer totalPages;
    }

}