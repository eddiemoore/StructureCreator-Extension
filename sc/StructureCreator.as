package sc 
{
	import flash.system.Capabilities;
	import sc.FileCreate;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import adobe.utils.*;
	/**
	 * ...
	 * @author Danny Murong, Ed Moore, Shang Liang
	 */
	public class StructureCreator extends MovieClip
	{
		private static const DEFAULT_SCHEMA_URL:String = "http://flashstructurecreator.googlecode.com/svn/trunk/Structure%20Schema.xml";
		private static const DEFAULT_WIDTH:int = 970;
		private static const DEFAULT_HEIGHT:int = 570;
		private static const DEFAULT_FPS:int = 30;
		private static const DEFAULT_CLASS_URL:String = "http://flashstructurecreator.googlecode.com/svn/trunk/templates/Class.as";
		
		private var _mainFolderURL:String;
		private var _schemaURL:String;
		private var _schemaXML:XML;
		private var _xmlLoader:URLLoader;

		private var _classLoader:URLLoader;
		private var _packageInput:String;
		private var _packageArr:Array;
		private var _packageClassName:String;
		private var _packageClassPath:String;
		private var _packageClassURI:String;

		internal static var swfFileName:String;
		
		public function StructureCreator() 
		{
			assignListeners();
			populatePackageInput();
			default_cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		function assignListeners():void
		{
			folder_btn.addEventListener(MouseEvent.CLICK, clickHandler);
			schema_btn.addEventListener(MouseEvent.CLICK, clickHandler);
			create_btn.addEventListener(MouseEvent.CLICK, clickHandler);
			default_cb.addEventListener(MouseEvent.CLICK, clickHandler);
			//edit_btn.addEventListener(MouseEvent.CLICK, clickHandler);
			widthInput_txt.addEventListener(FocusEvent.FOCUS_IN, focusHandler);
			widthInput_txt.addEventListener(FocusEvent.FOCUS_OUT, focusHandler);
			heightInput_txt.addEventListener(FocusEvent.FOCUS_IN, focusHandler);
			heightInput_txt.addEventListener(FocusEvent.FOCUS_OUT, focusHandler);
			framerateInput_txt.addEventListener(FocusEvent.FOCUS_IN, focusHandler);
			framerateInput_txt.addEventListener(FocusEvent.FOCUS_OUT, focusHandler);
			packageInput_txt.addEventListener(FocusEvent.FOCUS_IN, focusHandler);
			packageInput_txt.addEventListener(FocusEvent.FOCUS_OUT, focusHandler);
		}

		function populatePackageInput():void
		{
			_packageInput = new String(packageInput_txt.text);
			_packageArr = _packageInput.split(".");
			_packageClassName = String(_packageArr.pop());
			_packageClassPath = String(_packageArr.join("."));
		}

		function clickHandler(evt:MouseEvent):void
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
				
				case "default_cb":
					if (evt.currentTarget.selected)
					{
						schema_btn.enabled = false;
						//trace("schema_btn.enabled : " +schema_btn.enabled);
						//edit_btn.gotoAndStop(2);
						//trace("DEFAULT");
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
				
				/*case "edit_btn" :
					//default_cb.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					if (MovieClip(evt.currentTarget).currentFrame == 1)
					{
						if (schema_txt.text != "")
						{
							executeJSFL('"openSchema", "' + schema_txt.text + '"');
						}
					}
				break;*/
				
				case "create_btn":
					populatePackageInput();
					
					if (validate())
						startCreation();
				break;
			}
		}

		function focusHandler(evt:FocusEvent):void
		{
			var targetName:String = evt.currentTarget.name;
			
			switch (targetName)
			{
				case "widthInput_txt":
					if (widthInput_txt.text == String(StructureCreator.DEFAULT_WIDTH))
						widthInput_txt.text = "";
					else if (widthInput_txt.text == "")
						widthInput_txt.text = String(StructureCreator.DEFAULT_WIDTH);
				break;
				
				case "heightInput_txt":
					if (heightInput_txt.text == String(StructureCreator.DEFAULT_HEIGHT))
						heightInput_txt.text = "";
					else if (heightInput_txt.text == "")
						heightInput_txt.text = String(StructureCreator.DEFAULT_HEIGHT);
				break;
				
				case "framerateInput_txt":
					if (framerateInput_txt.text == String(StructureCreator.DEFAULT_FPS))
						framerateInput_txt.text = "";
					else if (framerateInput_txt.text == "")
						framerateInput_txt.text = String(StructureCreator.DEFAULT_FPS);
				break;
				
				case "packageInput_txt":
					if (packageInput_txt.text == "Optional")
						packageInput_txt.text = "";
					else if (packageInput_txt.text == "")
						packageInput_txt.text = "Optional";
				break;
			}
		}

		function executeJSFL(commands:String):String
		{
			return MMExecute('fl.runScript(fl.configURI + "WindowSWF/Structure Creator.jsfl", ' + commands + ')');
		}

		function validate():Boolean
		{
			var bool:Boolean = true;

			if (folder_txt.length != 0 && schema_txt.length != 0 && widthInput_txt.length != 0 && heightInput_txt.length != 0 && framerateInput_txt.length != 0)
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

		function startCreation():void
		{
			info_txt.htmlText += "Loading schema... Please wait...\n";
			_xmlLoader = new URLLoader(new URLRequest(_schemaURL));
			_xmlLoader.addEventListener(Event.COMPLETE, completeHandler);
		}

		function completeHandler(evt:Event):void
		{
			info_txt.htmlText += "Loading schema completed!\n";
			_schemaXML = new XML(_xmlLoader.data);
			getFolder(_schemaXML, _mainFolderURL);
		}

		function getFolder(xml:XML, folderPath:String):void
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
			}

			var folderList:XMLList = xml.children();

			for (var i:uint = 0; i < folderList.length(); i++)
			{
				var folderItemXML:XML = folderList[i];

				if (folderItemXML.name() == "folder")
				{
					if (_packageInput.toLowerCase() != "optional" && _packageInput != "")
					{
						for (var j in folderList)
						{
							var na:String = String(folderList[j].@name);
							if (folderList[j].name() == "file")
							{
								var ext:String = na.split(".")[1];
								if (ext.toLowerCase() == "fla")
								{
									createDocClass(folderURI);
									break;
								}
							}
						}
						
					}
					
					getFolder(folderItemXML, folderURI);
				}
				else if (folderItemXML.name() == "file")
				{
					var fileNameExtension:String = String(folderItemXML.@name);
					var fileName:String = fileNameExtension.split(".")[0];
					var fileExtension:String = fileNameExtension.split(".")[1];
					
					if (fileExtension.toLowerCase() == "fla")
					{
						swfFileName = fileName;
						var docClass:String = (_packageInput.toLowerCase() == "optional") ? "" : _packageInput;
						var exportPath:String = String(folderItemXML.@exportpath);
						info_txt.htmlText += executeJSFL('"createFLA", "' + folderURI + '", "' + fileName + '", ' + 3 + ', ' + widthInput_txt.text + ', ' + heightInput_txt.text + ', ' + framerateInput_txt.text + ', "' + docClass + '", "' + exportPath + '"') + "\n";
					}
					else
					{
						info_txt.htmlText += "Loading " + fileNameExtension + " (template)... Please wait...\n";
						new FileCreate(this, fileNameExtension, folderURI, String(folderItemXML.@url));
					}
				}
			}
		}

		function createDocClass(folderURI:String):void
		{
			var folderP = folderURI + "/" + _packageArr[0];
			
			for (var i:int = 0; i < _packageArr.length; i++)
			{
				info_txt.htmlText += executeJSFL('"createFolder", "' + folderP + '", "' + _packageArr[i] + '"') + "\n";
				
				if (i < _packageArr.length - 1)
					folderP = folderP + "/" + _packageArr[i + 1];
			}
			
			_packageClassURI = folderP;
			
			info_txt.htmlText += "Loading Class.as (template)... Please wait...\n";
			_classLoader = new URLLoader(new URLRequest(StructureCreator.DEFAULT_CLASS_URL));
			_classLoader.addEventListener(Event.COMPLETE, packageCompleteHandler);
		}

		function packageCompleteHandler(evt:Event):void
		{
			var classData:String = _classLoader.data;
			classData = classData.replace(/%PACKAGENAME%/g, _packageClassPath);
			classData = classData.replace(/%CLASSNAME%/g, _packageClassName);
			classData = escape(classData);
			info_txt.htmlText += executeJSFL('"createFile", "' + _packageClassURI + '", "' + _packageClassName + ".as" + '", "' + classData + '"') + "\n";
		}
		
	}
	
}