package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.model.ModelLocator;
	
	import mx.collections.ArrayCollection;
	
	public class PopulateAccountListCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var pale:PopulateAccountListEvent = e as PopulateAccountListEvent;
			var ml:ModelLocator = ModelLocator.getInstance();
			var db:Database = ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				var accountData:Array =  new Array();
				for each (var o:Object in e.data)
				{
					var accountInfo:Object = new Object();
					accountInfo.label = o.name;
					accountInfo.username = o.username;
					accountInfo.accountId = o.id;
					accountInfo.working = o.working;
					accountInfo.active = o.active;
					accountInfo.accountType = o.account_type;
					accountInfo.selected = (o.id == pale.selectedId) ? true : false;
					accountInfo.total = o.total;
					accountData.push(accountInfo);
				}
				ml.accounts = new ArrayCollection(accountData);
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.getAccountLabels(responder);
		}
	}
}