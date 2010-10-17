package com.asfug.structurecreator
{
	/**
	 * ...
	 * @author Ed Moore
	 */
	
	import flash.display.*;
	import flash.filesystem.*;
	import flash.events.*;
	
	public class SchemaCreator extends MovieClip 
	{
		var directory:File = File.documentsDirectory;
		var saveFile:File = File.documentsDirectory;
		var saveText:String = '';
		
		public function SchemaCreator() 
		{
			browse_btn.addEventListener(MouseEvent.CLICK, browseClicked);
		}
		
		private function browseClicked(e:MouseEvent):void
		{
			try
			{
				directory.browseForDirectory("Select Directory");
				directory.addEventListener(Event.SELECT, directorySelected);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}
		}
		
		function directorySelected(event:Event):void 
		{
			directory = event.target as File;
			templates_txt.text = directory.nativePath;
			
			create_mc.addEventListener(MouseEvent.CLICK, createButtonClicked);
			create_mc.buttonMode = true;
		}
		
		private function createButtonClicked(e:MouseEvent):void
		{
			saveText = '<?xml version="1.0" encoding="utf-8"?>\n';
			checkFolder(directory);
			
			saveSchemaFile();
		}
		
		function checkFolder(dir:File, tabs:int = 1, dirName:String='%BASE%'):void
		{
			saveText += new Array(tabs).join('\t');
			saveText += '<folder name="'+dirName+'">\n';
			var files:Array = dir.getDirectoryListing();
			var len:int = files.length;
			var f:File;
			var u1:String, u2:String, url:String;
			for(var i:uint = 0; i < len; ++i)
			{
				f = files[i];
				if (f.isDirectory)
				{
					checkFolder(f, tabs+1, f.name);
				}
				else
				{
					saveText += new Array(tabs+1).join('\t');
					//var url:String = f.url.replace(/:\/[a-zA-Z0-9]+/,'|/');
					//u1 = f.url.substring(0,f.url.indexOf(':', 5));
					//u2 = f.url.substr(f.url.indexOf(':', 5)+1);
					//url = u1 + '|' + u2;
					saveText += '<file name="'+f.name+'" url="'+f.url+'" />\n';
				}
			}
			saveText += new Array(tabs).join('\t');
			saveText += '</folder>\n';
		}
		
		private function saveSchemaFile():void
		{
			try
			{
				saveFile.browseForSave('Save Schema As');//.browseForDirectory("Select Directory");
				saveFile.addEventListener(Event.SELECT, saveFileSelected);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}
			
		}
		
		private function saveFileSelected(e:Event):void
		{
			//schema_txt.text = e.currentTarget.name;
			//saveFile = saveFile.resolvePath("MySchema.xml");
			var filestream:FileStream = new FileStream();
			filestream.addEventListener(Event.CLOSE, fileWrittenComplete);
			filestream.open(saveFile, FileMode.WRITE);
			filestream.writeUTFBytes(saveText);
			filestream.close();
		}
		
		private function fileWrittenComplete(event:Event):void {
			trace("MySchema.xml has been written to the file system.");
		}
		
	}
	
}