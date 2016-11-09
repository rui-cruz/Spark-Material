package spark.material.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import spark.components.Group;
	import spark.material.skins.HSliderSkin;

	[Style(name="inkColor", type="uint", format="Color", inherit="yes")]
	
	public class RGBHSlider extends spark.components.HSlider
	{
		[SkinPart(required="true")]
		public var inkHolder:Group;
		
		public var color:int = 0xff0000;
		
		public function RGBHSlider()
		{
			super();
						
			showDataTip = false;			
			
			minimum = 0;
			maximum = 360;
			stepSize = 0;
			
			if(!getStyle("skinClass"))
				setStyle("skinClass", HSliderSkin);
		}
		
		override public function set minimum(value:Number):void
		{
			super.minimum = 0;
		}
		
		override public function set maximum(value:Number):void
		{
			super.maximum = 360;
		}
		
		private var lastUnscaledWidth:Number = 0;
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if(unscaledWidth > 0 && unscaledWidth != lastUnscaledWidth && unscaledHeight > 0)
			{
				lastUnscaledWidth = unscaledWidth;
				drawBar();
			}
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		override protected function updateSkinDisplayList():void
		{
			super.updateSkinDisplayList();
			
			if(!inkHolder || !thumb) return;
			
			inkHolder.x = thumb.x + thumb.width*.5;
			
			if(unscaledWidth > 0 && unscaledWidth != lastUnscaledWidth && unscaledHeight > 0)
			{
				lastUnscaledWidth = unscaledWidth;
				drawBar();
			}
		}
		
		override protected function getCurrentSkinState():String
		{
			var currentSkinState:String = super.getCurrentSkinState();
			
			if(thumb && !enabled && thumb.skin.currentState != "disabled")
				thumb.skin.setCurrentState("disabled");
			else if(thumb && enabled && thumb.skin.currentState == "disabled")
				thumb.skin.setCurrentState("up");
			
			return currentSkinState;
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			
			if(focusManager)
				focusManager.hideFocus();
			
			destroyRipples();
			currentRipple = new InkRipple(0, 0, 40, getStyle("inkColor"));
			currentRipple.owner = inkHolder;
			inkHolder.addElement(currentRipple);
		}
		
		override protected function thumb_mouseDownHandler(event:MouseEvent):void
		{
			super.thumb_mouseDownHandler(event);
			
			if(currentRipple)
				currentRipple.isMouseDown = false;
			
			currentRipple = new InkRipple(0,0,40,40);
			currentRipple.owner = inkHolder;
			inkHolder.addElement(currentRipple);
			
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
		}
		
		protected function drawBar():void
		{
			if(!skin) return;
			
			skin.graphics.clear();
			
			var xp:int, realX:Number, yp:int, c:Array, i:int;
			var xpScale:Number = unscaledWidth / 360;
			
			yp = (unscaledHeight / 2) - 1;
						
			for (i = 0; i < unscaledWidth; i++){
				xp = (i/xpScale) % 360;
				c =  hsv(xp, 1, 1);
				
				skin.graphics.lineStyle(1, c[0] <<16 | c[1] <<8 | c[2], 1);
				skin.graphics.moveTo(i, yp);				
				skin.graphics.lineTo(i, yp+2);
				skin.graphics.endFill();
			}
		}
		
		private function systemManager_mouseUpHandler(event:Event):void
		{
			if (event.target == this) return;
			
			destroyRipples();
		}
		
		override protected function system_mouseUpHandler(event:Event):void
		{
			super.system_mouseUpHandler(event);
			if (event.target == this) return;
			destroyRipples();
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			destroyRipples();
		}
		
		protected var currentRipple:InkRipple;
		
		protected function destroyRipples():void
		{
			for(var i:int=0; i < inkHolder.numElements; i++)
			{
				inkHolder.getElementAt(i)["destroy"](true);
			}
		}
		
		protected static function hsv(h:Number, s:Number, v:Number):Array
		{
			var r:Number, g:Number, b:Number;
			var i:int;
			var f:Number, p:Number, q:Number, t:Number;
			
			if (s == 0){
				r = g = b = v;
				return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
			}
			
			h /= 60;
			i  = Math.floor(h);
			f = h - i;
			p = v *  (1 - s);
			q = v * (1 - s * f);
			t = v * (1 - s * (1 - f));
			
			switch( i ) {
				case 0:
					r = v;
					g = t;
					b = p;
					break;
				case 1:
					r = q;
					g = v;
					b = p;
					break;
				case 2:
					r = p;
					g = v;
					b = t;
					break;
				case 3:
					r = p;
					g = q;
					b = v;
					break;
				case 4:
					r = t;
					g = p;
					b = v;
					break;
				default:        // case 5:
					r = v;
					g = p;
					b = q;
					break;
			}
			return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
		}
	}
}