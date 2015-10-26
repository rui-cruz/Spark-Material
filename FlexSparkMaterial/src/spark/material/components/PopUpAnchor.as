package spark.material.components
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.LayoutDirection;
	import mx.utils.MatrixUtil;
	
	import spark.components.PopUpAnchor;
	
	public class PopUpAnchor extends spark.components.PopUpAnchor
	{
		private static var decomposition:Vector.<Number> = new <Number>[0,0,0,0,0];
		
		protected var adjustTop:Number = 0;
		protected var adjustLeft:Number = 0;
		
		public function adjustTopLeft(top:Number=0, left:Number=0):void
		{
			adjustTop = top;
			adjustLeft = left;
			
			updatePopUpTransform();
		}
		
		override protected function calculatePopUpPosition():Point
		{
			// This implementation doesn't handle rotation
			var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
			var matrix:Matrix = MatrixUtil.getConcatenatedMatrix(this, sandboxRoot);
			
			var regPoint:Point = new Point();
			
			if (!matrix)
				return regPoint;
			
			var popUpBounds:Rectangle = new Rectangle(); 
			var popUpAsDisplayObject:DisplayObject = popUp as DisplayObject;
			
			determinePosition(popUpPosition, popUpAsDisplayObject.width, popUpAsDisplayObject.height,
				matrix, regPoint, popUpBounds);
			
			MatrixUtil.decomposeMatrix(decomposition, matrix, 0, 0);
			var concatScaleX:Number = decomposition[3];
			var concatScaleY:Number = decomposition[4];

			popUpBounds.top += adjustTop;
			popUpBounds.bottom += adjustTop;
			popUpBounds.left += adjustLeft;
			popUpBounds.right += adjustLeft;

			// If the popUp still doesn't fit, then nudge it
			// so it is completely on the screen. Make sure to include scale.
			
			if (popUpBounds.top < screen.top)
				regPoint.y += (screen.top - popUpBounds.top) / concatScaleY;
			else if (popUpBounds.bottom > screen.bottom)
				regPoint.y -= (popUpBounds.bottom - screen.bottom) / concatScaleY;
			
			if (popUpBounds.left < screen.left)
				regPoint.x += (screen.left - popUpBounds.left) / concatScaleX;
			else if (popUpBounds.right > screen.right)
				regPoint.x -= (popUpBounds.right - screen.right) / concatScaleX;

			regPoint.x += adjustLeft;
			regPoint.y += adjustTop;
			// Compute the stage coordinates of the upper,left corner of the PopUp, taking
			// the postTransformOffsets - which include mirroring - into account.
			// If we're mirroring, then the implicit assumption that x=left will fail,
			// so we compensate here.
			
			if (layoutDirection == LayoutDirection.RTL)
				regPoint.x += popUpBounds.width;
			return MatrixUtil.getConcatenatedComputedMatrix(this, sandboxRoot).transformPoint(regPoint);
		}
	}
}