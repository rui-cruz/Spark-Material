package spark.material.events
{	
	import flash.events.Event;
	
	public class ChipsEvent extends Event
	{
		public static const REMOVE:String = "Remove";
		public static const ADD:String = "Add";
		private var _item:Object;
		
		public function ChipsEvent(type:String, item:Object=false, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			_item = item;			
		}
		
		public function get item():Object {
			return _item;
		}		
		
		public override function clone():Event {
			return new ChipsEvent(type, item, bubbles, cancelable);
		}		
	}	
}
