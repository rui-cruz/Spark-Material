/**
 * @Author http://saturnboy.com/2009/10/flow-layout/
 */
package spark.material.layouts
{
	import mx.core.ILayoutElement;
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	/**
	 * A custom flow layout based heavily on Evtim's code:
	 * http://evtimmy.com/2009/06/flowlayout-a-spark-custom-layout-example/
	 * 
	 * Assumes all elements have the same height, but different widths are
	 * obviously allowed (it wouldn't be a flow layout otherwise).
	 */
	public class FlowLayout extends LayoutBase {
		private var _border:Number = 10;
		private var _gap:Number = 10;
		
		public function set border(val:Number):void {
			_border = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateDisplayList();
			}
		}
		
		public function set gap(val:Number):void {
			_gap = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateDisplayList();
			}
		}
		
		override public function updateDisplayList(containerWidth:Number, containerHeight:Number):void {
			var x:Number = _border;
			var y:Number = _border;
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			
			//loop through all the elements
			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;
			
			for (var i:int = 0; i < count; i++) {
				var element:ILayoutElement = useVirtualLayout ?
					layoutTarget.getVirtualElementAt(i) :
					layoutTarget.getElementAt(i);
				
				//resize the element to its preferred size by passing in NaN
				element.setLayoutBoundsSize(NaN, NaN);
				
				//get element's size, but AFTER it has been resized to its preferred size.
				var elementWidth:Number = element.getLayoutBoundsWidth();
				var elementHeight:Number = element.getLayoutBoundsHeight();
				
				//does the element fit on this line, or should we move to the next line?
				if (x + elementWidth > containerWidth) {
					//start from the left side
					x = _border;
					
					//move to the next line, and add the gap, but not if it's the first element
					//(this assumes all elements have the same height, but different widths are ok)
					if (i > 0) {
						y += elementHeight + _gap;
					}
				}
				//position the element
				element.setLayoutBoundsPosition(x, y);
				
				//update max dimensions (needed for scrolling)
				maxWidth = Math.max(maxWidth, x + elementWidth);
				maxHeight = Math.max(maxHeight, y + elementHeight);
				
				//update the current pos, and add the gap
				x += elementWidth + _gap;
			}
			
			//set final content size (needed for scrolling)
			layoutTarget.setContentSize(maxWidth + _border, maxHeight + _border);
		}
	}
}
