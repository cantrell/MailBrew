package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class PopulateAccountInfoEvent extends CairngormEvent
	{
		public static var POPULATE_ACCOUNT_INFO_EVENT:String = "populateAccountInfoEvent";
		
		public var accountId:Number;
		
		public function PopulateAccountInfoEvent()
		{
			super(POPULATE_ACCOUNT_INFO_EVENT);
		}
	}
}