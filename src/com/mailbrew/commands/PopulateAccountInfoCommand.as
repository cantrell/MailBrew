package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.data.AccountInfo;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.PopulateAccountInfoEvent;
	import com.mailbrew.model.ModelLocator;
	
	public class PopulateAccountInfoCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var paie:PopulateAccountInfoEvent = PopulateAccountInfoEvent(e);
			var ml:ModelLocator = ModelLocator.getInstance();
			var db:Database = ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				var accountInfo:AccountInfo = new AccountInfo();
				accountInfo.accountId = Number(e.data.id);
				accountInfo.accountName = e.data.name;
				accountInfo.accountType = e.data.account_type;
				accountInfo.username = e.data.username;
				accountInfo.password = e.data.password;
				accountInfo.imapServer = e.data.imap_server;
				accountInfo.portNumber = Number(e.data.port_number);
				accountInfo.secure = Boolean(e.data.secure);
				accountInfo.notificationPosition = e.data.notification_location;
				accountInfo.notificationSound = e.data.notification_sound;
				accountInfo.active = e.data.active;
				ModelLocator.getInstance().accountInfo = accountInfo;
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.getAccountById(responder, paie.accountId);
		}
	}
}