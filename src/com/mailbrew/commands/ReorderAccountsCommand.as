package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.ReorderAccountsEvent;
	import com.mailbrew.model.ModelLocator;
	
	public class ReorderAccountsCommand
		implements ICommand
	{
		private var ml:ModelLocator;
		private var accountData:Array;
		
		public function execute(e:CairngormEvent):void
		{
			this.ml = ModelLocator.getInstance();
			if (ml.reorderAccountsLock) return;
			ml.reorderAccountsLock = true;
			var rae:ReorderAccountsEvent = ReorderAccountsEvent(e);
			this.accountData = rae.accountData;
			if (this.accountData == null || this.accountData.length == 0)
			{
				this.finish();
				return;
			}
			this.updateSortOrderLoop();
		}
		
		private function finish():void
		{
			this.ml.reorderAccountsLock = false;
		}
		
		private function updateSortOrderLoop():void
		{
			if (this.accountData == null || this.accountData.length == 0)
			{
				this.finish();
				return;
			}
			var account:Object = this.accountData.pop();
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				updateSortOrderLoop();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			this.ml.db.updateSortOrder(responder, account.accountId, account.sortOrder);
		}
	}
}