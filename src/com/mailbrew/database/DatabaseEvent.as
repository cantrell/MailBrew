package com.mailbrew.database
{
	import flash.events.Event;
	
	public class DatabaseEvent
		extends Event
	{
		public static const ERROR_EVENT:String   = "errorEvent";
		public static const RESULT_EVENT:String  = "resultEvent";

		public var data:*;

		public function DatabaseEvent(type:String)
		{
			super(type);
		}
	}
}