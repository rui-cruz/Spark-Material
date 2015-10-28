package spark.material.components
{	
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.geom.Point;

    import mx.core.mx_internal;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.TextArea;
	import spark.material.skins.TextAreaSkin;
	
	use namespace mx_internal;
	
	[SkinState("normalFocused")]
	[SkinState("normalWithFloatPrompt")]
	[SkinState("normalWithFloatPromptError")]
	[SkinState("normalFocusedWithFloatPrompt")]
	[SkinState("normalFocusedWithFloatPromptError")]
	[SkinState("disabledWithFloatPrompt")]
	[SkinState("disabledWithFloatPromptError")]
	
	[Style(name="nofloat", type="Boolean", inherit="no")]
	
	public class TextArea extends spark.components.TextArea
	{
		[SkinPart(required="false")]
		public var borderStroke:SolidColorStroke;

		public function TextArea()
		{
			super();
			
			if(!getStyle("skinClass"))
				setStyle("skinClass", TextAreaSkin);

			setStyle("focusSkin", null);
		}

		private var showErrorSkin:Boolean;
		mx_internal override function updateErrorSkin():void
		{
			if(errorString != null && errorString != "" && getStyle("showErrorSkin"))
			{
				showErrorSkin = true;
				if(skin.currentState.indexOf("Error") == -1)
					skin.currentState += "Error";
			}
			else
			{
				showErrorSkin = false;
				if(skin.currentState.indexOf("Error") != -1)
					skin.currentState = skin.currentState.substr(0, skin.currentState.indexOf("Error"));
			}
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
		
		protected function onFocusChange(evt:FocusEvent):void
		{
			if(skin && skin.contains(evt.relatedObject)) return;
			
			var focusPoint:Point = new Point(stage.mouseX, stage.mouseY);
			var objectsUnderPoint:Array = stage.getObjectsUnderPoint(focusPoint);
			stage.focus = InteractiveObject(objectsUnderPoint.pop().parent);
		}
		
		override protected function getCurrentSkinState():String
		{
			var skinState:String = enabled ? "normal" : "disabled";
			
			if(enabled && focusManager && focusManager.getFocus() == focusManager.findFocusManagerComponent(this))
			{
				skinState += "Focused";
				
				if(prompt != null && prompt != "")
					skinState += "WithFloatPrompt";
			}
			else if(prompt != null && prompt != "")
			{
				if(text.length > 0)
					skinState += "WithFloatPrompt";
				else
					skinState += "WithPrompt";
			}
			
			if(showErrorSkin)
				skinState += "Error";
			
			return skinState;
		}
	}
}

