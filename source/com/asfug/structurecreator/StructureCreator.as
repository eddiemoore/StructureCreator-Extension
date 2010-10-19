package com.asfug.structurecreator 
{
	import adobe.utils.MMExecute;
	import com.asfug.structurecreator.events.SCEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	//import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import fl.controls.CheckBox;
	/**
	 * ...
	 * @author Ed Moore, Danny Murong, Shang Liang
	 */
	public class StructureCreator extends MovieClip
	{
		private static const CURRENT_VERSION:String = "2.0.0";
		//private static const VERSION_CHECK:String = "http://flashstructurecreator.googlecode.com/svn/trunk/latestversion.txt";
		private static const VERSION_CHECK:String = "http://structurecreator.com/versions/extension/latestversion.txt";
		private static const DEFAULT_SCHEMA_URL:String = "http://flashstructurecreator.googlecode.com/svn/trunk/Structure_Schema_2.xml";
		private static const DEFAULT_PROJECT_NAME:String = "New Project";
		private static const DEFAULT_WIDTH:int = 970;
		private static const DEFAULT_HEIGHT:int = 570;
		private static const DEFAULT_FPS:int = 30;
		private static const DEFAULT_CLASS_URL:String = "Class.as"; // IN CONFIG URI
		private static const DEFAULT_FD_PROJ_URL:String = "Project.as3proj"; // IN CONFIG URI
		private static const FLASH_BUILDER_FILES:Array = [".project", ".actionScriptProperties", "org.eclipse.core.resources.prefs"]; // IN CONFIG URI
		
		private var _savedSettings:SharedObject;
		
		private var _mainFolderURL:String;
		private var _schemaURL:String;
		private var _schemaXML:XML;
		private var _xmlLoader:URLLoader;

		private var _classLoader:URLLoader;
		private var _docclass:String;
		private var _packageArr:Array;
		private var _packageClassName:String;
		internal static var packageClassPath:String;

		internal static var swfFileName:String;
		
		private var _totalFiles:int;
		private var _createdFiles:int;
		private var _otherLibs:Array;
		private var _librariesXML:XML;
		internal static var instance:StructureCreator;
		private var _custLib:CustomLibraries;
		
		public function StructureCreator() 
		{
			instance = this;
			
			init();
			assignListeners();
			
			checkForUpdate();
			
			getPackages();
			
			addEventListener(SCEvent.RESIZE, onResize, false, 0, true);
			//onResize(null);
		}
		
		private function init():void
		{
			_savedSettings = SharedObject.getLocal("structure_creator");
			
			projectname_txt.restrict = 'a-zA-Z0-9. ';
			projectname_txt.text = DEFAULT_PROJECT_NAME;
			
			width_txt.maxChars = 5;
			width_txt.restrict = '0-9';
			
			height_txt.maxChars = 5;
			height_txt.restrict = '0-9';
			
			framerate_txt.maxChars = 3;
			framerate_txt.restrict = '0-9';
			
			docclass_txt.restrict = "a-zA-Z0-9.";
			docclass_txt.text = "Optional";
			
			version_txt.text = 'version ' + CURRENT_VERSION;
		}
		
		private function checkSavedVars():void
		{
			//Schema
			if(_savedSettings.data.lastSchemaValue)
				schema_txt.text = _savedSettings.data.lastSchemaValue;
			
			//Width
			if (_savedSettings.data.newwidth)
				width_txt.text = _savedSettings.data.newwidth;
			else
				width_txt.text = String(DEFAULT_WIDTH);
			
			//Height
			if (_savedSettings.data.newheight)
				height_txt.text = _savedSettings.data.newheight;
			else
				height_txt.text = String(DEFAULT_HEIGHT);
			
			//Framerate
			if (_savedSettings.data.newfps)
				framerate_txt.text = _savedSettings.data.newfps;
			else
				framerate_txt.text = String(DEFAULT_FPS);
			
			//Default Schema Checkbox
			//info_txt.htmlText += "Default: " + _savedSettings.data.defaultCb;
			if (Boolean(_savedSettings.data.defaultCb))
			{
				if (!default_cb.selected)
					default_cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
			else if (Boolean(_savedSettings.data.defaultCb) == false)
			{
				trace("default not selected");
			}
			else
			{
				if (!default_cb.selected)
					default_cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
				
			//Flash Develop Checkbox
			if (Boolean(_savedSettings.data.flashdevelopCb))
			{
				if (!flashdevelop_cb.selected)
					flashdevelop_cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
			else if (Boolean(_savedSettings.data.flashdevelopCb) == false)
			{
				trace("default not selected");
			}
			else
			{
				if (!flashdevelop_cb.selected)
					flashdevelop_cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
				
			//Flash Builder Checkbox
			if (Boolean(_savedSettings.data.flashbuilderCb))
			{
				if (!flashbuilder_cb.selected)
					flashbuilder_cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
			else if (Boolean(_savedSettings.data.flashbuilderCb) == false)
			{
				trace("default not selected");
			}
			else
			{
				if (!flashbuilder_cb.selected)
					flashbuilder_cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
			
			var cb:WidgetCheckbox;
			//var cb:CheckBox;
			for (var i:int = 0; i < _librariesXML.library.length(); i++) 
			{
				cb = _custLib.getChildByName('lib_'+_librariesXML.library[i].@id) as WidgetCheckbox;
				//cb = _custLib.getChildByName('lib_'+_librariesXML.library[i].@id) as CheckBox;
				if (Boolean(_savedSettings.data['lib_' + _librariesXML.library[i].@id]))
				{
					if (!cb.selected)
						cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
				else if (Boolean(_savedSettings.data['lib_' + _librariesXML.library[i].@id]) == false)
				{
					trace("default not selected");
				}
				else
				{
					if (!cb.selected)
						cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
			}
		}
		
		private function assignListeners():void
		{
			folder_btn.addEventListener(MouseEvent.CLICK, clickHandler);
			schema_btn.addEventListener(MouseEvent.CLICK, clickHandler);
			create_btn.addEventListener(MouseEvent.CLICK, clickHandler);
			default_cb.addEventListener(MouseEvent.CLICK, clickHandler);
			flashdevelop_cb.addEventListener(MouseEvent.CLICK, clickHandler);
			flashbuilder_cb.addEventListener(MouseEvent.CLICK, clickHandler);
			
			projectname_txt.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			projectname_txt.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			width_txt.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			width_txt.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			height_txt.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			height_txt.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			framerate_txt.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			framerate_txt.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			docclass_txt.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			docclass_txt.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
		}
		
		private function clickHandler(evt:MouseEvent):void
		{
			var targetName:String = evt.currentTarget.name;
			
			switch (targetName)
			{
				case "folder_btn":
					var op:String = executeJSFL('"getMainFolderURI"');
					if (op != "null")
					{
						_mainFolderURL = op;
						folder_txt.text = _mainFolderURL;
					}
				break;
				
				case "schema_btn":
					var sch:String = executeJSFL('"getSchemaURL"');
					if (sch != "null")
					{
						_schemaURL = sch;
						schema_txt.text = _schemaURL;
					}
				break;
				
				case "flashdevelop_cb":
					
				break;
				
				case "flashbuilder_cb":
					
				break;
				
				case "default_cb":
					if (evt.currentTarget.selected)
					{
						schema_btn.enabled = false;
						_schemaURL = StructureCreator.DEFAULT_SCHEMA_URL;
						schema_txt.text = _schemaURL;
					}
					else
					{
						schema_btn.enabled = true;
						//edit_btn.gotoAndStop(1);
						trace("open");
						schema_txt.text = "";
					}
				break;

				case "create_btn":
					populatePackageInput();
					percent_txt.text = '';
					
					if (validate())
						startCreation();
				break;
			}
		}
		
		private function focusInHandler(evt:FocusEvent):void
		{
			var targetName:String = evt.currentTarget.name;
			
			switch (targetName)
			{
				case "width_txt":
					if (width_txt.text == String(StructureCreator.DEFAULT_WIDTH))
						width_txt.text = "";
				break;
				
				case "height_txt":
					if (height_txt.text == String(StructureCreator.DEFAULT_HEIGHT))
						height_txt.text = "";
				break;
				
				case "framerate_txt":
					if (framerate_txt.text == String(StructureCreator.DEFAULT_FPS))
						framerate_txt.text = "";
				break;
				
				case "projectname_txt":
					if (projectname_txt.text == String(StructureCreator.DEFAULT_PROJECT_NAME))
						projectname_txt.text = "";
				break;
				
				case "docclass_txt":
					if (docclass_txt.text == "Optional")
						docclass_txt.text = "";
				break;
			}
		}
		
		private function focusOutHandler(evt:FocusEvent):void
		{
			var targetName:String = evt.currentTarget.name;
			
			switch (targetName)
			{
				case "width_txt":
					if (width_txt.text == "")
						width_txt.text = String(StructureCreator.DEFAULT_WIDTH);
				break;
				
				case "height_txt":
					if (height_txt.text == "")
						height_txt.text = String(StructureCreator.DEFAULT_HEIGHT);
				break;
				
				case "framerate_txt":
					if (framerate_txt.text == "")
						framerate_txt.text = String(StructureCreator.DEFAULT_FPS);
				break;
				
				case "projectname_txt":
					if (projectname_txt.text == "")
						projectname_txt.text = StructureCreator.DEFAULT_PROJECT_NAME;
				break;
				
				case "docclass_txt":
					if (docclass_txt.text == "")
						docclass_txt.text = "Optional";
				break;
			}
		}
		
		private function populatePackageInput():void
		{
			_docclass = new String(docclass_txt.text);
			_packageArr = _docclass.split(".");
			_packageClassName = String(_packageArr.pop());
			packageClassPath = String(_packageArr.join("."));
		}
		
		private function validate():Boolean
		{
			var bool:Boolean = true;

			if (projectname_txt.length != 0 && folder_txt.length != 0 && schema_txt.length != 0 && width_txt.length != 0 && height_txt.length != 0 && framerate_txt.length != 0)
			{
				info_txt.htmlText = "";
			}
			else
			{
				info_txt.htmlText = "<font color='#FF0000'>* Fill in all fields.</font>";
				bool = false;
			}
			
			return bool;
		}
		
		private function startCreation():void
		{
			_savedSettings.clear();
			_savedSettings.data.lastSchemaValue = schema_txt.text;
			_savedSettings.data.newwidth = width_txt.text;
			_savedSettings.data.newheight = height_txt.text;
			_savedSettings.data.newfps = framerate_txt.text;
			_savedSettings.data.defaultCb = default_cb.selected;
			_savedSettings.data.flashdevelopCb = flashdevelop_cb.selected;
			_savedSettings.data.flashbuilderCb = flashbuilder_cb.selected;
			var cb:WidgetCheckbox;
			//var cb:CheckBox;
			for (var i:int = 0; i < _librariesXML.library.length(); i++) 
			{
				cb = _custLib.getChildByName('lib_'+_librariesXML.library[i].@id) as WidgetCheckbox;
				//cb = _custLib.getChildByName('lib_'+_librariesXML.library[i].@id) as CheckBox;
				_savedSettings.data['lib_' + _librariesXML.library[i].@id] = cb.selected;
			}
			var flushResult:Object = _savedSettings.flush();
			
			info_txt.htmlText += "Loading schema... Please wait...\n";
			_schemaURL = schema_txt.text;
			_xmlLoader = new URLLoader(new URLRequest(_schemaURL));
			_xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, schemaXMLLoadError);
			_xmlLoader.addEventListener(Event.COMPLETE, schemaXMLLoadComplete);
		}
		
		private function schemaXMLLoadError(e:IOErrorEvent):void
		{
			info_txt.htmlText += "<font color='#FF0000'>Error loading schema. Check internet connection.</font>\n";
		}
		
		private function schemaXMLLoadComplete(evt:Event):void
		{
			info_txt.htmlText += "Loading schema completed!\n";
			_schemaXML = new XML(_xmlLoader.data);
			_totalFiles = _schemaXML.descendants('file').length();
			_totalFiles += _schemaXML.descendants('folder').length();
			_createdFiles = 0;
			getFolder(_schemaXML, _mainFolderURL);
		}
		
		private function getFolder(xml:XML, folderPath:String):void
		{
			var folderName:String = String(xml.@name);
			var folderURI:String;
			if (String(Capabilities.os.toLowerCase()).indexOf("mac") == -1)
				folderURI = folderPath + "/";
			else 
				folderURI = folderPath;

			if (folderName != "%BASE%")
			{
				if (String(Capabilities.os.toLowerCase()).indexOf("mac") > -1)
					folderURI = folderPath + "/";
				folderURI += folderName;
				info_txt.htmlText += executeJSFL('"createFolder", "' + folderURI + '", "' + folderName + '"') + "\n";
				updatePercent();
			}
			else
			{
				if (flashdevelop_cb.selected)
				{
					var fd:String = executeJSFL('"getConfigURI"') + "StructureCreator/" + DEFAULT_FD_PROJ_URL;
					new FileCreate(this, projectname_txt.text + '.as3proj', folderURI, fd);
				}
				
				if (flashbuilder_cb.selected)
				{
					var fb:String = executeJSFL('"getConfigURI"') + "StructureCreator/fb/" + FLASH_BUILDER_FILES[0];
					new FileCreate(this, FLASH_BUILDER_FILES[0], folderURI, fb);
					fb = executeJSFL('"getConfigURI"') + "StructureCreator/fb/" + FLASH_BUILDER_FILES[1];
					new FileCreate(this, FLASH_BUILDER_FILES[1], folderURI, fb);
					fb = executeJSFL('"getConfigURI"') + "StructureCreator/fb/" + FLASH_BUILDER_FILES[2];
					info_txt.htmlText += executeJSFL('"createFolder", "' + folderURI + '/.settings", "' + '.settings' + '"') + "\n";
					new FileCreate(this, FLASH_BUILDER_FILES[2], folderURI + '/.settings', fb);
				}
			}

			var folderList:XMLList = xml.children();
			var folderItemXML:XML;
			
			for (var i:uint = 0; i < folderList.length(); i++)
			{
				folderItemXML = folderList[i];

				if (folderItemXML.name() == "folder")
				{	
					getFolder(folderItemXML, folderURI);
				}
				else if (folderItemXML.name() == "file")
				{
					createFile(folderItemXML, folderURI);
				}
			}
		}
		
		private function createFile(folderItemXML:XML, folderURI:String):void 
		{
			var fileNameExtension:String = String(folderItemXML.@name);
			var fileName:String = fileNameExtension.split(".")[0];
			var fileExtension:String = fileNameExtension.split(".")[1];
			
			if (fileExtension.toLowerCase() == "fla")
			{
				swfFileName = fileName;
				var docClass:String = (_docclass.toLowerCase() == "optional") ? "" : _docclass;
				var exportPath:String = String(folderItemXML.@exportpath);
				var classPath:String;
				if (folderItemXML.@classpath == undefined || folderItemXML.@classpath == null)
					classPath = "./";
				else 
					classPath = String(folderItemXML.@classpath);
					
				if (_docclass.toLowerCase() != "optional" && _docclass != "")
				{
					createDocClass(folderURI, classPath);
				}
				
				if (_otherLibs.length > 0)
				{
					createOtherLibraries(folderURI, classPath);
				}
				
				var version:String = executeJSFL('"getFlashVersion"');
				version = String(version.split(" ")[1]).split(",")[0];
				
				if (int(version) > 9)
				{
					var fla = executeJSFL('"createFlashGetProfile", "' + folderURI + '", "' + fileName + '", ' + 3 + ', ' + width_txt.text + ', ' + height_txt.text + ', ' + framerate_txt.text + ', "' + docClass + '", "' + exportPath + '", "' + classPath + '"') + "\n";
					processFlaSettings(String(fla), exportPath, fileName, folderURI, classPath);
				}
				else
				{
					info_txt.htmlText += executeJSFL('"createFLA", "' + folderURI + '", "' + fileName + '", ' + 3 + ', ' + width_txt.text + ', ' + height_txt.text + ', ' + framerate_txt.text + ', "' + docClass + '", "' + exportPath + '", "' + classPath + '"') + "\n";
				}
				//var fla = executeJSFL('"createFlashGetProfile", "' + folderURI + '", "' + fileName + '", ' + 3 + ', ' + width_txt.text + ', ' + height_txt.text + ', ' + framerate_txt.text + ', "' + docClass + '", "' + exportPath + '"') + "\n";
				//processFlaSettings(String(fla), exportPath, fileName, folderURI);
			}
			else
			{
				info_txt.htmlText += "Loading " + fileNameExtension + " (template)... Please wait...\n";
				//info_txt.htmlText += 'url : ' + folderItemXML.@url + '\n';
				if (folderItemXML.@url == null || folderItemXML.@url == undefined)
					new FileCreate(this, fileNameExtension, folderURI, '', folderItemXML.text());
				else
					new FileCreate(this, fileNameExtension, folderURI, String(folderItemXML.@url));
					
			}
		}
		
		private function createOtherLibraries(folderURI:String, classPath:String = './'):void
		{
			if (classPath != './' && classPath.indexOf('../') > -1)
			{
				var folders:Array = folderURI.split("/");
				while (classPath.indexOf('../') > -1)
				{
					folders = folders.slice(0, folders.length - 2);
					classPath = classPath.slice(3);
				}
				folderURI = folders.join('/') + '/' + classPath;
			}
			
			info_txt.text += 'the folder URI for other libs is ' + folderURI + '\n';
			
			var cb:WidgetCheckbox;
			var xml:XML;
			var folderList:XMLList
			var folderItemXML:XML;
			for (var i:int = 0; i < _otherLibs.length; i++) 
			{
				cb = _otherLibs[i] as WidgetCheckbox;
				if (cb.selected)
				{
					xml = _librariesXML.library[i] as XML;
					folderList = xml.children();
					
					for (var j:int = 0; j < folderList.length(); j++) 
					{
						folderItemXML = folderList[j] as XML;
						if (folderItemXML.name() == 'folder')
							getFolder(folderItemXML, folderURI);
						else if (folderItemXML.name() == 'file')
							createFile(folderItemXML, folderURI);
					}
				}
			}
		}
		
		private function processFlaSettings(flaSettings:String, exportPath:String, fileName:String, folderURI:String, classPath:String)
		{
			var xml:XML = new XML(flaSettings);
			xml.PublishFormatProperties.html = "0";
			xml.PublishFormatProperties.defaultNames = "0";
			xml.PublishFormatProperties.flashDefaultName = "0";
			xml.PublishFormatProperties.flashFileName = exportPath + fileName + ".swf";
			
			var types:Object = new Object();
			types.generatorFileName = "swt";
			types.projectorWinFileName = "exe";
			types.projectorMacFileName = "hqx";
			types.htmlFileName = "html";
			types.gifFileName = "gif";
			types.jpegFileName = "jpg";
			types.pngFileName = "png";
			types.qtFileName = "mov";
			types.rnwkFileName = "smil";
		
			// setting the other publish formats to fileName only
			for (var n in types)
				xml.PublishFormatProperties[n] = fileName + '.' + types[n];
			
			xml.PublishFlashProperties.ActionScriptVersion = '3';
			xml.PublishFlashProperties.PackageExportFrame = '1';
			
			var classPath:String;
	
			if (fileName.indexOf("/") > -1)
			{
				classPath = "";
				var splitPath = fileName.split("/");
				splitPath.length--;
				var i = splitPath.length;
				while (i--)
				{
					classPath += "../";
				}
			}
			
			xml.PublishFlashProperties.AS3PackagePaths = classPath + ";.";
			info_txt.htmlText += executeJSFL('"writeProfileXML", "' + escape(xml.toString()) + '", "' + folderURI + '", "' + fileName + '"') + "\n";
		}
		
		private function createDocClass(folderURI:String, classPath:String = './'):void
		{
			if (classPath != './' && classPath.indexOf('../') > -1)
			{
				var folders:Array = folderURI.split("/");
				while (classPath.indexOf('../') > -1)
				{
					folders = folders.slice(0, folders.length - 2);
					classPath = classPath.slice(3);
				}
				folderURI = folders.join('/') + '/' + classPath;
			}
			
			var _packageClassURI = folderURI + "/" + _packageArr[0];
			
			for (var i:int = 0; i < _packageArr.length; i++)
			{
				info_txt.htmlText += executeJSFL('"createFolder", "' + _packageClassURI + '", "' + _packageArr[i] + '"') + "\n";
				
				if (i < _packageArr.length - 1)
					_packageClassURI = _packageClassURI + "/" + _packageArr[i + 1];
			}
			
			info_txt.htmlText += "Loading Class.as (template)... Please wait...\n";
			var cf:String = executeJSFL('"getConfigURI"') + "StructureCreator/" + DEFAULT_CLASS_URL;
			new FileCreate(this, _packageClassName + '.as', _packageClassURI, cf);
		}
		
		public function updatePercent():void
		{
			_createdFiles += 1;
			percent_txt.text = Math.floor((_createdFiles / _totalFiles) * 100) + '%';
			if (_createdFiles >= _totalFiles)
			{
				percent_txt.text = 'Done';
			}
		}
		/**
		 * Execute JSFL
		 * @param	commands	commands to run
		 * @return
		 */
		internal function executeJSFL(commands:String):String
		{
			return MMExecute('fl.runScript(fl.configURI + "StructureCreator/Structure Creator.jsfl", ' + commands + ')');
		}
		
		/**
		 * Checks For Updates
		 */
		private function checkForUpdate():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, updateCheckComplete, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, updateCheckError, false, 0, true);
			loader.load(new URLRequest(VERSION_CHECK));
		}
		
		private function updateCheckError(e:IOErrorEvent):void {}
		
		private function updateCheckComplete(e:Event):void 
		{
			if (e.currentTarget.data != CURRENT_VERSION)
			{
				var update:String = executeJSFL('"versionChanged"');
				if (update == '1')
				{
					navigateToURL(new URLRequest("http://code.google.com/p/flashstructurecreator/"));
				}
			}
		}
		
		
		/**
		 * Get Packages
		 */
		private function getPackages():void
		{
			var loader:URLLoader = new URLLoader();
			var link:String = executeJSFL('"getConfigURI"') + "StructureCreator/libraries.xml";
			loader.addEventListener(Event.COMPLETE, packagesLoaded, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, packageLoadError, false, 0, true);
			loader.load(new URLRequest(link));
		}
		
		private function packageLoadError(e:IOErrorEvent):void {}
		
		private function packagesLoaded(e:Event):void 
		{
			_librariesXML = new XML(e.currentTarget.data);
			var cb:WidgetCheckbox;
			//var cb:CheckBox;
			var yPos:int = 0;
			_otherLibs = [];
			_custLib = new CustomLibraries();
			libraries_scrollpane.source = _custLib;
			for (var i:int = 0; i < _librariesXML.library.length(); i++) 
			{
				cb = new WidgetCheckbox();
				//cb = new CheckBox();
				cb.label = _librariesXML.library[i].@name;
				cb.name = 'lib_' + _librariesXML.library[i].@id;
				cb.y = yPos;
				cb.width = _custLib.width - 16;
				_custLib.addCheckbox(cb);
				_otherLibs.push(cb);
				
				yPos += Math.round(cb.height);
			}
			libraries_scrollpane.refreshPane();
			libraries_scrollpane.invalidate();
			
			checkSavedVars();
		}
		
		private function onResize(e:SCEvent):void 
		{
			create_btn.x = (e.width * 0.5) - (create_btn.width * 0.5);
			percent_txt.x = create_btn.x + create_btn.width + 3;
			
			projectname_txt.width = e.width - 24;
			docclass_txt.width = e.width - 24;
			
			folder_btn.x = e.width - folder_btn.width - 20;
			folder_txt.width = folder_btn.x - folder_txt.x -2; 
			
			schema_btn.x = e.width - schema_btn.width - 20;
			schema_txt.width = schema_btn.x - schema_txt.x -2;
			
			info_txt.width = e.width - 24;
			libraries_scrollpane.width = e.width - 24;
			if (_custLib)
				_custLib.setWidth(e.width - 24);
			version_txt.x = e.width - version_txt.width - 20;
		}
	}

}