ruleset a169x519 {
  meta {
    name "kQuery Reveal Modal"
    description <<
      jQuery Reveal Modal Plugin for KRL
    >>

    provides init

    // Copyright (C) 2012 Ed Orcutt
    // Licensed under: GNU Public License version 2 or later

    author "Ed Orcutt, LOBOSLLC"
    logging on

    // --------------------------------------------
    // ErrorStack reporting of errors from your ruleset
    // http://docs.kynetx.com/docs/ErrorStack

    key errorstack "REDACTED"

    // --------------------------------------------
    // Error Handling in KRL
    // http://www.windley.com/archives/2011/05/error_handling_in_krl.shtml

    use module a16x104 alias es
      with es_key = keys:errorstack()
  }

  global {

    // ------------------------------------------------------------------------
    // Dynamically inject a stylesheet

    injectStylesheet = defaction() {
      nucss = cssReveal.replace(re/[\t\n\r]/g, "");
      emit <<
        var head  = document.getElementsByTagName("head")[0];
        var style = document.createElement("style");
        var rules = document.createTextNode("#{nucss}");

        style.type = "text/css";
        if (style.styleSheet) {
            style.styleSheet.cssText = rules.nodeValue;
        } else {
            style.appendChild(rules);
        }
        head.appendChild(style);
      >>;
    };

    // ------------------------------------------------------------------------
    init = defaction() {
      {
      injectStylesheet();
      emit <<
        (function($) {
        
        /*---------------------------
         Defaults for Reveal
        ----------------------------*/
           
        /*---------------------------
         Listener for data-reveal-id attributes
        ----------------------------*/
        
          $('a[data-reveal-id]').live('click', function(e) {
            e.preventDefault();
            var modalLocation = $(this).attr('data-reveal-id');
            $('#'+modalLocation).reveal($(this).data());
          });
        
        /*---------------------------
         Extend and Execute
        ----------------------------*/
        
            $.fn.reveal = function(options) {
                
                
                var defaults = {  
                animation: 'fadeAndPop', //fade, fadeAndPop, none
                animationspeed: 300, //how fast animtions are
                closeonbackgroundclick: true, //if you click background will modal close?
                dismissmodalclass: 'close-reveal-modal' //the class of a button or element that will close an open modal
              }; 
              
                //Extend dem' options
                var options = $.extend({}, defaults, options); 
          
                return this.each(function() {
                
        /*---------------------------
         Global Variables
        ----------------------------*/
                  var modal = $(this),
                    topMeasure  = parseInt(modal.css('top')),
                topOffset = modal.height() + topMeasure,
                      locked = false,
                modalBG = $('.reveal-modal-bg');
        
        /*---------------------------
         Create Modal BG
        ----------------------------*/
              if(modalBG.length == 0) {
                modalBG = $('<div class="reveal-modal-bg" />').insertAfter(modal);
              }        
             
        /*---------------------------
         Open & Close Animations
        ----------------------------*/
              //Entrance Animations
              modal.bind('reveal:open', function () {
                modalBG.unbind('click.modalEvent');
                $('.' + options.dismissmodalclass).unbind('click.modalEvent');
                if(!locked) {
                  lockModal();
                  if(options.animation == "fadeAndPop") {
                    modal.css({'top': $(document).scrollTop()-topOffset, 'opacity' : 0, 'visibility' : 'visible'});
                    modalBG.fadeIn(options.animationspeed/2);
                    modal.delay(options.animationspeed/2).animate({
                      "top": $(document).scrollTop()+topMeasure + 'px',
                      "opacity" : 1
                    }, options.animationspeed,unlockModal());          
                  }
                  if(options.animation == "fade") {
                    modal.css({'opacity' : 0, 'visibility' : 'visible', 'top': $(document).scrollTop()+topMeasure});
                    modalBG.fadeIn(options.animationspeed/2);
                    modal.delay(options.animationspeed/2).animate({
                      "opacity" : 1
                    }, options.animationspeed,unlockModal());          
                  } 
                  if(options.animation == "none") {
                    modal.css({'visibility' : 'visible', 'top':$(document).scrollTop()+topMeasure});
                    modalBG.css({"display":"block"});  
                    unlockModal()        
                  }
                }
                modal.unbind('reveal:open');
              });   
        
              //Closing Animation
              modal.bind('reveal:close', function () {
                if(!locked) {
                  lockModal();
                  if(options.animation == "fadeAndPop") {
                    modalBG.delay(options.animationspeed).fadeOut(options.animationspeed);
                    modal.animate({
                      "top":  $(document).scrollTop()-topOffset + 'px',
                      "opacity" : 0
                    }, options.animationspeed/2, function() {
                      modal.css({'top':topMeasure, 'opacity' : 1, 'visibility' : 'hidden'});
                      unlockModal();
                    });          
                  }    
                  if(options.animation == "fade") {
                    modalBG.delay(options.animationspeed).fadeOut(options.animationspeed);
                    modal.animate({
                      "opacity" : 0
                    }, options.animationspeed, function() {
                      modal.css({'opacity' : 1, 'visibility' : 'hidden', 'top' : topMeasure});
                      unlockModal();
                    });          
                  }    
                  if(options.animation == "none") {
                    modal.css({'visibility' : 'hidden', 'top' : topMeasure});
                    modalBG.css({'display' : 'none'});  
                  }    
                }
                modal.unbind('reveal:close');
              });     
             
        /*---------------------------
         Open and add Closing Listeners
        ----------------------------*/
                  //Open Modal Immediately
              modal.trigger('reveal:open')
              
              //Close Modal Listeners
              var closeButton = $('.' + options.dismissmodalclass).bind('click.modalEvent', function () {
                modal.trigger('reveal:close')
              });
              
              if(options.closeonbackgroundclick) {
                modalBG.css({"cursor":"pointer"})
                modalBG.bind('click.modalEvent', function () {
                  modal.trigger('reveal:close')
                });
              }
              $('body').keyup(function(e) {
                    if(e.which===27){ modal.trigger('reveal:close'); } // 27 is the keycode for the Escape key
              });
              
              
        /*---------------------------
         Animations Locks
        ----------------------------*/
              function unlockModal() { 
                locked = false;
              }
              function lockModal() {
                locked = true;
              }  
              
                });//each call
            }//orbit plugin call
        })($KOBJ);
      >>;
      }
    };

    // ------------------------------------------------------------------------
    cssReveal = <<
.reveal-modal-bg{position:fixed;height:100%;width:100%;background:rgba(0,0,0,.8);z-index:100;display:none;top:0;left:0;}
.reveal-modal{visibility:hidden;top:100px;left:50%;margin-left:-300px;width:520px;background:#eee;position:absolute;z-index:101;-moz-border-radius:5px;-webkit-border-radius:5px;border-radius:5px;-moz-box-shadow:0 0 10px rgba(0,0,0,.4);-webkit-box-shadow:0 0 10px rgba(0,0,0,.4);-box-shadow:0 0 10px rgba(0,0,0,.4);padding:30px 40px 34px;}
.reveal-modal.small{width:200px;margin-left:-140px;}
.reveal-modal.medium{width:400px;margin-left:-240px;}
.reveal-modal.large{width:600px;margin-left:-340px;}
.reveal-modal.xlarge{width:800px;margin-left:-440px;}
.reveal-modal .close-reveal-modal{font-size:22px;line-height:.5;position:absolute;top:8px;right:11px;color:#aaa;text-shadow:0 -1px 1px rbga(0,0,0,.6);font-weight:700;cursor:pointer;}
    >>;
  }

  // ------------------------------------------------------------------------
  rule demo {
    select when pageview ".*"
    {
      init();
    }
  }

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
