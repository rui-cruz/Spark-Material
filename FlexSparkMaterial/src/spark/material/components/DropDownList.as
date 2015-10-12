package spark.material.components
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.DropDownList;
	import spark.core.IDisplayText;
	import spark.events.DropDownEvent;
	import spark.material.skins.DropDownListSkin;
	import spark.utils.LabelUtil;
	
	use namespace mx_internal;
	
	[Style(name="inkColor", type="uint", format="Color", inherit="yes", defaultValue="#CCCCCC")]
	[Style(name="selectedItemTextColor", type="uint", format="Color", inherit="yes", defaultValue="#106cc8")]
	
	[SkinState("normalError")]
	[SkinState("normalFocused")]
	[SkinState("normalFocusedError")]
	[SkinState("normalWithFloatPrompt")]
	[SkinState("normalWithFloatPromptError")]
	[SkinState("normalFocusedWithFloatPrompt")]
	[SkinState("normalFocusedWithFloatPromptError")]
	[SkinState("openError")]
	[SkinState("openFocused")]
	[SkinState("openFocusedError")]
	[SkinState("openWithFloatPrompt")]
	[SkinState("disabledWithFloatPrompt")]
	[SkinState("disabledWithFloatPromptError")]
	
	public class DropDownList extends spark.components.DropDownList
	{
		[SkinPart(required="false")]
		public var promptDisplay:IDisplayText;
		
		[SkinPart(required="false")]
		public var borderStroke:SolidColorStroke;
		
		[SkinPart(required="false")]
		public var popUp:PopUpAnchor;
		
		public function DropDownList()
		{
			super();
						
			if(!getStyle("skinClass"))
				setStyle("skinClass", DropDownListSkin);
			
			setStyle("focusSkin", null);
			
			addEventListener(DropDownEvent.CLOSE, onDropDownClose);
			addEventListener(DropDownEvent.OPEN, onDropDownOpen);
		}
				
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == promptDisplay)
			{
				promptDisplay.text = prompt;
			}
			else if(instance == popUp)
			{
				popUp.addEventListener(FlexEvent.CREATION_COMPLETE, onDropDownAdded);
			}
		}

		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			super.keyDownHandler(event);

			if(event.keyCode == Keyboard.SPACE && !isDropDownOpen)
			{
				openDropDown();
			}
		}

		protected function onDropDownAdded(evt:Event):void
		{
			if(!popUp) return;
			
			popUp.width = Math.max(dropDown.width, width);
			
			//itemRenderer label is at x=15 y=15
			var labelBounds:Rectangle = (labelDisplay as UIComponent).getBounds(skin);
			
			if(layout && selectedIndex != -1)
			{
				var middleItem:int = int(dataGroup.layout["requestedMaxRowCount"]/2);
				
				var spDelta:Point = dataGroup.layout.getScrollPositionDeltaToElement(Math.min(dataGroup.numElements-1,selectedIndex + middleItem));
				var selectedItemBounds:Rectangle = dataGroup.layout.getElementBounds(selectedIndex);
				
				if(spDelta && spDelta.y > 0)
				{
					dataGroup.horizontalScrollPosition += spDelta.x;
					dataGroup.verticalScrollPosition += spDelta.y;
					
					popUp.adjustTopLeft(labelBounds.y - (selectedItemBounds.y - spDelta.y) - 15, labelBounds.x - (selectedItemBounds.x - spDelta.x) - 15);
				}
				else
				{
					popUp.adjustTopLeft(labelBounds.y - selectedItemBounds.y - 15, labelBounds.x - selectedItemBounds.x - 15);
				}				
			}
			else
			{
				popUp.adjustTopLeft(labelBounds.y - 15, labelBounds.x - 15);
			}			
			
			dropDown.visible = true;
		}
		
		mx_internal override function positionIndexInView(index:int, topOffset:Number = NaN, bottomOffset:Number = NaN, leftOffset:Number = NaN, rightOffset:Number = NaN):void
		{
			//don't position.. we do that on onDropDownAdded
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
		
		override mx_internal function updateLabelDisplay(displayItem:* = undefined):void
		{
			if(labelDisplay)
			{
				if(displayItem == undefined)
					displayItem = selectedItem;
				
				if(displayItem != null && displayItem != undefined)
				{
					labelDisplay.text = LabelUtil.itemToLabel(displayItem, labelField, labelFunction);
					labelDisplay["visible"] = true;
				}
				else
				{
					if(labelDisplay["visible"] && skin.currentState.indexOf("WithFloatPrompt") != -1)
						skin.currentState = skin.currentState.slice(0,skin.currentState.indexOf("WithFloatPrompt"));
										
					labelDisplay["visible"] = false;
					if(promptDisplay)
						promptDisplay.text = prompt;					
				}
			}
			
			if(focusManager && focusManager.getFocus() != focusManager.findFocusManagerComponent(this) && skin.currentState.indexOf("Focused") != -1)
				skin.currentState = skin.currentState.substr(0,skin.currentState.indexOf("Focused")).substr(skin.currentState.indexOf("Focused"), skin.currentState.length);
		}

		protected function onDropDownOpen(evt:DropDownEvent):void
		{
			if(skin.currentState.indexOf("open") == -1)
				invalidateSkinState();
		}

		protected function onDropDownClose(evt:DropDownEvent):void
		{
			var focusPoint:Point = new Point(stage.mouseX, stage.mouseY);
			var objectsUnderPoint:Array = stage.getObjectsUnderPoint(focusPoint);
			var lastElement:Object = objectsUnderPoint.pop();
			if(lastElement && lastElement.hasOwnProperty("parent"))
				stage.focus = InteractiveObject(lastElement["parent"] || lastElement);
		}

		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			invalidateSkinState();
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			var skinState:String = !enabled ? "disabled" : isDropDownOpen ? "open" : "normal";
									
			if(enabled && focusManager && focusManager.getFocus() == focusManager.findFocusManagerComponent(this))
			{
				skinState += "Focused";
				
				if(openButton)
					openButton.skin.currentState = "down";
				
				if(selectedIndex != -1)
					skinState += "WithFloatPrompt";
			}
			else if(prompt != null && prompt != "" && selectedIndex != -1)
			{
				skinState += "WithFloatPrompt";
			}
			
			if(showErrorSkin)
				skinState += "Error";

			return skinState;
		}
	}
}