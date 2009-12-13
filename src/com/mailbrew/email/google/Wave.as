package com.mailbrew.email.google
{
	import com.adobe.serialization.json.JSON;
	import com.mailbrew.email.EmailCounts;
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.EmailHeader;
	import com.mailbrew.email.EmailModes;
	
	public class Wave extends UnsupportedService
	{
		private const SERVICE:String = "wave";
		private const INBOX_URL:String = "https://wave.google.com/wave/";
		private const LOGOUT_URL:String = "https://wave.google.com/wave/logout";
		private const INBOX_RE:RegExp = new RegExp(/var json = (\{"r":"\^d1".*});/);
		private const FROM_MAX:uint = 3;
		
		public function Wave(username:String, password:String)
		{
			super(username, password, SERVICE, INBOX_URL, LOGOUT_URL);
		}
		
		protected override function doInbox(response:String):void
		{
			try
			{
				var inboxString:String = INBOX_RE.exec(response)[1];
				var inboxObj:Object = JSON.decode(inboxString, true);
				var p:Object = inboxObj.p;
				var inbox:Array = p[1]; // This is the entire inbox -- everything you see when you log into Wave
				var messageTotal:Number = 0;
				var unreadTotal:Number = 0;
				var emailHeaders:Vector.<EmailHeader> = new Vector.<EmailHeader>();
				for each (var thread:Object in inbox)
				{
					var i:uint;
					var unread:Number = thread[7];
					messageTotal += thread[6];
					unreadTotal += unread;
					if (unread == 0) continue;
					var emailHeader:EmailHeader = new EmailHeader();
					emailHeader.id = thread[1];
					emailHeader.url = "https://wave.google.com/wave/#restored:wave:" + encodeURIComponent(encodeURIComponent(emailHeader.id)); // Must be encoded twice.
					var fromInformation:Array = thread[5];
					var fromString:String = new String();
					for (i = 0; i < fromInformation.length; ++i)
					{
						var fromStrTmp:String = fromInformation[i];
						fromString += fromStrTmp.substring(0, fromStrTmp.indexOf("@"));
						if (i == FROM_MAX - 1)
						{
							if (fromInformation.length > FROM_MAX)
							{
								fromString += "...";
							}
							break;
						}
						if (i != fromInformation.length - 1) fromString += ", ";
					}
					emailHeader.from = fromString;
					emailHeader.subject = thread[9][1];
					var summaryInformation:Array = thread[10];
					var summary:String = new String();
					for (i = 0; i < summaryInformation.length; ++i)
					{
						summary += summaryInformation[i][1];
						if (i == FROM_MAX - 1)
						{
							if (summaryInformation.length > FROM_MAX)
							{
								summary += "...";
							}
							break;
						}
						if (i != summaryInformation.length - 1) summary += "...";
					}
					emailHeader.summary = summary;
					emailHeaders.push(emailHeader);
				}
			}
			catch (error:Error)
			{
				this.dispatchProtocolError("Error parsing Google Wave inbox. Expect an update soon. [" +error.message+ "]");
				return;
			}
			if (this.mode == EmailModes.UNSEEN_COUNT_MODE)
			{
				var emailCounts:EmailCounts = new EmailCounts();
				emailCounts.totalEmails = messageTotal;
				emailCounts.unseenEmails = unreadTotal;
				var unseenCountEvent:EmailEvent = new EmailEvent(EmailEvent.UNSEEN_EMAILS_COUNT);
				unseenCountEvent.data = emailCounts;
				this.dispatchEvent(unseenCountEvent);
			}
			else if (this.mode == EmailModes.UNSEEN_EMAIL_HEADERS_MODE)
			{
				var unseenEmailEvent:EmailEvent = new EmailEvent(EmailEvent.UNSEEN_EMAILS);
				unseenEmailEvent.data = emailHeaders;
				this.dispatchEvent(unseenEmailEvent);
			}
			
		}
	}
}