({
	redirectIFrameUrl : function(component, event, helper,chosenMemberPlan) {
        var sourceString =  $A.get('$Label.c.faqVFurl')+ '/apex/prov_vf_KnowledgeArticle?articleType='+component.get("v.knwldge_articleType");
        sourceString += '&queryFields=' + component.get("v.knwldge_queryFields");

            sourceString += '&portalText=' + component.get("v.portal_configurationText");
            ////console.log('inside redirectIframeUrl:component.get("v.knwldge_articleTitle")::'+component.get("v.knwldge_articleTitle"));
            sourceString += '&articleTitle=' + component.get("v.knwldge_articleTitle");
        
         
        //console.log('sourceString::'+sourceString);
        component.set("v.src_vfPage",sourceString);
    },
})