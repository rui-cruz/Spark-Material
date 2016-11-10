package spark.material.components
{
	import flash.events.MouseEvent;
	
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import spark.components.VScrollBar;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.Power;
	
	use namespace mx_internal;
	
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
		
		private var scrollAnimation:Animate;
		override mx_internal function mouseWheelHandler(event:MouseEvent):void
		{
			if (event.isDefaultPrevented() || !viewport || !viewport.visible) return;
			
			var delta:Number = event.delta;
			var direction:Number = delta < 0 ? 1 : delta > 0 ? -1 : 0;
			var distance:Number = 100;
			var position:Number = viewport.verticalScrollPosition;
						
			if(!scrollAnimation)
			{	
				scrollAnimation = new Animate();
				scrollAnimation.easer = new Power(0, 3.0);
				scrollAnimation.target = viewport;
			}
			else if(scrollAnimation && scrollAnimation.isPlaying)
			{
				scrollAnimation.stop();
				position = (scrollAnimation.motionPaths[0] as SimpleMotionPath).valueTo as Number;
			}
			
			position = Math.max(0, Math.min(position + (distance * direction), maximum));
			scrollAnimation.duration = Math.min(Math.abs(viewport.verticalScrollPosition-position) * 3, 300);
			
			var smoothMotionPath:Vector.<MotionPath> = Vector.<MotionPath>([new SimpleMotionPath("verticalScrollPosition", viewport.verticalScrollPosition, position)]);
			scrollAnimation.motionPaths = smoothMotionPath;
			scrollAnimation.play();
			
			event.preventDefault();
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