This Extension panel is driven by xml schema, which can be customized to fit specific project requirements. It automatically creates fla, html, css and javascript files 
defined in the schema. It also includes [swfobject 2.2](http://code.google.com/p/swfobject/) and [swfaddress 2.4](http://www.asual.com/swfaddress/) in the default schema. 

Using this extension can effectively streamline new project creation work flow. It only takes a few clicks to achieve which usually takes hours to recreate, duplicate or 
customize from previous projects.

This extension does not serve as a framework. It's purpose is to easily create the structure of files and folders that are used when you start a project. We would also 
like to thank [Steven Sacks](http://www.stevensacks.net/) for his excellent JSFL.

Structure Creator works with Flash CS3, CS4 and now on **CS5**</b> (version 1.3+) on Windows and Mac.
It allows for a custom export path for fla files in the xml schema.
**Default template HTML and CSS files pass the W3C XHTML Strict 1.0 and CSS 2.1 tests.**

New in Version 2.0.1
--------------------
  - Added [TweenMax](http://www.greensock.com/tweenmax/) to package selector

New in Version 2.0.0
--------------------
  - Now has a package selector which includes [Away3d](http://away3d.com), [Papervision3D](http://www.papervision3d.org/), [Tweener](http://code.google.com/p/tweener/), [as3corelib](http://github.com/mikechambers/as3corelib), [Facebook API](http://code.google.com/p/facebook-actionscript-api/), [Mr. Doob's Stats](http://github.com/mrdoob/Hi-ReS-Stats) and [De MonsterDebugger](http://demonsterdebugger.com/).
  - Package selector works with classpath attribute in schema, to place files in correct location.
  - Redesigned
  - Scaleable

New in Version 1.3
------------------
  - Works with **Adobe Flash CS5**
  - Now checks for updates, so you can always have the latest version of Structure Creator.
  - You can now create Flash Builder Project files
  - Can now run without being online


Are you using Structure Creator?
--------------------------------
If you are using Structure Creator please email me [eddie.moore@gmail.com](mailto://eddie.moore@gmail.com) and tell us 
what you think about Structure Creator. Was it useful? What could be improved? You can send the link of the website 
that you have created using Structure Creator, we would love to see it.

![alt text](http://structurecreator.com/images/sc2.0.jpg "StructureCreator")

**Please only download the latest release**

Example Schema
--------------
	<folder name='%BASE%'>
		<folder name='assets' />
		<folder name='docs' />
		<folder name='release'>
			<folder name='css'>
				<file name='style.css' url="http://flashstructurecreator.googlecode.com/svn/trunk/templates/style.css" />
			</folder>
			<folder name='images' />
			<folder name='js'>
				<file name='swfaddress.js' url="http://flashstructurecreator.googlecode.com/svn/trunk/templates/swfaddress.js" />
				<file name='swfobject.js' url="http://flashstructurecreator.googlecode.com/svn/trunk/templates/swfobject.js" />
			</folder>
			<folder name='xml' />
			<file name='index.html' url="http://flashstructurecreator.googlecode.com/svn/trunk/templates/index.html" />
		</folder>
		<folder name='source'>
			<file name='main.fla' exportpath="../release/" />
		</folder>
	</folder>



### Create a folder
	<folder name='XXXXX'></folder>

This will create a folder with the name XXXXX

### Create a file
	<file name='XXXX.XXX' url='http://linktotemplate' />

This will create a file called XXXX.XXX (e.g index.html) based on a template file linked in the url attribute. 
Replace http://linktotemplate with the link to your template file. More information on templates are located below.

When adding a FLA file to your structure use this method
	<file name='main.fla' exportpath="../release/" classpath="../classes/" />

If you don't specify the export path then the swf will export into the same directory as the fla.
If you don't specify the classpath it will assume that the class folders are in the same directory as the fla file.


Templates
---------
If you are creating your own templates there are some variables that can be replaced with values when a new project is created. 
The following, lists current available variables.

+ **%SWFWIDTH%** - Width of swf 
+ **%SWFHEIGHT%** - Height of swf
+ **%SWFHALFWIDTH%** - Half of swf width
+ **%SWFHALFHEIGHT%** - Half of swf height
+ **%SWFNAME%** - Name of swf
+ **%SWFFPS%** - Swf frames per second
+ **%PACKAGENAME%** - Class package (for Document Class)
+ **%CLASSNAME%** - Name of Class (for Document Class)
+ **%PROJECTNAME%** - Name of Project (available in v1.2+)

Example Template for index.html
-------------------------------
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<title>%PROJECTNAME% - Created with Flash Structure Creator</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" type="text/css" href="css/style.css" />
		<script type="text/javascript" src="js/swfobject.js"></script>
		<script type="text/javascript" src="js/swfaddress.js"></script>
		<script type="text/javascript">
			var flashvars = {};
			var params = {menu: 'false'};
			var attributes = {id: '%SWFNAME%'};
			swfobject.embedSWF('%SWFNAME%.swf', '%SWFNAME%', '%SWFWIDTH%', '%SWFHEIGHT%', '9.0.45', 'js/expressinstall.swf', flashvars, params, attributes);
		</script>
	</head>
	<body>
		<div id="container">
			<div id="%SWFNAME%">
				<h1>%PROJECTNAME%</h1>
				<p>In order to view this page you need Flash Player 9+ support!</p>
				<p>
					<a href="http://www.adobe.com/go/getflashplayer">
						<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
					</a>
				</p>
			</div>
		</div>
	</body>
	</html>
