package com.asfug 
{
	import flash.events.ErrorEvent;
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	//import mx.controls.Alert;

	/**
	 * ...
	 * @author Ed Moore
	 */
	public class UpdateChecker
	{
		private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
		
		public function UpdateChecker() 
		{
			appUpdater.updateURL = "update.xml"; // Server-side XML file describing update
            appUpdater.isCheckForUpdateVisible = false; // We won't ask permission to check for an update
            appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate); // Once initialized, run onUpdate
            appUpdater.addEventListener(ErrorEvent.ERROR, onError); // If something goes wrong, run onError
            appUpdater.initialize(); // Initialize the update framework
		}
		
		private function onError(e:ErrorEvent):void 
		{
			//Alert.show(e.toString());
		}

		private function onUpdate(e:UpdateEvent):void 
		{
			appUpdater.checkNow(); // Go check for an update now
		}
	}

}