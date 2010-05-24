package com.mailbrew.email.google
{
	import com.adobe.serialization.json.JSON;
	import com.mailbrew.email.EmailCounts;
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.EmailHeader;
	import com.mailbrew.email.EmailModes;
	
	import flash.events.Event;
	import flash.html.HTMLLoader;
	
	public class Voice extends UnsupportedService
	{
		private const SERVICE:String = "grandcentral";
		private const INBOX_URL:String = "https://www.google.com/voice/inbox/recent/";
		private const LOGOUT_URL:String = "https://www.google.com/voice/account/signout";
		
		public function Voice(username:String, password:String)
		{
			super(username, password, SERVICE, INBOX_URL, LOGOUT_URL);
		}
		
		protected override function doInbox(response:String):void
		{
			try
			{
				var responseXML:XML = new XML(response);
				var jsonStr:String = responseXML.json;
				var json:Object = JSON.decode(jsonStr);
				
				if (this.mode == EmailModes.UNSEEN_COUNT_MODE)
				{
					var emailCounts:EmailCounts = new EmailCounts();
					emailCounts.totalEmails = json.totalSize;
					emailCounts.unseenEmails = json.unreadCounts.all;
					var unseenCountEvent:EmailEvent = new EmailEvent(EmailEvent.UNSEEN_EMAILS_COUNT);
					unseenCountEvent.data = emailCounts;
					this.dispatchEvent(unseenCountEvent);
				}
				else if (this.mode == EmailModes.UNSEEN_EMAIL_HEADERS_MODE)
				{
					var htmlStr:String = responseXML.html;
					var emailHeaders:Vector.<EmailHeader> = new Vector.<EmailHeader>();
					for each (var message:Object in json.messages)
					{
						if (Boolean(message.isRead))
						{
							continue;
						}
						var emailHeader:EmailHeader = new EmailHeader();
						emailHeader.url = "https://www.google.com/voice/";
						emailHeader.id = message.id;
						for each (var label:String in message.labels)
						{
							if (label == "sms")
							{
								emailHeader.type = "sms";
								emailHeader.from = "SMS From " + message.displayNumber;
								break;
							}
							else if (label == "voicemail")
							{
								emailHeader.type = "voicemail";
								emailHeader.from = "Voicemail From " + message.displayNumber;
								break;
							}
						}
						if (emailHeader.type == null) continue;
						emailHeaders.push(emailHeader);
					}
					var completeListener:Function = function (e:Event):void
					{
						htmlLoader.removeEventListener(Event.COMPLETE, completeListener);
						parseOutMessageText(HTMLLoader(e.target), emailHeaders);
					};
					var htmlLoader:HTMLLoader = new HTMLLoader();
					htmlLoader.addEventListener(Event.COMPLETE, completeListener);
					htmlLoader.loadString(htmlStr);
				}
			}
			catch (error:Error)
			{
				this.dispatchProtocolError("Error parsing Google Voice inbox. Expect an update soon. [" +error.message+ "]");
				return;
			}

		}
		
		private function parseOutMessageText(html:HTMLLoader, emailHeaders:Vector.<EmailHeader>):void
		{
			try
			{
				for each (var emailHeader:EmailHeader in emailHeaders)
				{
					var i:uint;
					if (emailHeader.type == "sms")
					{
						var smsDiv:Object = html.window.document.getElementById(emailHeader.id);
						var smsMessages:Object = smsDiv.getElementsByClassName("gc-message-sms-text");
						if (smsMessages.length == 0)
						{
							this.dispatchProtocolError("Google Voice SMS parsing is broken. Message length is 0.");
							continue;
						}
						emailHeader.summary = new String();
						var delimiter:String = (smsMessages.length == 1) ? "" : " ";
						for (i = 0; i < smsMessages.length; ++i)
						{
							var smsText:String = smsMessages[i].innerText;
							emailHeader.summary += (smsText + delimiter);
						}
					}
					else if (emailHeader.type == "voicemail")
					{
						var vmDiv:Object = html.window.document.getElementById(emailHeader.id);
						var vmBlock:Object = vmDiv.getElementsByClassName("gc-message-message-display");
						if (vmBlock.length == 0)
						{
							this.dispatchProtocolError("Google Voice voicemail parsing is broken. Can't get the block of voicemail words.");
							continue;
						}
						var vmWords:Object = vmBlock[0].getElementsByTagName("span");
						if (vmWords.length == 0)
						{
							this.dispatchProtocolError("Google Voice voicemail parsing is broken. Can't get the individual voicemail words.");
							continue;
						}
						emailHeader.summary = new String();
						for (i = 0; i < vmWords.length; ++i)
						{
							var vmText:String = vmWords[i].innerText;
							emailHeader.summary += (vmText + " ");
						}
					}
				}
			}
			catch (bigError:Error)
			{
				this.dispatchProtocolError("Google Voice support is broken. Expect an update soon. [" + bigError.message + "]");
				return;
			}
			var unseenEmailEvent:EmailEvent = new EmailEvent(EmailEvent.UNSEEN_EMAILS);
			unseenEmailEvent.data = emailHeaders;
			this.dispatchEvent(unseenEmailEvent);
		}
	}
}