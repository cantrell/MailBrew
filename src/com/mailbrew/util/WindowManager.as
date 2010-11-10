package com.mailbrew.util
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.geom.Rectangle;
	import flash.utils.describeType;
	
	public class WindowManager
	{
		
		public static const PREFERENCES:String  = "MailBrew Preferences";
		public static const ABOUT:String        = "About MailBrew";
		public static const ERROR_VIEWER:String = "Error Message";
		
		public static function isWindowOpen(title:String):Boolean
		{
			var allWindows:Array = NativeApplication.nativeApplication.openedWindows;
			for each (var win:NativeWindow in allWindows)
			{
				if (win.title == title)
				{
					return true;
				}
			}
			return false;
		}

		public static function getWindowByTitle(title:String):NativeWindow
		{
			var allWindows:Array = NativeApplication.nativeApplication.openedWindows;
			for each (var win:NativeWindow in allWindows)
			{
				if (win.title == title)
				{
					return win;
				}
			}
			return null;
		}

		public static function centerWindowOnMainScreen(win:NativeWindow, makeVisible:Boolean = false):void
		{
			var initialBounds:Rectangle = new Rectangle((Screen.mainScreen.bounds.width / 2 - (win.width/2)), (Screen.mainScreen.bounds.height / 2 - (win.height/2)), win.width, win.height);
			win.bounds = initialBounds;
			if (makeVisible) win.visible = true;
		}
	}
}