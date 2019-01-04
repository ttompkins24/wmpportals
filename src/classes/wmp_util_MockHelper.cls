/**********************************************************************************************************************
Name                        : 	wmp_util_MockHelper
Purpose                     : 	The utility helper that will aid in loadng and mapping mock objects to the external objects
Created on                  : 	09/12/2017
Developed by				: 	Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.0			1.0      	09/12/2017		Patrick Stephens	

**********************************************************************************************************************/
global without sharing class wmp_util_MockHelper {  
    //translate a list of mock objects to in-memory external object records
    global static	List<sObject>								translate(String toObjectType, List<sObject> fromObjectList){
    	system.debug('translate to: ' + toObjectType);
    	if(toObjectType==null || !toObjectType.endsWith('__x')){
    		//the from object is already an external object
    		return fromObjectList;
    	} else {  
    		if(fromObjectList!=null){
    			system.debug('fromSize: ' + fromObjectList.size());
    			list<String> fieldNames = wmp_util_Helper.getFieldNamesList(toObjectType,true);
    			List<sObject> result = new List<sObject>();
    			for(sObject sobj : fromObjectList){
    				SObject tObj = (sObject)Type.forName(toObjectType).newInstance();
    				//system.debug('toobj:  ' + toObjectType);
	    			for(String fName : fieldNames) {
	    				if(fname != 'displayurl' && fname != 'externalid')
	    				try{
	    					tObj.put(fName,sobj.get(fName));
	    				} catch (exception ex){
	    					system.debug('----------------------------------------------------------------------');
	    					system.debug(ex.getMessage());
	    					system.debug(ex.getStackTraceString());
	    					system.debug('----------------------------------------------------------------------');
	    				}
	    			}
	    			result.add(tObj);
    			}
    			return result;
    		} else {
    			system.debug('fromList is null');
    			return null;
    		}
    	} 
    }
}