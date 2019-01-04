public without sharing class prov_ctrl_KnowledgeArticle {

	@testVisible private sObject generic_knowledgeArticle;
	@TestVisible public String articleType_strng {get; set;}
	@TestVisible public String dataCategory_strng {get; set;}
	@TestVisible public String knwldge_articleTitle {get; set;}
	@TestVisible public List<String> listOfStringsToDisplay{get; set;}



	public prov_ctrl_KnowledgeArticle() {

		articleType_strng = ApexPages.currentPage().getParameters().get('articleType');
    	dataCategory_strng = ApexPages.currentPage().getParameters().get('portalText');
    	knwldge_articleTitle = ApexPages.currentPage().getParameters().get('articleTitle');
    	String queryString = '';
    	String statusLabel = System.Label.PublishStatus;
    	String language_strng = '';
    	listOfStringsToDisplay = new list<String>();

    	List<String>fieldQueried_list = new List<String>();
    	language_strng = UserInfo.getLanguage();

    	queryString = 'SELECT Id,Title,UrlName, FAQ_Name__c, Summary,KnowledgeArticleId' 
    					+ ' FROM FAQ__kav' 
    					+ ' WHERE ' 
    					+ 'PublishStatus = \''+statusLabel+'\''
    					+ ' AND '
    					+ ' Title =\''
    					+ knwldge_articleTitle+'\''
    					+ ' AND Language=\''
    					+ language_strng+'\'';

    	
    	System.debug('query string >> ' +  queryString);
    	try{
    		list<sObject> sObject_list_knwldgeArticles = Database.query(queryString);
            System.debug('sObject_list_knwldgeArticles:: ' + sObject_list_knwldgeArticles);

            if(!sObject_list_knwldgeArticles.isEmpty()){
    		
	    		//Assigning it to the generic sObject
		    	generic_knowledgeArticle = sObject_list_knwldgeArticles[0];
	    			System.debug('In else');
	    			system.debug(generic_knowledgeArticle);
		    		//getting the list of fields

		    		fieldQueried_list.add('FAQ_Name__c');


		    		String value = String.valueOf(generic_knowledgeArticle.get('FAQ_Name__c'));

		    			system.debug(value);

		    		//assigning to the list of strings to pass to the tokenization logic
		    		for(String iterating_field : fieldQueried_list){
		    			system.debug(iterating_field);
		    			listOfStringsToDisplay.add(String.valueOf(generic_knowledgeArticle.get(iterating_field)));
		    		}		
	    	}

	    	System.debug('list of strings to display' + listOfStringsToDisplay);

        }
        catch (Exception exp){
        	system.debug(exp);

        }
		
	}
}