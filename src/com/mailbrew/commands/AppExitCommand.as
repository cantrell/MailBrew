package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.model.ModelLocator;
	import com.mailbrew.notify.Notification;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.TimerEvent;
	
	public class AppExitCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			
			if (ml.checkEmailTimer != null)
			{
				ml.checkEmailTimer.stop();
				ml.checkEmailTimer.removeEventListener(TimerEvent.TIMER, ml.checkEmail);
			}
			
			ml.notificationManager.clear(Notification.TOP_RIGHT);
			ml.notificationManager.clear(Notification.TOP_LEFT);
			ml.notificationManager.clear(Notification.BOTTOM_RIGHT);
			ml.notificationManager.clear(Notification.BOTTOM_LEFT);
			for (var i:int = NativeApplication.nativeApplication.openedWindows.length - 1; i >= 0; --i)
			{
				NativeWindow(NativeApplication.nativeApplication.openedWindows[i]).close();
			}
			NativeApplication.nativeApplication.exit(0);
		}
	}
}