package com.mailbrew.commands
{
	import com.adobe.air.notification.AbstractNotification;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.model.ModelLocator;
	
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
			
			ml.purr.clear(AbstractNotification.TOP_RIGHT);
			ml.purr.clear(AbstractNotification.TOP_LEFT);
			ml.purr.clear(AbstractNotification.BOTTOM_RIGHT);
			ml.purr.clear(AbstractNotification.BOTTOM_LEFT);
			for (var i:int = NativeApplication.nativeApplication.openedWindows.length - 1; i >= 0; --i)
			{
				NativeWindow(NativeApplication.nativeApplication.openedWindows[i]).close();
			}
			NativeApplication.nativeApplication.exit(1);
		}
	}
}