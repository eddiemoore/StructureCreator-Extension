/**
 * @Author Danny Murong, Edward Moore, Shang Liang
 * @Code to create fla is based off code by Steven Sacks (http://www.stevensacks.net/)
 */

function getMainFolderURI()
{
	return fl.browseForFolderURL("Select main folder");
}

function getSchemaURL()
{
	return fl.browseForFileURL("open", "Select structure schema");
}

function getDefaultSchemaURL()
{
	return fl.configURI + "WindowSWF/Structure%20Schema.xml";
}

function openSchema(fileURI)
{
	return fl.openDocument(fileURI);
}

function createFile(folderURI, fileName, stringData)
{
	if (FLfile.exists(folderURI + "/" + fileName))
	{
		return "File (" + fileName + ") already exists! Overwrite file.";
	}
		
	FLfile.write(folderURI + "/" + fileName, unescape(stringData));
	return "File (" + fileName + ") created!";
}

function createFolder(folderURI, folderName)
{
	if (FLfile.exists(folderURI))
	{
		return "Folder (" + folderName + ") already exists!";
	}
	else
	{
		FLfile.createFolder(folderURI);
		return "Folder (" + folderName + ") created!";
	}
}

/**
 * @param folderPath	full path of the fla
 * @param fileName		name of the fla
 * @param asVersion		actionscript version 2 or 3 
 */
function createFLA(folderPath, fileName, asVersion, width, height, framerate, documentClass, exportPath)
{
	fl.createDocument();
	fl.getDocumentDOM().frameRate						= framerate;
	fl.getDocumentDOM().width							= width;
	fl.getDocumentDOM().height							= height;
	fl.getDocumentDOM().docClass 						= documentClass;
	fl.getDocumentDOM().getTimeline().layers[0].name	= "as";
	fl.getDocumentDOM().getTimeline().layers[0].locked	= true;
	
	var xml, from, to, delta;

	// export the profile and read it in
	var profilePath = folderPath + "/_Profile_.xml";
	fl.getDocumentDOM().exportPublishProfile(profilePath);
	xml = FLfile.read(profilePath);
	
	// override html to 0
	from = xml.indexOf("<html>");
	to = xml.indexOf("</html>");
	delta = xml.substring(from, to);
	xml = xml.split(delta).join("<html>0");
		
	// override default names to 0
	from = xml.indexOf("<defaultNames>");
	to = xml.indexOf("</defaultNames>");
	delta = xml.substring(from, to);
	xml = xml.split(delta).join("<defaultNames>0");

	// override flash default name to 0
	from = xml.indexOf("<flashDefaultName>");
	to = xml.indexOf("</flashDefaultName>");
	delta = xml.substring(from, to);
	xml = xml.split(delta).join("<flashDefaultName>0");

	// replace the publish path for swf
	from = xml.indexOf("<flashFileName>");
	to = xml.indexOf("</flashFileName>");
	delta = xml.substring(from, to);
	
	var parentPath = "../";
	
	if (fileName.indexOf("/") > -1)
	{
		var splitPath = fileName.split("/");
		splitPath.length--;
		var i = splitPath.length;
		while (i--)
		{
			parentPath += "../";
		}
	}
	
	xml = xml.split(delta).join("<flashFileName>" + exportPath + fileName + ".swf");

	// the other publish formats
	var types = {};
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
	{
		from = xml.indexOf("<" + n + ">");
		to = xml.indexOf("</" + n + ">");
		delta = xml.substring(from, to);
		xml = xml.split(delta).join("<" + n + ">" + fileName + "." + types[n]);
	}

	// make sure package paths look in ./classes, and classes export in frame 1
	from = xml.indexOf("<ActionScriptVersion>");
	to = xml.indexOf("</ActionScriptVersion>");
	delta = xml.substring(from, to);
	xml = xml.split(delta).join("<ActionScriptVersion>" + asVersion);

	from = xml.indexOf("<PackageExportFrame>");
	to = xml.indexOf("</PackageExportFrame>");
	delta = xml.substring(from, to);
	xml = xml.split(delta).join("<PackageExportFrame>1");

	// set package paths based on AS version
	if (asVersion == 2)
	{
		from = xml.indexOf("<PackagePaths>");
		to = xml.indexOf("</PackagePaths>");
	}
	else
	{
		from = xml.indexOf("<AS3PackagePaths>");
		to = xml.indexOf("</AS3PackagePaths>");
	}
	
	delta = xml.substring(from, to);
	
	var classPath = "./";
	
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
	
	if (asVersion == 2)
		xml = xml.split(delta).join("<PackagePaths>" + classPath + "classes");
	else
		xml = xml.split(delta).join("<AS3PackagePaths>" + classPath + "classes" + ";.");
	
	// write the modified profile and import it
	FLfile.write(profilePath, xml);
	fl.getDocumentDOM().importPublishProfile(profilePath);

	// add watermark for fun
	if (fileName == "main")
		watermark();

	// save and publish the fla
	fl.saveDocument(fl.getDocumentDOM(), folderPath + "/" + fileName + ".fla");
	fl.getDocumentDOM().publish();
	
	if (fileName != "main")
		fl.closeDocument(fl.getDocumentDOM());
	
	// delete the publish profile xml (no longer needed)
	FLfile.remove(profilePath);
	
	return "FLA (" + fileName + ") created!";
}


function watermark()
{
	fl.getDocumentDOM().getTimeline().addNewLayer("watermark", "normal", false);
	fl.getDocumentDOM().addNewText({left:0, top:0, right:100, bottom:100} , "» Created by Danny, Edward & Shang!");
	fl.getDocumentDOM().selectAll();
	fl.getDocumentDOM().selection[0].setTextAttr("face", "Verdana");
	fl.getDocumentDOM().selection[0].setTextAttr("fillColor", 0);
	fl.getDocumentDOM().selection[0].setTextAttr("size", "11");	
	fl.getDocumentDOM().selection[0].autoExpand = true;
	fl.getDocumentDOM().selection[0].fontRenderMode = "bitmap";
	fl.getDocumentDOM().selection[0].lineType = "single line";
	fl.getDocumentDOM().selection[0].textType = "static";
	fl.getDocumentDOM().selectNone();
}