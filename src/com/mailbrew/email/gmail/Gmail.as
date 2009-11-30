package com.mailbrew.email.gmail
{
	import com.mailbrew.email.EmailCounts;
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.EmailHeader;
	import com.mailbrew.email.EmailModes;
	import com.mailbrew.email.IEmailService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
	
	import mx.utils.Base64Encoder;

	[Event(name="connectionFailed",        type="com.mailbrew.email.EmailEvent")]
	[Event(name="connectionSucceeded",     type="com.mailbrew.email.EmailEvent")]
	[Event(name="authenticationFailed",    type="com.mailbrew.email.EmailEvent")]
	[Event(name="authenticationSucceeded", type="com.mailbrew.email.EmailEvent")]
	[Event(name="unseenEmailsCount",       type="com.mailbrew.email.EmailEvent")]
	[Event(name="unseenEmails",            type="com.mailbrew.email.EmailEvent")]

	public class Gmail extends EventDispatcher implements IEmailService
	{
		private const PURL:Namespace = new Namespace("http://purl.org/atom/ns#");

		private var username:String;
		private var password:String;
		private var mode:String;
		private var status:Number;
		
		public function Gmail(username:String, password:String)
		{
			this.username = username;
			this.password = password;
		}
		
		public function testAccount():void
		{
			this.mode = EmailModes.AUTHENTICATION_TEST_MODE;
			this.start();
		}

		private function start():void
		{
			this.status = NaN;
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
			var req:URLRequest = new URLRequest("https://mail.google.com/mail/feed/atom");
			req.authenticate = false;
			var authString:String = this.username + ":" + this.password;
			var b64:Base64Encoder = new Base64Encoder();
			b64.encode(authString, 0, authString.length);
			var authHeader:URLRequestHeader = new URLRequestHeader("Authorization", ("Basic " + b64.toString()));
			req.requestHeaders = new Array(authHeader);
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
			this.dispatchEvent(new EmailEvent(EmailEvent.CONNECTION_SUCCEEDED));
			if (this.status == 401)
			{
				this.dispatchEvent(new EmailEvent(EmailEvent.AUTHENTICATION_FAILED));
				return;
			}
			this.dispatchEvent(new EmailEvent(EmailEvent.AUTHENTICATION_SUCCEEDED));
			if (this.mode == EmailModes.AUTHENTICATION_TEST_MODE) return;
			var urlLoader:URLLoader = e.target as URLLoader;
			var response:XML = new XML(urlLoader.data);
			if (this.mode == EmailModes.UNSEEN_COUNT_MODE)
			{
				var unseenCount:Number = Number(response.PURL::fullcount);
				var unseenCountEvent:EmailEvent = new EmailEvent(EmailEvent.UNSEEN_EMAILS_COUNT);
				var emailCounts:EmailCounts = new EmailCounts();
				emailCounts.unseenEmails = unseenCount;
				unseenCountEvent.data = emailCounts;
				this.dispatchEvent(unseenCountEvent);
			}
			else if (this.mode == EmailModes.UNSEEN_EMAIL_HEADERS_MODE)
			{
				var unseenEmails:Vector.<EmailHeader> = new Vector.<EmailHeader>();
				for each (var email:XML in response.PURL::entry)
				{
					var emailHeader:EmailHeader = new EmailHeader();
					emailHeader.from = email.PURL::author.PURL::name;
					emailHeader.id = email.PURL::id;
					emailHeader.subject = email.PURL::title;
					emailHeader.summary = email.PURL::summary;
					emailHeader.url = email.PURL::link.@href;
					unseenEmails.push(emailHeader);
				}
				var unseenEvent:EmailEvent = new EmailEvent(EmailEvent.UNSEEN_EMAILS);
				unseenEvent.data = unseenEmails;
				this.dispatchEvent(unseenEvent);
			}
		}
		
		public function getUnseenEmailCount():void
		{
			this.mode = EmailModes.UNSEEN_COUNT_MODE;
			this.start();
		}
		
		public function getUnseenEmailHeaders():void
		{
			this.mode = EmailModes.UNSEEN_EMAIL_HEADERS_MODE;
			this.start();
		}
	}
}