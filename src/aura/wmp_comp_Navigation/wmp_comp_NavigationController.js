({
	doInit : function(component, event, helper) {
		helper.retrievePlans(component);
		helper.helperLoadConfig(component);
		
	},
	
	refreshMemberPlansNav : function(component,event, helper){
		helper.retrievePlans(component);
	},
	
	redirectUrl : function(component, event, helper){
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.loc;
		var subId = selectItem.dataset.subid;
		var planId = selectItem.dataset.planid;
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
						'subscriberGuid' : subId,
						'planGuid' : planId,
						'pageName' : pageName
		});
		redirectEvent.fire();
		
		var isMobile = component.get('v.showMobile');
					
		if(isMobile){
			var cmpTarget = component.find('navContentModal');
			var cmpBack = component.find('navBackdrop');
			$A.util.removeClass(cmpBack,'slds-backdrop--open');
			$A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
		}
	},
	
	closeModal:function(component,event,helper){
        var cmpTarget = component.find('navContentModal');
        var cmpBack = component.find('navBackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    openModal: function(component,event,helper) {
        var cmpTarget = component.find('navContentModal');
        var cmpBack = component.find('navBackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    
	runJquery : function(component, event, helper){
		//console.log('runJquery...');
        
        
       /* $('.nav ul li > a:not(:only-child)').one('click', function (e) {
	    	console.log('inside2...');
	    	$(this).siblings('.nav-dropdown').toggle();
	    	e.stopPropagation();
	    });*/
        $('html').click(function(){
	    	//console.log('inside html click...');
	    	$('.dropdown-menu').removeClass('in');
	    	$('.dropdown a.endIcon.open').removeClass('open');
	    	
	    });
       
//        	component.runMethod();
       
	    var resizeNav = function(){
			if($(this).width() > 768){
				component.runMethod();
			}
		};
		
		$(window).off('resize', resizeNav);
	    window.onresize = resizeNav;
	    
	   
	},
	
	runDropdown : function(component, event, helper){
		
//		console.log('inside runDropdown ');
		var curTarget = event.currentTarget;
		$(curTarget).toggleClass('open');
		$(curTarget).siblings('.dropdown-menu').toggleClass('in');
		var sibling = $(curTarget).siblings('.dropdown-menu').get(0);
		var parent = $(curTarget).parent().parent();
//		console.log("$(parent).hasClass('moreDropdown')::"+$(parent).attr('class') );
		if( $(parent).hasClass('moresubmenu') ){//in the more list
			$('#nav-main .in').not(sibling).not($('#moreList')).each(function(){
	    		$(this).removeClass('in');
		     });
		     $('#nav-main .open').not(curTarget).not($('.moreDropdown')).each(function(){
	    		$(this).removeClass('open');
		     });
		} else {//not in the more dropdown
			$('#nav-main .in').not(sibling).each(function(){
	    		$(this).removeClass('in');
		     });
		     
		     $('#nav-main .open').not(curTarget).each(function(){
	    		$(this).removeClass('open');
		     });
		}
	     
		event.stopPropagation();
		 
	},
	
	runCollapse : function(component, event, helper){
		//console.log('inside runCollapse');
		var curTarget = event.currentTarget;
		$(curTarget).toggleClass('open');
		$(curTarget).siblings('.dropdown-collapse').toggleClass('in');
		var sibling = $(curTarget).siblings('.dropdown-collapse').get(0);
    	$('#navModalConId .dropdown-collapse.in').not(sibling).each(function(){
    		$(this).removeClass('in');
	     });
	     
	     $('#navModalConId .open').not(curTarget).each(function(){
    		$(this).removeClass('open');
	     });
	     
		event.stopPropagation();
		 
	},
	
	recalcNav : function(component, event, helper){
		 if($(this).width() < 768){
			 return;
		 }
		 if(! $('#topNavRowId').is(':visible')){
			 return;
		 }
		 
		var navwidth = 0;
        var morewidth = $('#topNavRowId .more').outerWidth(true);
        
        $('#topNavRowId > li.topNavCell:not(.more)').each(function() {
            navwidth += $(this).outerWidth( true );
        });
//        console.log('navWidth::'+navwidth);
//        console.log('before::fadCell::'+$('#fadTopCellId').outerWidth( true ) );
        var fadCellContainer = $('#fadTopCellId').outerWidth( true ) ;
//        if(fadCellContainer < 183){
//        	fadCellContainer = 184;
//        }
//        console.log('fadCellContainer::'+fadCellContainer);
//        console.log('fadCell::'+fadCellContainer);
        //var availablespace = $('nav').outerWidth(true) - morewidth;
        var availablespace = $('#nav-main').width() - morewidth - fadCellContainer;
//        console.log('availSpace::'+availablespace);
      
        if (navwidth > availablespace) { 
        	while(navwidth > availablespace){
	            var lastItem = $('#topNavRowId > li:not(.more)').last();
	            if(lastItem.outerWidth( true ) > 0){
		            lastItem.attr('data-width', lastItem.outerWidth( true ));
		            navwidth -= lastItem.outerWidth( true );
//		            $(lastItem).click(function(){
//		            	component.runDropdownClick();
//		            });
		            //$(lastItem).find('.endIcon h4').addClass('inverse');
//		            $(lastItem).removeClass('topNavCell');
		            lastItem.prependTo($('#topNavRowId .more ul.moresubmenu'));
		         } else {
		            //$(lastItem).find('.endIcon h4').removeClass('inverse');
		        	 lastItem.remove();
		         }
		    }
        	component.runMethod();
            
        } else {
            
	        var firstMoreElement = $('#topNavRowId li.more li').first();
	        if (navwidth + firstMoreElement.data('width') < availablespace ) {
//	        	$(firstMoreElement).addClass('topNavCell');
	        	//$(firstMoreElement).find('.endIcon h4').removeClass('inverse');
	            firstMoreElement.insertBefore($('#topNavRowId .more'));
	            component.runMethod();
	        }
	    }
	    
	    
	    //console.log($('#moreList li').length);
	    if ($('#moreList li').length > 0) {
	        $('.more').css('display','block');
        } else {
            $('.more').css('display','none');
        }
	},
	
	
})