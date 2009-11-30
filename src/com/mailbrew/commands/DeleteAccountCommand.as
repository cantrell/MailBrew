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
			this.deleteMessages(dae.accountId);
		}
		
		private function deleteMessages(accountId:Number):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				deleteAccount(accountId);
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			ModelLocator.getInstance().db.deleteMessagesByAccountId(responder, accountId);
		}
		
		private function deleteAccount(accountId:Number):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				ModelLocator.getInstance().accountInfo = null;
				new PopulateAccountListEvent().dispatch();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			ModelLocator.getInstance().db.deleteAccountById(responder, accountId);
		}
	}
}