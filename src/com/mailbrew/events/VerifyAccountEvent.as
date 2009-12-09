package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class VerifyAccountEvent extends CairngormEvent
	{
		public static var VERIFY_ACCOUNT_EVENT:String = "verifyAccountEvent";
		
		public var accountType:String;
		public var username:String;
		public var password:String;
		public var portNumber:Number;
		public var server:String;
		public var secure:Boolean;
		
		public function VerifyAccountEvent()
		{
			super(VERIFY_ACCOUNT_EVENT);
		}
	}
}