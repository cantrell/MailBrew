package com.mailbrew.email
{
	import flash.events.Event;
	
	public class EmailEvent extends Event
	{
		public static const CONNECTION_FAILED:String        = "connectionFailed";
		public static const CONNECTION_SUCCEEDED:String     = "connectionSucceeded";
		public static const AUTHENTICATION_FAILED:String    = "authenticationFailed";
		public static const AUTHENTICATION_SUCCEEDED:String = "authenticationSucceeded";
		public static const UNSEEN_EMAILS_COUNT:String      = "unseenEmailsCount";
		public static const UNSEEN_EMAILS:String            = "unseenEmails";
		
		public var data:*;
		
		public function EmailEvent(type:String)
		{
			super(type, false, false);
		}
	}
}