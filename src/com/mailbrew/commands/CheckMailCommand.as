package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.model.ModelLocator;
	
	import mx.collections.ArrayCollection;
	
	public class CheckMailCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			/*
			var ml:ModelLocator = ModelLocator.getInstance();
			var db:Database = ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				var accountData:Array =  new Array();
				for each (var o:Object in e.data)
				{
					accountData.push({label:o.name, accountId:o.id});
				}
				ml.accounts = new ArrayCollection(accountData);
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.getAccounts(responder);
			*/
		}
	}
}