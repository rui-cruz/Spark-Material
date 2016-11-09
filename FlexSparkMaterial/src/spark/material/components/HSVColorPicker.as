package spark.material.components
{	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;

	[Event(name="change", type="flash.events.ColorPickerEvent")]
	
	public class HSVColorPicker extends UIComponent
	{
		[Embed(source="/spark/material/assets/graphics/colorCursor.png")]
		public var colorCursor:Class;
		
		private var cursorBitmap:BitmapAsset;
		public function HSVColorPicker()
		{
			minWidth = 150;
			minHeight = 100;
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		override protected function initializationComplete():void
		{
			super.initializationComplete();
			
			colorHSV = new ColorHSV();
			colorHSV.fromUint(selectedColor);
			hex = colorHSV.toHEX();
			hue = colorHSV.h;
			
			cursorBitmap = new colorCursor();
			cursorBitmap.x = (colorHSV.s * minWidth) - 6;
			cursorBitmap.y = ((1-colorHSV.v) * minHeight) - 6;
			addChild(cursorBitmap);
			
			draw();
		}
		
		private var _hue:int;
		public function set hue(angle:int):void
		{
			_hue = angle;
			
			if(angle == colorHSV.h) return;
			
			colorHSV.h = angle;
			selectedColor = colorHSV.toUint();
			hex = colorHSV.toHEX();
			
			draw();
			
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, selectedColor));
		}
		[Bindable]
		public function get hue():int
		{
			return _hue;
		}
		
		private var _selectedColor:uint;
		public function set selectedColor(color:uint):void
		{
			_selectedColor = color;
			
			if(!colorHSV || color == colorHSV.toUint()) return;
			
			colorHSV.fromUint(color);
			hue = colorHSV.h;
			draw();
			
			cursorBitmap.x = (colorHSV.s * minWidth) - 6;
			cursorBitmap.y = ((1-colorHSV.v) * minHeight) - 6;
			
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, selectedColor));
		}
		[Bindable]
		public function get selectedColor():int
		{
			return _selectedColor;
		}
		
		private var _hex:String;
		public function set hex(value:String):void
		{
			_hex = value;
			
			if(value == colorHSV.toHEX()) return;
			
			colorHSV.fromHEX(value);
			selectedColor = colorHSV.toUint();
			hue = colorHSV.h;
			draw();
			
			cursorBitmap.x = (colorHSV.s * minWidth) - 6;
			cursorBitmap.y = ((1-colorHSV.v) * minHeight) - 6;
			
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, selectedColor));
		}
		[Bindable]
		public function get hex():String
		{
			return _hex;
		}
		
		private var cursorId:int;
		
		private function onMouseDown(evt:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			cursorManager.removeCursor(cursorId);
			cursorManager.hideCursor();
			
			var point:Point = globalToLocal(new Point(evt.stageX, evt.stageY));
			
			var colorX:int = Math.min(Math.max(0, point.x), width);
			var colorY:int = Math.min(Math.max(0, point.y), height);
			
			cursorBitmap.x = colorX - 6;
			cursorBitmap.y = colorY - 6;
			
			colorHSV.hsv(colorHSV.h, colorX / width, 1-(colorY / height));
			selectedColor = colorHSV.toUint();
			
			hex = colorHSV.toHEX();
			
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, selectedColor));
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			if(!evt.buttonDown) return;
						
			var point:Point = globalToLocal(new Point(evt.stageX, evt.stageY));
			
			var colorX:int = Math.min(Math.max(0, point.x), width);
			var colorY:int = Math.min(Math.max(0, point.y), height);
			
			cursorBitmap.x = colorX - 6;
			cursorBitmap.y = colorY - 6;
			
			colorHSV.hsv(colorHSV.h, colorX / width, 1-(colorY / height));
			selectedColor = colorHSV.toUint();
			
			hex = colorHSV.toHEX();
			
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, selectedColor));
		}
		
		private function onMouseUp(evt:MouseEvent):void
		{
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			cursorManager.showCursor();
		}		
		
		private var colorHSV:ColorHSV;
		
		private var lastUnscaledWidth:Number = 0;
		override protected function updateDisplayList(_unscaledWidth:Number, _unscaledHeight:Number):void
		{
			if(lastUnscaledWidth != _unscaledWidth)
			{
				lastUnscaledWidth = _unscaledWidth;
				draw();
			}
			
			super.updateDisplayList(_unscaledWidth, _unscaledHeight);
		}
		
		private var colorSwatch:BitmapData;
		protected function draw():void
		{
			if(width == 0 || height == 0 || !graphics) return;
			
			graphics.clear();
			
			colorSwatch = new BitmapData(width, height, false, 0);
			colorSwatch.lock();
			
			for(var y:int = 0; y <= height; y++)
			{
				for(var x:int = 0; x <= width; x++)
				{
					colorSwatch.setPixel(x, y, (new ColorHSV(hue, x/width, 1-(y/height))).toUint());
				}
			}
			
			colorSwatch.unlock();
			
			graphics.beginBitmapFill(colorSwatch, null, false, false);
			graphics.drawRect(0,0, width, height );
			graphics.endFill();	
		}
	}
}

class ColorHSV
{	
	private var _r:Number;
	private var _g:Number;
	private var _b:Number;
	
	private var _h:Number;	//Hue
	private var _s:Number;	//Saturation
	private var _v:Number;	//Value | Brightness
	
	private var _a:Number;
	/**
	 * @param	h_	Hue (degree 360)
	 * @param	s_	Saturation [0.0,1.0]
	 * @param	v_	Brightness [0.0,1.0]
	 * @param	a	Alpha [0.0,1.0]
	 */
	public function ColorHSV( h:Number=0.0, s:Number = 1.0, v:Number = 1.0, a:Number = 1.0  ) 
	{
		hsv( h, s, v );
		_a = a;
	}
	
	public function get h():Number { return _h; }
	public function set h( value:Number ):void
	{
		_h = value;
	}

	public function get hr():Number { return Math.PI*_h / 180; }
	public function set hr( value:Number ):void
	{
		_h = 180*value/Math.PI;
	}
	
	public function get s():Number { return _s; }
	public function set s( value:Number ):void
	{
		if ( value > 1.0 ) { _s = 1.0; } else if ( value < 0.0 ) { _s = 0.0; } else { _s = value; }
	}
	
	public function get v():Number { return _v; }
	public function set v( value:Number ):void
	{
		if ( value > 1.0 ) { _v = 1.0; } else if ( value < 0.0 ) { _v = 0.0; } else { _v = value; }
	}
	
	//------------------------------------------------------------------------------------------------------------------- SET
	
	/**
	 * @param	h	Hue (degree 360)
	 * @param	s	Saturation [0.0,1.0]
	 * @param	v	Brightness [0.0,1.0]
	 */
	public function hsv( h:Number, s:Number = 1.0, v:Number = 1.0 ):void
	{
		_h = h;
		if ( s > 1.0 ) { _s = 1.0; } else if ( s < 0.0 ) { _s = 0.0; } else { _s = s; }
		if ( v > 1.0 ) { _v = 1.0; } else if ( v < 0.0 ) { _v = 0.0; } else { _v = v; }
		
		update_rgb();
	}
	
	//------------------------------------------------------------------------------------------------------------------- update
	
	/**
	 * HSV to RGB
	 * @private
	 */
	protected function update_rgb():void 
	{
		if ( _s > 0 ){
			var h:Number = ((_h < 0) ? _h % 360 + 360 : _h % 360 ) / 60;
			if ( h < 1 ) {
				_r = Math.round( 255*_v );
				_g = Math.round( 255*_v * ( 1 - _s * (1 - h) ) );
				_b = Math.round( 255*_v * ( 1 - _s ) );
			}else if ( h < 2 ) {
				_r = Math.round( 255*_v * ( 1 - _s * (h - 1) ) );
				_g = Math.round( 255*_v );
				_b = Math.round( 255*_v * ( 1 - _s ) );
			}else if ( h < 3 ) {
				_r = Math.round( 255*_v * ( 1 - _s ) );
				_g = Math.round( 255*_v );
				_b = Math.round( 255*_v * ( 1 - _s * (3 - h) ) );
			}else if ( h < 4 ) {
				_r = Math.round( 255*_v * ( 1 - _s ) );
				_g = Math.round( 255*_v * ( 1 - _s * (h - 3) ) );
				_b = Math.round( 255*_v );
			}else if ( h < 5 ) {
				_r = Math.round( 255*_v * ( 1 - _s * (5 - h) ) );
				_g = Math.round( 255*_v * ( 1 - _s ) );
				_b = Math.round( 255*_v );
			}else{
				_r = Math.round( 255*_v );
				_g = Math.round( 255*_v * ( 1 - _s ) );
				_b = Math.round( 255*_v * ( 1 - _s * (h - 5) ) );
			}
		}else{
			_r = _g = _b = Math.round( 255*_v );
		}
	}
	
	protected function apply_rgb():void 
	{
		if( _r!=_g || _r!=_b ){
			if ( _g > _b ) {
				if ( _r > _g ) { //r>g>b
					_v = _r/255;  
					_s = (_r - _b) / _r;
					_h = 60 * (_g - _b) / (_r - _b);
				}else if( _r < _b ){ //g>b>r
					_v = _g/255;
					_s = (_g - _r) / _g;
					_h = 60 * (_b - _r) / (_g - _r) + 120;
				}else { //g=>r=>b
					_v = _g/255;
					_s = (_g - _b)/_g;
					_h = 60 * (_b - _r) / (_g - _b) + 120;
				}
			}else{
				if ( _r > _b ) { // r>b=>g
					_v = _r/255;
					_s = (_r - _g) / _r;
					_h = 60 * (_g - _b) / (_r - _g);
					if ( _h < 0 ) _h += 360;
				}else if ( _r < _g ){ //b=>g>r
					_v = _b/255;
					_s = (_b - _r) / _b;
					_h = 60 * (_r - _g)/(_b - _r) + 240;
				}else { //b=>r=>g
					_v = _b/255;
					_s = (_b - _g) / _b;
					_h = 60 * (_r - _g)/(_b - _g) + 240;
				}
			}
		}else {
			_h = _s = 0;
			_v = _r/255;
		}
	}
	
	public function fromHEX(val:String):void
	{
		if(val.indexOf("#") != -1)
			val = val.substr(val.indexOf("#")+1);
		
		fromUint(parseInt(val, 16));
	}
	
	public function fromUint(val:uint):void
	{
		_r = (val >> 16) & 255;
		_g = (val >> 8) & 255;
		_b = val & 255;
		
		apply_rgb();
	}
	
	public function toUint():uint
	{
		update_rgb();
		
		return _r << 16 | _g << 8 | _b; 
	}
	
	public function toHEX():String
	{
		update_rgb();
		
		return componentToHex(_r) + componentToHex(_g) + componentToHex(_b);
		
		function componentToHex(val:Number):String
		{
			var hex:String = val.toString(16);
			return hex.length == 1 ? "0" + hex : hex;
		}
	}
}