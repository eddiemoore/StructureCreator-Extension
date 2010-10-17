package com.asfug
{
	/**
	 * ...
	 * @author Ed Moore
	 */
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import fl.controls.TextArea;
	
	public class XMLTransverse extends MovieClip 
	{
		private static var _xmlUrl:String = '';
		private static var _directory:String = '';
		private var _xmlLoader:URLLoader;
		
		public function XMLTransverse(schema_xml:String, directory:String) 
		{
			_xmlUrl = schema_xml;
			_directory = directory;
			
			StructureCreator.instance.addInfoText("Start Creation");
			
			loadXML();
		}
		
		private function loadXML():void
		{
			StructureCreator.instance.addInfoText("load the xml " + _xmlUrl);
			_xmlLoader = new URLLoader();
			_xmlLoader.addEventListener(Event.COMPLETE, hComplete);
			_xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, secError);
			_xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, hError);
			_xmlLoader.load(new URLRequest(_xmlUrl));
		}
		
		private function secError(e:SecurityErrorEvent):void 
		{
			StructureCreator.instance.addInfoText("security error: " + e);
		}
		
		private function hComplete(e:Event):void 
		{
			StructureCreator.instance.addInfoText('load xml complete');
			_xmlLoader.removeEventListener(Event.COMPLETE, hComplete);
			_xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR, hError);
			
			var xml:XML = new XML(e.currentTarget.data);
			trace(xml.folder.length());
			StructureCreator.instance.addInfoText(xml.folder.length());
			createStructure(xml);
		}
		
		private function createStructure(xml:XML, path:String = '/'):void
		{
			var currPath:String = path;
			StructureCreator.instance.addInfoText(currPath);
			var file:File;
			var url:String;
			var quality:String;
			for (var j:int = 0; j < xml.file.length(); j++) 
			{
				trace("create file: " + xml.file[j].@name);
				StructureCreator.instance.addInfoText("create file: " + xml.file[j].@name);
				url = xml.file[j].@url;
				quality = xml.file[j].@quality;
				quality = quality == '' ? '80' : quality;
				
				new FileCreate(_directory + currPath, xml.file[j].@name, url, xml.file[j].text(), uint(quality));
			}
			var dir:File;
			for (var i:int = 0; i < xml.folder.length(); ++i)
			{
				trace("create folder : " + xml.folder[i].@name);
				StructureCreator.instance.addInfoText("create folder : " + xml.folder[i].@name);
				dir = new File();
				dir.url = _directory + currPath;
				dir = dir.resolvePath(xml.folder[i].@name);
				dir.createDirectory();
				
				if (xml.folder[i].folder.length() > 0 || xml.folder[i].file.length() > 0)
				{
					createStructure(xml.folder[i] as XML, currPath + xml.folder[i].@name + '/');
				}
			}
			
		}
		
		private function hError(e:IOErrorEvent):void 
		{
			StructureCreator.instance.addInfoText("load xml error: " + e + "\n");
			trace("Error: " + e);
		}
		
	}
	
}