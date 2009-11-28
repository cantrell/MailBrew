package com.mailbrew.email.gmail
{
	import flash.events.EventDispatcher;
	import com.mailbrew.email.IEmailService;

	[Event(name="connectionFailed",        type="com.mailbrew.email.EmailEvent")]
	[Event(name="connectionSucceeded",     type="com.mailbrew.email.EmailEvent")]
	[Event(name="authenticationSucceeded", type="com.mailbrew.email.EmailEvent")]
	[Event(name="authenticationFailed",    type="com.mailbrew.email.EmailEvent")]
	[Event(name="unseenEmails",            type="com.mailbrew.email.EmailEvent")]

	public class Gmail extends EventDispatcher implements IEmailService
	{
		private var username:String;
		private var password:String;
		
		public function Gmail(username:String, password:String)
		{
			this.username = username;
			this.password = password;
		}
		
		public function testAccount():void
		{
			
		}
		
		public function getUnseenEmailCount():void
		{
			
		}
		
		public function getUnseenEmailHeaders():void
		{
			
		}
	}
}