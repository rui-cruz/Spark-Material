package utils
{
	
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	/**
	 
	 full credit goes to: 
	 http://blog.earthbrowser.com/2009/01/simple-solution-for-mousewheel-events.html
	 */
	public class MouseWheelEnabler
	{
		static private var initialised : Boolean = false;
		static private var currentItem : InteractiveObject;
		static private var browserMouseEvent : MouseEvent;
		
		public static function init( stage : Stage ) : void
		{
			if( !initialised )
			{
				initialised = true;
				registerListenerForMouseMove( stage );
				registerJS();
			}
		}
				
		private static function registerListenerForMouseMove( stage : Stage ) : void
		{
			stage.addEventListener
				(
					MouseEvent.MOUSE_MOVE, 
					function( e : MouseEvent ) : void
					{
						currentItem = InteractiveObject( e.target );
						browserMouseEvent = MouseEvent( e );
					}
				);
		}
		
		
		private static function registerJS() : void
		{
			if( ExternalInterface.available )
			{
				var id:String = 'eb_' + Math.floor(Math.random()*1000000);
				ExternalInterface.addCallback(id, function():void{});
				ExternalInterface.call(MouseWheelEnabler_JavaScript.CODE);
				ExternalInterface.call("eb.InitMacMouseWheel", id);
				ExternalInterface.addCallback('externalMouseEvent', handleExternalMouseEvent);	
			}
		}
		
		private static function handleExternalMouseEvent(delta:Number):void
		{
			if(currentItem && browserMouseEvent)
			{
				currentItem.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false, 
					browserMouseEvent.localX, browserMouseEvent.localY, browserMouseEvent.relatedObject,
					browserMouseEvent.ctrlKey, browserMouseEvent.altKey, browserMouseEvent.shiftKey, browserMouseEvent.buttonDown,
					int(delta)));
			}
		}
		
	}
}

class MouseWheelEnabler_JavaScript
{
	public static const CODE : XML = 
	
		<script><![CDATA[
			function()
			{
				// create unique namespace
				if(typeof eb == "undefined" || !eb)	
				{
					eb = {};
				}
				
				var userAgent = navigator.userAgent.toLowerCase();
				eb.platform = 
				{
					win:/win/.test(userAgent),
					mac:/mac/.test(userAgent)
				};
				
				eb.vars = {};
				
				eb.browser = 
				{
					version: (userAgent.match(/.+(?:rv|it|ra|ie)[\/: ]([\d.]+)/) || [])[1],
					safari: /webkit/.test(userAgent),
					opera: /opera/.test(userAgent),
					msie: /msie/.test(userAgent) && !/opera/.test(userAgent),
					mozilla: /mozilla/.test(userAgent) && !/(compatible|webkit)/.test(userAgent),
					chrome: /chrome/.test(userAgent)
				};
				
				// find the function we added
				eb.findSwf = function(id) 
				{
					var objects = document.getElementsByTagName("object");
					for(var i = 0; i < objects.length; i++)
					{
						if(typeof objects[i][id] != "undefined")
						{
							return objects[i];
						}
					}
					
					var embeds = document.getElementsByTagName("embed");
					
					for(var j = 0; j < embeds.length; j++)
					{
						if(typeof embeds[j][id] != "undefined")
						{
							return embeds[j];
						}
					}
						
					return null;
				}
				
				eb.usingWmode = function( swf )
				{
					if( typeof swf.getAttribute == "undefined" )
					{
						return false;
					}
					
					var wmode = swf.getAttribute( "wmode" );
					eb.log( "trying getAttributes: " + wmode );
					if( typeof wmode == "undefined" )
					{
						return false;
					}
					
					eb.log( "wmode: " + wmode );
					return true;
				}
				
				eb.log = function( message ) 
				{
					if( typeof console != "undefined" )
					{
						console.log( message );
					}
					else
					{
						//alert( message );
					}
				}
				
				eb.shouldAddHandler = function( swf )
				{
					if( !swf )
					{
						return false;
					}
	
					if( eb.platform.mac )
					{
						return true;
					}
					
					var usingWmode = eb.usingWmode( swf );
					if( !eb.browser.msie && usingWmode )
					{
						return true;
					}
					
					return false;
				}
				
				eb.InitMacMouseWheel = function(id) 
				{	
					var swf = eb.findSwf(id);
					var shouldAdd = eb.shouldAddHandler( swf );
					
					if( shouldAdd ) 
					{
						
						var mouseOver = false;
	
						/// Mouse move detection for mouse wheel support
						function _mousemove(event) 
						{
							mouseOver = event && event.target && (event.target == swf);
						}
	
						/// Mousewheel support
						var _mousewheel = function(event) 
						{
							if(mouseOver) 
							{
								var delta = 0;
								if(event.wheelDelta)		delta = event.wheelDelta / (eb.browser.opera ? 12 : 120);
								else if(event.detail)		delta = -event.detail;
								if(event.preventDefault)	event.preventDefault();
								swf.externalMouseEvent(delta);
								return true;
							}
							return false;
						}
	
						// install mouse listeners
						if(typeof window.addEventListener != 'undefined') 
						{
							window.addEventListener('DOMMouseScroll', _mousewheel, false);
							window.addEventListener('DOMMouseMove', _mousemove, false);
						}
						
						window.onmousewheel = document.onmousewheel = _mousewheel;
						window.onmousemove = document.onmousemove = _mousemove;
					}
				}	
			}
		]]></script>;
}