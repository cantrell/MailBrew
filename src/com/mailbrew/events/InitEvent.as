package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class InitEvent extends CairngormEvent
	{
		public static var INIT_EVENT:String = "initEvent";
		
		public function InitEvent()
		{
			super(INIT_EVENT);
		}
	}
}