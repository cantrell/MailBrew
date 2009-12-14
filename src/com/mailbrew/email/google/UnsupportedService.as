package com.mailbrew.email.google
{
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.EmailModes;
	import com.mailbrew.email.IEmailService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	[Event(name="connectionFailed",        type="com.mailbrew.email.EmailEvent")]
	[Event(name="connectionSucceeded",     type="com.mailbrew.email.EmailEvent")]
	[Event(name="authenticationFailed",    type="com.mailbrew.email.EmailEvent")]
	[Event(name="authenticationSucceeded", type="com.mailbrew.email.EmailEvent")]
	[Event(name="unseenEmailsCount",       type="com.mailbrew.email.EmailEvent")]
	[Event(name="unseenEmails",            type="com.mailbrew.email.EmailEvent")]
	[Event(name="protocolError",           type="com.mailbrew.email.EmailEvent")]
	
	public class UnsupportedService extends EventDispatcher implements IEmailService
	{
		private const APP_NAME:String = "MailBrew";
		private const LOGIN_URL:String = "https://www.google.com/accounts/ClientLogin";
		
		private var username:String;
		private var password:String;
		private var serviceName:String;
		private var inboxUrl:String;
		private var logoutUrl:String;
		protected var mode:String;
		private var internalMode:String;
		private var status:Number;
		private var authToken:String;
		
		public function UnsupportedService(username:String, password:String, serviceName:String, inboxUrl:String, logoutUrl:String)
		{
			this.username = username;
			this.password = password;
			this.serviceName = serviceName;
			this.inboxUrl = inboxUrl;
			this.logoutUrl = logoutUrl;
		}
		
		private function login():void
		{
			this.status = NaN;
			this.internalMode = InternalModes.LOGIN;
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
			var req:URLRequest = new URLRequest(LOGIN_URL);
			req.method = URLRequestMethod.POST;
			req.contentType = "application/x-www-form-urlencoded";
			var urlVars:URLVariables = new URLVariables();
			urlVars.accountType = "GOOGLE";
			urlVars.service = this.serviceName;
			urlVars.source = APP_NAME;
			urlVars.Email = this.username;
			urlVars.Passwd = this.password;
			req.data = urlVars;
			urlLoader.load(req);
		}
		
		private function getInbox():void
		{
			this.status = NaN;
			this.internalMode = InternalModes.INBOX;
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
			var req:URLRequest = new URLRequest(this.inboxUrl);
			req.method = URLRequestMethod.GET;
			var urlVars:URLVariables = new URLVariables();
			urlVars.nouacheck = "";
			urlVars.auth = this.authToken;
			req.data = urlVars;
			urlLoader.load(req);
		}
		
		private function logout():void
		{
			this.status = NaN;
			this.internalMode = InternalModes.LOGOUT;
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
			var req:URLRequest = new URLRequest(this.logoutUrl);
			req.method = URLRequestMethod.GET;
			var urlVars:URLVariables = new URLVariables();
			urlVars.auth = this.authToken;
			req.data = urlVars;
			urlLoader.load(req);
		}
		
		private function onResponseStatus(e:HTTPStatusEvent):void
		{
			this.status = e.status;
		}
		
		private function onIOError(e:IOErrorEvent):void
		{
			var ee:EmailEvent = new EmailEvent(EmailEvent.CONNECTION_FAILED);
			ee.data = e.text;
			this.dispatchEvent(ee);
		}
		
		private function onComplete(e:Event):void
		{
			if (this.status == 403)
			{
				var authFailedEvent:EmailEvent = new EmailEvent(EmailEvent.AUTHENTICATION_FAILED);
				this.dispatchEvent(authFailedEvent);
				return;
			}
			if (this.status != 200)
			{
				this.dispatchProtocolError("Unexpected response code: [" + this.status + "]");
				return;
			}
			this.dispatchEvent(new EmailEvent(EmailEvent.CONNECTION_SUCCEEDED));
			var urlLoader:URLLoader = e.target as URLLoader;
			var response:String = urlLoader.data as String;
			if (this.internalMode == InternalModes.LOGIN)
			{
				var responseStrings:Array = response.split("\n");
				var responseObj:Object = new Object();
				for each (var responseString:String in responseStrings)
				{
					var name:String = responseString.substring(0, responseString.indexOf("="));
					var value:String = responseString.substring(responseString.indexOf("=") + 1, responseString.length);
					if (name.length > 0 && value.length > 0)
					{
						responseObj[name] = value;
					}
				}
				if (responseObj["Error"] != null)
				{
					var authFailedEvent2:EmailEvent = new EmailEvent(EmailEvent.AUTHENTICATION_FAILED);
					authFailedEvent2.data = response.substring(response.indexOf("=") + 1, response.indexOf("\n"));
					this.dispatchEvent(authFailedEvent2);
				}
				else if (responseObj["Auth"] != null)
				{
					var authSucceededEvent:EmailEvent = new EmailEvent(EmailEvent.AUTHENTICATION_SUCCEEDED);
					authSucceededEvent.data = responseObj["Auth"];
					this.authToken = authSucceededEvent.data;
					this.dispatchEvent(authSucceededEvent);
					if (this.mode != EmailModes.AUTHENTICATION_TEST_MODE)
					{
						this.getInbox();
					}
				}
				else
				{
					this.dispatchProtocolError("Login attempt failed. Request returned an unexpected response: [" + response + "]");
					return;
				}
			}
			else if (this.internalMode == InternalModes.INBOX)
			{
				this.doInbox(response);
				// Logging out logs out the browser client, as well.
				// Best to skip it until we have real API support.
				//this.logout();
			}
			else if (this.internalMode == InternalModes.LOGOUT)
			{
				// Not much to do. Bye.
			}
		}
		
		protected function doInbox(response:String):void
		{
			// Override me!
		}
		
		protected function dispatchProtocolError(msg:String):void
		{
			var pe:EmailEvent = new EmailEvent(EmailEvent.PROTOCOL_ERROR);
			pe.data = msg;
			this.dispatchEvent(pe);
		}
		
		public function testAccount():void
		{
			this.mode = EmailModes.AUTHENTICATION_TEST_MODE;
			this.login();
		}
		
		public function getUnseenEmailCount():void
		{
			this.mode = EmailModes.UNSEEN_COUNT_MODE;
			this.login();
		}
		
		public function getUnseenEmailHeaders():void
		{
			this.mode = EmailModes.UNSEEN_EMAIL_HEADERS_MODE;
			this.login();
		}
	}
}