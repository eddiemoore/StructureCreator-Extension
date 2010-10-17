package com.asfug 
{
	import flash.display.*;
	import flash.net.FileFilter;
	import flash.text.*;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.events.Event;
	import com.asfug.XMLTransverse;
	import fl.controls.TextArea;
	/**
	 * ...
	 * @author Ed Moore
	 */
	public class StructureCreator extends MovieClip
	{
		var directory:File = File.documentsDirectory;
		var schema_file:File = new File();
		public var infoText:TextArea;
		public static var instance:StructureCreator;
		public static var project_title:String;
		
		public function StructureCreator() 
		{
			instance = this;
			
			infoText = getChildByName('info_txt') as TextArea;
			create_btn.addEventListener(MouseEvent.CLICK, createFolderStructure);
			browse_btn.addEventListener(MouseEvent.CLICK, browseForFolder);
			schema_btn.addEventListener(MouseEvent.CLICK, selectSchema);
			
			new UpdateChecker();
		}

		private function browseForFolder(e:MouseEvent):void
		{
			try
			{
				directory.browseForDirectory("Select Directory");
				directory.addEventListener(Event.SELECT, directorySelected);
			}
			catch (error:Error)
			{
				infoText.text = "Failed: " + error.message;
			}
		}

		private function directorySelected(event:Event):void 
		{
			directory = event.target as File;
			dir_txt.text = directory.nativePath;
		}

		private function selectSchema(e:MouseEvent):void
		{
			//schema_txt.text = "select schema";
			try
			{
				schema_file.browseForOpen("Select Schema", [new FileFilter("Schema XML (*.xml)", "*.xml")]);
				schema_file.addEventListener(Event.SELECT, schemaSelected);
			}
			catch (error:Error)
			{
				infoText.text = "Failed: " + error.message;
			}
		}

		private function schemaSelected(event:Event):void 
		{
			schema_file = event.target as File;
			schema_txt.text = schema_file.nativePath;
		}

		private function createFolderStructure(e:MouseEvent):void 
		{
			project_title = projectname_txt.text;
			infoText.text = directory.url + "\n";
			infoText.appendText(schema_file.url + "\n");
			new XMLTransverse(schema_file.url, directory.url);
		}
		
		public function addInfoText(str:String) {
			infoText.appendText(str + "\n");
		}
	}

}