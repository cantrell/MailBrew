package com.mailbrew.util
{
	import com.mailbrew.data.AccountTypes;
	import com.mailbrew.model.ModelLocator;
	
	import flash.display.Bitmap;

	public class ServiceIconFactory
	{
		public static const GMAIL_RE:RegExp = new RegExp(/@gmail\.com$/);
		public static function getSmallServiceIconClass(accountType:String, username:String = null):Class
		{
			switch (accountType)
			{
				case(AccountTypes.IMAP):
					return ModelLocator.getInstance().ImapIconClassSmall;
				case(AccountTypes.GMAIL):
					if (username == null || username.search(GMAIL_RE) != -1)
					{
						return ModelLocator.getInstance().GmailIconClassSmall;
					}
					else
					{
						return ModelLocator.getInstance().GoogleAppsIconClassSmall;
					}
				case(AccountTypes.GOOGLE_WAVE):
					return ModelLocator.getInstance().WaveIconClassSmall;
				case(AccountTypes.GOOGLE_VOICE):
					return ModelLocator.getInstance().VoiceIconClassSmall;
			}
			return null;
		}

		public static function getLargeServiceIconClass(accountType:String, username:String = null):Class
		{
			switch (accountType)
			{
				case(AccountTypes.IMAP):
					return ModelLocator.getInstance().ImapIconClassLarge;
				case(AccountTypes.GMAIL):
					if (username == null || username.search(GMAIL_RE) != -1)
					{
						return ModelLocator.getInstance().GmailIconClassLarge;
					}
					else
					{
						return ModelLocator.getInstance().GoogleAppsIconClassLarge;
					}
				case(AccountTypes.GOOGLE_WAVE):
					return ModelLocator.getInstance().WaveIconClassLarge;
				case(AccountTypes.GOOGLE_VOICE):
					return ModelLocator.getInstance().VoiceIconClassLarge;
			}
			return null;
		}

		public static function getLargeServiceIconBitmap(accountType:String, username:String = null):Bitmap
		{
			switch (accountType)
			{
				case(AccountTypes.IMAP):
					return ModelLocator.getInstance().imapIconBitmapLarge;
				case(AccountTypes.GMAIL):
					if (username == null || username.search(GMAIL_RE) != -1)
					{
						return ModelLocator.getInstance().gmailIconBitmapLarge;
					}
					else
					{
						return ModelLocator.getInstance().googleAppsIconBitmapLarge;
					}
				case(AccountTypes.GOOGLE_WAVE):
					return ModelLocator.getInstance().waveIconBitmapLarge;
				case(AccountTypes.GOOGLE_VOICE):
					return ModelLocator.getInstance().voiceIconBitmapLarge;
			}
			return null;
		}
	}
}