package com.asfug.structurecreator
{
	/**
	 * ...
	 * @author Ed Moore
	 */
	
	import flash.display.*;
	import flash.filesystem.*;
	import flash.events.*;
	
	public class LibraryCreator extends MovieClip 
	{
		var directory:File = File.documentsDirectory;
		var saveFile:File = File.documentsDirectory;
		var saveText:String = '';
		
		public function LibraryCreator() 
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
			saveText = '';
			checkFolder(directory, directory.name);
			
			saveSchemaFile();
		}
		
		function checkFolder(dir:File, dirName:String='%BASE%'):void
		{
			var files:Array = dir.getDirectoryListing();
			var len:int = files.length;
			var f:File;
			//var dir:String = dirName;
			for(var i:uint = 0; i < len; ++i)
			{
				f = files[i];
				if (f.isDirectory)
				{
					checkFolder(f, dirName + '/' + f.name);
				}
				else
				{
					saveText += '<file source="' + dirName + '/' + f.name + '" destination="$flash/StructureCreator/' + dirName + '" />\n';
				}
			}
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