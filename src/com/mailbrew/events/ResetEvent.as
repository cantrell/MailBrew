package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class ResetEvent extends CairngormEvent
	{
		public static var RESET_EVENT:String = "resetEvent";
		
		public function ResetEvent()
		{
			super(RESET_EVENT);
		}
	}
}