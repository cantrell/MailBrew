package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.data.PreferenceKeys;
	import com.mailbrew.events.SavePreferencesEvent;
	import com.mailbrew.model.ModelLocator;
	import com.mailbrew.util.StatusBarManager;
	
	import flash.desktop.NativeApplication;
	
	public class SavePreferencesCommand
		implements ICommand
	{
		private var ml:ModelLocator;
		public function execute(e:CairngormEvent):void
		{
			this.ml = ModelLocator.getInstance();
			var spe:SavePreferencesEvent = e as SavePreferencesEvent;
			this.ml.prefs.setValue(PreferenceKeys.UPDATE_INTERVAL, spe.updateInterval);
			this.ml.prefs.setValue(PreferenceKeys.NOTIFICATION_DISPLAY_INTERVAL, spe.notificationDisplayInterval);
			this.ml.prefs.setValue(PreferenceKeys.IDLE_THRESHOLD, spe.idleThreshold);
			this.ml.prefs.setValue(PreferenceKeys.APPLICATION_ALERT, spe.applicationAlert);
			this.ml.prefs.save();
			try
			{
				NativeApplication.nativeApplication.startAtLogin = spe.startAtLogin;
			}
			catch (e:Error)
			{
				if (e.errorID != 2014) throw e;
			}
			this.ml.checkEmailTimer.stop();
			this.ml.checkEmailTimer.delay = (this.ml.prefs.getValue(PreferenceKeys.UPDATE_INTERVAL) * 60 * 1000);
			this.ml.checkEmailTimer.start();
			this.ml.notificationManager.setIdleThreshold(this.ml.prefs.getValue(PreferenceKeys.IDLE_THRESHOLD));
			StatusBarManager.showMessage("Preferences saved", false);
		}
	}
}