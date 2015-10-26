package spark.material.components
{
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;

    import spark.components.ButtonBarButton;
    import spark.components.Group;

    [Style(name="inkColor", type="uint", format="Color", inherit="yes", defaultValue="#666666")]
    [Style(name="selectedItemTextColor", type="uint", format="Color", inherit="yes", defaultValue="#106cc8")]

    public class ButtonBarButton extends spark.components.ButtonBarButton
    {
        [SkinPart(required="true")]
        public var inkHolder:Group;

        public var inkColor:uint = 0x999999;

        public function ButtonBarButton()
        {
            super();
        }

        override protected function attachSkin():void
        {
            if(getStyle("inkColor") != undefined)
                inkColor = getStyle("inkColor");

            super.attachSkin();
        }

        private var hasFocus:Boolean;
        override protected function focusInHandler(event:FocusEvent):void
        {
            super.focusInHandler(event);

            focusManager.hideFocus();
            invalidateSkinState();
        }

        override protected function focusOutHandler(event:FocusEvent):void
        {
            super.focusInHandler(event);
            hasFocus = false;
            invalidateSkinState();
        }

        override protected function getCurrentSkinState():String
        {
            if(!hasFocus && focusManager && focusManager.getFocus() == focusManager.findFocusManagerComponent(this))
            {
                hasFocus = true;
                return "over";
            }

            return super.getCurrentSkinState();
        }

        protected var currentRipple:InkRipple;
        override protected function mouseEventHandler(event:Event):void
        {
            super.mouseEventHandler(event);

            if(currentRipple)
                currentRipple.isMouseDown = false;

            if(event.type == MouseEvent.MOUSE_DOWN)
            {
                var rippleRadius:Number = Math.sqrt(width*width+height*height);
                currentRipple = new InkRipple(event["localX"], event["localY"], rippleRadius*2, inkColor, 1200);
                currentRipple.owner = inkHolder;
                inkHolder.addElement(currentRipple);

                systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
            }
        }

        override protected function buttonReleased():void
        {
            super.buttonReleased();

            destroyRipples();
        }

        private function systemManager_mouseUpHandler(event:Event):void
        {
            if (event.target == this) return;

            destroyRipples();
        }

        protected function destroyRipples():void
        {
            for(var i:int=0; i < inkHolder.numElements; i++)
            {
                inkHolder.getElementAt(i)["destroy"](true);
            }
        }
    }
}
