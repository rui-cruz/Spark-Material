package spark.material.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.material.skins.CheckBoxSkin;
	
	[Style(name="accentColor", type="uint", format="Color", inherit="yes")]
	
	public class CheckBox extends spark.components.CheckBox
	{
		[SkinPart(required="true")]
		public var inkHolder:Group;
		
		public function CheckBox()
		{
			super();
			
			if(!getStyle("skinClass"))
				setStyle("skinClass", CheckBoxSkin);
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
			super.focusOutHandler(event);
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
				currentRipple = new InkRipple(0,0,40,40);
				currentRipple.owner = inkHolder;
				inkHolder.addElement(currentRipple);
				
				systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);
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