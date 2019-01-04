global without sharing class prov_ctrl_PreChat_Form {
	public String caseRecordType {
		get {
			return [SELECT Id FROM RecordType WHERE DeveloperName = 'General_Case' LIMIT 1].Id;
		}
	}
	public String caseOwner {
		get {
			return [SELECT Id FROM Group WHERE DeveloperName = 'DentaQuest_Portal_Cases' LIMIT 1].Id;
		}
	}

	public String chatUrl {
		get{
			return prov_util_Cache.getPortalConfiguration().Live_Agent_Init_URL__c;
		}
	}

	public String chatJsUrl {
		get{
			String url = prov_util_Cache.getPortalConfiguration().Live_Agent_Init_URL__c;
			return url.substring(0, url.length()-4) + 'content/g/js/32.0/prechat.js';
		}
	}

	@RemoteAction
	global static List<Account> serviceLocationOptions(String businessId) {
		List<Account> options = new List<Account>();
		for(Account location : getAllAvailableServiceLocations(businessId)) {
			options.add(location);
		}
		system.debug('location options apex: '+options);
		return options;
	}

	@RemoteAction
	global static List<Account> providerOptions(String businessId, String locationId) {
		List<Account> options = new List<Account>();
		for(Account provider : getAllAvailableProviders(businessId, locationId)) {
			options.add(provider);
		}
		system.debug('provider options apex: '+options);
		return options;
	}

	private static List<Account> getAllAvailableServiceLocations(String currentBusinessId) { 
        //populate strings with values for DAL query
        Id bizId = Id.valueOf(currentBusinessId);
        List<Account> availableServiceLocationResult = prov_util_Cache.retrieveServiceLocation(bizId);
        availableServiceLocationResult.sort();
        system.debug('availableServiceLocationResult apex: '+availableServiceLocationResult);
        return availableServiceLocationResult;
    }

	public static List<Account> getAllAvailableProviders(String currentBusinessId, String locationId) {
        //populate strings with values for DAL query
        List<Account> availableDentistsResult = prov_util_Cache.retrieveProviders(currentBusinessId, locationId);
        availableDentistsResult.sort();
        system.debug('availableDentistsResult apex: '+availableDentistsResult);
        return availableDentistsResult;
    }
}