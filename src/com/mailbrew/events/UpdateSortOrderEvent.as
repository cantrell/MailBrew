package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class UpdateSortOrderEvent extends CairngormEvent
	{
		public static var UPDATE_SORT_ORDER_EVENT:String = "updateSortOrderEvent";
		
		public var accountId:Number;
		public var sortOrder:Number;
		
		public function UpdateSortOrderEvent()
		{
			super(UPDATE_SORT_ORDER_EVENT);
		}
	}
}