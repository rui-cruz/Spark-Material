/**
 * Copy of spark.components.Alert, extending was causing errors..
 */

package spark.material.components
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.EventPhase;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import mx.core.FlexGlobals;
    import mx.core.IFlexDisplayObject;
    import mx.core.IFlexModule;
    import mx.core.IFlexModuleFactory;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.events.CloseEvent;
    import mx.events.FlexEvent;
    import mx.managers.IActiveWindowManager;
    import mx.managers.ISystemManager;
    import mx.managers.PopUpManager;

    import spark.components.Group;
    import spark.components.Panel;
    import spark.components.supportClasses.TextBase;
    import spark.material.skins.AlertSkin;

    use namespace mx_internal;

    [Style(name="buttonStyleName", type="String", inherit="no")]
    [Style(name="messageStyleName", type="String", inherit="no")]
    [Style(name="titleStyleName", type="String", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

//[AccessibilityClass(implementation="mx.accessibility.AlertAccImpl")]

    [RequiresDataBinding(true)]

    //[ResourceBundle("controls")]

    public class Alert extends Panel
    {
        [Inspectable(category="Size")]

        public static var buttonHeight:Number = 21;
        [Inspectable(category="Size")]

        public static var buttonWidth:Number = 65;

        public static function show(message:String = "", title:String = "",
                                    buttonLabels:Vector.<String> = null /* Alert.OK */,
                                    parent:Sprite = null,
                                    closeHandler:Function = null,
                                    iconClass:Class = null,
                                    defaultButtonIndex:uint = 0 /* Alert.OK */,
                                    modal:Boolean = true,
                                    moduleFactory:IFlexModuleFactory = null,
                                    parameters:Array = null):Alert {
            //                      var modal:Boolean =(flags & Alert.NONMODAL) ? false : true;

            if (!parent) {
                var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
                // no types so no dependencies
                var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
                if (mp && mp.useSWFBridge())
                    parent = Sprite(sm.getSandboxRoot());
                else
                    parent = Sprite(FlexGlobals.topLevelApplication);
            }

            var alert:Alert = new Alert();
            alert.buttonLabels = ( buttonLabels ) ? buttonLabels : Vector.<String>(["OK"]);
            alert.defaultButtonIndex = defaultButtonIndex;

            alert.message = message;
            alert.title = title;
            alert.iconClass = iconClass;
            alert.parameters = parameters;

            if (closeHandler != null)
                alert.addEventListener(CloseEvent.CLOSE, closeHandler);

            // Setting a module factory allows the correct embedded font to be found.
            if (moduleFactory)
                alert.moduleFactory = moduleFactory;
            else if (parent is IFlexModule)
                alert.moduleFactory = IFlexModule(parent).moduleFactory;
            else {
                if (parent is IFlexModuleFactory)
                    alert.moduleFactory = IFlexModuleFactory(parent);
                else
                    alert.moduleFactory = FlexGlobals.topLevelApplication.moduleFactory;

                // also set document if parent isn't a UIComponent
                if (!parent is UIComponent)
                    alert.document = FlexGlobals.topLevelApplication.document;
            }

            alert.addEventListener(FlexEvent.CREATION_COMPLETE, static_creationCompleteHandler);
            PopUpManager.addPopUp(alert, parent, modal);

            return alert;
        }

        public function Alert() {
            super();
            // Panel properties.
            title = "";
            message = "";

            if (!getStyle("skinClass"))
                setStyle("skinClass", AlertSkin);
        }

        public var parameters:Array;
        [SkinPart(required="false")]
        public var messageDisplay:TextBase;
        [SkinPart(required="false")]
        public var buttonGroup:Group;
        [SkinPart(required="false")]
        public var iconGroup:Group;
        [SkinPart(required="false")]
        public var topGroup:Group;
        protected var _buttonLabelsChanged:Boolean;

        //----------------------------------
        //  defaultButtonFlag
        //----------------------------------
        [Inspectable(category="Other")]

        protected var _iconClassChanged:Boolean;
        private var _defaultButtonChanged:Boolean;
        private var _buttons:Vector.<Button>;
        private var _icon:UIComponent;

        //----------------------------------
        //  iconClass
        //----------------------------------

        override public function set initialized(value:Boolean):void {
            super.initialized = value;

            setButtonFocus();
        }

        protected var _buttonLabels:Vector.<String>;

        public function get buttonLabels():Vector.<String> {
            return _buttonLabels;
        }

        public function set buttonLabels(value:Vector.<String>):void {
            if (_buttonLabels == value) return;

            _buttonLabels = value;
            _buttonLabelsChanged = true;

            invalidateProperties();
        }

        //----------------------------------
        //  text
        //----------------------------------

        [Inspectable(category="General")]

        private var _defaultButtonIndex:uint = 0;

        public function get defaultButtonIndex():int {
            return _defaultButtonIndex;
        }

        public function set defaultButtonIndex(value:int):void {
            if (_defaultButtonIndex == value) return;

            _defaultButtonIndex = value;
            _defaultButtonChanged = true;

            invalidateProperties();
        }

        private var _iconClass:Class;

        public function get iconClass():Class {
            return _iconClass;
        }

        public function set iconClass(value:Class):void {
            if (_iconClass == value) return;

            _iconClass = value;
            _iconClassChanged = true;

            invalidateProperties();
        }

        [Inspectable(category="General")]

        protected var _message:String;

        public function get message():String {
            return _message;
        }

        public function set message(value:String):void {
            if (_message == value) return;

            _message = value
            if (messageDisplay) messageDisplay.text = _message;
        }

        override protected function initializeAccessibility():void {
            if (Alert.createAccessibilityImplementation != null)
                Alert.createAccessibilityImplementation(this);
        }

        override public function styleChanged(styleProp:String):void {
            super.styleChanged(styleProp);

            var all:Boolean = ( !styleProp || styleProp == "styleName" )
            if (( all || styleProp == "buttonStyleName" ) && _buttons) {
                var buttonStyleName:String = getStyle("buttonStyleName");

                var n:int = _buttons.length;
                for (var i:int = 0; i < n; i++) {
                    _buttons[i].styleName = buttonStyleName;
                }
            }

            if (( all || styleProp == "messageStyleName" ) && messageDisplay) {
                var messageStyleName:String = getStyle("messageStyleName");
                messageDisplay.styleName = messageStyleName;
            }
        }

        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            if (partName == "buttonGroup")
                createButtons(Group(instance));
            else if (partName == "messageDisplay") {
                messageDisplay.text = message;
                messageDisplay.styleName = getStyle("messageStyleName");
            }
            else if (partName == "iconDisplay")
                createIcon(Group(instance));
            else if (partName == "topGroup")
                addDragEvent(Group(instance));
        }

        override protected function partRemoved(partName:String, instance:Object):void {
            super.partAdded(partName, instance);
            if (partName == "buttonGroup") destroyButtons(Group(instance));
            else if (partName == "iconDisplay") destroyIcon(Group(instance));
            else if (partName == "topGroup") removeDragEvent(Group(instance));
        }

        override protected function commitProperties():void {
            super.commitProperties();

            if (_buttonLabelsChanged) {
                destroyButtons(buttonGroup);
                createButtons(buttonGroup);
            }

            if (_iconClassChanged) {
                _iconClassChanged = false;

                destroyIcon(iconGroup);

                var icon:DisplayObject = new iconClass();
                _icon = new UIComponent();
                _icon.addChild(icon);
                _icon.width = icon.width;
                _icon.height = icon.height;

                createIcon(iconGroup);
            }

            if (_defaultButtonChanged) setButtonFocus();
        }

        protected function addDragEvent(container:Group):void {
            if (!container)  return;

            container.addEventListener(MouseEvent.MOUSE_DOWN, onTopGroupMouseDown);
        }

        protected function removeDragEvent(container:Group):void {
            if (!container)  return;

            container.removeEventListener(MouseEvent.MOUSE_DOWN, onTopGroupMouseDown);
        }

        protected function createIcon(container:Group):void {
            if (!container || !_icon) return;

            container.visible = true;
            container.includeInLayout = true;
            container.addElement(_icon);
        }

        protected function destroyIcon(container:Group):void {
            if (!container || !_icon) return;

            if (_icon.parent == container)
            {
                container.removeElement(_icon);
                container.visible = false;
                container.includeInLayout = false;
            }
            _icon = null;
        }

        protected function createButtons(container:Group):void {
            _buttonLabelsChanged = false;
            //                      _defaultButtonChanged =false;

            if (!container || !buttonLabels) return;

            _buttons = new Vector.<Button>();

            var button:Button;
            var numButtons:int = buttonLabels.length;
            for (var i:int = 0; i < numButtons; i++) {
                button = new Button();
                button.focusEnabled = true;
                button.setStyle("buttonStyle", "flat");
                button.setStyle("inkColor", 0x82bfff);
                button.setStyle("color", 0x025aa3);
                button.label = buttonLabels[i];
                button.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);
                button.addEventListener(KeyboardEvent.KEY_DOWN, onButtonKeyDown, false, 0, true);

                container.addElement(button);
                //                              button.setActualSize(Alert.buttonWidth, Alert.buttonHeight);
                _buttons.push(button);
            }

            setButtonFocus();
        }

        protected function destroyButtons(container:Group):void {
            if (!_buttons)
                return;

            var button:Button;
            var numButtons:int = _buttons.length;
            for (var i:int = 0; i < numButtons; i++) {
                button = _buttons[i];
                button.removeEventListener(MouseEvent.CLICK, onButtonClick, false);
                button.removeEventListener(KeyboardEvent.KEY_DOWN, onButtonKeyDown, false);
                if (container) container.removeElement(button);
            }

            _buttons = null;
        }

        private function removeAlert(index:int):void {
            visible = false;
            dispatchEvent(new CloseEvent(CloseEvent.CLOSE, false, false, index));

            PopUpManager.removePopUp(this);

            if (_buttons) destroyButtons(buttonGroup);
        }

        private function setButtonFocus():void {
            if (!initialized) return;

            var sm:ISystemManager = systemManager;
            var awm:IActiveWindowManager = IActiveWindowManager(sm.getImplementation("mx.managers::IActiveWindowManager"));
            if (awm) awm.activate(this);

            _defaultButtonChanged = false;
            if (_buttons) {
                if (_defaultButtonIndex >= 0 && _defaultButtonIndex < _buttons.length - 1) {
                    _buttons[_defaultButtonIndex].setFocus();
                    _buttons[_defaultButtonIndex].drawFocus(true);
                }
            }
        }

        protected function onTopGroupMouseDown(event:MouseEvent):void {
            startDrag(false, parent.getBounds(stage));
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
        }

        protected function onStageMouseUp(event:MouseEvent):void {
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            stopDrag();
        }

        protected function onButtonClick(event:MouseEvent):void {
            removeAlert(buttonGroup.getElementIndex(Button(event.currentTarget)));
        }

        protected function onButtonKeyDown(event:KeyboardEvent):void {
            if (event.keyCode == Keyboard.ENTER) removeAlert(_buttons.indexOf(event.currentTarget));
        }

        private static function static_creationCompleteHandler(event:FlexEvent):void {
            if (event.target is IFlexDisplayObject && event.eventPhase == EventPhase.AT_TARGET) {
                var alert:Alert = Alert(event.target);
                alert.removeEventListener(FlexEvent.CREATION_COMPLETE, static_creationCompleteHandler);

                alert.setActualSize(alert.getExplicitOrMeasuredWidth(),
                        alert.getExplicitOrMeasuredHeight());
                PopUpManager.centerPopUp(alert);
            }
        }

        mx_internal static var createAccessibilityImplementation:Function;

    }

}
