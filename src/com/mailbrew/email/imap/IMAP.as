package com.mailbrew.email.imap
{
	import com.mailbrew.email.EmailCounts;
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.EmailHeader;
	import com.mailbrew.email.EmailModes;
	import com.mailbrew.email.IEmailService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.SecureSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;

	[Event(name="connectionFailed",        type="com.mailbrew.email.EmailEvent")]
	[Event(name="connectionSucceeded",     type="com.mailbrew.email.EmailEvent")]
	[Event(name="authenticationFailed",    type="com.mailbrew.email.EmailEvent")]
	[Event(name="authenticationSucceeded", type="com.mailbrew.email.EmailEvent")]
	[Event(name="unseenEmailsCount",       type="com.mailbrew.email.EmailEvent")]
	[Event(name="unseenEmails",            type="com.mailbrew.email.EmailEvent")]
	[Event(name="protocolError",           type="com.mailbrew.email.EmailEvent")]

	public class IMAP extends EventDispatcher implements IEmailService
	{
		private static const CRLF:String = "\r\n";

		private var tag:String;
		private var doneRegExp:RegExp;

		private var username:String;
		private var password:String;
		private var imapServer:String;
		private var portNumber:Number;
		private var secure:Boolean;
		private var mode:String;
		
		private var socket:Socket;
		private var buffer:ByteArray;
		private var unseenMessageIds:Array;

		public function IMAP(username:String, password:String, imapServer:String, portNumber:Number, secure:Boolean)
		{
			this.buffer = new ByteArray();
			this.username = username;
			this.password = password;
			this.imapServer = imapServer;
			this.portNumber = portNumber;
			this.secure = secure;
		}

		public function testAccount():void
		{
			this.mode = EmailModes.AUTHENTICATION_TEST_MODE;
			start();
		}

		public function getUnseenEmailHeaders():void
		{
			this.mode = EmailModes.UNSEEN_EMAIL_HEADERS_MODE;
			this.start();
		}
		
		public function getUnseenEmailCount():void
		{
			this.mode = EmailModes.UNSEEN_COUNT_MODE;
			this.start();
		}
		
		
		private function start():void
		{
			this.tag = Tags.CONNECT_TAG;
			this.doneRegExp = new RegExp("\\" + this.tag + ".+\\r\\n");
			this.stop();
			this.socket = (this.secure) ? new SecureSocket() : new Socket();
			this.socket.addEventListener(Event.CONNECT, onConnect);
			this.socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.socket.addEventListener(Event.CLOSE, onClose);
			this.socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			this.socket.connect(this.imapServer, this.portNumber);
		}
		
		public function stop():void
		{
			if (this.socket != null && this.socket.connected)
			{
				this.socket.close();
				this.socket = null;
			}
		}
		
		private function onConnect(e:Event):void
		{
			this.dispatchEvent(new EmailEvent(EmailEvent.CONNECTION_SUCCEEDED));
		}
		
		private function onIOError(e:IOErrorEvent):void
		{
			var emailEvent:EmailEvent = new EmailEvent(EmailEvent.CONNECTION_FAILED);
			emailEvent.data = e.text;
			this.dispatchEvent(emailEvent);
		}
		
		private function onClose(e:Event):void
		{
			this.socket = null;
		}
				
		private function onSocketData(e:ProgressEvent):void
		{
			var s:Socket = e.target as Socket;
			s.readBytes(this.buffer, this.buffer.length, s.bytesAvailable);
			var bufferString:String = buffer.toString();
			if (bufferString.search(this.doneRegExp) != -1)
			{
				this.onResponse();
			}
		}
		
		private function onResponse():void
		{
			var bufferString:String = this.buffer.toString();
			this.buffer.clear();
			if (this.tag == Tags.CONNECT_TAG)
			{
				this.setTag(Tags.LOGIN_TAG);
				this.socket.writeUTFBytes(Tags.LOGIN_TAG + " LOGIN " + this.username + " " + this.password + CRLF);
				this.socket.flush();
			}
			else if (this.tag == Tags.LOGIN_TAG)
			{
				if (bufferString.indexOf(Tags.LOGIN_TAG + " OK") != -1) // Successful login
				{
					this.dispatchEvent(new EmailEvent(EmailEvent.AUTHENTICATION_SUCCEEDED));
					if (this.mode == EmailModes.UNSEEN_COUNT_MODE)
					{
						this.getStatus(bufferString);
					}
					else if (this.mode == EmailModes.UNSEEN_EMAIL_HEADERS_MODE)
					{
						this.selectInbox();
					}
					else
					{
						this.stop();
					}
				}
				else
				{
					this.dispatchEvent(new EmailEvent(EmailEvent.AUTHENTICATION_FAILED));
				}
			}
			else if (this.tag == Tags.STATUS_TAG)
			{
				this.onGetStatus(bufferString);
			}
			else if (this.tag == Tags.SELECT_TAG)
			{
				this.getUnseenMessageNumbers();
			}
			else if (this.tag == Tags.SEARCH_TAG)
			{
				this.onGetUnseenMessageNumbers(bufferString);
			}
			else if (this.tag == Tags.FETCH_TAG)
			{
				this.onFetchUnseenSubjects(bufferString);
			}
		}
		
		private function getStatus(bufferString:String):void
		{
			this.setTag(Tags.STATUS_TAG);
			this.socket.writeUTFBytes(Tags.STATUS_TAG + " STATUS inbox (MESSAGES UNSEEN)" + CRLF);
			this.socket.flush();
		}
		
		private function onGetStatus(bufferString:String):void
		{
			try
			{
				var statusData:String = bufferString.substring(bufferString.indexOf("(")+1, bufferString.indexOf(")"));
				var dataArray:Array = statusData.split(" ");
				var messages:Number = 0;
				var unseen:Number = 0;
				for (var i:uint = 0; i < dataArray.length; ++i)
				{
					if (dataArray[i] == "MESSAGES")
					{
						messages = Number(dataArray[i+1]);
						continue;
					}
					if (dataArray[i] == "UNSEEN")
					{
						unseen = Number(dataArray[i+1]);
						continue;
					}
				}
				var emailEvent:EmailEvent = new EmailEvent(EmailEvent.UNSEEN_EMAILS_COUNT);
				var counts:EmailCounts = new EmailCounts();
				counts.totalEmails = messages;
				counts.unseenEmails = unseen;
				emailEvent.data = counts;
				this.dispatchEvent(emailEvent);
				this.stop();
			}
			catch (error:Error)
			{
				this.dispatchProtocolError("Error getting status. [" + error.message+ "]");
			}
		}
		
		private function selectInbox():void
		{
			this.setTag(Tags.SELECT_TAG);
			this.socket.writeUTFBytes(Tags.SELECT_TAG + " SELECT inbox" + CRLF);
			this.socket.flush();
		}
		
		private function getUnseenMessageNumbers():void
		{
			this.setTag(Tags.SEARCH_TAG);
			this.socket.writeUTFBytes(Tags.SEARCH_TAG + " SEARCH UNSEEN" + CRLF);
			this.socket.flush();
		}
		
		private function onGetUnseenMessageNumbers(bufferString:String):void
		{
			var messageNumberString:String = bufferString.substring(bufferString.indexOf("SEARCH") + 7, bufferString.indexOf(CRLF));
			this.fetchUnseenSubjects(messageNumberString);
		}
		
		private function fetchUnseenSubjects(messageNumberString:String):void
		{
			this.setTag(Tags.FETCH_TAG);
			messageNumberString = messageNumberString.replace(/[ ]/g, ",");
			this.socket.writeUTFBytes(Tags.FETCH_TAG + " FETCH " + messageNumberString + " (FLAGS BODY.PEEK[HEADER.FIELDS (FROM SUBJECT)])" + CRLF);
			this.socket.flush();
		}
		
		private function onFetchUnseenSubjects(bufferString:String):void
		{
			this.stop();
			var emailEvent:EmailEvent = new EmailEvent(EmailEvent.UNSEEN_EMAILS);
			emailEvent.data = this.parseMessages(bufferString);
			this.dispatchEvent(emailEvent);
		}

		private function parseMessages(bufferString:String):Vector.<EmailHeader>
		{
			var messageData:Vector.<EmailHeader> = new Vector.<EmailHeader>();
			try
			{
				var rawMessages:Array = bufferString.split(CRLF+CRLF+")"+CRLF);
				rawMessages.pop();
				for each (var rawMessage:String in rawMessages)
				{
					var messageParts:Array = rawMessage.split(CRLF);
					var id:Number = NaN;
					var from:String = null;
					var subject:String = null;
					for each (var messagePart:String in messageParts)
					{
						if (messagePart.search(/^\*/) != -1)
						{
							id = Number(messagePart.substring(2, rawMessage.indexOf("FETCH")));
						}
						else if (messagePart.search(/^From:/) != -1)
						{
							from = messagePart.substr(6, messagePart.length);
							from = from.replace(/ <.+>/, "");
							from = from.replace(/\"/g, "");
						}
						else if (messagePart.search(/^Subject:/) != -1)
						{
							subject = messagePart.substr(9, messagePart.length);
						}
					}
					if (!isNaN(id) && from != null && subject != null)
					{
						var email:EmailHeader = new EmailHeader();
						email.id = String(id);
						email.from = from;
						email.subject = subject;
						messageData.push(email);
					}
				}
			}
			catch (error:Error)
			{
				this.dispatchProtocolError("Unexpected error parsing message data. [" + error.message + "]");
			}
			return messageData;
		}

		private function setTag(tag:String):void
		{
			this.tag = tag;
			this.doneRegExp = new RegExp(tag + ".+\\r\\n");
		}
		
		private function dispatchProtocolError(msg:String):void
		{
			var pe:EmailEvent = new EmailEvent(EmailEvent.PROTOCOL_ERROR);
			pe.data = msg;
			this.dispatchEvent(pe);
		}
	}
}