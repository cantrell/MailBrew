package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.DeleteAccountEvent;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.model.ModelLocator;
	
	public class DeleteAccountCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var dae:DeleteAccountEvent = DeleteAccountEvent(e);
			var db:Database = ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				new PopulateAccountListEvent().dispatch();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.deleteAccount(responder, dae.accountId);
		}
	}
}