package spark.material.components
{	
	import mx.collections.IList;
	import mx.core.ClassFactory;
	
	import spark.components.SkinnableDataContainer;
	import spark.material.events.ChipsEvent;
	import spark.material.item_renderer.ChipCreatorItemRenderer;
	import spark.material.item_renderer.ChipItemRenderer;
	
	public class Chips extends SkinnableDataContainer
	{	
		public function Chips() {
			super();
		}
		
		override protected function initializationComplete():void {
			super.initializationComplete();
			
			this.itemRendererFunction = selectRenderer;			
			this.addEventListener(ChipsEvent.ADD, onAddChip);
			this.addEventListener(ChipsEvent.REMOVE, onRemoveChip);
		}
		
		override public function set dataProvider(value:IList):void {
			super.dataProvider = value;
			value.addItem(new Object);
		}
		
		private function onAddChip(event:ChipsEvent):void {
			this.addChip(event.item as String);
		}		
		
		private function onRemoveChip(event:ChipsEvent):void {
			var index:int = this.dataProvider.getItemIndex(event.item);
			this.removeChip(index);
		}			
		
		/**
		 * Add new Chip to group
		 * 
		 * @param item
		 */
		private function addChip(item:Object):void {
			// Check if item is empty or already exist
			if(item=="" || this.dataProvider.getItemIndex(item)!=-1) {
				return;
			}
			this.dataProvider.addItemAt(item, this.dataProvider.length-1);
		}
		
		/**
		 * Remove Chip with passed index from group
		 * 
		 * @param index
		 */
		private function removeChip(index:int):void {
			this.dataProvider.removeItemAt(index);
		}
		
		/**
		 * Detect ItemRenderer depending on passed item
		 * 
		 * @param item
		 */
		private function selectRenderer(item:Object):ClassFactory {
			if (this.isChipCreatorItem(item)==true) {
				return  new ClassFactory(ChipCreatorItemRenderer);
			}
			return new ClassFactory(ChipItemRenderer);
		}
		
		/**
		 * Detect if passed item is the (last) Chip creator item
		 * Perhaps it would be better to return always the last item
		 * 
		 * @param item
		 * @return Boolean
		 */
		private function isChipCreatorItem(item:Object):Boolean {
			if(item is String) {
				return false;
			}
			return true;
		}
	}
}
