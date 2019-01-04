global without sharing class prov_ctrl_Panel_Roster_Print {
	public String renderStr{get;set;}
	public List<prov_wrap_PanelRoster> panelRosterResults {
        get {
            return panelRosterResultsInternal;
        }set;}
    
    /*public String requestLabel {get;set;}
		public String chooserender {get;set;}
    
    */
	public String errorMessageString {
        get {
            return errorMessageStringInternal;
        } private set;
    }
    global Boolean showMessage {get;set;}
	public Boolean hasError {
		get{
			return hasErrorInternal;
		} private set;
	}
	public String locationId {get;set;}
	public String providerId {get;set;}
	public String businessId{get;set;}
	public String firstName{get;set;}
	public String lastName{get;set;}
	public String sortDirection{get;set;}
	public String sortField{get;set;}
	public String routeId{get;set;}
	public List<prov_wrap_PanelRoster> panelRosterResultsInternal {get;set;}
	public String errorMessageStringInternal {get;set;}
	public Boolean hasErrorInternal {get;set;}

	global prov_ctrl_Panel_Roster_Print() {
		hasErrorInternal = false;
        showMessage = false;
		renderStr  = '';
        panelRosterResultsInternal = new List<prov_wrap_PanelRoster>();
		errorMessageStringInternal = 'Error printing: ';
		locationId = ApexPages.currentPage().getParameters().get('locId');
		providerId = ApexPages.currentPage().getParameters().get('provId');
		firstName = ApexPages.currentPage().getParameters().get('fName');
		lastName = ApexPages.currentPage().getParameters().get('lName');
		sortDirection = ApexPages.currentPage().getParameters().get('sortDir');
		sortField = ApexPages.currentPage().getParameters().get('sortField');
		routeId = ApexPages.currentPage().getParameters().get('routeId');
		prov_util_CacheObject tobj = prov_util_Cache.cobj;
		businessId = ApexPages.currentPage().getParameters().get('bId');
		
		
        
		Set<String> visibleLOBs = tobj.VisibleLOB;
		system.debug('provider id in vf class: ' + providerId);
		system.debug('locaiton is in vf class: ' + locationId);
		system.debug('providerMap : '+ prov_util_Cache.retrieveProviderIdsByBusinessId(businessId));
		if(!visibleLOBs.contains(routeId)) {
			errorMessageStringInternal += 'Line of Business supplied is not available for the current Business. ';
			hasErrorInternal = true;
		}
		if(locationId != null && locationId != 'undefined'){	
			system.debug(prov_util_Cache.retrieveServiceLocationIdsByBusinessId(businessId));
			if(!prov_util_Cache.retrieveServiceLocationIdsByBusinessId(businessId).contains(locationId)) {
				errorMessageStringInternal += 'Service Location supplied is not available for the current Business. ';
				hasErrorInternal = true;
			}
		}
		
		if(providerId != null && providerId != 'undefined') {
			if(!prov_util_Cache.retrieveProviderIdsByBusinessId(businessId).contains(providerId)) {
				errorMessageStringInternal += 'Provider supplied is not available for the current Business. ';
				hasErrorInternal = true;
			}
		}

		if(!hasErrorInternal) {
			//panelRosterSearch();
			hasError = true;
			//errorMessageStringInternal = 'loading the results...';
			//panelRosterSearch();
        } else {
            showMessage = true;
        }
	}
	
	
	public void recordSetListCon(){
		System.debug('panelList::'+renderStr);
		panelRosterResultsInternal =  ( List<prov_wrap_PanelRoster>)JSON.deserialize(renderStr,List<prov_wrap_PanelRoster>.class);
        showMessage = false;
	}
	
	@RemoteAction 
	global static List<prov_wrap_PanelRoster> panelRosterSearchRemote(String businessId,String locationId,String providerId,String firstName,String lastName,String sortDirection,String sortField,String routeId, Boolean hasError) {
		if(hasError) return new List<prov_Wrap_PanelRoster>();
		//retrieve the panel roster results using the panel roaster method
		List<prov_wrap_PanelRoster> tempResults = Prov_ctrl_PanelRoster.retrievePanelRoster(businessId,locationId,providerId,
										(firstName == null ? '' : firstName), (lastName == null ? '' : lastName),
										sortDirection,'1',sortField,'10000',routeId);

		for(prov_wrap_PanelRoster tempMember : tempResults) {

			system.debug(tempMember);
			if(tempMember.phone != null) {
				tempMember.phone = formatPhone(tempMember.phone);
			}
		}
		system.debug('tempResults: '+tempResults);
		return tempResults;
	}
	
	@TestVisible private static String FormatPhone(String Phone) {
		string nondigits = '[^0-9]';
		string PhoneDigits;
		
		// remove all non numeric
		PhoneDigits = Phone.replaceAll(nondigits,'');
		
		// 10 digit: reformat with dashes
		if (PhoneDigits.length() == 10) 
			return '(' + PhoneDigits.substring(0,3) + ') ' +
				PhoneDigits.substring(3,6) + '-' +
				PhoneDigits.substring(6,10);
		// 11 digit: if starts with 1, format as 10 digit 
		if (PhoneDigits.length() == 11) {
			if (PhoneDigits.substring(0,1) == '1') {
			return  '(' + PhoneDigits.substring(1,4) + ') ' +
					PhoneDigits.substring(4,7) + '-' +
					PhoneDigits.substring(7,11);
			}
		}

		// if it isn't a 10 or 11 digit number, return the original because
		// it may contain an extension or special information
		return( Phone );
	}
}