package com.mailbrew.util
{
	import com.mailbrew.data.AccountTypes;

	public class ServiceToURLMapper
	{
		public static function getServiceURL(serviceName:String, username:String = null):String
		{
			if (serviceName == AccountTypes.GMAIL)
			{
				if (username == null || username.search(/@gmail\.com$/) != -1)
				{
					return "https://mail.google.com";
				}
				else
				{
					var domain:String = username.substring(username.indexOf("@") + 1, username.length);
					return "http://mail.google.com/a/" + domain + "/";
				}
			}
			else if (serviceName == AccountTypes.GOOGLE_VOICE)
			{
				return "https://www.google.com/voice";
			}
			else if (serviceName == AccountTypes.GOOGLE_WAVE)
			{
				return "http://wave.google.com";
			}
			return null;
		}
	}
}