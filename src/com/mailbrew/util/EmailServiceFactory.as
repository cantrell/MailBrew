package com.mailbrew.util
{
	import com.mailbrew.data.AccountTypes;
	import com.mailbrew.email.IEmailService;
	import com.mailbrew.email.google.Gmail;
	import com.mailbrew.email.google.Voice;
	import com.mailbrew.email.google.Wave;
	import com.mailbrew.email.imap.IMAP;

	public class EmailServiceFactory
	{
		public static function getEmailService(type:String, username:String, password:String, server:String = null, portNumber:Number = NaN, secure:Boolean = false):IEmailService
		{
			var  emailService:IEmailService;
			if (type == AccountTypes.IMAP)
			{
				emailService = new IMAP(username, password, server, portNumber, secure);
			}
			else if (type == AccountTypes.GMAIL)
			{
				emailService = new Gmail(username, password);
			}
			else if (type == AccountTypes.GOOGLE_WAVE)
			{
				emailService = new Wave(username, password);
			}
			else if (type == AccountTypes.GOOGLE_VOICE)
			{
				emailService = new Voice(username, password);
			}
			return emailService;
		}
	}
}