({
	// Your renderer method overrides go here
    rerender : function(cmp, helper){
        console.log('Theme ReRender');
    	this.superRerender();
    	// do custom rerendering here
	}
})