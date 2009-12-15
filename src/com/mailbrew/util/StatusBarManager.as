package com.mailbrew.util
{
	import com.mailbrew.model.ModelLocator;

	public class StatusBarManager
	{
		public static function showMessage(message:String, showProgressBar:Boolean = false):void
		{
			ModelLocator.getInstance().statusMessage = message;
			ModelLocator.getInstance().showStatusProgressBar = showProgressBar;
		}

		public static function clearMessage():void
		{
			ModelLocator.getInstance().statusMessage = "";
			ModelLocator.getInstance().showStatusProgressBar = false;
		}
	}
}