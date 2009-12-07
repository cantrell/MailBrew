package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class AppExitEvent extends CairngormEvent
	{
		public static var APP_EXIT_EVENT:String = "appExitEvent";
		
		public function AppExitEvent()
		{
			super(APP_EXIT_EVENT);
		}
	}
}