package com.asfug.structurecreator 
{
	import com.asfug.structurecreator.events.SCEvent;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import fl.containers.ScrollPane;
	import flash.events.Event;
	/**
	 * ...
	 * @author Ed Moore
	 */
	public class Main extends MovieClip
	{
		private var _sc:StructureCreator;
		
		public function Main() 
		{
			stage.align = StageAlign.TOP_LEFT;
			
			masterScroll_mc.setSize(stage.stageWidth, stage.stageHeight);
			_sc = new StructureCreator();
			masterScroll_mc.source = _sc;
			masterScroll_mc.horizontalScrollPolicy = "off";
			masterScroll_mc.refreshPane();
			masterScroll_mc.invalidate();
			
			stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
		}
		
		private function onResize(e:Event):void
		{
			masterScroll_mc.setSize(stage.stageWidth, stage.stageHeight);
			masterScroll_mc.refreshPane();
			masterScroll_mc.invalidate();
			_sc.dispatchEvent(new SCEvent(SCEvent.RESIZE, stage.stageWidth, stage.stageHeight));
		}
		
	}

}