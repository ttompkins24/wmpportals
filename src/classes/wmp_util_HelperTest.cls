/**********************************************************************************************************************
Name                        : wmp_util_HelperTest
Purpose                     : Test class for wmp_util_Helper
Created on                  : November 2017
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                            By                      Comments
1.0             8           November 2017                   West Monroe Partners    See header - purpose
 
**********************************************************************************************************************/
@IsTest
private class wmp_util_HelperTest {
    static testmethod void testMethods(){
        system.assertNotEquals(null,wmp_util_Helper.RandomInteger(50));
        String testResult = wmp_util_Helper.RandomString(20);
        system.assertEquals(20,testResult.length());
        list<sobject> testObjs = wmp_util_Helper.getObjects('User');
        system.assertNotEquals(0, testObjs.size());
        testObjs = wmp_util_Helper.getObjects('User', 'WHERE name = \'ssdsncncjsjshgxxtt122344ssdfc\'');
        system.assertEquals(0, testObjs.size());
        testResult = wmp_util_Helper.getSelectStar('User');
        system.assertNotEquals(0,testResult.length());
        List<String> testList = wmp_util_Helper.getFieldNamesList('User');
        Set<String> testSet = wmp_util_Helper.getFieldNames('User');
        system.assertNotEquals(0,testList.size());
        system.assertNotEquals(0,testSet.size());
        map<string,string> testMap = wmp_util_Helper.getFieldLabelsMap('User',true);
        system.assertNotEquals(0,testMap.size());
        testList = wmp_util_Helper.getFieldLabelsList('User',true);
        system.assertNotEquals(0,testList.size());
        list<SelectOption> testOptions = wmp_util_Helper.getFieldListSelectOptions('User');
        system.assertNotEquals(0,testOptions.size());
        testResult = wmp_util_Helper.getSelectStarSOQL('User');
        system.assertNotEquals(0,testResult.length());
        testList = wmp_util_Helper.getFieldNamesList('User',true);
        system.assertNotEquals(0,testList.size());
    }
     
}