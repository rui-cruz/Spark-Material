package spark.material.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import spark.components.Group;
	import spark.components.RadioButton;
	import spark.material.skins.RadioButtonSkin;
	
	public class RadioButton extends spark.components.RadioButton
	{
		[SkinPart(required="true")]
		public var inkHolder:Group;
		
		public function RadioButton()
		{
			super();
			
			if(!getStyle("skinClass"))
				setStyle("skinClass", RadioButtonSkin);
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			
			focusManager.hideFocus();
			
			destroyRipples();
			currentRipple = new InkRipple(0, 0, 40, selected ? 0xff6868 : 0x999999);
			currentRipple.owner = inkHolder;
			inkHolder.addElement(currentRipple);
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			destroyRipples();
		}
		
		protected var currentRipple:InkRipple;
		override protected function mouseEventHandler(event:Event):void
		{				
			super.mouseEventHandler(event);
			
			if(currentRipple)
				currentRipple.isMouseDown = false;
			
			if(event.type == MouseEvent.MOUSE_DOWN)
			{
				currentRipple = new InkRipple(0, 0, 40, 40);
				currentRipple.owner = inkHolder;
				inkHolder.addElement(currentRipple);
				
				systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
			}
		}
		
		override protected function buttonReleased():void
		{
			super.buttonReleased();
			
			destroyRipples();
		}
		
		private function systemManager_mouseUpHandler(event:Event):void
		{
			if (event.target == this) return;
			
			destroyRipples();
		}
		
		protected function destroyRipples():void
		{
			for(var i:int=0; i < inkHolder.numElements; i++)
			{
				inkHolder.getElementAt(i)["destroy"](true);
			}
		}
	}
}