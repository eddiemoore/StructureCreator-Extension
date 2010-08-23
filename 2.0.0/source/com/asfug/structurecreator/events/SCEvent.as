package com.asfug.structurecreator.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ed Moore
	 */
	public class SCEvent extends Event 
	{
		public static const RESIZE:String = 'resize';
		private var _width:Number;
		private var _height:Number;
		
		public function SCEvent(type:String, width:Number, height:Number, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			_width = width;
			_height = height;
		} 
		
		public function get width():Number { return _width; }
		
		public function get height():Number { return _height; }
		
	}
	
}