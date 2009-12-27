package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class ReorderAccountsEvent extends CairngormEvent
	{
		public static var REORDER_ACCOUNTS_EVENT:String = "reorderAccountsEvent";
		
		public var accountData:Array;
		
		public function ReorderAccountsEvent()
		{
			super(REORDER_ACCOUNTS_EVENT);
		}
	}
}