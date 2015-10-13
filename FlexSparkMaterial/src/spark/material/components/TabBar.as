package spark.material.components
{
import flash.geom.Rectangle;
import flash.geom.Rectangle;

import mx.core.IVisualElement;
import mx.events.FlexEvent;

import spark.components.TabBar;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.Sine;
import spark.primitives.Line;

    public class TabBar extends spark.components.TabBar
    {
        [SkinPart(required="true")]
        public var selectedTabLine:Line;

        public function TabBar()
        {
            //TO-DO: Find the method that validates the selected tab or invalidate on itemSelected to get bounds
            addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete)
        }

        private function onCreationComplete(event:FlexEvent):void
        {
            moveSelectionStroke();
        }

        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
        }

        override public function drawFocus(isFocused:Boolean):void
        {
            // nothing...
        }

        override protected function itemSelected(index:int, selected:Boolean):void
        {
            super.itemSelected(index, selected);

            if(selected)
                moveSelectionStroke();
        }

        private var lineLeftAnimation:Animate;
        private var lineRightAnimation:Animate;

        protected function moveSelectionStroke():void
        {
            if (!dataGroup || (selectedIndex < 0) || (selectedIndex >= dataGroup.numElements)) return;

            var rendererBounds:Rectangle = dataGroup.layout.getElementBounds(selectedIndex);

            if(rendererBounds)
            {
                lineLeftAnimation = new Animate(selectedTabLine);
                lineLeftAnimation.suspendBackgroundProcessing = false;
                lineLeftAnimation.duration = 150;
                lineLeftAnimation.motionPaths = new Vector.<MotionPath>;
                lineLeftAnimation.motionPaths.push(new SimpleMotionPath("left", selectedTabLine.left, rendererBounds.left));

                lineRightAnimation = new Animate(selectedTabLine);
                lineRightAnimation.suspendBackgroundProcessing = false;
                lineRightAnimation.duration = 150;
                lineRightAnimation.motionPaths = new Vector.<MotionPath>;
                lineRightAnimation.motionPaths.push(new SimpleMotionPath("right", selectedTabLine.right, width - rendererBounds.left - rendererBounds.width));

                if(rendererBounds.left < selectedTabLine.left)
                {
                    lineRightAnimation.startDelay = 100;
                    lineLeftAnimation.easer = new Sine(0);
                }
                else
                {
                    lineLeftAnimation.startDelay = 100;
                    lineRightAnimation.easer = new Sine(0);
                }

                lineLeftAnimation.play();
                lineRightAnimation.play();
            }
        }
    }
}
