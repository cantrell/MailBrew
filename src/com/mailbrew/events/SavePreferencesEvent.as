package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class SavePreferencesEvent extends CairngormEvent
	{
		public static var SAVE_PREFERENCES_EVENT:String = "savePreferencesEvent";
		
		public var updateInterval:uint;
		public var notificationDisplayInterval:uint;
		public var idleThreshold:uint;
		public var startAtLogin:Boolean;
		
		public function SavePreferencesEvent()
		{
			super(SAVE_PREFERENCES_EVENT);
		}
	}
}