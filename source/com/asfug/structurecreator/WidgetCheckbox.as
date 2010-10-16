package com.asfug.structurecreator
{
    import fl.controls.CheckBox;
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.text.TextFieldAutoSize;
    
    public class WidgetCheckbox extends CheckBox
    {
        
        public function WidgetCheckbox()
        {
        }
        
        override protected function configUI():void 
        {
            super.configUI();
            
            // remove the background movie clip added in the superclass
            removeChild(background);
            
            // redraw the hit area of the checkbox component
            var bg:Shape = new Shape();
            var g:Graphics = bg.graphics;
            g.beginFill(0, 0);
            
            // draw the background area using the width and the height of the 
            // component, instead of hardcoding these properties ( in the
            // superclass the width and height of the rectangle were 100 and 100
            g.drawRect(0, 0, _width, _height);
            
            g.endFill();
            background = bg as DisplayObject;
            
            // add the new background
            addChildAt(background, 0);
        }
        
        override public function set label(value:String):void 
        {
            super.label = value;
            
            // in the superclass the size of the label textfield was set to
            // 100 by 100 px; instead of using these values, autosize the
            // textfield every time a new label is set
            textField.multiline = false;
            textField.autoSize = TextFieldAutoSize.LEFT;
        }
    }
    
}