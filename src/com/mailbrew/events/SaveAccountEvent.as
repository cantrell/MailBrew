package com.mailbrew.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class SaveAccountEvent extends CairngormEvent
	{
		public static var SAVE_ACCOUNT_EVENT:String = "saveAccountEvent";
		
		public var saveMode:String;
		public var accountId:Number;
		public var accountType:String;
		public var accountName:String;
		public var username:String;
		public var password:String;
		public var imapServer:String;
		public var portNumber:Number;
		public var secure:Boolean;
		public var notificationPosition:String;
		
		public function SaveAccountEvent()
		{
			super(SAVE_ACCOUNT_EVENT);
		}
	}
}
