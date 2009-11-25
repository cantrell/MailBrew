package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class DeleteAccountEvent extends CairngormEvent
	{
		public static var DELETE_ACCOUNT_EVENT:String = "deleteAccountEvent";
		
		public var accountId:Number;
		
		public function DeleteAccountEvent()
		{
			super(DELETE_ACCOUNT_EVENT);
		}
	}
}