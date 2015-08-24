package spark.material.components
{	
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.geom.Point;
	
	import mx.core.mx_internal;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.TextInput;
	import spark.material.skins.TextInputSkin;
	
	use namespace mx_internal;
		
	[SkinState("normalFocused")]
	[SkinState("normalWithFloatPrompt")]
	[SkinState("normalFocusedWithFloatPrompt")]
	[SkinState("disabledWithFloatPrompt")]
	
	[Style(name="nofloat", type="Boolean", inherit="no")]
	
	public class TextInput extends spark.components.TextInput
	{
		[SkinPart(required="false")]
		public var borderStroke:SolidColorStroke;
		
		public function TextInput()
		{
			super();
			
			if(!getStyle("skinClass"))
				setStyle("skinClass", TextInputSkin);
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == textDisplay)
				textDisplay.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChange);
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if(instance == textDisplay)
				textDisplay.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChange);
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			
			focusManager.hideFocus();
		}
				
		protected function onFocusChange(evt:FocusEvent):void
		{
			if(skin && skin.contains(evt.relatedObject)) return;
			
			var focusPoint:Point = new Point(stage.mouseX, stage.mouseY);
			var objectsUnderPoint:Array = stage.getObjectsUnderPoint(focusPoint);
			stage.focus = InteractiveObject(objectsUnderPoint.pop().parent);
		}
		
		override protected function getCurrentSkinState():String
		{
			if(focusManager && focusManager.getFocus() == focusManager.findFocusManagerComponent(this))
			{
				if(prompt != null && prompt != "")
					return enabled ? "normalFocusedWithFloatPrompt" : "disabledWithFloatPrompt";
				
				return enabled ? "normalFocused" : "disabled";
			}
			
			if(prompt != null && prompt != "")
			{
				if(text.length > 0)
					return enabled ? "normalWithFloatPrompt" : "disabledWithFloatPrompt";
				
				return enabled ? "normalWithPrompt" : "disabledWithPrompt";
			}
			
			return enabled ? "normal" : "disabled";
		}
	}
}