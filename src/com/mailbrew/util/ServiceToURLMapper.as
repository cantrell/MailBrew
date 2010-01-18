package com.mailbrew.util
{
	import com.mailbrew.data.AccountTypes;

	public class ServiceToURLMapper
	{
		public static function getServiceURL(serviceName:String, username:String = null):String
		{
			if (serviceName == AccountTypes.GMAIL)
			{
				if (username == null || username.indexOf("@") == -1 || username.search(/@gmail\.com$/) != -1)
				{
					return "http://mail.google.com/mail/?shva=1#inbox";
				}
				else
				{
					var domain:String = username.substring(username.indexOf("@") + 1, username.length);
					return "http://mail.google.com/a/" + domain + "/#inbox";
				}
			}
			else if (serviceName == AccountTypes.GOOGLE_VOICE)
			{
				return "https://www.google.com/voice/#inbox";
			}
			else if (serviceName == AccountTypes.GOOGLE_WAVE)
			{
				return "http://wave.google.com/wave/";
			}
			return null;
		}
	}
}