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
	import com.mailbrew.events.UpdateSortOrderEvent;
	import com.mailbrew.model.ModelLocator;
	
	public class UpdateSortOrderCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var usoe:UpdateSortOrderEvent = UpdateSortOrderEvent(e);
			var ml:ModelLocator = ModelLocator.getInstance();
			var db:Database = ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.updateSortOrder(responder, usoe.accountId, usoe.sortOrder);
		}
	}
}