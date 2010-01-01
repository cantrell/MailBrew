package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.components.IconAlert;
	import com.mailbrew.data.AccountSaveMode;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.PopulateAccountInfoEvent;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.events.SaveAccountEvent;
	import com.mailbrew.model.ModelLocator;
	
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
				if (sae.saveMode == AccountSaveMode.INSERT)
				{
					insertSortOrder(e.data, e.data);
				}
				else
				{
					IconAlert.showSuccess("Account Updated", "Your account information has been updated.");
				}
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
								 sae.notificationSound,
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
								 sae.notificationSound,
								 sae.active);
			}
		}
		
		private function insertSortOrder(accountId:Number, sortOrder:Number):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var db:Database = ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				var pale:PopulateAccountListEvent = new PopulateAccountListEvent();
				pale.selectedId = accountId;
				pale.dispatch();
				IconAlert.showSuccess("Account Created", "Your new account has been created.");
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.updateSortOrder(responder, accountId, sortOrder);
		}
	}
}