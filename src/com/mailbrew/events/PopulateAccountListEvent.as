package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class PopulateAccountListEvent extends CairngormEvent
	{
		public static var POPULATE_ACCOUNT_LIST_EVENT:String = "populateAccountListEvent";
		
		public function PopulateAccountListEvent()
		{
			super(POPULATE_ACCOUNT_LIST_EVENT);
		}
	}
}
