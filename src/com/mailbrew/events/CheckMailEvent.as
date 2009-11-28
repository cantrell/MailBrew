package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class CheckMailEvent extends CairngormEvent
	{
		public static var CHECK_MAIL_EVENT:String = "checkMailEvent";
		
		public function CheckMailEvent()
		{
			super(CHECK_MAIL_EVENT);
		}
	}
}