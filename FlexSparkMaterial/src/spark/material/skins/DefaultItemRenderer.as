package spark.material.skins
{
	import flash.events.Event;
	
	import spark.skins.spark.DefaultItemRenderer;

	public class DefaultItemRenderer extends spark.skins.spark.DefaultItemRenderer
	{
		public function DefaultItemRenderer()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			//inkGroup
		}
		
		private function interactionStateDetector_changeHandler(event:Event):void
		{
			invalidateDisplayList();
			
			//detect mouseDown
		}		
	}	
}