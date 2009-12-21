package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class UpdateAppIconEvent extends CairngormEvent
	{
		public static var UPDATE_APP_ICON_EVENT:String = "updateAppIconEvent";
		
		public function UpdateAppIconEvent()
		{
			super(UPDATE_APP_ICON_EVENT);
		}
	}
}