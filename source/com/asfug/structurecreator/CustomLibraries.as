package com.asfug.structurecreator 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Ed Moore
	 */
	public class CustomLibraries extends Sprite
	{
		
		public function CustomLibraries() 
		{
			
		}
		
		public function addCheckbox(cb):void
		{
			addChild(cb);
			bg_mc.height = this.height;
		}
		
		public function setWidth(widthNum:Number):void
		{
			bg_mc.width = widthNum;
		}
		
	}

}