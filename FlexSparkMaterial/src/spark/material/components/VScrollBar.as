package spark.material.components
{
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.VScrollBar;
	
	[SkinState("normalAndHovered")]
	
	public class VScrollBar extends spark.components.VScrollBar
	{
		public function VScrollBar()
		{
			super();
			
			addEventListener(FlexEvent.CHANGE_END, onScrollChangeEnd);
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == thumb)
			{
				thumb.addEventListener(MouseEvent.MOUSE_OVER, onMouseInteraction);
				thumb.addEventListener(MouseEvent.MOUSE_OUT, onMouseInteraction);
			}
			else if(instance == track)
			{
				track.addEventListener(MouseEvent.MOUSE_OVER, onMouseInteraction);
				track.addEventListener(MouseEvent.MOUSE_OUT, onMouseInteraction);
			}
		}
		
		private var isOut:Boolean = true;
		private var thumbOver:Boolean;
		private var trackOver:Boolean;
		
		protected function onMouseInteraction(event:MouseEvent):void
		{
			isOut = event.type == MouseEvent.MOUSE_OUT;
			
			if(event.target == thumb)
				thumbOver = event.type == MouseEvent.MOUSE_OVER || event.buttonDown;
			else if(event.target == track)
				trackOver = event.type == MouseEvent.MOUSE_OVER || event.buttonDown;
			
			invalidateSkinState();
		}
		
		protected function onScrollChangeEnd(evt:FlexEvent):void
		{
			if(!isOut) return;
			
			thumbOver = trackOver = false;
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			var skinState:String = super.getCurrentSkinState();
			
			if(skinState == "normal" && (!isOut || thumbOver || trackOver))
				skinState += "AndHovered";
			
			return skinState;
		}
	}
}