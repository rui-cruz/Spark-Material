package spark.material.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import spark.components.Group;
	import spark.components.HSlider;
	import spark.material.skins.HSliderSkin;
	
	[SkinState("normalAndZero")]
	[SkinState("disabledAndZero")]
	
	[Style(name="inkColor", type="uint", format="Color", inherit="yes", defaultValue="#ff6868")]
	
	public class HSlider extends spark.components.HSlider
	{
		[SkinPart(required="true")]
		public var inkHolder:Group;
		
		public function HSlider()
		{
			super();
			
			showDataTip = false;
			
			if(!getStyle("skinClass"))
				setStyle("skinClass", HSliderSkin);
		}
		
		override protected function setValue(_value:Number):void
		{
			var oldValue:Number = value;
			
			super.setValue(_value);
			
			if(_value == 0 || oldValue == 0)
			{
				styleChanged(null);
				invalidateSkinState();
			}
		}
		
		override protected function updateSkinDisplayList():void
		{
			super.updateSkinDisplayList();
			
			inkHolder.x = thumb.x + thumb.width*.5;
			
			skin.graphics.clear();
			
			if(value > 0)
			{
				skin.graphics.moveTo(0, height*.5);
				skin.graphics.lineStyle(2, enabled ? 0x4557b7 : 0xb2b2b2, 1, false, "normal", "square");				
				skin.graphics.lineTo(thumb.x - (enabled ? 0 : 3), height*.5);
			}
			
			if(value < maximum)
			{
				skin.graphics.lineStyle(2, 0xb2b2b2);
				skin.graphics.moveTo(thumb.x + thumb.width + (enabled ? 0 : 2), height*.5);
				skin.graphics.lineTo(width, height*.5);
			}
			
			skin.graphics.endFill();
		}
		
		override protected function getCurrentSkinState():String
		{
			var currentSkinState:String = super.getCurrentSkinState();
			
			if(thumb && !enabled && thumb.skin.currentState != "disabled")
				thumb.skin.setCurrentState("disabled");
			else if(thumb && enabled && thumb.skin.currentState == "disabled")
				thumb.skin.setCurrentState("up");
			
			if(value == 0)
			{
				return currentSkinState + "AndZero";
			}
			
			return currentSkinState;
		}
				
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			
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
	}
}