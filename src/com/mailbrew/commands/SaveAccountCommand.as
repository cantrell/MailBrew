package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.data.AccountSaveMode;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.events.SaveAccountEvent;
	import com.mailbrew.model.ModelLocator;
	
	import mx.controls.Alert;
		
	public class SaveAccountCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var sae:SaveAccountEvent = SaveAccountEvent(e);
			var ml:ModelLocator = ModelLocator.getInstance();
			var db:Database = ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				new PopulateAccountListEvent().dispatch();
				Alert.show("Your account information has been saved.", "Account Saved", Alert.OK, null, null, ml.faceSmileIconClass);
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			if (sae.saveMode == AccountSaveMode.INSERT)
			{
				db.insertAccount(responder,
								 sae.accountName,
								 sae.accountType,
								 sae.username,
								 sae.password,
								 sae.imapServer,
								 sae.portNumber,
								 sae.secure,
								 sae.notificationPosition,
								 sae.sound,
								 sae.active);
			}
			else
			{
				db.updateAccount(responder,
								 sae.accountId,
								 sae.accountName,
								 sae.accountType,
								 sae.username,
								 sae.password,
								 sae.imapServer,
								 sae.portNumber,
								 sae.secure,
								 sae.notificationPosition,
								 sae.sound,
								 sae.active);
			}
		}
	}
}