package spark.material.components
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.core.mx_internal;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.DropDownController;
	import spark.events.DropDownEvent;
	import spark.material.skins.DropDownColorPickerSkin;
	
	use namespace mx_internal;
	
	[Event(name="close", type="spark.events.DropDownEvent")]
	[Event(name="open", type="spark.events.DropDownEvent")]
	[Event(name="change", type="mx.events.ColorPickerEvent")]
	
	[SkinState("open")]
	
	public class DropDownColorPicker extends SkinnableContainer
	{
		[SkinPart(required="false")]
		public var dropDown:DisplayObject;
		
		[SkinPart(required="true")]
		public var openButton:ButtonBase;
		
		[SkinPart(required="true")]
		public var startColorGroup:Group;
		
		[SkinPart(required="false")]
		public var colorPicker:HSVColorPicker;
		
		[Bindable]
		public var startColor:uint;
		
		public function DropDownColorPicker()
		{
			super();
			
			if(!getStyle("skinClass"))
				setStyle("skinClass", DropDownColorPickerSkin);
			
			dropDownController = new DropDownController();
		}
		
		override public function get baselinePosition():Number
		{
			return height - getStyle("fontSize");
		}
		
		override protected function initializationComplete():void
		{
			startColor = selectedColor;
			
			super.initializationComplete();
		}
				
		private var _selectedColor:uint = 16777216;
		public function set selectedColor(val:uint):void
		{
			if(val == _selectedColor) return;
			
			_selectedColor = val;
			
			if(colorPicker)
				colorPicker.selectedColor = val;
			
			if(openButton)
				openButton.setStyle("color", val);
		}
		[Bindable]
		public function get selectedColor():uint
		{
			return _selectedColor;
		}
		
		public function get isDropDownOpen():Boolean
		{
			if (dropDownController)
				return dropDownController.isOpen;
			else
				return false;
		}
		
		private var _dropDownController:DropDownController; 
		protected function get dropDownController():DropDownController
		{
			return _dropDownController;
		}
		
		protected function set dropDownController(value:DropDownController):void
		{
			if (_dropDownController == value)
				return;
			
			_dropDownController = value;
			
			_dropDownController.addEventListener(DropDownEvent.OPEN, dropDownController_openHandler);
			_dropDownController.addEventListener(DropDownEvent.CLOSE, dropDownController_closeHandler);
			
			if (openButton)
				_dropDownController.openButton = openButton;
			if (dropDown)
				_dropDownController.dropDown = dropDown;
		}
				
		override protected function getCurrentSkinState():String
		{
			return !enabled ? "disabled" : isDropDownOpen ? "open" : "normal";
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == openButton)
			{
				if(dropDownController)
					dropDownController.openButton = openButton;
				
				openButton.setStyle("color", Math.min(selectedColor, 16777215));
			}
			else if(instance == dropDown && dropDownController)
			{
				dropDownController.dropDown = dropDown;
			}
			else if(instance == startColorGroup)
			{
				startColor = selectedColor;
				startColorGroup.addEventListener(MouseEvent.CLICK, onStartColorClick);
			}
			else if(instance == colorPicker)
			{
				colorPicker.selectedColor = selectedColor;
				colorPicker.addEventListener(ColorPickerEvent.CHANGE, onColorChange);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == startColorGroup)
			{
				startColorGroup.removeEventListener(MouseEvent.CLICK, onStartColorClick);
			}
			else if(instance == colorPicker)
			{
				colorPicker.removeEventListener(ColorPickerEvent.CHANGE, onColorChange);
			}
		}
		
		protected function onStartColorClick(evt:MouseEvent):void
		{
			colorPicker.selectedColor = startColor;
		}
		
		protected function onColorChange(evt:ColorPickerEvent):void
		{
			selectedColor = evt.color;
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, evt.color));
		}
		
		mx_internal function dropDownController_openHandler(event:DropDownEvent):void
		{
			addEventListener(FlexEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
			invalidateSkinState();
		}
		
		mx_internal function open_updateCompleteHandler(event:FlexEvent):void
		{   
			removeEventListener(FlexEvent.UPDATE_COMPLETE, open_updateCompleteHandler);			
			dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
		}
		
		protected function dropDownController_closeHandler(event:DropDownEvent):void
		{
			addEventListener(FlexEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
			invalidateSkinState();
		}
		
		private function close_updateCompleteHandler(event:FlexEvent):void
		{   
			removeEventListener(FlexEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
			dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
		}
	}
}