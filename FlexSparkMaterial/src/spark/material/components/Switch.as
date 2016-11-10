package spark.material.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.core.mx_internal;
	
	import spark.components.Group;
	import spark.components.supportClasses.ToggleButtonBase;
	import spark.material.skins.SwitchSkin;
	
	use namespace mx_internal;
	
	public class Switch extends ToggleButtonBase
	{
		mx_internal static var createAccessibilityImplementation:Function;
		
		[SkinPart(required="true")]
		public var inkHolder:Group;
		
		public function Switch()
		{
			super();
			
			if(!getStyle("skinClass"))
				setStyle("skinClass", SwitchSkin);
		}
		
		override public function get baselinePosition():Number
		{
			return 18;
		}
		
		override protected function initializeAccessibility():void
		{
			if (Switch.createAccessibilityImplementation != null)
				Switch.createAccessibilityImplementation(this);
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