package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.data.PreferenceKeys;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.AppExitEvent;
	import com.mailbrew.events.SavePreferencesEvent;
	import com.mailbrew.model.ModelLocator;
	
	public class ResetCommand
		implements ICommand
	{
		private var ml:ModelLocator;
		
		public function execute(e:CairngormEvent):void
		{
			this.ml = ModelLocator.getInstance();

			var spe:SavePreferencesEvent = new SavePreferencesEvent();
			spe.updateInterval = PreferenceKeys.UPDATE_INTERVAL_DEFAULT;
			spe.notificationDisplayInterval = PreferenceKeys.NOTIFICATION_DISPLAY_INTERVAL_DEFAULT;
			spe.idleThreshold = PreferenceKeys.IDLE_THRESHOLD_DEFAULT;
			spe.applicationAlert = PreferenceKeys.APPLICATION_ALERT_DEFAULT;
			spe.startAtLogin = PreferenceKeys.START_AT_LOGIN_DEFAULT;
			spe.dispatch();
			this.dropMessagesTable();
		}
		
		private function dropMessagesTable():void
		{
			var db:Database = this.ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				dropAccountsTable();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.dropMessagesTable(responder);
		}

		private function dropAccountsTable():void
		{
			var db:Database = this.ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				new AppExitEvent().dispatch();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.dropAccountsTable(responder);
		}
	}
}