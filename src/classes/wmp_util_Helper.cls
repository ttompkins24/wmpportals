/**********************************************************************************************************************
Name                        : 	WMP_util_Helper
Purpose                     : 	The utility that will contain Helper methods that will help with any method
Created on                  : 	08/09/2017
Developed by				: 	Todd Tompkins
History
Version#    Sprint#     Date            by                   Comments
1.0			1.0      	08/9/2017		Todd Tompkins		

**********************************************************************************************************************/
global without sharing class wmp_util_Helper {
    global static Integer RandomInteger(Integer upperBound){
    	return RandomInteger(0,upperBound);
    }
     
    global static Integer RandomInteger(Integer lowerBound, Integer upperBound){
        return Math.round(Math.random() * (upperBound - lowerBound)) + lowerBound;
    }
    
	global static String RandomString(Integer stringSize) {

        String result = ''; 
        List <String> cArray = new String [] {'A','B','C','D','E','F','G','H','I','J','K','L','M','N',
            									'O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b',
            									'c','d','e','f','g','h','i','j','k','l','m','n','o','p',
            									'q','r','s','t','u','v','w','x','y','z','0','1','2','3',
            									'4','5','6','7','8','9','-','$','#','!','@','+','=','%'};
    	Double rand = RandomInteger(cArray.size());
        for(integer i = 0; i<stringSize;i++){
            result += cArray[i];
        }
        return result;
    }
    
  	global static string getSelectStarSOQL (string objectTypeName) {
      return getSelectStarSOQL(Schema.getGlobalDescribe().get(objectTypeName), false);
  }
  
  	global static string getSelectStarSOQL (string objectTypeName, boolean removeSystemFields) {
      return getSelectStarSOQL(Schema.getGlobalDescribe().get(objectTypeName), removeSystemFields);
  }
  
  	global static set<string> getFieldNames(schema.SObjectType objectType){
      return objectType.getDescribe().fields.getMap().keySet();
  }
  
  	global static set<string> getFieldNames(string objectTypeName){
      return Schema.getGlobalDescribe().get(objectTypeName).getDescribe().fields.getMap().keySet();
  }
    
  	global static List<string> getFieldNamesList(string objectTypeName){
      return new list<string>(Schema.getGlobalDescribe().get(objectTypeName).getDescribe().fields.getMap().keySet());
  }
    
  	global static List<string> getFieldNamesList(string objectTypeName, boolean removeSystemFields){
      set<string> tSet = Schema.getGlobalDescribe().get(objectTypeName).getDescribe().fields.getMap().keySet();
      if(removeSystemFields){ 
          tSet.removeAll(new List<String>{'name','setupownerid','id','isdeleted','ownerid','createdbyid','createddate','lastmodifiedbyid','lastmodifieddate','systemmodstamp'}); 
      }
      return new list<string>(tSet);
  }
    
  	global static List<string> getFieldLabelsList(string objectTypeName, boolean removeSystemFields){
      map<string, Schema.SObjectField> tMap = Schema.getGlobalDescribe().get(objectTypeName).getDescribe().fields.getMap();
      list<string> result = new list<string>();
      set<string> tSet = new set<String>{'name','setupownerid','id','isdeleted','ownerid','createdbyid','createddate','lastmodifiedbyid','lastmodifieddate','systemmodstamp'};
      for(string s : tMap.keySet()){
          if(!removeSystemFields || !tSet.contains(s)){
              result.add(tMap.get(s).getDescribe().getLabel());
          }
      }
      return result;
  }
  
  	global static map<string,string> getFieldLabelsMap(string objectTypeName, boolean removeSystemFields){
      map<string, Schema.SObjectField> tMap = Schema.getGlobalDescribe().get(objectTypeName).getDescribe().fields.getMap();
      map<string,string> result = new map<string,string>();
      set<string> tSet = new set<String>{'name','setupownerid','id','isdeleted','ownerid','createdbyid','createddate','lastmodifiedbyid','lastmodifieddate','systemmodstamp'};
      for(string s : tMap.keySet()){
          if(!removeSystemFields || !tSet.contains(s)){
              result.put(s,tMap.get(s).getDescribe().getLabel());
          }
      }
      return result;
  }
  
  	global static string getSelectStar(string objectTypeName){
      return getSelectStar(getFieldNames(Schema.getGlobalDescribe().get(objectTypeName)));
  }
    
  	global static string getSelectStar(Set<string> strList){
      string result = 'SELECT ';
      for (String fieldName : strList) {
            result += fieldName + ', ';
        }
        result = result .substring(0,result .length()-2) + ' ';
      return result;
  }  
  
  //Santosh addition to look for knowledge article and replace the file with name and body
  global static set<string> getFieldNamesForKAV(string objectTypeName){
  	//Map for the field tracking
  	Set<String> objectFieldNames = new Set<String>();
  	map<string, Schema.SObjectField> tMap = Schema.getGlobalDescribe().get(objectTypeName).getDescribe().fields.getMap();
      for(String iterating_string : tMap.keySet()){
      		if(!iterating_string.contains('__body__s'))
      			objectFieldNames.add(iterating_string);
      }
    return objectFieldNames;
  }
  	global static String getSelectStarSOQL (Schema.SObjectType objectType, boolean removeSystemFields) {
    
        String selectStarSOQL;
        Set<String> objectFieldNames = new Set<String>();
        //Santosh addition to look for knowledge article and replace the file with name and body
		//checking if the object type is kav
		if(objectType.getDescribe().getName().contains('__kav')){ 
			objectFieldNames = getFieldNamesForKAV(objectType.getDescribe().getName());
		}else{
			objectFieldNames = getFieldNames(objectType);
		}
		
        if (removeSystemFields != null && removeSystemFields) {
            objectFieldNames.removeAll(new List<String>{'id','isdeleted','ownerid','createdbyid','createddate','lastmodifiedbyid','lastmodifieddate','systemmodstamp'});        
        }
        System.debug('Field names >> '+ objectFieldNames);
        selectStarSOQL = getSelectStar(objectFieldNames);
        selectStarSOQL += ' FROM ' + objectType.getDescribe().getName() + ' ';
    
      return selectStarSOQL;
  }
    
    global static list<SelectOption> getFieldListSelectOptions(string objectTypeName){
    	return getFieldListSelectOptions(objectTypeName, false, true);
    }
    global static list<SelectOption> getFieldListSelectOptions(string objectTypeName, boolean removeSystemFields, boolean performSort){
        list<SelectOption> result = new list<SelectOption>();
        Map<string,string> fmap = getFieldLabelsMap(objectTypeName,removeSystemFields);
        for(string fn : fmap.keySet()){
            SelectOption so = new SelectOption(fn,fmap.get(fn));
            result.add(so);
        }
        if(performSort)
            result = sortOptionList(result);
        return result;
    }
    
  	global static List<SelectOption> sortOptionList(List<SelectOption> ListToSort) {
    if(ListToSort == null || ListToSort.size() <= 1) return ListToSort;

        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();

        integer pivot = ListToSort.size() / 2;

        // save the pivot and remove it from the list

        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);

        for(SelectOption x : ListToSort) {
            if (x.getLabel() <= pivotValue.getLabel()) Less.add(x);
            else /* if (x.getLabel() > pivotValue.getLabel()) */ Greater.add(x);
        }

        List<SelectOption> returnList = new List<SelectOption>();

        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater));

        return returnList; 
    }
    
    global static list<sobject> getObjects(string objectTypeName){
    	return getObjects(objectTypeName,null,true);
    } 
    
    global static list<sobject> getObjects(string objectTypeName, string whereClause){
    	return getObjects(objectTypeName,WhereClause,true);
    }    
    global static list<sobject> getObjects(string objectTypeName, string whereClause, boolean removeSystemFields){
        list<sobject> result = new list<sobject>();
        String soql = getSelectStarSOQL(objectTypeName, removeSystemFields);
        if(whereClause==null)
            whereClause='';
        System.debug('******************************');
        System.debug(soql + ' ' + whereClause);
        System.debug('******************************');
        result = database.query(soql + ' ' + whereClause);
        return result;
    }
    
}