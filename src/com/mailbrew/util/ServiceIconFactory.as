package com.mailbrew.util
{
	import com.mailbrew.data.AccountTypes;
	import com.mailbrew.model.ModelLocator;

	public class ServiceIconFactory
	{
		public static function getServiceIconClass(accountType:String):Class
		{
			switch (accountType)
			{
				case(AccountTypes.IMAP):
					return ModelLocator.getInstance().ImapIconClassSmall;
				case(AccountTypes.GMAIL):
					return ModelLocator.getInstance().GmailIconClassSmall;
				case(AccountTypes.GOOGLE_WAVE):
					return ModelLocator.getInstance().WaveIconClassSmall;
				case(AccountTypes.GOOGLE_VOICE):
					return ModelLocator.getInstance().VoiceIconClassSmall;
			}
			return null;
		}
	}
}