/*******************************************************************************************************
Name                        : prov_util_JSON
Purpose                     : utility clas to format JSON strings for readability
Created on                  : May 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                    by                              Comments
1.0             8        May 2018       West Monroe Partners            See header - purpose
 
*******************************************************************************************************/

global without sharing class prov_util_JSON {
    global static String formatJSON(String sourceJSON, Boolean displayNulls){
        String formattedJSON = '*********************************\n';
        try{
            Map<String, Object> myMap = (Map<String, Object>) JSON.deserializeUntyped(sourceJSON);
            formattedJSON += formatObj(myMap, 1, displayNulls, false, 0);
            formattedJSON += '*********************************';
            formattedJSON = preserveWhitespace(formattedJSON);
        }
        catch(exception ex){
            System.debug(ex);
            return 'Improper JSON';
        }

        return formattedJSON;
    }


    private static String formatObj(Map<String, Object> myMap, Integer level, Boolean displayNulls, Boolean isArray, Integer arrayNestingLevel){
        String formattedJSON ='';
        Boolean firstObject = true;

        // recursive function was reverseing every other nested array, need to ensure order of input = output
        Map<String, Object> iterableMap = new Map<String, Object>();
        if( Math.mod(arrayNestingLevel, 2) != 0 && isArray ) {
            iterableMap = reverseMap(myMap);
        }
        else{
            iterableMap = myMap;
        }

        for (String key : iterableMap.keySet()){
            
            if(firstObject && level ==1){
                try{
                    String val = (String) iterableMap.get(key);
                    formattedJSON += createIndent(level) + key.capitalize() +': ' +  val + ' \n';
                    firstObject = false;
                    continue;
                } catch (exception ex){ }
            }else if(firstObject && level!= 1){
                //formattedJSON += createIndent(level) +'----\n';
            }
            firstObject = false;

            // handle arrays
            try{
                if(iterableMap.get(key) != null){
                    List<Object> arr = (List<Object>)iterableMap.get(key);
                    String formattedKey = key;
                    if(key.contains('_')){
                            formattedKey = '';
                        for(String s : key.split('_')){
                            formattedKey += s.capitalize() + ' ';
                        }
                    }
                    formattedJSON += createIndent(level) + '-- ' + formattedKey.trim() + ' --\n';
                    String arrayJSON = '';
                    for(Object o : arr){
                        arrayJSON = JSON.serialize(o);
                        Map<String, Object> arrayMap = (Map<String, Object>) JSON.deserializeUntyped(arrayJSON);
                        formattedJSON += formatObj(arrayMap, level + 1, displayNulls, true, arrayNestingLevel + 1);
                    }
                    continue;
                }
            } catch (exception ex){ }

            // handle integers
            try{
                Integer i = (Integer)iterableMap.get(key);
                if(i != null || displayNulls){
                    formattedJSON += createIndent(level) + key.capitalize() + ': ' + i + '\n';
                }
                continue;
            } catch (exception ex){ }
            
            // handle strings
            try{
                String val = (String) iterableMap.get(key);
                if((val != null && val.toLowerCase() != 'null') || displayNulls){
                    formattedJSON += createIndent(level) + key.capitalize() + ': ' + val + '\n';
                }
                continue;
            } catch (exception ex){ }
			
            // handle Boolean
            try{
                Boolean b = (Boolean) iterableMap.get(key);
                if((b != null) || displayNulls){
                    formattedJSON += createIndent(level) + key.capitalize() + ': ' + b + '\n';
                }
                continue;
            } catch (exception ex){ }
            
            // handle nested JSON
            try{
                String formattedKey = key;
                if(key.contains('_')){
                    	formattedKey = '';
                    for(String s : key.split('_')){
                        formattedKey += s.capitalize() + ' ';
                    }
                }
                formattedJSON += createIndent(level) + '-- ' + formattedKey.trim() + ' --\n';
                Map<String, Object> passJson = (Map<String, Object>)iterableMap.get(key);
                formattedJSON += formatObj( passJson, level + 1, displayNulls, false, arrayNestingLevel);
                continue;
            } catch (exception ex){ }
        }

        if(!checkMultipleNewLine(formattedJSON)){
            formattedJSON += '\n';
        }
        return formattedJSON;
    }

    // The main formatter function was reversing the order of arrays, this function 
    // is used to ensure the rendered text is in the same order of the incoming JSON
    private static Map<String, Object> reverseMap(Map<String, Object> objects){
        Map<String, Object> reversedMap = new Map<String, Object>();
        List<String> keys = new List<String>();
        for(String s : objects.keySet()){
            keys.add(s);
        }
        
        for(Integer i = keys.size()-1; i>=0; i--){
            reversedMap.put(keys[i], objects.get(keys[i]));
        }

        return reversedMap;
    }

    // This function is used to ensure we do not have multiple empty lines in a row
    private static Boolean checkMultipleNewLine(String s){
        for(Integer i = s.length()-1; i>0; i--){
            if(isNewLineChar(s,i)){
                for(Integer j = i-1; j>0; j--){
                    if(isNewLineChar(s,j)){
                        return true;
                    }
                    else if(!isWhiteSpaceChar(s,j)){
                        return false;
                    }
                }
                return true;
            }
            else if(!isWhiteSpaceChar(s,i)){
                return false;
            }
        }
        return false;
    }

    private static Boolean isNewLineChar(String s, Integer index){
        if(s.substring(index, index+1) == '\n'){
            return true;
        }
        return false;
    }

    private static Boolean isWhiteSpaceChar(String s, Integer index){
        if(s.substring(index, index+1) == ' '){
            return true;
        }
        return false;
    }

    // This function replaces whitespace with a character that will render correctly in a text area
    // standard whitespaces are compressed by the browser in a text area  
    private static String preserveWhitespace(String s){
        if(s!= null)
            s = s.replace(' ',String.fromCharArray( new Integer[] { 160 }));
        return s;
    }

    private static String createIndent(Integer i){
        String s = '';
        i--;
        for(Integer n=0; n<i; n++){
            s += '    ';
        }
        return s;
    }

}